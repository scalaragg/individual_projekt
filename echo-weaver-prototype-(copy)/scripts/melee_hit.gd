extends Area2D

@export var damage: int = 5
@export var knockback: float = 100
@export var time_alive: float = 0.1

var effects: Array[String] = []
var timer = 0.0
var already_hit = []


func _ready():
	timer = time_alive


func hit_stop():
	Engine.time_scale = 0.05
	await get_tree().create_timer(0.03, true, false, true).timeout
	Engine.time_scale = 1.0


func _on_body_entered(body):
	# ---------------- VALIDATION ----------------
	if !is_instance_valid(body):
		return

	if already_hit.has(body):
		return

	if !body.is_in_group("enemy"):
		return

	if !body.has_method("take_damage"):
		return

	already_hit.append(body)

	print("EFFECTS:", effects)

	# ---------------- DAMAGE ----------------
	var final_damage = damage

	for effect in effects:
		if effect == "red":
			final_damage += 2

	body.take_damage(final_damage)

	for effect in effects:
		if effect == "green":
			var player = get_tree().get_first_node_in_group("player")

			if player != null and player.has_method("heal"):
				player.heal(2)
				print("GREEN ORB: heal")

	var hit_camera = get_viewport().get_camera_2d()

	if hit_camera != null and hit_camera.has_method("add_shake"):
		hit_camera.add_shake(4)

	await hit_stop()

	if !is_instance_valid(body):
		return


	# ---------------- HITSTOP ----------------
	await hit_stop()

	if !is_instance_valid(body):
		return

	# ---------------- STUN ----------------
	if body.has_method("stun"):
		body.stun(0.1)

	# ---------------- KNOCKBACK ----------------
	if body.has_method("apply_knockback"):
		var direction = (body.global_position - global_position).normalized()
		body.apply_knockback(direction * knockback)

	# ---------------- ORB EFFECTS ----------------
	for effect in effects:

		# GREEN ORB — HEAL
		if effect == "green":
			var player = get_tree().get_first_node_in_group("player")

			if player != null and player.has_method("heal"):
				player.heal(2)
				print("GREEN ORB: heal")

				player.modulate = Color(0.5, 1.5, 0.5)

				await get_tree().create_timer(0.05).timeout

				if is_instance_valid(player):
					player.modulate = Color.WHITE

		# RED ORB — DAMAGE VISUAL
		elif effect == "red":
			print("RED ORB: bonus damage")

			if body.has_node("AnimatedSprite2D"):
				var enemy_sprite = body.get_node("AnimatedSprite2D")
				enemy_sprite.modulate = Color(1.5, 0.5, 0.5)

				await get_tree().create_timer(0.05).timeout

				if is_instance_valid(enemy_sprite):
					enemy_sprite.modulate = Color.WHITE

		# BLUE ORB — SLOW
		elif effect == "blue":
			if body.has_method("slow"):
				body.slow(0.5, 1.0)
				print("BLUE ORB: slow")

				if body.has_node("AnimatedSprite2D"):
					var enemy_sprite = body.get_node("AnimatedSprite2D")
					enemy_sprite.modulate = Color(0.5, 0.7, 1.5)

					await get_tree().create_timer(0.1).timeout

					if is_instance_valid(enemy_sprite):
						enemy_sprite.modulate = Color.WHITE
			else:
				print("BLUE ORB: у врага нет метода slow")


func _physics_process(delta):
	timer -= delta

	if timer <= 0:
		queue_free()
