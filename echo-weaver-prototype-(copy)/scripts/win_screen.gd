extends Control


func _ready():
	Engine.time_scale = 1.0


func _on_restart_button_pressed():
	GameState.reset_run()
	get_tree().change_scene_to_file("res://tscns/level1_study.tscn")


func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://tscns/menu.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
