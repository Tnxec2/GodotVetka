extends Node2D

signal level_changed()


var is_game_started = false


func _ready() -> void:
	$UI/ButtonCancel.show()
	$UI/ButtonCancel.text = 'quit'
	Globals.level = 0
	change_ui()


func _on_ButtonRun_pressed() -> void:
	$UI/ButtonLevel.hide()
	$UI/ButtonRun.hide()
	$UI/ButtonCancel.show()
	$UI/ButtonCancel.text = 'cancel'
	is_game_started = true
	$Map.on_run_game()


func _on_ButtonLevel_pressed() -> void:
	Globals.level += 1
	if Globals.level > 5:
		Globals.level = 0
	change_ui()


func change_ui():
	$Map.draw_start_screen(Globals.level)


func _on_ButtonNewGame_pressed() -> void:
	get_tree().reload_current_scene()


func _on_ButtonResume_pressed() -> void:
	is_game_started = true
	$UI/ButtonCancel.show()
	$UI/GameOverPopupDialog.hide()
	$Map.resume_game()


func _on_Map_show_game_over_popup() -> void:
	is_game_started = false
	$UI/ButtonCancel.hide()
	$UI/GameOverPopupDialog.popup()


func _on_ButtonCancel_pressed() -> void:
	if is_game_started:
		$Map.cancel_game()
	else:
		get_tree().quit()

