module Program
open System
open System.IO
open System.Text.Json
open FParsec
open Validate

let private decompileStep (step: Lang.ResponseStep) =
    let get k = if step.parameters.ContainsKey(k) then step.parameters.[k] else "0"
    match step.actionType with
    | "MoveTo"    -> sprintf "    MoveTo %s %s" (get "x") (get "y")
    | "Harvest"   -> sprintf "    Harvest %s" (get "target_id")
    | "Construct" -> sprintf "    Construct %s %s %s" (get "scene") (get "x") (get "y")
    | other       -> sprintf "    # Unknown action: %s" other

let private decompilePlan (plan: Lang.ResponsePlan) =
    plan.unitPlans
    |> List.map (fun up ->
        let uid =
            match up.unitId.ValueKind with
            | JsonValueKind.Number -> string (up.unitId.GetInt32())
            | _                    -> up.unitId.GetString()
        let steps = up.steps |> List.map decompileStep |> String.concat "\n"
        sprintf "unit %s:\n%s\nEND" uid steps)
    |> String.concat "\n\n"

[<EntryPoint>]
let main argv =
    if argv.Length >= 3 && argv.[0] = "--decompile" then
        let inputPath  = argv.[1]
        let outputPath = argv.[2]
        try
            let json = File.ReadAllText(inputPath)
            let opts = JsonSerializerOptions()
            opts.PropertyNamingPolicy <- JsonNamingPolicy.CamelCase
            let plan = JsonSerializer.Deserialize<Lang.ResponsePlan>(json, opts)
            let dsl  = decompilePlan plan
            File.WriteAllText(outputPath, dsl)
            printfn "OK"
            0
        with ex ->
            eprintfn "Decompile error: %s" ex.Message
            2

    elif argv.Length >= 2 then
        let inputPath  = argv.[0]
        let outputPath = argv.[1]
        let input = File.ReadAllText(inputPath).Trim()

        let opts = JsonSerializerOptions()
        opts.PropertyNamingPolicy <- JsonNamingPolicy.SnakeCaseLower
        opts.WriteIndented <- true

        match run parsePlan input with
        | Success(value, _, _) ->
            let json = JsonSerializer.Serialize(value, opts)
            File.WriteAllText(outputPath, json)
            printfn "OK"
            0
        | Failure(msg, _, _) ->
            eprintfn "Parse error: %s" msg
            2

    else
        eprintfn "Usage: dsl <inputFile> <outputFile>"
        eprintfn "       dsl --decompile <inputJson> <outputDsl>"
        1
