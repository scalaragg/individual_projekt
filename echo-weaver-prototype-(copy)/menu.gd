extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://main.tscn")



func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	$VBoxContainer.visible = false
	$SettingsPanel.visible = true


func _on_back_pressed():
	$SettingsPanel.visible = false
	$VBoxContainer.visible = true


func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_h_slider_value_changed(value):
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, db)
