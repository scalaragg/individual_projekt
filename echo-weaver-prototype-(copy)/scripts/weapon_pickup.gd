extends Area2D

@export var weapon_data: WeaponData

var player = null
var player_inside = false

@onready var sprite = $Sprite2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		player.pickup_weapon(weapon_data)
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_inside = true
		sprite.modulate = Color(0.5, 1.5, 0.5)


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		player = null
		sprite.modulate = Color.WHITE
