# GiNaC Integration Guide

This guide explains how to set up the GiNaC C++ library for use in Opticos via GDExtension. This is a one-time setup step for contributors working on the project from scratch.

## What is GiNaC?

[GiNaC](https://www.ginac.de/) is an open source C++ library for symbolic mathematics. In Opticos, it powers all symbolic calculus operations (differentiation, integration, limits, etc.) which are exposed to GDScript via a GDExtension wrapper.

## Prerequisites

- Godot 4.3 or later
- A Linux environment (this guide uses WSL on Windows, but native Linux works the same way)
- GiNaC and CLN installed:
```bash
  sudo apt install libginac-dev libcln-dev
```
- SCons build tool installed:
```bash
  sudo apt install scons
```

> **WSL users:** Running Godot from WSL requires a display server. On Windows 11, WSLg handles this automatically. On Windows 10, you will need a third-party X server such as [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [X410](https://x410.dev/).

---

## Project Structure

After completing this guide, your project should look like this:
```
source/graph-environment/
├── project.godot
├── my_ginac.gdextension
├── ginac_extension/
│   ├── SConstruct
│   ├── bin/                  # compiled .so goes here
│   ├── godot-cpp/            # cloned from GitHub
│   └── src/
│       ├── ginac_node.h
│       ├── ginac_node.cpp
│       ├── register_types.h
│       └── register_types.cpp
└── autoloads/
    └── ginac.gd
```

---

## Step 1: Set Up the Extension Folder

Navigate to `source/graph-environment/` in your terminal and run:
```bash
mkdir -p ginac_extension/src
mkdir -p ginac_extension/bin
cd ginac_extension

git clone https://github.com/godotengine/godot-cpp.git
cd godot-cpp
git checkout master
git submodule update --init
scons platform=linux
cd ..
```

> **Note:** The `master` branch of godot-cpp targets Godot 4.3+. This build step takes a few minutes.

---

## Step 2: Create the Source Files

### `ginac_extension/src/register_types.h`
```cpp
#pragma once
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_ginac_module(ModuleInitializationLevel p_level);
void uninitialize_ginac_module(ModuleInitializationLevel p_level);
```

### `ginac_extension/src/register_types.cpp`
```cpp
#include "register_types.h"
#include "ginac_node.h"
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_ginac_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
    ClassDB::register_class<GiNaCNode>();
}

void uninitialize_ginac_module(ModuleInitializationLevel p_level) {}

extern "C" GDExtensionBool GDE_EXPORT ginac_library_init(
    GDExtensionInterfaceGetProcAddress p_get_proc_address,
    const GDExtensionClassLibraryPtr p_library,
    GDExtensionInitialization *r_initialization) {

    godot::GDExtensionBinding::InitObject init_object(p_get_proc_address, p_library, r_initialization);
    init_object.register_initializer(initialize_ginac_module);
    init_object.register_terminator(uninitialize_ginac_module);
    init_object.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
    return init_object.init();
}
```

### `ginac_extension/src/ginac_node.h`
```cpp
#pragma once
#include <godot_cpp/classes/node.hpp>
#include <ginac/ginac.h>

namespace godot {

class GiNaCNode : public Node {
    GDCLASS(GiNaCNode, Node)

private:
    GiNaC::symbol x;
    GiNaC::symtab table;
    GiNaC::parser *reader;

    GiNaC::ex parse(const String &expr);

protected:
    static void _bind_methods();

public:
    GiNaCNode();
    ~GiNaCNode();

    String expand(String expr);
    String differentiate(String expr);
    String differentiate_nth(String expr, int n);
    String integrate(String expr);
    double integrate_definite(String expr, double a, double b);
    double evaluate(String expr, double value);
    String limit(String expr, double value);
};

}
```

### `ginac_extension/src/ginac_node.cpp`
```cpp
#include "ginac_node.h"
#include <godot_cpp/core/class_db.hpp>
#include <sstream>

using namespace godot;
using namespace GiNaC;

GiNaCNode::GiNaCNode() : x("x") {
    table["x"] = x;
    reader = new parser(table);
}

GiNaCNode::~GiNaCNode() {
    delete reader;
}

ex GiNaCNode::parse(const String &expr) {
    return (*reader)(std::string(expr.utf8().get_data()));
}

void GiNaCNode::_bind_methods() {
    ClassDB::bind_method(D_METHOD("expand", "expr"), &GiNaCNode::expand);
    ClassDB::bind_method(D_METHOD("differentiate", "expr"), &GiNaCNode::differentiate);
    ClassDB::bind_method(D_METHOD("differentiate_nth", "expr", "n"), &GiNaCNode::differentiate_nth);
    ClassDB::bind_method(D_METHOD("integrate", "expr"), &GiNaCNode::integrate);
    ClassDB::bind_method(D_METHOD("integrate_definite", "expr", "a", "b"), &GiNaCNode::integrate_definite);
    ClassDB::bind_method(D_METHOD("evaluate", "expr", "value"), &GiNaCNode::evaluate);
    ClassDB::bind_method(D_METHOD("limit", "expr", "value"), &GiNaCNode::limit);
}

String GiNaCNode::expand(String expr) {
    std::ostringstream oss;
    oss << parse(expr).expand();
    return String(oss.str().c_str());
}

String GiNaCNode::differentiate(String expr) {
    std::ostringstream oss;
    oss << parse(expr).diff(x);
    return String(oss.str().c_str());
}

String GiNaCNode::differentiate_nth(String expr, int n) {
    std::ostringstream oss;
    oss << parse(expr).diff(x, n);
    return String(oss.str().c_str());
}

String GiNaCNode::integrate(String expr) {
    std::ostringstream oss;
    ex e = parse(expr);
    oss << integral(x, 0, x, e).eval_integ();
    return String(oss.str().c_str());
}

double GiNaCNode::integrate_definite(String expr, double a, double b) {
    ex e = parse(expr);
    ex result = integral(x, a, b, e).eval_integ();
    return ex_to<numeric>(result.evalf()).to_double();
}

double GiNaCNode::evaluate(String expr, double value) {
    ex e = parse(expr).subs(x == value);
    return ex_to<numeric>(e.evalf()).to_double();
}

String GiNaCNode::limit(String expr, double value) {
    ex e = parse(expr).subs(x == value);
    std::ostringstream oss;
    oss << e.evalf();
    return String(oss.str().c_str());
}
```

---

## Step 3: Create the SConstruct File

Create `ginac_extension/SConstruct` (not inside `src/`):
```python
#!/usr/bin/env python
import os

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])

env.ParseConfig("pkg-config --cflags --libs ginac")

sources = Glob("src/*.cpp")

library = env.SharedLibrary(
    "bin/libginac_extension{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
    source=sources,
)
Default(library)
```

---

## Step 4: Build the Extension

From inside `ginac_extension/`, run:
```bash
scons platform=linux
```

This produces a `.so` file in `ginac_extension/bin/`. Verify the filename matches what is in `my_ginac.gdextension`:
```bash
ls ginac_extension/bin/
```

---

## Step 5: Create the `.gdextension` Manifest

Create `my_ginac.gdextension` in `source/graph-environment/`:
```ini
[configuration]
entry_symbol = "ginac_library_init"
compatibility_minimum = "4.1"

[libraries]
linux.debug.x86_64 = "res://ginac_extension/bin/libginac_extension.linux.template_debug.x86_64.so"
linux.release.x86_64 = "res://ginac_extension/bin/libginac_extension.linux.template_release.x86_64.so"
```

---

## Step 6: Create the GDScript Autoload

Create `autoloads/ginac.gd`:
```gdscript
extends Node

var _node: GiNaCNode

func _ready() -> void:
    _node = GiNaCNode.new()
    add_child(_node)

func expand(expr: String) -> String:
    return _node.expand(expr)

func differentiate(expr: String) -> String:
    return _node.differentiate(expr)

func differentiate_nth(expr: String, n: int) -> String:
    return _node.differentiate_nth(expr, n)

func integrate(expr: String) -> String:
    return _node.integrate(expr)

func integrate_definite(expr: String, a: float, b: float) -> float:
    return _node.integrate_definite(expr, a, b)

func evaluate(expr: String, value: float) -> float:
    return _node.evaluate(expr, value)

func limit(expr: String, value: float) -> String:
    return _node.limit(expr, value)
```

---

## Step 7: Register the Autoload in Godot

1. Open the project in Godot
2. Go to **Project → Project Settings → Globals → Autoload**
3. Click the folder icon and select `autoloads/ginac.gd`
4. Set the name to `GiNaC`
5. Click **Add**

---

## Step 8: Verify the Extension Loaded

1. In the **Scene** panel, click **"+"** to add a node
2. Search for `GiNaCNode`. If it appears, the extension loaded successfully

---

## Rebuilding After Changes

Any time you modify `ginac_node.h` or `ginac_node.cpp`, you must rebuild before the changes take effect in Godot:
```bash
cd source/graph-environment/ginac_extension
scons platform=linux
```

Then reload the project in Godot via **Project → Reload Current Project**.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `GiNaCNode` doesn't appear in node list | Check that the `.so` filename in `my_ginac.gdextension` exactly matches the file in `bin/` |
| `scons: *** No SConstruct file found` | Make sure `SConstruct` is in `ginac_extension/` root, not inside `src/` |
| `Missing SConscript 'godot-cpp/SConstruct'` | The `godot-cpp` folder is missing; re-run the clone and build steps in Step 1 |
| Linker errors during build | Run `sudo ldconfig` and retry |
| `CLN not found` during build | Run `sudo apt install libcln-dev` |