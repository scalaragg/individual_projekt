extends CharacterBody2D

@export var is_boss: bool = false

@export var normal_sprite_frames: SpriteFrames
@export var boss_sprite_frames: SpriteFrames

@onready var sprite = $AnimatedSprite2D
var is_hurt = false
var is_dead = false
var is_attacking = false

@export var hurt_lock_time: float = 0.25

@export var EnemyDamage = 15
@export var damage_text_scene: PackedScene
@export var death_y: float = 2000.0

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
@export var attack_hit_delay: float = 0.25

@onready var audio_hit = get_node_or_null("AudioHit")

@export var boss_dash_speed: float = 420.0
@export var boss_dash_cooldown: float = 3.0
@export var boss_dash_time: float = 0.28
@export var boss_dash_damage: int = 20
@export var boss_dash_range: float = 45.0

var boss_dash_timer: float = 2.0
var boss_dash_duration_timer: float = 0.0
var boss_is_dashing: bool = false
var boss_dash_direction: float = 1.0
var boss_dash_can_damage: bool = true



var invulnerable = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player_in_range = false
var player = null

var is_stunned = false

var attack_timer = 0.0

var speed_multiplier = 1.0
var knockback_velocity = Vector2.ZERO

#-------БОСС Дэщ--------

func handle_boss_dash(delta, distance, direction):
	if is_dead:
		return

	if is_hurt:
		return

	if player == null:
		return

	if boss_dash_timer > 0:
		boss_dash_timer -= delta

	if boss_is_dashing:
		boss_dash_duration_timer -= delta

		velocity.x = boss_dash_direction * boss_dash_speed

		if sprite != null:
			if boss_dash_direction < 0:
				sprite.flip_h = false
			elif boss_dash_direction > 0:
				sprite.flip_h = true

		var dash_distance = global_position.distance_to(player.global_position)

		if dash_distance <= boss_dash_range and boss_dash_can_damage:
			if player.has_method("take_damage"):
				player.take_damage(boss_dash_damage)
			boss_dash_can_damage = false

		if boss_dash_duration_timer <= 0:
			boss_is_dashing = false
			boss_dash_timer = boss_dash_cooldown
			boss_dash_can_damage = true

		return

	if distance <= chase_range and boss_dash_timer <= 0:
		boss_dash_direction = direction

		if boss_dash_direction == 0:
			boss_dash_direction = 1

		boss_is_dashing = true
		boss_dash_duration_timer = boss_dash_time
		boss_dash_can_damage = true

		play_attack_anim()

#------- старт атаку -------

func start_attack():
	if is_dead:
		return

	if is_hurt:
		return

	if is_attacking:
		return

	play_attack_anim()

	await get_tree().create_timer(attack_hit_delay).timeout

	if is_dead:
		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range + 10:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

#------Дроп--------
func drop_loot():
	if !drop_orb:
		print("Дроп выключен")
		return

	if orb_scene == null:
		print("orb_scene не задан")
		return

	if randf() > orb_drop_chance:
		print("Орб не выпал по шансу")
		return

	var orb = orb_scene.instantiate()

	var final_orb_type = orb_drop_type

	if final_orb_type == "random":
		var types = ["red", "green", "blue"]
		final_orb_type = types.pick_random()

	if "orb_type" in orb:
		orb.orb_type = final_orb_type

	if orb.has_method("update_visual"):
		orb.update_visual()

	orb.global_position = global_position
	get_parent().add_child(orb)

	print("Выпал орб:", final_orb_type)

# ---------------- FLASH ----------------

func flash():
	if sprite == null:
		return

	var old_color = sprite.modulate

	sprite.modulate = Color(1.0, 0.3, 0.3)

	await get_tree().create_timer(0.08).timeout

	if is_instance_valid(sprite):
		sprite.modulate = old_color


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
	if invulnerable:
		return

	if is_dead:
		return

	invulnerable = true

	if audio_hit != null:
		audio_hit.pitch_scale = randf_range(0.95, 1.05)
		audio_hit.play()

	print("Враг атакован")

	health -= damage
	spawn_damage_text(damage)
	flash()
	print("enemy hp:", health)

	if health <= 0:
		die()
		return

	play_hit_anim()

	await get_tree().create_timer(0.15).timeout

	if is_instance_valid(self):
		invulnerable = false
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
	if is_dead:
		return

	is_dead = true
	Engine.time_scale = 1.0
	velocity = Vector2.ZERO

	drop_loot()

	if sprite != null and sprite.sprite_frames.has_animation("dead"):
		play_anim("dead")
	else:
		queue_free()

# ------------ анимации ----------
func play_anim(anim_name: String):
	if sprite == null:
		return

	if !sprite.sprite_frames.has_animation(anim_name):
		return

	if sprite.animation == anim_name and sprite.is_playing():
		return

	sprite.play(anim_name)


func update_animation():
	if sprite == null:
		return

	if is_dead:
		return

	if is_hurt:
		return

	if is_attacking:
		return

	if abs(velocity.x) > 5:
		play_anim("run")
	else:
		play_anim("idle")
		
		
		
func play_hit_anim():
	if is_dead:
		return

	is_hurt = true
	play_anim("hit")

	await get_tree().create_timer(hurt_lock_time).timeout

	is_hurt = false
	
	
func play_attack_anim():
	if is_dead:
		return

	if is_hurt:
		return

	is_attacking = true
	play_anim("attack")
	
func _on_animation_finished():
	if sprite == null:
		return

	if sprite.animation == "attack":
		is_attacking = false

	if sprite.animation == "hit":
		is_hurt = false

	if sprite.animation == "dead":
		queue_free()

# ---------------- READY ----------------

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if is_boss:
		if boss_sprite_frames != null:
			sprite.sprite_frames = boss_sprite_frames
	else:
		if normal_sprite_frames != null:
			sprite.sprite_frames = normal_sprite_frames
			
	add_to_group("enemy")

	if sprite != null:
		sprite.animation_finished.connect(_on_animation_finished)
		play_anim("idle")
	
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
		
	if global_position.y > death_y:
		die()
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	if !is_on_floor():
		velocity.y += gravity * delta

	var distance = global_position.distance_to(player.global_position)
	var direction = sign(player.global_position.x - global_position.x)
	if is_boss:
		handle_boss_dash(delta, distance, direction)
		if boss_is_dashing:
			move_and_slide()
			update_animation()
			return

	if distance <= chase_range:
		if distance > stop_distance:
			velocity.x = direction * speed * speed_multiplier
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		if distance <= attack_range and attack_timer <= 0:
			start_attack()
			attack_timer = attack_cooldown
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if sprite != null:
		if direction < 0:
			sprite.flip_h = false
		elif direction > 0:
			sprite.flip_h = true

	move_and_slide()
	update_animation()
