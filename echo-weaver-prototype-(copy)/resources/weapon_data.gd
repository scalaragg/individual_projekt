extends Resource
class_name WeaponData

enum WeaponType {
	SWORD,
	HAMMER,
	SPEAR
}

@export var weapon_type: WeaponType

@export var weapon_name: String = "Sword"

@export var damage: int = 10
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 0.5

@export var knockback: float = 200.0

@export var orb_slots: int = 3
@export var inserted_orbs: Array[String] = []
