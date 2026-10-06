use std::collections::HashMap;

use godot::prelude::*;
use mathcore::{MathCore, MathError};

#[derive(GodotClass)]
#[class(base=Object)]
pub struct MathCoreWrapper {
    base: Base<Object>,
}

#[godot_api]
impl IObject for MathCoreWrapper {
    fn init(base: Base<Object>) -> Self {
        Self { base }
    }
}

#[godot_api]
impl MathCoreWrapper {
    #[func]
    fn evaluate_with_vars(&self, expr: GString, vars: Dictionary<GString, f64>) -> f64 {
        let math: MathCore = MathCore::new();
        let rust_vars: HashMap<String, f64> = vars
            .iter_shared()
            .map(|(k, v)| (k.to_string(), v))
            .collect();

        match math.evaluate_with_vars(&expr.to_string(), &rust_vars) {
            Ok(result) => result,
            Err(e @ (MathError::DivisionByZero | MathError::Overflow)) => {
                godot_error!("{e}");
                f64::INFINITY
            }
            Err(e) => {
                godot_error!("{e}");
                f64::NAN
            }
        }
    }
}
