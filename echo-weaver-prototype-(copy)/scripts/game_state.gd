extends Node

var player_health: int = 100

var current_weapon: WeaponData = null
var inventory: Array[WeaponData] = []
var current_weapon_index: int = -1

var stored_orbs: Array[String] = []

var spawn_position: Vector2 = Vector2.ZERO

var checkpoint_health: int = 100
var checkpoint_weapon: WeaponData = null
var checkpoint_inventory: Array[WeaponData] = []
var checkpoint_weapon_index: int = -1
var checkpoint_orbs: Array[String] = []


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
	
func save_checkpoint():
	checkpoint_health = player_health
	checkpoint_weapon = current_weapon
	checkpoint_inventory = inventory.duplicate()
	checkpoint_weapon_index = current_weapon_index
	checkpoint_orbs = stored_orbs.duplicate()


func load_checkpoint():
	player_health = checkpoint_health
	current_weapon = checkpoint_weapon
	inventory = checkpoint_inventory.duplicate()
	current_weapon_index = checkpoint_weapon_index
	stored_orbs = checkpoint_orbs.duplicate()
