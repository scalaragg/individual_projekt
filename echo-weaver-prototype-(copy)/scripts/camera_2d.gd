extends Camera2D

var shake_power: float = 0.0


func add_shake(power):

	shake_power = power


func _process(delta):

	if shake_power > 0:

		offset = Vector2(
			randf_range(-shake_power, shake_power),
			randf_range(-shake_power, shake_power)
		)

		shake_power = lerpf(shake_power, 0.0, 15 * delta)

	else:

		offset = Vector2.ZERO
