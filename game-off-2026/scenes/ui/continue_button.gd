extends Button


func _on_pressed() -> void:
	if GameManager.is_landed():
		GameManager.next_level()
