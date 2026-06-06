extends CharacterBody2D

@onready var sprite = $Sprite2D

@export var EnemyDamage = 15
@export var health = 20
@export var orb_scene: PackedScene
@export var speed = 200
@export var damage_text_scene: PackedScene

var invulnerable = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_in_range = false
var player = null

var is_stunned = false

var attack_cooldown = 1.0
var attack_timer = 0.0

var speed_multiplier = 1.0
var knockback_velocity = Vector2.ZERO


# ---------------- FLASH ----------------

func flash():

	if sprite == null:
		return
	sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.08).timeout
		sprite.modulate = Color.DARK_RED


# ---------------- DAMAGE TEXT ----------------

func spawn_damage_text(damage):

	if damage_text_scene == null:
		return
	var text = damage_text_scene.instantiate()
	text.text = str(damage)
	text.global_position = global_position + Vector2(0, -20)
	get_parent().add_child(text)

# ------------- STUN ---------------------------

func stun(duration):

	is_stunned = true

	await get_tree().create_timer(duration).timeout

	if is_instance_valid(self):
		is_stunned = false

# ---------------- DAMAGE ----------------

func take_damage(damage):
	print("Враг атакован")
	health -= damage
	spawn_damage_text(damage)
	flash()
	print("enemy hp:", health)
	
	if invulnerable:
		return
	invulnerable = true

	if health <= 0:
		die()
		return
	
	await get_tree().create_timer(0.15).timeout

	if is_instance_valid(self):
		invulnerable = false

# ---------------- KNOCKBACK ----------------

func apply_knockback(force):
	knockback_velocity = force


# ---------------- SLOW ----------------

func slow(power, duration):
	speed_multiplier = power
	await get_tree().create_timer(duration).timeout

	if is_instance_valid(self):
		speed_multiplier = 1.0


# ---------------- DIE ----------------

func die():
	Engine.time_scale = 1.0

	if orb_scene:
		var orb = orb_scene.instantiate()
		orb.global_position = global_position
		get_parent().add_child(orb)

	queue_free()


# ---------------- READY ----------------

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
# ---------------- PLAYER DETECT ----------------

func _on_area_2d_body_entered(body):

	if body.is_in_group("player"):
		player_in_range = true
		
func _on_area_2d_body_exited(body):

	if body.is_in_group("player"):
		player_in_range = false





# ---------------- PHYSICS ----------------

func _physics_process(delta):

	# stun
	if is_stunned:
		move_and_slide()
		return
		
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# movement
	if player_in_range and player != null:
		var direction = (
			player.global_position - global_position
		).normalized()
		velocity.x = direction.x * speed * speed_multiplier

	else:
		velocity.x = 0

	# attack
	attack_timer -= delta

	if player_in_range and player != null:
		var distance = global_position.distance_to(
			player.global_position
		)

		if distance < 40 and attack_timer <= 0:

			if player.has_method("take_damage"):
				player.take_damage(EnemyDamage)
			attack_timer = attack_cooldown

	# knockback
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(
		Vector2.ZERO,
		12 * delta
	)
	

	move_and_slide()
