extends Area2D

@export var weapon_data: WeaponData
var player = null
var player_inside = false


func _ready():
	player = get_tree().get_first_node_in_group("player")
	update_visual()


func update_visual():
	if weapon_data == null:
		return
	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		# OPTIONAL:
		# different texture per weapon later

func _physics_process(delta):
	if player_inside:
		if Input.is_action_just_pressed("interact"):
			if player != null:
				player.pickup_weapon(weapon_data)
				queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
