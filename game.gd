extends Node2D

signal level_changed()

const SETTINGS_FILE_NAME = "user://game-data.json"

var is_game_started = false


func _ready() -> void:
	$UI/ButtonCancel.show()
	$UI/ButtonCancel.text = 'quit'
	Globals.level = 0
	load_settings()
	change_ui()


func _on_ButtonRun_pressed() -> void:
	$UI/ButtonLevel.hide()
	$UI/ButtonRun.hide()
	$UI/ButtonCancel.show()
	$UI/ButtonCancel.text = 'cancel'
	save_settings()
	is_game_started = true
	$ViewportContainer/Viewport/Map.on_run_game()


func _on_ButtonLevel_pressed() -> void:
	Globals.level += 1
	if Globals.level > 5:
		Globals.level = 0
	change_ui()


func change_ui():
	$ViewportContainer/Viewport/Map.draw_start_screen(Globals.level)
	$UI/LabelDebug.text = str(get_viewport().size) + " " + str($ViewportContainer/Viewport/Map.get_viewport_rect().size)
	

func _on_ButtonNewGame_pressed() -> void:
	get_tree().reload_current_scene()


func _on_ButtonResume_pressed() -> void:
	is_game_started = true
	$UI/ButtonCancel.show()
	$UI/GameOverPopupDialog.hide()
	$ViewportContainer/Viewport/Map.resume_game()


func _on_Map_show_game_over_popup() -> void:
	is_game_started = false
	$UI/ButtonCancel.hide()
	$UI/GameOverPopupDialog.popup()


func _on_ButtonCancel_pressed() -> void:
	if is_game_started:
		$ViewportContainer/Viewport/Map.cancel_game()
	else:
		get_tree().quit()


func save_settings():
	var file = File.new()
	file.open(SETTINGS_FILE_NAME, File.WRITE)
	file.store_string(to_json({
		"level": Globals.level
	}))
	file.close()


func load_settings():
	var file = File.new()
	if file.file_exists(SETTINGS_FILE_NAME):
		file.open(SETTINGS_FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			prints(data.level, typeof(data.level), TYPE_REAL, (typeof(data.level) == TYPE_REAL))
			if typeof(data.level) == TYPE_REAL and data.level >= 0 and data.level <= 5:
				Globals.level = data.level
				change_ui()
			else:
				printerr("Corrupted data! Bad saved level!")
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
