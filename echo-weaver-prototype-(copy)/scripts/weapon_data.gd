extends Resource
class_name WeaponData

@export var weapon_name: String = "Sword"
@export var damage: int = 5
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 0.6
@export var effects: Array[String] = []

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			
			var final_damage = damage
			
			for effect in effects:
				if effect == "red":
					final_damage += 2
				elif effect == "blue":
					final_damage += 1
			
			body.take_damage(final_damage)
