#!/bin/bash

# Find all directories containing Terraform files
dirs=$(find . -type d -name '*.tf')

# Loop through each directory
for dir in $dirs; do
    # Navigate to the directory
    cd "$dir"

    # Run TFLint on the Terraform files in the current directory
    tflint --init

    # Navigate back to the root directory
    cd -
done
