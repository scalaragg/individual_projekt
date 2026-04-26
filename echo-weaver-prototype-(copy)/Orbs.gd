extends CharacterBody2D

@export var orb_type: String = "green"
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attract_speed = 200
var player = null
func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("нашёл игрока:", player)
var is_attracting = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		is_attracting = true
func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		is_attracting = false

func _physics_process(delta: float) -> void:

	if is_attracting and player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * attract_speed
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = 0

	if player != null:
		var distance = global_position.distance_to(player.global_position)

		if distance <= 61:
			if player.has_method("add_thread"):
				player.add_orb(orb_type)
			queue_free()

	move_and_slide()
