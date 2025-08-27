FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["hr-mcp-server.csproj", "./"]
RUN dotnet restore "hr-mcp-server.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "hr-mcp-server.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "hr-mcp-server.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY Data/candidates.json ./Data/
ENTRYPOINT ["dotnet", "hr-mcp-server.dll"]