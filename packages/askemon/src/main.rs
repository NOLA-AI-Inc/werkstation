use serde_json::{json, Value};
use jsonschema::{JSONSchema};
use dialoguer::{Input, Confirm};
use std::{fs, io::Result};

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: promptjson <path to schema.json> <output json file>");
        std::process::exit(1);
    }

    let schema_path = &args[1];
    let output_path = &args[2];

    let schema_str = fs::read_to_string(schema_path)?;
    let schema_json: Value = serde_json::from_str(&schema_str)?;

    let mut result_json = json!({});

    if let Value::Object(properties) = &schema_json["properties"] {
        process_properties(properties, &mut result_json)?;
    }

    // Print the resulting JSON object
    match serde_json::to_string_pretty(&result_json) {
        Ok(json_str) => println!("Generated JSON:\n{}", json_str),
        Err(e) => eprintln!("Error converting to JSON string: {}", e),
    }

    fs::write(output_path, serde_json::to_string_pretty(&result_json)?)?;

    println!("JSON file created successfully at {}", output_path);
    Ok(())
}
fn handle_string(prompt: &str, subschema: &Value) -> Value {
    let mut input = Input::new();
    input.with_prompt(prompt);
    if let Some(default) = subschema.get("default").and_then(Value::as_str) {
        input.default(default.to_string());
    }
    let input_str: String = input.interact_text().unwrap();
    json!(input_str)
}

fn handle_integer(prompt: &str, subschema: &Value) -> Value {
    let mut input = Input::new();
    input.with_prompt(prompt);
    if let Some(default) = subschema.get("default").and_then(Value::as_i64) {
        input.default(default.to_string());
    }
    let input_str: String = input.interact_text().unwrap();
    let input_int: i64 = input_str.parse().unwrap();
    json!(input_int)
}

fn handle_boolean(prompt: &str, subschema: &Value) -> Value {
    let mut input = Confirm::new();
    input.with_prompt(prompt);
    if let Some(default) = subschema.get("default").and_then(Value::as_bool) {
        input.default(default);
    }
    let input_bool: bool = input.interact().unwrap();
    json!(input_bool)
}

fn handle_value(prompt: &str, subschema: &Value) -> Value {
    match subschema["type"].as_str().unwrap_or("string") {
        "string" => handle_string(prompt, subschema),
        "integer" => handle_integer(prompt, subschema),
        "boolean" => handle_boolean(prompt, subschema),
        "array" => {
            let mut arr = Vec::new();
            if let Some(item_schema) = subschema.get("items") {
                process_array(prompt, item_schema, &mut arr).unwrap();
            }
            json!(arr)
        }
        "object" => {
            let mut nested_obj = json!({});
            if let Value::Object(nested_properties) = &subschema["properties"] {
                process_properties(nested_properties, &mut nested_obj).unwrap();
            }
            nested_obj
        }
        _ => {
            eprintln!("Unsupported type");
            json!(null)
        }
    }
}

fn process_properties(properties: &serde_json::Map<String, Value>, result_json: &mut Value) -> Result<()> {
    for (key, subschema) in properties {
        let title = subschema["title"].as_str().unwrap_or(key);
        let description = subschema["description"].as_str().unwrap_or("");

        let prompt = if description.is_empty() {
            format!("\n\nEnter value for {}\n\n{}", title, key)
        } else {
            format!("\n\nEnter value for {}\n{}\n\n{}", title, description, key)
        };



        let item_value = handle_value(&prompt, subschema);

        if item_value == Value::Null {
            break;
        }

        // Validate the input against the subschema
        let field_json = json!({ key: item_value });
        let subschema_object = json!({ "type": "object", "properties": { key: subschema } });
        let subschema = JSONSchema::compile(&subschema_object).unwrap();

        if subschema.validate(&field_json).is_ok() {
            if let Some(obj) = result_json.as_object_mut() {
                obj.insert(key.to_string(), item_value);
            } else {
                eprintln!("Unable to set value for {}", key);
            }
        } else {
            eprintln!("Invalid input for {}", key);
        }
    }

    Ok(())
}
fn process_array(prompt: &str, item_schema: &Value, arr: &mut Vec<Value>) -> Result<()> {
    loop {
        let input_prompt = format!("{} (leave empty to finish): ", prompt);
        let item_value = handle_value(&input_prompt, item_schema);
        if item_value == Value::Null {
            break;
        }
        arr.push(item_value);
    }
    Ok(())
}
