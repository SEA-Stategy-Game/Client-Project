## Multiplayer

To interact with the multiplayer module, you need to have the [Game Room Manager](https://github.com/SEA-Stategy-Game/game-room-manager/pull/1) running in your machine.
There is information on how to run it in the project's README. 
 

# Build and Run Guide

This project consists of three components that must be started separately:

1. DSL compiler
2. Backend API
3. Game Room Manager
4. Godot client

## Prerequisites

Install the following tools before building:

* .NET 8 SDK
* Go
* Godot 4.x

# 1. Build the DSL Compiler

Open a terminal in the project root.

Navigate to the DSL project:

```bash
cd dsl
```

Clean previous build artifacts:

```bash
rm -rf bin obj out
```

Restore NuGet packages:

```bash
dotnet restore
```

Build the project:

```bash
dotnet build -c Release
```

Publish a standalone executable for macOS Apple Silicon:

```bash
dotnet publish -c Release -r osx-arm64 --self-contained true -o out/publish
```

Return to the project root:

```bash
cd ..
```

The published executable will now exist at:

```text
dsl/out/publish/dsl
```



# 2. Start the Backend API

Open a new terminal.

Navigate to the backend directory:

```bash
cd backend
```

Run the backend API:

```bash
dotnet run --project PlanBackend.Api/PlanBackend.Api.csproj
```

The backend should now be running on:

```text
http://127.0.0.1:5000
```



# 3. Start the Game Room Manager

Open another terminal.

Navigate to the game room manager repository:

```bash
cd game-room-manager
```

Run the server:

```bash
go run ./cmd/game-room-manager
```



# 4. Launch the Godot Client

Open another terminal.

Launch the Godot project manually:

```bash
/path/to/godot/executable --path /path/to/project
```

Example:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path ~/Projects/Client-Project
```



# Recommended Startup Order

Start components in the following order:

1. Backend API
2. Game Room Manager
3. Godot Client



# Notes

* The Godot client automatically uses the published DSL executable if it exists.
* If the published executable is missing, the client falls back to running:

```text
dotnet dsl.dll
```

* After modifying the DSL project, rebuild and republish it before launching the client again.

* If dependency issues occur, fully clean the DSL project again:

```bash
rm -rf bin obj out
```
