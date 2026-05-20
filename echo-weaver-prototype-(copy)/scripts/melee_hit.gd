extends Area2D

@export var damage: int = 5
@export var knockback: float = 100

var effects: Array[String] = []

@export var time_alive: float = 0.1

var timer: float = 0.0

func _ready():
	timer = time_alive
	
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			var final_damage = damage
			
			# RED ORB
			for effect in effects:
				if effect == "red":
					final_damage += 2
			body.take_damage(final_damage)
			
			# KNOCKBACK
			if body.has_method("apply_knockback"):
				var direction = (
					body.global_position - global_position
				).normalized()
				body.apply_knockback(direction * knockback)
				
			# GREEN ORB
			for effect in effects:
				if effect == "green":
					var player = get_tree().get_first_node_in_group("player")
					if player != null:
						player.heal(2)

func _physics_process(delta):

	timer -= delta

	if timer <= 0:
		queue_free()
