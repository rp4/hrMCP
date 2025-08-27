# PowerShell script to test Azure MCP Server

$serverUrl = "https://mcplan-app.azurewebsites.net"

Write-Host "Testing MCP Server at $serverUrl" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Test 1: Initialize connection
Write-Host "`nTest 1: Initializing MCP connection..." -ForegroundColor Cyan
$initRequest = @{
    jsonrpc = "2.0"
    method = "initialize"
    params = @{
        protocolVersion = "0.1.0"
        capabilities = @{}
        clientInfo = @{
            name = "PowerShell Test Client"
            version = "1.0.0"
        }
    }
    id = 1
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/mcp" -Method POST -Body $initRequest -ContentType "application/json"
    Write-Host "✓ Initialization successful" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "✗ Initialization failed: $_" -ForegroundColor Red
}

# Test 2: List available tools
Write-Host "`nTest 2: Listing available tools..." -ForegroundColor Cyan
$listToolsRequest = @{
    jsonrpc = "2.0"
    method = "tools/list"
    params = @{}
    id = 2
} | ConvertTo-Json

try {
    $toolsResponse = Invoke-RestMethod -Uri "$serverUrl/mcp" -Method POST -Body $listToolsRequest -ContentType "application/json"
    Write-Host "✓ Tools retrieved successfully:" -ForegroundColor Green
    $toolsResponse.result.tools | ForEach-Object {
        Write-Host "  - $($_.name): $($_.description)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Failed to list tools: $_" -ForegroundColor Red
}

# Test 3: Call ListCandidates tool
Write-Host "`nTest 3: Calling ListCandidates tool..." -ForegroundColor Cyan
$callToolRequest = @{
    jsonrpc = "2.0"
    method = "tools/call"
    params = @{
        name = "ListCandidates"
        arguments = @{}
    }
    id = 3
} | ConvertTo-Json -Depth 10

try {
    $candidatesResponse = Invoke-RestMethod -Uri "$serverUrl/mcp" -Method POST -Body $callToolRequest -ContentType "application/json"
    Write-Host "✓ ListCandidates called successfully" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $candidatesResponse | ConvertTo-Json -Depth 10
} catch {
    Write-Host "✗ Failed to call ListCandidates: $_" -ForegroundColor Red
}