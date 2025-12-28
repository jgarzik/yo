use super::{sha256, validate_path, SchemaOptions};
use serde_json::{json, Value};
use std::path::Path;

pub fn schema(opts: &SchemaOptions) -> Value {
    if opts.optimize {
        json!({
            "type": "function",
            "function": {
                "name": "Edit",
                "description": "Edit file: find→replace",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "path": { "type": "string" },
                        "edits": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "find": { "type": "string" },
                                    "replace": { "type": "string" },
                                    "count": { "type": "integer", "description": "0=all, default 1" }
                                },
                                "required": ["find", "replace"]
                            }
                        }
                    },
                    "required": ["path", "edits"]
                }
            }
        })
    } else {
        json!({
            "type": "function",
            "function": {
                "name": "Edit",
                "description": "Edit file with find/replace. Requires permission.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "path": { "type": "string", "description": "File path relative to root" },
                        "edits": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "find": { "type": "string" },
                                    "replace": { "type": "string" },
                                    "count": { "type": "integer", "description": "Times to replace (0=all, default 1)" }
                                },
                                "required": ["find", "replace"]
                            }
                        }
                    },
                    "required": ["path", "edits"]
                }
            }
        })
    }
}

pub fn execute(args: Value, root: &Path) -> anyhow::Result<Value> {
    let path = args["path"].as_str().unwrap_or("");

    let full_path = match validate_path(path, root) {
        Ok(p) => p,
        Err(e) => return Ok(e),
    };

    let original = match std::fs::read_to_string(&full_path) {
        Ok(s) => s,
        Err(e) => {
            return Ok(json!({ "error": { "code": "read_error", "message": e.to_string() } }))
        }
    };

    let before_sha = sha256(original.as_bytes());
    let mut content = original.clone();
    let mut total_applied = 0;

    let edits = args["edits"].as_array();
    if let Some(edits) = edits {
        for edit in edits {
            let find = edit["find"].as_str().unwrap_or("");
            let replace = edit["replace"].as_str().unwrap_or("");
            let count = edit["count"].as_i64().unwrap_or(1);

            if find.is_empty() {
                continue;
            }

            if count == 0 {
                let c = content.matches(find).count();
                content = content.replace(find, replace);
                total_applied += c;
            } else {
                let mut remaining = count as usize;
                let mut result = String::new();
                let mut rest = content.as_str();
                while remaining > 0 {
                    if let Some(pos) = rest.find(find) {
                        result.push_str(&rest[..pos]);
                        result.push_str(replace);
                        rest = &rest[pos + find.len()..];
                        remaining -= 1;
                        total_applied += 1;
                    } else {
                        break;
                    }
                }
                result.push_str(rest);
                content = result;
            }
        }
    }

    if let Err(e) = std::fs::write(&full_path, &content) {
        return Ok(json!({ "error": { "code": "write_error", "message": e.to_string() } }));
    }

    Ok(json!({
        "path": path,
        "applied": total_applied,
        "before_sha256": before_sha,
        "after_sha256": sha256(content.as_bytes())
    }))
}
