extends Control

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("HUD found player: ", player)

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var hp_label = get_node_or_null("HealthLabel")
	var red_label = get_node_or_null("RedLabel")
	var green_label = get_node_or_null("GreenLabel")
	var blue_label = get_node_or_null("BlueLabel")

	if hp_label != null:
		hp_label.text = "HP: " + str(player.health)

	if red_label != null:
		red_label.text = "Pulse: " + str(player.red_orbs)

	if green_label != null:
		green_label.text = "Flow: " + str(player.green_orbs)

	if blue_label != null:
		blue_label.text = "Edge: " + str(player.blue_orbs)
