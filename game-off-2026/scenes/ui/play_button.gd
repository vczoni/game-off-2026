extends Button


func _on_pressed() -> void:
	# melhor trocar para GameManager.play_button_pressed()?
	if GameManager.is_on_titlescreen():
		GameManager.start_game()
	elif GameManager.is_paused():
		GameManager.pause_routine()
	elif GameManager.is_landed():
		GameManager.reset_routine()
	elif GameManager.is_crashed():
		GameManager.reset_routine()
