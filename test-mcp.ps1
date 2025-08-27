# PowerShell script to test MCP server

param(
    [string]$Url = "https://mcplan-app.azurewebsites.net"
)

Write-Host "Testing MCP Server at $Url" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Test basic connectivity
Write-Host "`nTesting server connectivity..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing
    Write-Host "✓ Server is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Server not responding: $_" -ForegroundColor Red
    exit 1
}

# Test MCP endpoint
Write-Host "`nTesting MCP endpoint..." -ForegroundColor Cyan
$mcpEndpoint = "$Url/mcp/v1/completion"

$testPayload = @{
    method = "tools/list"
    params = @{}
} | ConvertTo-Json

try {
    $mcpResponse = Invoke-RestMethod -Uri $mcpEndpoint -Method POST -Body $testPayload -ContentType "application/json"
    Write-Host "✓ MCP endpoint is working" -ForegroundColor Green
    Write-Host "Available tools:" -ForegroundColor Yellow
    $mcpResponse.tools | ForEach-Object { Write-Host "  - $($_.name)" }
} catch {
    Write-Host "Testing alternative MCP endpoint format..." -ForegroundColor Yellow
    # Try different endpoint format
    try {
        $altEndpoint = "$Url/mcp"
        $altResponse = Invoke-RestMethod -Uri $altEndpoint -Method POST -Body $testPayload -ContentType "application/json"
        Write-Host "✓ MCP endpoint found at /mcp" -ForegroundColor Green
    } catch {
        Write-Host "✗ MCP endpoint not responding: $_" -ForegroundColor Red
    }
}

Write-Host "`nTest complete!" -ForegroundColor Green