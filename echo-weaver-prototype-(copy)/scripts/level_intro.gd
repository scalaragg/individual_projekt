extends Node

@export var level_title: String = "Уровень 1"


func _ready():
	await get_tree().process_frame

	var hud = get_tree().get_first_node_in_group("hud")

	if hud != null and hud.has_method("show_level_title"):
		hud.show_level_title(level_title)
