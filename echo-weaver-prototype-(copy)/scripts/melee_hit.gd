extends Area2D

@export var damage: int = 5
@export var knockback: float = 100
@export var time_alive: float = 0.1
var effects: Array[String] = []
var timer = 0.0
func _ready():

	timer = time_alive

func _on_body_entered(body):

	if !is_instance_valid(body):
		return

	if !body.is_in_group("enemy"):
		return

	if !body.has_method("take_damage"):
		return


	# ---------------- DAMAGE ----------------

	var final_damage = damage
	
	for effect in effects:
		if effect == "red":
			final_damage += 2
	body.take_damage(final_damage)
	
	if body.has_method("stun"):
		body.stun(0.1)

	if !is_instance_valid(body):
		return


	# ---------------- HITSTOP ----------------

	Engine.time_scale = 0.05

	await get_tree().create_timer(
		0.03,
		true,
		false,
		true
	).timeout
	Engine.time_scale = 1.0
	if !is_instance_valid(body):
		return


	# ---------------- KNOCKBACK ----------------

	if body.has_method("apply_knockback"):

		var direction = (
			body.global_position - global_position
		).normalized()

		body.apply_knockback(direction * knockback)


	# ---------------- EFFECTS ----------------

	for effect in effects:

		# GREEN
		if effect == "green":
			var player = get_tree().get_first_node_in_group("player")
			if player != null:
				if player.has_method("heal"):
					player.heal(2)
				player.modulate = Color(0.5, 1.5, 0.5)
				await get_tree().create_timer(0.05).timeout
				if is_instance_valid(player):
					player.modulate = Color.WHITE


		# RED
		elif effect == "red":
			if body.has_node("AnimatedSprite2D"):
				var sprite = body.get_node("AnimatedSprite2D")
				sprite.modulate = Color(1.5, 0.5, 0.5)
				await get_tree().create_timer(0.05).timeout
				if is_instance_valid(sprite):
					sprite.modulate = Color.WHITE


		# BLUE
		elif effect == "blue":
			if body.has_method("slow"):
				body.slow(0.5, 1.0)


	# ---------------- CAMERA SHAKE ----------------

	var camera = get_viewport().get_camera_2d()
	if camera != null:
		if camera.has_method("add_shake"):
			camera.add_shake(4)


func _physics_process(delta):
	timer -= delta
	if timer <= 0:
		queue_free()
