extends Node2D


var is_game_started = false


func _ready() -> void:
	$UI/ButtonCancel.text = 'quit'
	if OS.has_feature('HTML5'):
		$UI/ButtonCancel.hide()
	else:
		$UI/ButtonCancel.show()
	var w = $Sky.texture.get_width()
	var h = $Sky.texture.get_height()
	var window_size = get_viewport_rect().size
	var sc = max( w / window_size.x, h / window_size.y)
	if w > window_size.x and h > window_size.y:
		sc = -sc
	$Sky.scale = Vector2(sc, sc)
	Globals.level = 0
	Globals.load_settings()
	change_ui()


func change_ui():
	$Map.draw_start_screen(Globals.level)
	$UI/LabelDebug.text = str(get_viewport().size) + " " + str($Map.get_viewport_rect().size)


func _on_Map_show_game_over_popup(won: bool) -> void:
	is_game_started = false
	$UI/ButtonCancel.hide()
	if won:
		$UI/GameOverPopupDialog/TextureRect/Label.text = 'You won!'
	else:
		$UI/GameOverPopupDialog/TextureRect/Label.text = 'Cancel game'
	$UI/GameOverPopupDialog.popup()


func _on_UI_cancel_pressed() -> void:
	if is_game_started:
		$Map.cancel_game()
	else:
		if !OS.has_feature('HTML5'):
			get_tree().quit()


func _on_UI_level_pressed() -> void:
	Globals.level += 1
	if Globals.level > 5:
		Globals.level = 0
	change_ui()


func _on_UI_new_game_pressed():
	get_tree().reload_current_scene()


func _on_UI_resume_pressed() -> void:
	is_game_started = true
	$UI/ButtonCancel.show()
	$UI/GameOverPopupDialog.hide()
	$Map.resume_game()


func _on_UI_run_pressed() -> void:
	$UI/ButtonLevel.hide()
	$UI/ButtonRun.hide()
	$UI/ButtonCancel.show()
	$UI/ButtonCancel.text = 'cancel'
	Globals.save_settings()
	is_game_started = true
	$Map.on_run_game()
