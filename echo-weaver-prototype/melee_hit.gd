extends Area2D

@export var damage = 5
@export var time_alive = 0.1

var timer = 0.0

func _ready():
	timer = time_alive
	print("melee ready")

func _on_body_entered(body):
	print("melee touched: ", body.name)
	print("groups: ", body.get_groups())

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _physics_process(delta):
	timer -= delta
	if timer <= 0:
		queue_free()
