extends Control

func _on_interactive_animator_button_pressed() -> void:
	get_tree().change_scene_to_file("res://limit_animator_menu.tscn")


func _on_opticos_textbook_button_pressed() -> void:
	get_tree().change_scene_to_file("res://opticos textbook main menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
