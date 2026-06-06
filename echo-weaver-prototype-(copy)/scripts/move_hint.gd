extends Node2D

@export var hint_texture: Texture2D
@export var hint_text: String = ""
@export var visible_on_start: bool = false

@onready var visual = $Visual
@onready var sprite = $Visual/Sprite2D
@onready var label = $Visual/Label
@onready var area = $Area2D

var tween: Tween


func _ready():
	sprite.texture = hint_texture
	label.text = hint_text

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	if visible_on_start:
		visual.modulate.a = 1.0
	else:
		visual.modulate.a = 0.0


func fade_to(alpha_value: float):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(visual, "modulate:a", alpha_value, 0.2)


func _on_body_entered(body):
	if body.is_in_group("player"):
		fade_to(1.0)


func _on_body_exited(body):
	if body.is_in_group("player"):
		fade_to(0.0)
