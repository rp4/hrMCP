using ModelContextProtocol.Server;
using System.ComponentModel;
using System.Text.Json;
using System.Text.Json.Serialization;
using HRMCPServer;
using HRMCPServer.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure the HR MCP Server settings
builder.Services.Configure<HRMCPServerConfiguration>(
    builder.Configuration.GetSection(HRMCPServerConfiguration.SectionName));

// Load candidates data and register as singleton
var candidatesData = await LoadCandidatesAsync(builder.Configuration);
builder.Services.AddSingleton(candidatesData);

// Register the candidate service
builder.Services.AddScoped<ICandidateService, CandidateService>();

// Add the MCP services: the transport to use (HTTP) and the tools to register.
builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly();
    
var app = builder.Build();

// Configure the application to use the MCP server
app.MapMcp();

// Add a simple health check endpoint
app.MapGet("/health", () => Results.Ok(new { 
    status = "healthy", 
    service = "HR MCP Server", 
    timestamp = DateTime.UtcNow 
}));

// Add a status page to verify the server is running
app.MapGet("/", () => 
{
    var html = @"
<!DOCTYPE html>
<html>
<head>
    <title>HR MCP Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 800px; margin: 0 auto; }
        h1 { color: #333; border-bottom: 2px solid #4CAF50; padding-bottom: 10px; }
        .status { background: #4CAF50; color: white; padding: 10px 20px; border-radius: 4px; display: inline-block; margin: 20px 0; }
        .tools { background: #f9f9f9; padding: 20px; border-radius: 4px; margin-top: 20px; }
        .tool { margin: 10px 0; padding: 10px; background: white; border-left: 3px solid #2196F3; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
        .endpoint { margin-top: 20px; padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 4px; }
    </style>
</head>
<body>
    <div class='container'>
        <h1>HR MCP Server</h1>
        <div class='status'>Server is running!</div>
        
        <p>This is a Model Context Protocol (MCP) server for managing HR candidate data.</p>
        
        <div class='endpoint'>
            <strong>MCP Endpoint:</strong> <code>POST https://mcplan-app.azurewebsites.net/mcp</code>
        </div>
        
        <div class='tools'>
            <h2>Available MCP Tools:</h2>
            <div class='tool'>
                <strong>ListCandidates</strong> - Returns all candidates in the system
            </div>
            <div class='tool'>
                <strong>AddCandidate</strong> - Adds a new candidate (requires: firstName, lastName, email, currentRole)
            </div>
            <div class='tool'>
                <strong>UpdateCandidate</strong> - Updates an existing candidate by email
            </div>
            <div class='tool'>
                <strong>RemoveCandidate</strong> - Removes a candidate by email
            </div>
            <div class='tool'>
                <strong>SearchCandidates</strong> - Searches candidates by name, email, skills, or role
            </div>
        </div>
        
        <div style='margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 0.9em;'>
            <p>To use this MCP server:</p>
            <ul>
                <li>Configure your MCP client with the endpoint URL</li>
                <li>Use transport type: <code>http</code></li>
                <li>All data modifications are temporary (in-memory only)</li>
            </ul>
        </div>
    </div>
</body>
</html>";
    return Results.Content(html, "text/html");
});

// Run the application
// This will start the MCP server and listen for incoming requests.
app.Run();

// Helper method to load candidates from JSON file
static async Task<List<Candidate>> LoadCandidatesAsync(IConfiguration configuration)
{
    try
    {
        var hrConfig = configuration.GetSection(HRMCPServerConfiguration.SectionName).Get<HRMCPServerConfiguration>();
        
        if (hrConfig == null || string.IsNullOrEmpty(hrConfig.CandidatesPath))
        {
            Console.WriteLine("HR configuration or CandidatesPath not found. Using empty candidate list.");
            return new List<Candidate>();
        }

        if (!File.Exists(hrConfig.CandidatesPath))
        {
            Console.WriteLine($"Candidates file not found at: {hrConfig.CandidatesPath}. Using empty candidate list.");
            return new List<Candidate>();
        }

        var jsonContent = await File.ReadAllTextAsync(hrConfig.CandidatesPath);
        var candidates = JsonSerializer.Deserialize<List<Candidate>>(jsonContent, GetJsonOptions());

        Console.WriteLine($"Loaded {candidates?.Count ?? 0} candidates from file: {hrConfig.CandidatesPath}");
        return candidates ?? new List<Candidate>();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error loading candidates from file: {ex.Message}. Using empty candidate list.");
        return new List<Candidate>();
    }
}

// Helper method for JSON serialization options
static JsonSerializerOptions GetJsonOptions()
{
    return new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };
}