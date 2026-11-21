class_name SceneManager
extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_postition"):
		get_tree().reload_current_scene()
