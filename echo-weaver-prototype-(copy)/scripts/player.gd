extends CharacterBody2D

@export var weapon: WeaponData
@export var speed: float = 300.0
@export var acceleration: float = 5000.0
@export var friction: float = 3000.0
@export var jump_velocity: float = -400.0
@export var health = 100

var is_run = false
var run_speed: float = 500.0
var current_speed = speed

@export var melee_scene: PackedScene
var melee_cooldown = 0.0
var melee_delay = 1

# ------------------- УРОН -------------------
func take_damage(damage: int):
	print("Игрок атакован")
	health -= damage
	print("player hp:", health)
	
	if health <= 0:
		die()

func die():
	print("Игрок умер")
	get_tree().reload_current_scene()

# ------------------- АТАКА -------------------
func attack():
	var hit = melee_scene.instantiate()

	var damage = weapon.damage
	var attack_range = weapon.attack_range

	if weapon == null:
		damage = 5
		attack_range = 20

	var offset = attack_range
	if facing_direction == -1:
		offset = -attack_range

	hit.global_position = global_position + Vector2(offset, 0)

	# ВОТ ТУТ МАГИЯ 👇
	hit.damage = damage
	print("дальность атаки ",attack_range, " Урон: ",
	 damage)
	get_parent().add_child(hit)

# ------------------- ПРЫЖОК -------------------
var max_jump = 2
var left_jump = 0

var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0

# ------------------- ОРБЫ (я их факал)-------------------
var red_orbs = 0
var green_orbs = 0
var blue_orbs = 0

func add_orb(orb_type):
	print("picked: ", orb_type)

	if orb_type == "red":
		red_orbs += 1
	elif orb_type == "green":
		green_orbs += 1
	elif orb_type == "blue":
		blue_orbs += 1

	print("pulse: ", red_orbs, " | flow: ", green_orbs, " | edge: ", blue_orbs)

# ------------------- СОСТОЯНИЕ ПОЛА -------------------
var on_floar_time: float = 0.1
var coyto_timer: float = 0.0
var was_on_floor = true

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
		
		
		
		
		
		
		
		

# ------------------- ПУССSICS -------------------
func _physics_process(delta):

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menu.tscn")

	# ГРАВИТАЦИЯ
	if not is_on_floor():
		velocity.y += gravity * delta

	# ПРЫЖОК
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	if is_on_floor():
		left_jump = max_jump
		coyto_timer = on_floar_time
	else:
		coyto_timer -= delta

	if was_on_floor and not is_on_floor() and left_jump == max_jump:
		left_jump = 1

	if jump_buffer_timer > 0 and (coyto_timer > 0 or left_jump > 0):
		if left_jump == 1:
			velocity.y = jump_velocity * 0.7
		else:
			velocity.y = jump_velocity

		left_jump -= 1
		coyto_timer = 0
		jump_buffer_timer = 0

	# ДВИЖЕние
	var direction = Input.get_axis("move_left", "move_right")

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
		if melee_cooldown <= 0:
			attack()
			melee_cooldown = melee_delay

	was_on_floor = is_on_floor()
	move_and_slide()
