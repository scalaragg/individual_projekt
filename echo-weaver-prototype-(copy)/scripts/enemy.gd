extends CharacterBody2D

@onready var sprite = $Sprite2D

@export var EnemyDamage = 15
@export var damage_text_scene: PackedScene

@export var drop_orb: bool = true
@export_enum("red", "green", "blue", "random") var orb_drop_type: String = "random"
@export var orb_drop_chance: float = 1.0
@export var orb_scene: PackedScene

@export var health: int = 10
@export var speed: float = 80.0
@export var attack_damage: int = 10
@export var attack_range: float = 25.0
@export var attack_cooldown: float = 1.0
@export var chase_range: float = 220.0
@export var stop_distance: float = 18.0

var invulnerable = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_in_range = false
var player = null

var is_stunned = false

var attack_timer = 0.0

var speed_multiplier = 1.0
var knockback_velocity = Vector2.ZERO


#------Дроп--------
func drop_loot():
	if !drop_orb:
		return

	if orb_scene == null:
		return

	if randf() > orb_drop_chance:
		return

	var orb = orb_scene.instantiate()

	var final_type = orb_drop_type
	if final_type == "random":
		var types = ["red", "green", "blue"]
		final_type = types.pick_random()

	if "orb_type" in orb:
		orb.orb_type = final_type

	orb.global_position = global_position
	get_parent().add_child(orb)

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
		
	drop_loot()
	queue_free()
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
	if attack_timer > 0:
		attack_timer -= delta

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	if !is_on_floor():
		velocity.y += gravity * delta

	var distance = global_position.distance_to(player.global_position)
	var direction = sign(player.global_position.x - global_position.x)

	if distance <= chase_range:
		if distance > stop_distance:
			velocity.x = direction * speed * speed_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		if distance <= attack_range and attack_timer <= 0:
			player.take_damage(attack_damage)
			attack_timer = attack_cooldown
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
