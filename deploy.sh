#!/bin/bash

# Azure deployment script for HR MCP Server

echo "Azure App Service Deployment Script"
echo "===================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed."
    echo "Install it from: https://aka.ms/InstallAzureCLIDeb"
    exit 1
fi

# Prompt for Azure details
read -p "Enter your Resource Group name: " RESOURCE_GROUP
read -p "Enter your App Service name: " APP_NAME

echo ""
echo "Starting deployment..."

# Build and publish the application
echo "1. Building application..."
dotnet publish -c Release -o ./publish

# Create a zip file for deployment
echo "2. Creating deployment package..."
cd publish
zip -r ../deploy.zip .
cd ..

# Deploy to Azure
echo "3. Deploying to Azure App Service..."
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --src-path deploy.zip \
    --type zip

echo ""
echo "Deployment complete!"
echo "Your app should be available at: https://${APP_NAME}.azurewebsites.net"
echo ""
echo "To view logs, run:"
echo "az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"