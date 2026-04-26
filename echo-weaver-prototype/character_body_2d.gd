extends CharacterBody2D

@export var health = 20
@export var thread_scene: PackedScene
@export var speed = 200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_in_range = false
var player = null

var attack_cooldown = 1.0
var attack_timer = 0.0

func take_damage(damage):
	print("Враг атакован")
	health -= damage
	print("enemy hp: ", health)

	if health <= 0:
		die()

func die():
	if thread_scene:
		var thread = thread_scene.instantiate()
		thread.global_position = global_position
		get_parent().add_child(thread)
	queue_free()

func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("нашёл игрока:", player)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("ИГРОК ВОШЕЛ")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("ИГРОК ВЫШЕЛ")

func _physics_process(delta: float) -> void:
	# гравитация
	if not is_on_floor():
		velocity.y += gravity * delta

	# движение к игроку
	if player_in_range and player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		
	else:
		velocity.x = 0
			
	attack_timer -= delta
	if player_in_range and player != null:
		var distance = global_position.distance_to(player.global_position)
		
		if distance < 40 and attack_timer <= 0:
			player.take_damage(10)
			attack_timer = attack_cooldown
			
			
	move_and_slide()
