extends CharacterBody2D

@export var shockwave_scene: PackedScene
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


func take_damage(damage):
	print("Игрок атакован")
	health -= damage
	print("player hp:", health)
	
	if health <= 0:
		die()
	
func die():
	print("Игрок умер")
	get_tree().reload_current_scene()
	
	#--------------------атака-------------------
func attack():
	if melee_scene == null:
		print("melee_scene не задан")
		return
	

	var hit = melee_scene.instantiate()

	# позиция перед игроком
	var offset = 30
	if facing_direction == -1:
		offset = -30
	else:
		offset = 30

	hit.global_position = global_position + Vector2(offset, 0)
	get_parent().add_child(hit)

# прыжочки---------------------------------------------------
var max_jump = 2
var left_jump = 0
# jump buffer
var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0
# нитки ---------------------------------------------------п-----
var red_threads = 0
var green_threads = 0
var blue_threads = 0
func add_thread(thread_type):
	print("picked: ", thread_type)

	if thread_type == "red":
		red_threads += 1
	elif thread_type == "green":
		green_threads += 1
	elif thread_type == "blue":
		blue_threads += 1

	print("pulse: ", red_threads, " | flow: ", green_threads, " | edge: ", blue_threads)
	
# каст блятских ниток
var sealed_spell = ""
var cast_queue = []
var sealed_cast = []
var max_cast_queue = 3


func add_to_cast_queue(thread_type):
	if cast_queue.size() >= max_cast_queue:
		cast_queue.pop_at(cast_queue.size() - 1) # удаляем справа
	cast_queue.insert(0, thread_type) # добавляем слева
	print(cast_queue)

#запечатываем блятские нитки
func can_seal_cast():
	var need_red = 0
	var need_green = 0
	var need_blue = 0
	
	for thread in cast_queue:
		if thread == "red":
			need_red += 1
		elif thread == "green":
			need_green += 1
		elif thread == "blue":
			need_blue += 1
	if red_threads >= need_red and green_threads >= need_green and blue_threads >= need_blue and cast_queue.size() == 3:
		return true
	else:
		return false
	
# состояния стояния на полу-----------------------------------------------------------------------------
var on_floar_time: float = 0.1 # если персонаж стоит на полу( время по умол., если на полу - не идет) 
var coyto_timer: float = 0.0 # таймер с момента схождения с пола
var was_on_floor = true
# направление движения----------------------------------------------------------
var facing_direction: float = 1.0 # направление взгляда (по умол. впарво)
var dash_direction: float = 1.0 # направление деша = направление взгляда (по умол. впарво)
# дэщ--------------------------------------------------------------------------
var dash_speed:float= 800.0
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
		if is_dash == true:
			current_speed = dash_speed
			dash_timer -= delta
		if dash_timer <=0:
			is_dash = false
		if dash_cooldown_timer > 0:
			dash_cooldown_timer -= delta
	
# шоквейв ----------------------------
func spawn_shockwave():
	print("spawn_shockwave called")

	if shockwave_scene == null:
		print("shockwave_scene is NULL")
		return

	var wave = shockwave_scene.instantiate()

	if wave == null:
		print("wave is NULL")
		return

	wave.global_position = global_position + Vector2(20*facing_direction, 0)
	get_parent().add_child(wave)

	print("player pos: ", global_position)
	print("wave pos: ", wave.global_position)
	print("wave added to scene")









func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menu.tscn")
	
	# Гравитация ---------------------------------------------
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
			# Прыжок ---------------------------------------------------
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	if is_on_floor():
		left_jump = max_jump
		coyto_timer = on_floar_time
	else:
		coyto_timer -= delta
	# если просто сошёл с платформы без прыжка — считаем первый прыжок потраченным 
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
		
		
		


	# Движение ------------------------------------------------------------
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = direction
	# бег (переключение)
	var shift = Input.is_action_just_pressed("Shift")
	
	if shift:
		is_run = not is_run
	
	if is_run:
		current_speed = run_speed
	else:
		current_speed = speed
		#дэщ
	_use_dash(delta,direction)

	
	# само движение ------------------------------------------
	
	if is_dash:
		velocity.y = 0
		velocity.x = dash_direction * dash_speed
	else:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * current_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		
			# каст блятских ниток ----------------------------------------------------------------------------------------------ь-ь-
	if Input.is_action_just_pressed("Q"):
		add_to_cast_queue("blue")
	elif Input.is_action_just_pressed("W"):
		add_to_cast_queue("green")
	elif Input.is_action_just_pressed("E"):
		add_to_cast_queue("red")
	
	if Input.is_action_just_pressed("R"):
		if can_seal_cast():
			# Считаем, сколько нитей нужно для текущей очереди
			var need_red = 0
			var need_green = 0
			var need_blue = 0

			for thread in cast_queue:
				if thread == "red":
					need_red += 1
				elif thread == "green":
					need_green += 1
				elif thread == "blue":
					need_blue += 1

			# Списываем нужное количество нитей у игрока
			red_threads -= need_red
			green_threads -= need_green
			blue_threads -= need_blue

			# Копируем текущую очередь в запечатанный каст
			sealed_cast = cast_queue.duplicate()

			# Для проверки выводим в консоль
			print("sealed cast: ", sealed_cast)
			print("pulse: ", red_threads, " | flow: ", green_threads, " | edge: ", blue_threads)
		else:
			print("Недостаточно нитей для запечатывания")
			cast_queue.clear()
		if sealed_cast.size() == 3:
			if sealed_cast == ["red","red","red"]:
				print("shockwave")
				sealed_spell = "shockwave"
			elif sealed_cast == ["green","green","green"]:
				print("Speed_up")
				sealed_spell = "Speed_boost"
			elif sealed_cast == ["blue","blue","blue"]:
				print("Slowdown")
				sealed_spell = "Slowdown"
			elif sealed_cast == ["red","green","blue"]:
				print("Sun_strike")
				sealed_spell = "Sun_strike"
		
	#КАСТУЕМ ЗАКЛИНАНИЯ --------------------------------------------------------------------------------
	if Input.is_action_just_pressed("F"):
		print("F pressed")
		print("sealed_spell = ", sealed_spell)
		if sealed_spell == "":
			print("Нет запечатанного заклинания")
		elif sealed_spell == "shockwave":
			print("КАСТ: Ударная волна")
			spawn_shockwave()
			sealed_cast.clear()
		elif sealed_spell == "Speed_boost":
			print("КАСТ: Ускорение")
			sealed_cast.clear()
		elif sealed_spell == "Slowdown":
			print("КАСТ: Замедление")
			sealed_cast.clear()
		elif sealed_spell == "Sun_strike":
			print("КАСТ: солнечный удар")
			sealed_cast.clear()
		sealed_spell = ""
		
		
	#милишная атака-------------------------------------------
	melee_cooldown -= delta

	if Input.is_action_just_pressed("attack"):
		if melee_cooldown <= 0:
			attack()
			melee_cooldown = melee_delay
			
	was_on_floor = is_on_floor()
	move_and_slide()
