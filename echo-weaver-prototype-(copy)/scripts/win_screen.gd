extends Control

@onready var main_menu_ui = get_node_or_null("Control")
@onready var settings_panel = get_node_or_null("SettingsPanel")
@onready var dark_overlay = get_node_or_null("DarkOverlay")

@onready var screen_page = get_node_or_null("SettingsPanel/SettingsBox/ScreenPage")
@onready var sound_page = get_node_or_null("SettingsPanel/SettingsBox/SoundPage")
@onready var controls_page = get_node_or_null("SettingsPanel/SettingsBox/ControlsPage")

@onready var fullscreen_check = get_node_or_null("SettingsPanel/SettingsBox/ScreenPage/FullscreenCheck")
@onready var resolution_label = get_node_or_null("SettingsPanel/SettingsBox/ScreenPage/ResolutionLabel")

@onready var volume_label = get_node_or_null("SettingsPanel/SettingsBox/SoundPage/VolumeLabel")
@onready var volume_slider = get_node_or_null("SettingsPanel/SettingsBox/SoundPage/VolumeSlider")


func _ready():
	Engine.time_scale = 1.0

	if settings_panel != null:
		settings_panel.hide()

	if dark_overlay != null:
		dark_overlay.hide()

	if main_menu_ui != null:
		main_menu_ui.show()

	if fullscreen_check != null:
		fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		
		if fullscreen_check.button_pressed:
			fullscreen_check.text = "Полный экран: ВКЛ"
		else:
			fullscreen_check.text = "Полный экран: ВЫКЛ"

	if resolution_label != null:
		update_resolution_label()

	if volume_slider != null:
		volume_slider.min_value = 0
		volume_slider.max_value = 100
		volume_slider.step = 1
		volume_slider.value = 80
		set_volume(80)

	show_settings_page("screen")


func _on_play_button_pressed():
	GameState.reset_run()
	get_tree().change_scene_to_file("res://tscns/level1_study.tscn")


func _on_settings_button_pressed():
	print("SETTINGS PRESSED")
	print("DARK:", dark_overlay)

	if main_menu_ui != null:
		main_menu_ui.hide()

	if dark_overlay != null:
		dark_overlay.show()
		dark_overlay.color = Color(0, 0, 0, 0.45)

	if settings_panel != null:
		settings_panel.show()

	show_settings_page("screen")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	if settings_panel != null:
		settings_panel.hide()

	if dark_overlay != null:
		dark_overlay.hide()

	if main_menu_ui != null:
		main_menu_ui.show()


func _on_screen_tab_button_pressed():
	show_settings_page("screen")


func _on_sound_tab_button_pressed():
	show_settings_page("sound")


func _on_controls_tab_button_pressed():
	show_settings_page("controls")


func show_settings_page(page_name: String):
	if screen_page != null:
		screen_page.hide()

	if sound_page != null:
		sound_page.hide()

	if controls_page != null:
		controls_page.hide()

	if page_name == "screen":
		if screen_page != null:
			screen_page.show()

	if page_name == "sound":
		if sound_page != null:
			sound_page.show()

	if page_name == "controls":
		if controls_page != null:
			controls_page.show()


func _on_fullscreen_check_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

		if fullscreen_check != null:
			fullscreen_check.text = "Полный экран: ВКЛ"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		if fullscreen_check != null:
			fullscreen_check.text = "Полный экран: ВЫКЛ"

	update_resolution_label()


func update_resolution_label():
	if resolution_label == null:
		return

	var window_size = DisplayServer.window_get_size()
	resolution_label.text = "Разрешение: " + str(window_size.x) + " x " + str(window_size.y)


func _on_volume_slider_value_changed(value):
	set_volume(value)


func set_volume(value):
	var master_bus = AudioServer.get_bus_index("Master")

	if value <= 0:
		AudioServer.set_bus_volume_db(master_bus, -80)
	else:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(value / 100.0))

	if volume_label != null:
		volume_label.text = "Громкость: " + str(int(value)) + "%"
