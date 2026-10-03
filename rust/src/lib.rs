use godot::prelude::*;

mod mathcore_wrapper;

struct Opticos;

#[gdextension]
unsafe impl ExtensionLibrary for Opticos {}
