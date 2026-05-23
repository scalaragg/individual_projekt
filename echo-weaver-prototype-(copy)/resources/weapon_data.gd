extends Resource
class_name WeaponData

enum WeaponType {
	SWORD,
	HAMMER,
	SPEAR,
	DAGGER
}

@export var weapon_name: String = "Sword"
@export var weapon_type: WeaponType
@export var damage: int = 10
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 0.5
@export var knockback: float = 100.0
@export var max_orb_slots = 3
@export var inserted_orbs: Array[String] = []
