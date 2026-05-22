extends Label

var velocity = Vector2(0, -40)
var timer = 0.5

func _ready():
	scale = Vector2(1.2,1.2)

func _process(delta):
	position += velocity * delta
	modulate.a -= delta * 2
	timer -= delta
	if timer <= 0:
		queue_free()
