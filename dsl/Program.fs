open System
open System.IO
open System.Text.Json
open FParsec
open Validate

let rec private decompileStep (indent: string) (step: Lang.ResponseStep) =
    let get k    = if step.parameters.ContainsKey(k) then step.parameters.[k] else "0"
    let getStr k = if step.parameters.ContainsKey(k) then step.parameters.[k] else ""
    match step.actionType with
    | "MoveTo"    -> sprintf "%sMoveTo %s %s" indent (get "x") (get "y")
    | "Harvest"   ->
        let rt   = getStr "resource_type"
        let mode = getStr "mode"
        let tid  = get "target_id"
        if rt <> "" then
            let name = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(rt.ToLower())
            if mode = "return" then sprintf "%sHarvest %s return" indent name
            else sprintf "%sHarvest %s" indent name
        else sprintf "%sHarvest %s" indent tid
    | "Attack"    ->
        let mode = getStr "mode"
        match mode with
        | "move"   -> sprintf "%sAttack move %s %s" indent (get "x") (get "y")
        | "target" -> sprintf "%sAttack %s"         indent (get "target_id")
        | _        -> sprintf "%sAttack nearest"    indent
    | "Construct" -> sprintf "%sConstruct %s %s %s" indent (getStr "scene") (get "x") (get "y")
    | "If"        ->
        let cond      = getStr "condition"
        let inner     = indent + "  "
        let thenBlock = step.body      |> List.map (decompileStep inner) |> String.concat "\n"
        let elseBlock = step.elseBody |> List.map (decompileStep inner) |> String.concat "\n"
        if step.elseBody.IsEmpty then
            sprintf "%sif %s\n%s\n%sEND if" indent cond thenBlock indent
        else
            sprintf "%sif %s\n%s\n%selse\n%s\n%sEND if" indent cond thenBlock indent elseBlock indent
    | other       -> sprintf "%s# Unknown action: %s" indent other

let private decompilePlan (plan: Lang.ResponsePlan) =
    plan.unitPlans
    |> List.map (fun up ->
        let uid =
            match up.unitId.ValueKind with
            | JsonValueKind.Number -> string (up.unitId.GetInt32())
            | _                    -> up.unitId.GetString()
        let steps = up.steps |> List.map (decompileStep "    ") |> String.concat "\n"
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
