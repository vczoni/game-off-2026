class_name SplashScreen
extends Control


@export var fade_time: float = 0.2
@export var screen_time: float = 0.8
@export var screen_list: Array[MarginContainer]


func _ready() -> void:
	if len(self.screen_list) > 0:
		self.run()


func run() -> void:
	self.hide_screens()

	var tween := create_tween()

	for screen in screen_list:
		tween.tween_interval(fade_time)
		tween.tween_property(screen, "modulate:a", 1.0, fade_time/2)
		tween.tween_interval(screen_time)
		tween.tween_property(screen, "modulate:a", 0.0, fade_time/2)

	await tween.finished
	await get_tree().process_frame


func hide_screens() -> void:
	for screen in screen_list:
		screen.modulate.a = 0.0
