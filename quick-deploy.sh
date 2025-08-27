#!/bin/bash

# Quick deployment for MCPlan

echo "Deploying HR MCP Server to Azure..."
echo "==================================="

# Check Azure login status
if ! az account show &> /dev/null; then
    echo "Please login to Azure first:"
    az login
fi

echo "Building application..."
dotnet publish -c Release -o ./publish

echo "Creating deployment package..."
cd publish
zip -r ../deploy.zip .
cd ..

echo "Deploying to MCPlan..."
az webapp deploy \
    --resource-group "MCPs" \
    --name "MCPlan" \
    --src-path deploy.zip \
    --type zip

echo ""
echo "✅ Deployment complete!"
echo "Your app is at: https://mcplan.azurewebsites.net"