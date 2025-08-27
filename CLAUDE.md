# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an HR MCP (Model Context Protocol) Server built with .NET 10 and ASP.NET Core. It provides HR management tools accessible via MCP, allowing management of candidate information through a set of exposed tools.

## Key Commands

### Build and Run
```bash
# Build the project
dotnet build

# Run the server (default port 47002 in Development)
dotnet run

# Run with specific launch profile
dotnet run --launch-profile http
dotnet run --launch-profile https
dotnet run --launch-profile devtunnel

# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

### Development Tunnel (for exposing local server)
```bash
devtunnel user login
devtunnel create hr-mcp -a --host-header unchanged
devtunnel port create hr-mcp -p 47002
devtunnel host hr-mcp
```

## Architecture

### Core Components

**MCP Integration** (Program.cs:20-24)
- Uses ModelContextProtocol.Server and ModelContextProtocol.AspNetCore packages
- Registers tools automatically from assembly with `WithToolsFromAssembly()`
- Exposes HTTP transport for MCP communication

**Service Layer**
- `ICandidateService` interface defines contract for candidate operations
- `CandidateService` implements in-memory candidate management with thread-safe operations
- Singleton pattern for candidate data persistence during server lifetime

**Tool Layer** (Tools/HRTools.cs)
- `HRTools` class decorated with `[McpServerToolType]` exposes MCP tools
- Available tools:
  - ListCandidates: Returns all candidates
  - AddCandidate: Adds new candidate (checks for duplicate emails)
  - UpdateCandidate: Updates existing candidate by email
  - RemoveCandidate: Removes candidate by email
  - SearchCandidates: Searches across all candidate fields

**Data Models** (Tools/Models.cs)
- `Candidate`: Core entity with properties for FirstName, LastName, Email, CurrentRole, SpokenLanguages, Skills
- `CandidateCollection`: Container for returning multiple candidates
- JSON serialization uses snake_case naming convention

### Data Flow

1. **Startup**: Server loads candidates from JSON file (Data/candidates.json) into memory
2. **Request Processing**: MCP requests → HRTools → ICandidateService → In-memory data store
3. **Data Persistence**: All changes are in-memory only; server restart reloads from JSON file

### Configuration

- Port configuration in appsettings.Development.json (default: 47002)
- Candidate data path configurable via `HRMCPServer:CandidatesPath` setting
- Launch profiles support http, https, and devtunnel modes

## Important Notes

- This is a .NET 10 project targeting the latest framework
- All candidate modifications are temporary (in-memory only)
- Thread-safe operations using concurrent collections in CandidateService
- Email is used as unique identifier for candidates
- Graceful handling of missing/corrupt candidate data files