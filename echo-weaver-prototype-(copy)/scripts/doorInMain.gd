extends Sprite2D

var player = null
var player_inside = false

@onready var sprite = $Sprite2D


func _process(delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_inside = true



func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		player = null
