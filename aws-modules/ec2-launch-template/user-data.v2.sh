#!/bin/bash

# Author: Akash Girme
# Date : 3-March-2024
# Updated At: 12-March-2024

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
