extends Control

func _on_interactive_animator_menu_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
