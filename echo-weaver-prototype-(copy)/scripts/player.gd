extends CharacterBody2D


const SWORD = preload("res://resources/weapons/sword.tres")
const HAMMER = preload("res://resources/weapons/hammer.tres")
const SPEAR = preload("res://resources/weapons/spear.tres")

@onready var sprite = $AnimatedSprite2D

var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var can_control: bool = true

var inventory: Array[WeaponData] = []

var current_weapon_index = 0
var weapon = null

@export var speed: float = 200.0
@export var acceleration: float = 5000.0
@export var friction: float = 3000.0
@export var health = 100

var is_run = false
var run_speed: float = 350.0
var current_speed = speed

@export var melee_scene: PackedScene
var melee_cooldown = 0.0
var melee_delay = 1
@export var attack_hit_delay: float = 0.12

@export var fall_death_y: float = 900.0
@export var fall_damage: int = 15

var spawn_position: Vector2
var is_respawning: bool = false

@export var max_step_height: int = 10
@export var step_check_distance: float = 6.0

var is_invincible: bool = false
@export var invincible_time: float = 0.4
@export var hurt_lock_time: float = 0.25

@onready var audio_jump = get_node_or_null("AudioJump")
@onready var audio_attack = get_node_or_null("AudioAttack")
@onready var audio_hurt = get_node_or_null("AudioHurt")
@onready var audio_pickup = get_node_or_null("AudioPickup")
@onready var audio_step = get_node_or_null("AudioStep")
@onready var audio_death = get_node_or_null("AudioDeath")
@onready var audio_get_damage = get_node_or_null("AudioGetDamage")

@export var step_interval: float = 0.28
var step_timer: float = 0.0

#----спавн атак хитбокс ------

func spawn_attack_hitbox(attack_direction: float):
	await get_tree().create_timer(attack_hit_delay).timeout

	if is_dead:
		return

	if weapon == null:
		return

	var hit = melee_scene.instantiate()

	var damage = weapon.damage
	var attack_range = weapon.attack_range
	var knockback = weapon.knockback

	var hit_position = attack_range * attack_direction

	var collision = hit.get_node("CollisionShape2D")
	var shape = collision.shape
	var hit_sprite = hit.get_node("Sprite2D")

	if weapon.weapon_type == WeaponData.WeaponType.HAMMER:
		shape.size = Vector2(80, 80)
		hit_position *= 0.8
		hit_sprite.scale = Vector2(2, 2)
		hit_sprite.modulate = Color.RED

	elif weapon.weapon_type == WeaponData.WeaponType.SPEAR:
		shape.size = Vector2(140, 25)
		hit_position *= 1.0
		hit_sprite.scale = Vector2(1, 1)
		hit_sprite.modulate = Color.BLUE

	else:
		shape.size = Vector2(50, 40)
		hit_sprite.scale = Vector2(1, 1)
		hit_sprite.modulate = Color.WHITE

	hit.global_position = global_position + Vector2(hit_position, 0)
	hit.damage = damage
	hit.knockback = knockback
	hit.effects = weapon.inserted_orbs.duplicate()

	get_parent().add_child(hit)

	print("АТАКА:")
	print("оружие:", weapon.weapon_name)
	print("урон:", damage)
	print("орбы:", weapon.inserted_orbs)

#---------звук---------
func handle_footsteps(delta):
	if audio_step == null:
		return

	if !is_on_floor():
		step_timer = 0.0
		return

	if abs(velocity.x) < 20:
		step_timer = 0.0
		return

	step_timer -= delta

	if step_timer <= 0:
		audio_step.pitch_scale = randf_range(0.9, 1.1)
		audio_step.play()
		step_timer = step_interval

#----- анимациии ------
func update_animation():
	if sprite == null:
		return

	if is_dead:
		return

	if is_attacking:
		return

	if is_hurt:
		return

	var direction = Input.get_axis("move_left", "move_right")

	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

	if !is_on_floor():
		if velocity.y < 0:
			play_anim("jump")
		else:
			play_anim("fall")
		return


	if abs(velocity.x) > 10:
		play_anim("run")
	else:
		play_anim("idle")

#-----конец анимаций_------
func _on_animation_finished():
	if sprite == null:
		return

	if sprite.animation == "attack":
		is_attacking = false

	if sprite.animation == "hurt":
		is_hurt = false

#-----безопасная анимка------
func play_anim(anim_name: String):
	if sprite == null:
		return

	if !sprite.sprite_frames.has_animation(anim_name):
		return

	if sprite.animation == anim_name and sprite.is_playing():
		return

	sprite.play(anim_name)
	
#-------плей харт анимация-------

func play_hurt_anim():
	if is_attacking:
		return

	is_hurt = true

	if sprite != null and sprite.sprite_frames.has_animation("hurt"):
		sprite.play("hurt")

	await get_tree().create_timer(hurt_lock_time).timeout

	is_hurt = false

# -----дамаг флэш---------
func damage_flash():
	modulate = Color(1.5, 0.4, 0.4)

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
#--------------- Поднимание предметов ----------

func pickup_weapon(new_weapon):

	if new_weapon == null:
		return
# DROPPING OLD WEAPON

	if weapon != null:
		var dropped_scene = preload(
			"res://tscns/weapon_pickup.tscn"
		)
		var dropped = dropped_scene.instantiate()
		dropped.weapon_data = weapon
		dropped.global_position = global_position + Vector2(
			30 * facing_direction,
			0
		)
		get_parent().add_child(dropped)
	# EQUIP NEW
	weapon = new_weapon
	if audio_pickup != null:
		audio_pickup.play()
	print("picked weapon:", weapon.weapon_name)
	
	
#-------step up -----------
func try_step_up(direction: float):
	if !is_on_floor():
		return

	if direction == 0:
		return

	var dir = sign(direction)
	var forward_motion = Vector2(dir * step_check_distance, 0)

	# Если впереди нет препятствия — подниматься не надо
	if !test_move(global_transform, forward_motion):
		return

	# Проверяем высоту от 1 до max_step_height
	for h in range(1, max_step_height + 1):
		var raised_transform = global_transform.translated(Vector2(0, -h))

		# Если на этой высоте впереди уже свободно — поднимаем игрока
		if !test_move(raised_transform, forward_motion):
			global_position.y -= h
			global_position.x += dir * 2
			return


# ---------------- ORBS ----------------

var stored_orbs: Array[String] = []

var max_stored_orbs = 5

func add_orb(orb_type):

	if stored_orbs.size() >= max_stored_orbs:
		print("orb inventory full")
		return

	stored_orbs.append(orb_type)

	print("picked orb:", orb_type)
	print("stored:", stored_orbs)
	if audio_pickup != null:
		audio_pickup.play()

func insert_next_orb():

	if weapon == null:
		return

	if stored_orbs.size() <= 0:
		print("нет орбов")
		return

	if weapon.inserted_orbs.size() >= weapon.max_orb_slots:

		# удаляем первый orb
		weapon.inserted_orbs.pop_front()

	var orb = stored_orbs.pop_front()

	weapon.inserted_orbs.append(orb)

	print("weapon:", weapon.weapon_name)
	print("inserted:", weapon.inserted_orbs)

#---------- equip weapon func --------------
	   

func equip_weapon(index):

	if index < 0 or index >= inventory.size():
		return

	current_weapon_index = index
	weapon = inventory[index]

	print("Экипировано:", weapon.weapon_name)



# ------------------- УРОН -------------------



func take_damage(amount):
	if is_invincible:
		return

	health -= amount
	print("урон:", amount)
	print("hp:", health)
	
	if audio_get_damage != null:
		audio_get_damage.play()
	play_hurt_anim()
	damage_flash()

	var hud = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_damage_overlay"):
		hud.show_damage_overlay()

	var camera = get_viewport().get_camera_2d()
	if camera != null and camera.has_method("add_shake"):
		camera.add_shake(6)

	if health <= 0:
		die()
		return
	
	is_invincible = true
	await get_tree().create_timer(invincible_time).timeout
	is_invincible = false

func die():
	if is_dead:
		return
		
	is_dead = true
	can_control = false
	velocity = Vector2.ZERO
	Engine.time_scale = 1.0
	
	


	if sprite != null and sprite.sprite_frames.has_animation("die") and audio_death != null:
		sprite.play("die")
		audio_death.play()
		await sprite.animation_finished

	GameState.load_checkpoint()
	get_tree().reload_current_scene()



# ------------------- АТАКА -------------------
func attack():
	if weapon == null:
		return

	if is_attacking:
		return

	if melee_scene == null:
		print("melee_scene не задан")
		return

	is_attacking = true
	play_anim("attack")

	var attack_direction = facing_direction
	spawn_attack_hitbox(attack_direction)
	if audio_attack != null:
		audio_attack.play()

	await get_tree().create_timer(attack_hit_delay).timeout

	if is_dead:
		return

	if weapon == null:
		return

	var hit = melee_scene.instantiate()

	var damage = weapon.damage
	var attack_range = weapon.attack_range
	var knockback = weapon.knockback

	var offset = attack_range

	if facing_direction == -1:
		offset = -attack_range
		
	var hit_position = offset
	var collision = hit.get_node("CollisionShape2D")
	var shape = collision.shape
	var sprite = hit.get_node("Sprite2D")

	if weapon.weapon_type == WeaponData.WeaponType.HAMMER:
		shape.size = Vector2(80, 80)
		hit_position *= 0.8
		sprite.scale = Vector2(2, 2)
		sprite.modulate = Color.RED

	elif weapon.weapon_type == WeaponData.WeaponType.SPEAR:
		shape.size = Vector2(140, 25)
		hit_position *= 1.0
		sprite.scale = Vector2(100, 100)
		sprite.modulate = Color.BLUE

	else:
		shape.size = Vector2(50, 40)
		sprite.scale = Vector2(1, 1)
		sprite.modulate = Color.WHITE

	hit.global_position = global_position + Vector2(hit_position, 0)
	hit.damage = damage
	hit.knockback = knockback
	if weapon != null:
		hit.effects = weapon.inserted_orbs.duplicate()

	get_parent().add_child(hit)

	print("АТАКА:")
	print("оружие:", weapon.weapon_name)
	print("урон:", damage)
	print("орбы:", weapon.inserted_orbs)

# --------- Респавн ----------

func respawn_after_fall():
	is_respawning = true

	health -= fall_damage

	if health <= 0:
		die()
		return

	global_position = spawn_position
	velocity = Vector2.ZERO

	print("Упал. HP:", health)

	await get_tree().create_timer(0.2).timeout
	is_respawning = false


# ------------------- ПРЫЖОК -------------------
@export var jump_velocity: float = -400.0

var max_air_jumps: int = 1
var air_jumps_left: int = 1

var coyote_time: float = 0.12
var coyote_timer: float = 0.0

var jump_buffer_time: float = 0.12
var jump_buffer_timer: float = 0.0

var second_jump_multiplier: float = 0.75

func do_jump(power_multiplier: float = 1.0):
	velocity.y = jump_velocity * power_multiplier
	if audio_jump != null:
		audio_jump.play()
	jump_buffer_timer = 0.0
# ------------------- НАПРАВЛЕНИЕ -------------------
var facing_direction: float = 1.0
var dash_direction: float = 1.0

# ------------------- Блятский ДЭШ -------------------
var dash_speed: float = 800.0
var dash_time: float = 0.1
var is_dash = false
var dash_cooldown = 3
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _use_dash(delta, direction):
	var dash = Input.is_action_just_pressed("dash")
	if dash and dash_cooldown_timer <= 0 and not is_dash:
		if direction != 0:
			dash_direction = direction
		else:
			dash_direction = facing_direction

		is_dash = true
		dash_timer = dash_time
		dash_cooldown_timer = dash_cooldown

	if is_dash:
		current_speed = dash_speed
		dash_timer -= delta

	if dash_timer <= 0:
		is_dash = false

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
		
# -------- Орбы -----------
		
func insert_orb(orb_type: String):

	if weapon == null:
		return

	if weapon.inserted_orbs.size() >= weapon.orb_slots:
		print("Нет свободных слотов")
		return

	weapon.inserted_orbs.append(orb_type)

	print("Вставлен orb:", orb_type)
	print(weapon.inserted_orbs)


# -------реади-----------------------
func _ready():
	Engine.time_scale = 1.0
	
	var spawn = get_tree().get_first_node_in_group("spawn_point")

	if spawn != null:
		spawn_position = spawn.global_position
	else:
		spawn_position = global_position

	global_position = spawn_position
	
	if sprite != null:
		sprite.animation_finished.connect(_on_animation_finished)

	if GameState.current_weapon != null or GameState.stored_orbs.size() > 0:
		GameState.load_player(self)
	else:
		inventory.clear()
		weapon = null
		current_weapon_index = -1
		
	if GameState.checkpoint_inventory.is_empty() and GameState.checkpoint_weapon == null and GameState.checkpoint_orbs.is_empty():
		GameState.save_player(self)
		GameState.save_checkpoint()

	print("Игрок загружен")
	print("HP:", health)
	print("Оружие:", weapon)
	print("Орбы:", stored_orbs)
	
# ----------------- heal ----------------------
func heal(amount):
	health += amount

	if health > 100:
		health = 100

	print("heal:", amount)
	print("hp:", health)

	var hud = get_tree().get_first_node_in_group("hud")

	if hud != null and hud.has_method("show_heal_overlay"):
		hud.show_heal_overlay()
	
	

# ------------------- ПУССSICS -------------------
func _physics_process(delta):
	if Input.is_action_just_pressed("weapon_1"):
		equip_weapon(0)

	if Input.is_action_just_pressed("weapon_2"):
		equip_weapon(1)

	if Input.is_action_just_pressed("weapon_3"):
		equip_weapon(2)
		
	# INSERT ORB

	if Input.is_action_just_pressed("Q"):
		insert_next_orb()

	if Input.is_action_just_pressed("esc"):
		get_tree().change_scene_to_file("res://tscns/menu.tscn")

	# ГРАВИТАЦИЯ
	if not is_on_floor():
		velocity.y += gravity * delta

	# ------------------- JUMP -------------------

	# jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# floor / coyote / reset air jumps
	if is_on_floor():
		coyote_timer = coyote_time
		air_jumps_left = max_air_jumps
	else:
		coyote_timer -= delta

	# jump logic
	if jump_buffer_timer > 0.0:

		# обычный прыжок с пола или coyote jump
		if coyote_timer > 0.0:
			do_jump()
			coyote_timer = 0.0

		# double jump
		elif air_jumps_left > 0:
			do_jump(second_jump_multiplier)
			air_jumps_left -= 1
		
	# ДВИЖЕние
	var direction = Input.get_axis("move_left", "move_right")
	try_step_up(direction)

	if direction != 0:
		facing_direction = direction

	var shift = Input.is_action_just_pressed("Shift")

	if shift:
		is_run = not is_run

	if is_run:
		current_speed = run_speed
	else:
		current_speed = speed

	_use_dash(delta, direction)

	if is_dash:
		velocity.y = 0
		velocity.x = dash_direction * dash_speed
	else:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * current_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	# ------------------- Атак джокера -------------------
	melee_cooldown -= delta

	if Input.is_action_just_pressed("attack"):
		if weapon == null:
			print("Нечем атаковать")
		elif melee_cooldown <= 0:
			attack()
			melee_cooldown = weapon.attack_cooldown
	
	move_and_slide()
	update_animation()
	handle_footsteps(delta)

	if global_position.y > fall_death_y and !is_respawning:
		respawn_after_fall()
