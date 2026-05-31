module Lang

open System.Collections.Generic

// Internal AST used during parsing (commands can be nested under `If`)
type Command =
    | Action of string * Dictionary<string, string>          // actionType, params
    | If of string * Command list * Command list             // condition, then-body, else-body
    | UnitCommand of string * string list                    // unit id digits, dot path

// Output shape — matches the backend's PlanStepIR exactly when serialized.
type Step = {
    stepIndex  : int
    stepType   : string
    actionType : string
    parameters : Dictionary<string, string>
    body       : Step list
    else_body  : Step list
}

type UnitPlan = {
    unitId: string
    steps: Step list
}

type PlanSubmission = {
    schemaVersion: string
    gameId: string
    playerId: string
    unitPlans: UnitPlan list
}

// Types for deserializing a backend plan-version response (camelCase JSON).
type ResponseStep = {
    actionType : string
    parameters : Dictionary<string, string>
    body       : ResponseStep list
    else_body  : ResponseStep list   // JSON key "else_body" — CamelCase leaves underscored names unchanged
}

type ResponseUnitPlan = {
    unitId: System.Text.Json.JsonElement   // backend may return int or string
    steps: ResponseStep list
}

type ResponsePlan = {
    unitPlans: ResponseUnitPlan list
}
