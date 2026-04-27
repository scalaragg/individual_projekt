extends Area2D

@export var damage: int = 5
var effects: Array[String] = []

@export var time_alive: float = 0.1
var timer: float = 0.0


func _ready():
	timer = time_alive
	print("melee ready")

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _physics_process(delta):
	timer -= delta
	if timer <= 0:
		queue_free()
