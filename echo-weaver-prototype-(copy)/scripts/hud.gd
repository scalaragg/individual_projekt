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
	var orb_label = get_node_or_null("OrbLabel")
	var weapon_label = get_node_or_null("WeaponLabel")
	var slot_label = get_node_or_null("SlotLabel")

	# HP
	if hp_label != null:
		hp_label.text = "HP: " + str(player.health)

	# STORED ORBS

	if orb_label != null:
		orb_label.text = "ORBS: " + str(
			player.stored_orbs
		)

	# WEAPON NAME
	if weapon_label != null:
		if player.weapon != null:
			weapon_label.text = (
				"WEAPON: "
				+ player.weapon.weapon_name
			)
		else:
			weapon_label.text = "WEAPON: NONE"


	# INSERTED ORBS
	if slot_label != null:
		if player.weapon != null:
			var slots = ""
			for orb in player.weapon.inserted_orbs:
				slots += "[" + orb + "]"
			var empty_slots = (
				player.weapon.max_orb_slots
				- player.weapon.inserted_orbs.size()
			)
			for i in range(empty_slots):
				slots += "[_]"
			slot_label.text = slots
