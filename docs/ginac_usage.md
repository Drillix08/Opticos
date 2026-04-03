# Using GiNaC in Opticos

This guide is for contributors writing GDScript in Opticos who want to use symbolic math operations powered by GiNaC.

> **Prerequisites:** The GiNaC extension must already be built and the `GiNaC` autoload registered. If you haven't done this yet, see [ginac_integration.md](ginac_integration.md).

---

## Overview

GiNaC is available project-wide as an autoload named `GiNaC`. You can call it from any GDScript file without any imports or setup. All functions operate on single-variable expressions using `x` as the independent variable.

Expressions are passed in and returned as strings using standard mathematical notation. For example:
```gdscript
GiNaC.differentiate("x^3 + 2*x")  # returns "3*x^2+2"
```

---

## Expression Syntax

When passing expressions as strings, use the following syntax:

| Operation | Syntax | Example |
|---|---|---|
| Addition | `+` | `"x^2 + x"` |
| Subtraction | `-` | `"x^2 - x"` |
| Multiplication | `*` | `"2*x"` |
| Division | `/` | `"1/x"` |
| Exponentiation | `^` | `"x^3"` |
| Parentheses | `()` | `"(x+1)^2"` |

> **Note:** Always write multiplication explicitly. For example, `2x` will not parse correctly, use `2*x` instead.

---

## Function Reference

### `GiNaC.expand(expr: String) -> String`

Expands a symbolic expression.
```gdscript
GiNaC.expand("(x+1)^2")       # returns "x^2+2*x+1"
GiNaC.expand("(x+1)*(x-1)")   # returns "x^2-1"
```

---

### `GiNaC.differentiate(expr: String) -> String`

Returns the first derivative of an expression with respect to `x`.
```gdscript
GiNaC.differentiate("x^3 + 2*x")   # returns "3*x^2+2"
GiNaC.differentiate("5")            # returns "0"
```

---

### `GiNaC.differentiate_nth(expr: String, n: int) -> String`

Returns the nth derivative of an expression with respect to `x`.
```gdscript
GiNaC.differentiate_nth("x^3 + 2*x", 2)   # returns "6*x"
GiNaC.differentiate_nth("x^3 + 2*x", 3)   # returns "6"
```

---

### `GiNaC.integrate(expr: String) -> String`

Returns the indefinite integral of an expression with respect to `x`.
```gdscript
GiNaC.integrate("x^2")    # returns "x^3/3"
GiNaC.integrate("2*x")    # returns "x^2"
```

> **Note:** The constant of integration `C` is omitted.

---

### `GiNaC.integrate_definite(expr: String, a: float, b: float) -> float`

Returns the definite integral of an expression from `a` to `b`.
```gdscript
GiNaC.integrate_definite("x^2", 0.0, 3.0)   # returns 9.0
GiNaC.integrate_definite("2*x", 0.0, 2.0)   # returns 4.0
```

---

### `GiNaC.evaluate(expr: String, value: float) -> float`

Evaluates an expression at a given value of `x`. This is the primary function for plotting `y = f(x)` point by point.
```gdscript
GiNaC.evaluate("x^2", 3.0)         # returns 9.0
GiNaC.evaluate("x^3 + 2*x", 2.0)   # returns 12.0
```

---

### `GiNaC.limit(expr: String, value: float) -> String`

Returns the limit of an expression as `x` approaches a given value. Uses direct substitution, so it works correctly for any continuous function.
```gdscript
GiNaC.limit("x^2", 3.0)    # returns "9"
GiNaC.limit("1/x", 2.0)    # returns "1/2"
```

> **Note:** Indeterminate forms such as `sin(x)/x` as `x → 0` are not currently supported and will return a numeric error. This may be addressed in a future update.

---

## Example: Plotting a Derivative

Here is a practical example of how you might use GiNaC to plot both a function and its derivative across a range of x values:
```gdscript
func get_plot_points(expr: String, x_min: float, x_max: float, steps: int) -> Array:
    var derivative = GiNaC.differentiate(expr)
    var points = []

    for i in range(steps + 1):
        var x = x_min + i * (x_max - x_min) / steps
        points.append({
            "x": x,
            "y": GiNaC.evaluate(expr, x),
            "dy": GiNaC.evaluate(derivative, x)
        })

    return points
```

---

## Extending the API

If you need a GiNaC feature that isn't currently exposed, it must be added at the C++ level first. See [ginac_integration.md](ginac_integration.md) for the full extension structure. After adding a new method to `ginac_node.h`, `ginac_node.cpp`, and `autoloads/ginac.gd`, rebuild the extension with:
```bash
cd source/graph-environment/ginac_extension
scons platform=linux
```

Then reload the project in Godot via **Project → Reload Current Project**.