extends CanvasLayer

signal no_stamina()

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar
@onready var health_text = $"../HealthText"
@onready var health_anim = $"../HealthAnim"

var stamina_cost
var attack_cost = 10
var block_cost = 0.6
var slide_cost = 20
var run_cost = 0.5
var max_health = 120
var old_health = max_health

var health:
	set(value):
## clamp - ограничивает переменную health в минимальном и максимальном значении
		health = clamp(value, 0, max_health)
		health_bar.value = health
		var difference = health - old_health
		health_text.text = str(difference)
		old_health = health
		if difference < 0:
			health_anim.play("damage_received")
		else:
			health_anim.play("health_received")

var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")

func _ready():
	health = max_health
	health_bar.max_value = health
	health_bar.value = health

func _process(delta):
	stamina_bar.value = stamina
	if stamina < 100:
		stamina += 10 * delta

func stamina_consumption():
	stamina -= stamina_cost

func _on_health_regen_timeout():
	health += 1

func _input(event):
	if Input.is_action_pressed("attack") and stamina > 10:
		stamina -= attack_cost
