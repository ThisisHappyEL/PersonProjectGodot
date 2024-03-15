extends Node2D

## Скрипт для исключительно оптимизационной сцены, которую потом можно будет пихать в разных мобов

signal no_health()
signal damage_received()

@onready var health_bar = $HealthBar
@onready var damage_text = $HealthBar/DamageText
@onready var animPlayer = $AnimationPlayer

@export var max_health = 100

## каждый раз, когда наше здоровье происходит тело setget
var health = 100:
	set(value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true

func _ready():
	health_bar.max_value = max_health
	health = max_health
	health_bar.visible = false

func _on_hurt_box_area_entered(_area):
	health -= Global.player_damage
	damage_text.text = str(Global.player_damage)
	animPlayer.stop()
	animPlayer.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else:
		emit_signal("damage_received")
