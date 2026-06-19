extends Area2D

@export var next_scene_path: String = "res://tscns/menu.tscn"
@export var playertscn: PackedScene

@onready var audio_door = get_node_or_null("AudioDoor")

var enemies_dead = false
var player_inside = false
var is_open = false
var is_transitioning = false
var player = null

var can_control = true

@onready var sprite = $AnimatedSprite2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	sprite.play("idle")


func _process(delta):
	if !can_control:
		playertscn.velocity.x = 0
		playertscn.move_and_slide()
		return
	
	check_enemies()

	if player_inside and enemies_dead and !is_open and !is_transitioning:
		open_door()

	if player_inside and is_open and !is_transitioning:
		if Input.is_action_just_pressed("interact"):
			enter_door()


func check_enemies():
	if enemies_dead:
		return

	if get_tree().get_nodes_in_group("enemy").size() == 0:
		enemies_dead = true
		print("Все враги убиты. Дверь теперь может открыться.")


func open_door():
	is_open = true

	if sprite.sprite_frames.has_animation("open"):
		sprite.play("open")
	else:
		sprite.play("idle")


func close_door():
	is_open = false

	if sprite.sprite_frames.has_animation("close"):
		sprite.play("close")
	else:
		sprite.play("idle")


func enter_door():
	if player == null:
		return

	is_transitioning = true

	GameState.save_player(player)
	GameState.save_checkpoint()
	if audio_door != null:
		audio_door.play()
		await get_tree().create_timer(0.25).timeout

	if "can_control" in player:
		player.can_control = false

	var tween = create_tween()
	tween.tween_property(player, "modulate:a", 0.0, 0.6)
	await tween.finished

	await close_door()
	get_tree().change_scene_to_file(next_scene_path)


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true
		player = body

		# если врагов уже нет — открываем при подходе
		if enemies_dead and !is_open and !is_transitioning:
			open_door()


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

		if !is_transitioning:
			player = null

		# если игрок отошёл и не входит в дверь — можно закрыть обратно
		if is_open and !is_transitioning:
			close_door()
