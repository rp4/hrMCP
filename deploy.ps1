# PowerShell deployment script for HR MCP Server to Azure

Write-Host "Deploying HR MCP Server to Azure..." -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Check if logged into Azure
try {
    az account show | Out-Null
} catch {
    Write-Host "Please login to Azure first:" -ForegroundColor Yellow
    az login
}

Write-Host "`nBuilding application..." -ForegroundColor Cyan
dotnet publish -c Release -o ./publish

Write-Host "Deploying to MCPlan..." -ForegroundColor Cyan
az webapp deploy `
    --resource-group "MCPs" `
    --name "MCPlan" `
    --src-path "./publish" `
    --type "zip"

Write-Host "`n✅ Deployment complete!" -ForegroundColor Green
Write-Host "Your app is at: https://mcplan.azurewebsites.net" -ForegroundColor Yellow