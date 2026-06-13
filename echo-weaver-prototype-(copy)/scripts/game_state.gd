extends Node

var player_health: int = 100

var current_weapon: WeaponData = null
var inventory: Array[WeaponData] = []
var current_weapon_index: int = -1

var stored_orbs: Array[String] = []

var spawn_position: Vector2 = Vector2.ZERO


func save_player(player):
	player_health = player.health

	current_weapon = player.weapon
	inventory = player.inventory.duplicate()
	current_weapon_index = player.current_weapon_index

	stored_orbs = player.stored_orbs.duplicate()


func load_player(player):
	player.health = player_health

	player.weapon = current_weapon
	player.inventory = inventory.duplicate()
	player.current_weapon_index = current_weapon_index

	player.stored_orbs = stored_orbs.duplicate()
