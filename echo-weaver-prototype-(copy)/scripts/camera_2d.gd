extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 10.0
var original_offset: Vector2 = Vector2.ZERO

func _ready():
	original_offset = offset
	make_current()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
		offset = original_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = original_offset

func add_shake(amount: float):
	shake_strength = max(shake_strength, amount)
