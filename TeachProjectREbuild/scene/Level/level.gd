extends Node2D

@onready var light_animation = $Light/LightAnimation
@onready var day_text = $CanvasLayer/DayText
@onready var player = $Player/Player

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT,
}

var state: int = MORNING

## Объявили переменную, которая может хранить только целые числа (из-за int). Не уверен зачем, но ладно.
var day_count: int

## Реди - функция-обработчик, которая вызывается автоматически годотом, когда узел(нод) полностью инициализирован и готов к использованию.
func _ready():
	Global.gold = 0
	day_count = 0
	morning_state()

func _on_day_night_timeout():
	if state < 3:
		state += 1
	else:
		state = 0
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	Signals.emit_signal("day_time", state, day_count)
## Тут фишка в том, что статусы, не смотря на название, по уже знакомой мне системе являются обезличенными числами по сути. От 0 до 3 (в данной ситуации, так как их 4)

func morning_state():
## tween (интерполяция между) - временная анимация, создающаяся в моменте в коде и делающая что-то с указанным объектом
## tween_property - метод для создания анимаций с помощью tween. Поддерживает 4 свойста:(цель, свойство,конечное значение, время в кадрах),
## а тип перехода и смягчения по умолчанию линейный
## Для справки вот другой метод - interpolate_property с более гибкой настройкой, включающей тип перехода и тип смягчения.
## create_tween() создаёт новый Tween
## get_tree() нужен только для работы create_tween() ведь она по условию требует наличие сцены.
	day_count += 1
	day_text.text = "DAY " + str(day_count)
	light_animation.play("sunrise")
	
	
func evening_state():
	light_animation.play("sunset")


