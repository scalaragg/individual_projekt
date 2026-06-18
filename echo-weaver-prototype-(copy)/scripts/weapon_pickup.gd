extends Area2D

@export var weapon_data: WeaponData

var player = null
var player_inside = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	update_visual()


func update_visual():
	if weapon_data == null:
		return

	if sprite == null:
		return

	if weapon_data.pickup_texture != null:
		sprite.texture = weapon_data.pickup_texture


func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		player.pickup_weapon(weapon_data)
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_inside = true
		sprite.modulate = Color(0.639, 1.194, 0.858, 1.0)


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		player = null
		sprite.modulate = Color.WHITE
