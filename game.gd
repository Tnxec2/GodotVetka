extends Node2D

signal level_changed()


func _ready() -> void:
	Globals.level = 0
	change_ui()


func _on_ButtonRight_pressed() -> void:
	$UI/ButtonLeft.visible = false
	$UI/ButtonRight.visible = false
	$Map.on_run_game()


func _on_ButtonLeft_pressed() -> void:
	Globals.level += 1
	if Globals.level > 5:
		Globals.level = 0
	change_ui()


func change_ui():
	$Map.draw_start_screen(Globals.level)
