extends CharacterBody2D


const SWORD = preload("res://resources/weapons/sword.tres")
const HAMMER = preload("res://resources/weapons/hammer.tres")
const SPEAR = preload("res://resources/weapons/spear.tres")

var inventory: Array[WeaponData] = []

var current_weapon_index = 0
var weapon: WeaponData

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

#---------- equip weapon func --------------



func equip_weapon(index):

	if index < 0 or index >= inventory.size():
		return

	current_weapon_index = index
	weapon = inventory[index]

	print("Экипировано:", weapon.weapon_name)



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

	if melee_scene == null:
		return

	var hit = melee_scene.instantiate()
	var damage = 5
	var attack_range = 20
	var knockback = 100.0

	if weapon != null:
		damage = weapon.damage
		attack_range = weapon.attack_range
		knockback = weapon.knockback

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
		
func _ready():

	inventory.append(SWORD)
	inventory.append(HAMMER)
	inventory.append(SPEAR)

	equip_weapon(0)

# ------------------- ПУССSICS -------------------

	

func _physics_process(delta):
	if Input.is_action_just_pressed("weapon_1"):
		equip_weapon(0)

	if Input.is_action_just_pressed("weapon_2"):
		equip_weapon(1)

	if Input.is_action_just_pressed("weapon_3"):
		equip_weapon(2)
		
	if Input.is_action_just_pressed("ui_page_up"):
		insert_orb("red")

	if Input.is_action_just_pressed("ui_page_down"):
		insert_orb("green")

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
	if velocity.x != 0:
		if direction == 1:
		
			get_node("AnimatedSprite2D").play("move_right")
		elif direction == -1:
		
			get_node("AnimatedSprite2D").play("move_left")
	else:
		get_node("AnimatedSprite2D").play("idle")

	# ------------------- Атак джокера -------------------
	melee_cooldown -= delta

	if Input.is_action_just_pressed("attack"):
		if melee_cooldown <= 0:
			attack()
			melee_cooldown = melee_delay

	was_on_floor = is_on_floor()
	move_and_slide()
