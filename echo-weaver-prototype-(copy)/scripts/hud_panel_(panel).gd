extends CanvasLayer

var player = null

@onready var hud_panel = get_node_or_null("HUDPanel")

@onready var hp_label = get_node_or_null("HUDPanel/VBoxContainer/HPRow/HPLabel")
@onready var weapon_label = get_node_or_null("HUDPanel/VBoxContainer/WeaponRow/WeaponLabel")

@onready var orbs_text = get_node_or_null("HUDPanel/VBoxContainer/OrbsRow/OrbsText")
@onready var orbs_slots = get_node_or_null("HUDPanel/VBoxContainer/OrbsRow/OrbsSlots")

@onready var slots_text = get_node_or_null("HUDPanel/VBoxContainer/WeaponSlotsRow/SlotsText")
@onready var weapon_slots = get_node_or_null("HUDPanel/VBoxContainer/WeaponSlotsRow/WeaponSlots")

@onready var heart_icon = get_node_or_null("HUDPanel/VBoxContainer/HPRow/HeartIcon")
@onready var weapon_icon = get_node_or_null("HUDPanel/VBoxContainer/WeaponRow/WeaponIcon")

@onready var damage_overlay = get_node_or_null("DamageOverlay")
@onready var low_hp_vignette = get_node_or_null("LowHPVignette")

func _ready():
	player = get_tree().get_first_node_in_group("player")

	print("hp_label = ", hp_label)

	if orbs_text != null:
		orbs_text.text = "Orbs"

	if slots_text != null:
		slots_text.text = "Slots"

	setup_panel_style()

	# временно, если нет иконок
	#if heart_icon != null:
	#	heart_icon.hide()

	#if weapon_icon != null:
	#	weapon_icon.hide()

	setup_panel_style()
	
	
func update_low_hp_vignette():
	if low_hp_vignette == null:
		return

	var max_hp = 100.0
	var hp_percent = float(player.health) / max_hp

	if hp_percent > 0.35:
		low_hp_vignette.modulate.a = 0.0
		return

	var danger = 0.55 - (hp_percent / 0.35)
	low_hp_vignette.modulate = Color(1.0, 0.0, 0.0, danger * 0.45)
	
func show_damage_overlay():
	print("DAMAGE OVERLAY CALLED")

	if damage_overlay == null:
		print("DamageOverlay не найден")
		return

	damage_overlay.color = Color(1, 0, 0, 0.18)

	var tween = create_tween()
	tween.tween_property(damage_overlay, "color:a", 0.0, 0.35)


func _process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	update_hp()
	update_weapon()
	update_orbs()
	update_weapon_slots()
	update_low_hp_vignette()


func setup_panel_style():
	var style = StyleBoxFlat.new()

	style.bg_color = Color(0.12, 0.20, 0.32, 0.75)
	style.border_color = Color(0.75, 0.85, 0.95, 0.55)

	style.set_border_width_all(2)
	style.set_corner_radius_all(6)

	hud_panel.add_theme_stylebox_override("panel", style)


func update_hp():
	if hp_label == null:
		return

	if heart_icon != null and heart_icon.visible:
		hp_label.text = str(player.health)
	else:
		hp_label.text = "HP  " + str(player.health)


func update_weapon():
	if weapon_label == null:
		return

	if player.weapon != null:
		weapon_label.text = player.weapon.weapon_name
	else:
		weapon_label.text = "No weapon"


func update_orbs():
	clear_container(orbs_slots)

	var max_orbs = player.max_stored_orbs
	var stored_orbs = player.stored_orbs

	for orb in stored_orbs:
		orbs_slots.add_child(create_orb_icon(orb))

	var empty_count = max_orbs - stored_orbs.size()

	for i in range(empty_count):
		orbs_slots.add_child(create_empty_icon())


func update_weapon_slots():
	clear_container(weapon_slots)

	if player.weapon == null:
		for i in range(3):
			weapon_slots.add_child(create_empty_slot())
		return

	for orb in player.weapon.inserted_orbs:
		weapon_slots.add_child(create_orb_slot(orb))

	var empty_count = player.weapon.max_orb_slots - player.weapon.inserted_orbs.size()

	if empty_count < 0:
		empty_count = 0

	for i in range(empty_count):
		weapon_slots.add_child(create_empty_slot())


func clear_container(container):
	for child in container.get_children():
		child.queue_free()


func create_orb_icon(orb_type: String):
	var rect = ColorRect.new()

	rect.custom_minimum_size = Vector2(12, 12)
	rect.color = get_orb_color(orb_type)

	return rect


func create_empty_icon():
	var rect = ColorRect.new()

	rect.custom_minimum_size = Vector2(12, 12)
	rect.color = Color(1, 1, 1, 0.18)

	return rect


func create_orb_slot(orb_type: String):
	var rect = ColorRect.new()

	rect.custom_minimum_size = Vector2(16, 16)
	rect.color = get_orb_color(orb_type)

	return rect


func create_empty_slot():
	var rect = ColorRect.new()

	rect.custom_minimum_size = Vector2(16, 16)
	rect.color = Color(0.05, 0.08, 0.13, 0.65)

	return rect


func get_orb_color(orb_type: String):
	if orb_type == "red":
		return Color(1.0, 0.35, 0.35, 1.0)

	if orb_type == "green":
		return Color(0.45, 1.0, 0.65, 1.0)

	if orb_type == "blue":
		return Color(0.45, 0.65, 1.0, 1.0)

	return Color.WHITE
