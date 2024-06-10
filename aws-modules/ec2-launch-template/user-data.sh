#!/bin/bash

# Author: Akash Girme
# Date : 3-March-2024
# Updated At: 12-March-2024
# Version: 6

# Update apt packages & Install ruby required for codedeploy to run & Install wget.
sudo apt update && sudo apt install ruby-full -y && sudo apt install wget -y && \
sudo apt install jq -y


# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

# Install PM2
npm install pm2 -g

# Install the CodeDeploy agent
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install && \
chmod +x ./install && \
sudo ./install auto
sudo systemctl start codedeploy-agent

# Enable system Firewall
sudo ufw enable -y

# Install Nginx
sudo apt install nginx -y && sudo ufw allow 'Nginx Full'

#Nginx as Reverse Proxy setup
FILENAME="app"
SITES_AVAILABLE_DIR="/etc/nginx/sites-available"
SITES_ENABLED_DIR="/etc/nginx/sites-enabled"

# Remove default Nginx configuration
sudo rm -f $SITES_AVAILABLE_DIR/* $SITES_ENABLED_DIR/* 

sudo tee > "$SITES_AVAILABLE_DIR/$FILENAME" <<"EOF"
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        proxy_pass http://127.0.0.1:3000; # Redirect traffic to localhost:3000
        proxy_buffering off;
        proxy_http_version  1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF


# Link Nginx configuration created in sites_available with sites-enabled
sudo ln -s -f $SITES_AVAILABLE_DIR/$FILENAME $SITES_ENABLED_DIR/ && \

# Test the Nginx configuration
sudo nginx -t

# If the configuration test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
else
    echo "Error: Nginx configuration test failed. Please check the configuration."
fi

# Install AWS-CLI

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && \
sudo ./aws/install && \

# Create .env.local file
mkdir /home/ubuntu/skillstreet
sudo touch /home/ubuntu/skillstreet/.env.local

# Change File Permission to write and remove immutable
sudo chown ubuntu:ubuntu /home/ubuntu/skillstreet/.env.local
sudo chattr -i /home/ubuntu/skillstreet/.env.local


# Fetch the environment from instance tags
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_TAGS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Environment)
ENVIRONMENT=$(echo "$INSTANCE_TAGS")


# Fetch and write multiple secrets to a .env file with custom names
secrets=(
            "ACCESS_TOKEN_JWT_SECRET"
            "REFRESH_TOKEN_JWT_SECRET"
            "VALIDATION_TOKEN_JWT_SECRET"
            "${ENVIRONMENT}_DB_LINK"
            "${ENVIRONMENT}_REDIS_URL"
            "GOOGLE_OAUTH_CLIENT_ID"
            "GOOGLE_OAUTH_CLIENT_SECRET"
            "FACEBOOK_OAUTH_CLIENT_ID"
            "FACEBOOK_OAUTH_CLIENT_SECRET"
            "CLOUDINARY_CLOUD_NAME"
            "CLOUDINARY_API_KEY"
            "CLOUDINARY_API_SECRET"
            "OPENAI_API_KEY"
            "${ENVIRONMENT}_UI_BASE_URL"
            "${ENVIRONMENT}_AUTH_UI_URL"
            "${ENVIRONMENT}_AUTH_API_URL"
            "SNS_ACCESS_KEY_ID"
            "SNS_SECRET_ACCESS_KEY"
            "POSTMARK_API_KEY"
            "POSTMARK_SENDER"


) # List of secrets to fetch
custom_names=( 
                "ACCESS_TOKEN_JWT_SECRET"
                "REFRESH_TOKEN_JWT_SECRET"
                "VALIDATION_TOKEN_JWT_SECRET"
                "DB_LINK"
                "REDIS_URL"
                "GOOGLE_OAUTH_CLIENT_ID"
                "GOOGLE_OAUTH_CLIENT_SECRET"
                "FACEBOOK_OAUTH_CLIENT_ID"
                "FACEBOOK_OAUTH_CLIENT_SECRET"
                "CLOUDINARY_CLOUD_NAME"
                "CLOUDINARY_API_KEY"
                "CLOUDINARY_API_SECRET"
                "OPENAI_API_KEY"
                "UI_BASE_URL"
                "AUTH_UI_URL"
                "AUTH_API_URL"
                "ACCESS_KEY_ID"
                "SECRET_ACCESS_KEY"
                "POSTMARK_API_KEY"
                "POSTMARK_SENDER"
        ) # Custom names for the secrets used in application
secrets_file="/home/ubuntu/skillstreet/.env.local"

# Clear the .env file
> "$secrets_file"

for index in "${!secrets[@]}"; do
    secret_name=${secrets[$index]}
    custom_name=${custom_names[$index]}
    secret_value=$(aws secretsmanager get-secret-value --secret-id "${secret_name}" --region "us-east-1"  | jq -r '.SecretString')
    # secret_value=$(aws secretsmanager get-secret-value --secret-id "${secret_name}" --region "us-east-1" --query SecretString --output text | jq -r '."${secret_name}"'
    if [[ "$secret_value" == *"{"* ]]; then
        secret_value=$(echo "$secret_value" | jq -r 'to_entries[0].value')
    fi
    echo "${custom_name}=${secret_value}" >> "$secrets_file"
done


