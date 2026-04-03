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