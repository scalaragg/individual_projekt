extends CharacterBody2D

@export_enum("red", "green", "blue") var orb_type: String = "red"

@export var red_texture: Texture2D
@export var green_texture: Texture2D
@export var blue_texture: Texture2D

@export var attract_delay: float = 0.45
var can_attract: bool = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var attract_speed = 250
var player = null
var is_attracting = false

@onready var sprite = $Sprite2D


func _ready():
	player = get_tree().get_first_node_in_group("player")
	update_visual()

	await get_tree().create_timer(attract_delay).timeout
	can_attract = true


func update_visual():
	if sprite == null:
		return

	if orb_type == "red":
		sprite.texture = red_texture
	elif orb_type == "green":
		sprite.texture = green_texture
	elif orb_type == "blue":
		sprite.texture = blue_texture


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		if can_attract:
			is_attracting = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		is_attracting = false


func _physics_process(delta):
	if is_attracting and player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * attract_speed
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = 0

	if player != null and can_attract:
		var distance = global_position.distance_to(player.global_position)

		if distance <= 40:
			if player.has_method("add_orb"):
				player.add_orb(orb_type)

			queue_free()

	move_and_slide()
