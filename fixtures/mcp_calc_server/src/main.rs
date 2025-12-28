//! Minimal MCP calc server for testing - implements add and sub operations.

use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::io::{self, BufRead, Write};

#[derive(Deserialize)]
struct JsonRpcRequest {
    id: Option<u64>,
    method: String,
    params: Option<Value>,
}

#[derive(Serialize)]
struct JsonRpcResponse {
    jsonrpc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    id: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<JsonRpcError>,
}

#[derive(Serialize)]
struct JsonRpcError {
    code: i32,
    message: String,
}

fn main() {
    let stdin = io::stdin();
    let stdout = io::stdout();

    for line in stdin.lock().lines() {
        let line = match line {
            Ok(l) => l,
            Err(_) => break,
        };

        if line.is_empty() {
            continue;
        }

        let request: JsonRpcRequest = match serde_json::from_str(&line) {
            Ok(r) => r,
            Err(e) => {
                eprintln!("MCP Calc Server: Parse error: {}", e);
                continue;
            }
        };

        let response = handle_request(&request);

        if let Some(resp) = response {
            let json = serde_json::to_string(&resp).unwrap();
            let mut out = stdout.lock();
            writeln!(out, "{}", json).ok();
            out.flush().ok();
        }
    }
}

fn handle_request(req: &JsonRpcRequest) -> Option<JsonRpcResponse> {
    match req.method.as_str() {
        "initialize" => Some(JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            id: req.id,
            result: Some(json!({
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "tools": {}
                },
                "serverInfo": {
                    "name": "mcp-calc",
                    "version": "0.1.0"
                }
            })),
            error: None,
        }),

        "notifications/initialized" => None, // No response for notifications

        "tools/list" => Some(JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            id: req.id,
            result: Some(json!({
                "tools": [
                    {
                        "name": "add",
                        "description": "Add two numbers (x + y)",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "x": { "type": "integer", "description": "First number" },
                                "y": { "type": "integer", "description": "Second number" }
                            },
                            "required": ["x", "y"]
                        }
                    },
                    {
                        "name": "sub",
                        "description": "Subtract two numbers (x - y)",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "x": { "type": "integer", "description": "Number to subtract from" },
                                "y": { "type": "integer", "description": "Number to subtract" }
                            },
                            "required": ["x", "y"]
                        }
                    }
                ]
            })),
            error: None,
        }),

        "tools/call" => {
            let params = req.params.as_ref()?;
            let tool_name = params["name"].as_str()?;
            let args = &params["arguments"];

            let result = match tool_name {
                "add" => {
                    let x = args["x"].as_i64().unwrap_or(0);
                    let y = args["y"].as_i64().unwrap_or(0);
                    let sum = x + y;
                    json!({
                        "content": [
                            { "type": "text", "text": sum.to_string() }
                        ]
                    })
                }
                "sub" => {
                    let x = args["x"].as_i64().unwrap_or(0);
                    let y = args["y"].as_i64().unwrap_or(0);
                    let diff = x - y;
                    json!({
                        "content": [
                            { "type": "text", "text": diff.to_string() }
                        ]
                    })
                }
                _ => {
                    return Some(JsonRpcResponse {
                        jsonrpc: "2.0".to_string(),
                        id: req.id,
                        result: None,
                        error: Some(JsonRpcError {
                            code: -32601,
                            message: format!("Unknown tool: {}", tool_name),
                        }),
                    });
                }
            };

            Some(JsonRpcResponse {
                jsonrpc: "2.0".to_string(),
                id: req.id,
                result: Some(result),
                error: None,
            })
        }

        _ => Some(JsonRpcResponse {
            jsonrpc: "2.0".to_string(),
            id: req.id,
            result: None,
            error: Some(JsonRpcError {
                code: -32601,
                message: format!("Method not found: {}", req.method),
            }),
        }),
    }
}
