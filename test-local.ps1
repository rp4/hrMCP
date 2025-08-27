# PowerShell script to test MCP server locally

Write-Host "Starting HR MCP Server locally..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Start the server in background
Write-Host "`n1. Starting server on http://localhost:47002..." -ForegroundColor Cyan
$serverProcess = Start-Process dotnet -ArgumentList "run", "--urls", "http://localhost:47002" -WorkingDirectory $PWD -PassThru

Start-Sleep -Seconds 5

Write-Host "`n2. Opening MCP Inspector..." -ForegroundColor Cyan
Write-Host "   Use these settings in the Inspector:" -ForegroundColor Yellow
Write-Host "   - Server URL: http://localhost:47002" -ForegroundColor Yellow
Write-Host "   - Transport: HTTP" -ForegroundColor Yellow

# Try to open inspector with npx
try {
    npx @modelcontextprotocol/inspector http://localhost:47002
} catch {
    Write-Host "`nIf npx doesn't work, open in browser:" -ForegroundColor Yellow
    Write-Host "https://modelcontextprotocol.io/inspector" -ForegroundColor Cyan
    Write-Host "And manually enter: http://localhost:47002" -ForegroundColor Cyan
}

Write-Host "`nPress Ctrl+C to stop the server when done testing..." -ForegroundColor Green

# Wait for user to stop
Wait-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue

Write-Host "`nServer stopped." -ForegroundColor Red