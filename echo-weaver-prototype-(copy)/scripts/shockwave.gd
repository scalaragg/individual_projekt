extends Area2D

@export var damage = 20
@export var time_alive = 0.15

var timer = 0.0

func _ready() -> void:
	timer = time_alive
	print("shockwave ready")

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		return

	print("shockwave touched: ", body.name)

	if body.has_method("take_damage"):
		body.take_damage(damage)

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		queue_free()
