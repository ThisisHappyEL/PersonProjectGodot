extends CharacterBody2D

## Скорость персонажа
const SPEED = 120
## Так называемый "State Machine"(Машина состояний), отвечающий за различные состояния персонажа. Нужен, чтобы упростить и сократить код и не прописывать тысячу if
## На любое состояние (if персонаж стоит на земле и if не двигается - idle и в этом духе)
## enum - читай перечисление состояний машины состояний
enum {
	MOVE,
	ATTACK,
	COMBO1,
	COMBO2,
	BLOCK,
	SLIDE,
	DAMAGE,
	CAST,
	DEATH,
}

## Гравитация
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
## @onready - штукенция, которая используется для объявления переменных, которые должны быть инициализированы до начала выполнения функции _ready()
## правда в текущем коде её нет. Интересно зачем тогда onready?
@onready var animPlayer = $AnimationPlayer
@onready var stats = $stats
## Нужен только для создания анимации появления и исчезновения частиц листьев в AnimationPlayer
@onready var leafs = $Leafs

var run = 1
var state = MOVE 
var combo = false
var attack_cooldown = false
var damage_basic = 10
var damage_multiplier = 1
var damage_current
var recovery = false

func _ready():
	$AttackDirection/DamageBox/HitBox/CollisionShape2D.disabled = true
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received"))
	

func _physics_process(delta):
## Гравитация
## проверка того, находится ли персонаж на земле. Если нет, то применяет к его движению по координате y + (помним про то, что вверх - это минус, а вниз - плюс)
## из константы гравитации, помноженной на дельту
	if not is_on_floor():
## Дельта, как обычно, для плавности анимации по отношению к прошлому кадру
		velocity.y += gravity * delta
	if velocity.y > 0:
		animPlayer.play("Fall")
	
	Global.player_damage = damage_basic * damage_multiplier

## mathc (сопоставление) сопоставляет значение состояния с шаблонами машины состояний, указанной ранее.
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		COMBO1:
			combo_state1()
		COMBO2:
			combo_state2()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DEATH:
			death_state()
		DAMAGE:
			damage_state()
	
	## Вшитая функци Godot, которая позволяет перемещать объект по сцене с учётом столкновения с другими объектами и физическими свойствами окр. среды, такими как гравитация и трение.
	move_and_slide()

	## Отправка позиции игрока перед срабатываением сигнала
	Global.player_pos = self.position

func move_state():
## эта переменная возвращает -1/0/1 в зависимости от того какая задействуется опция. Левый вариант (движение на лево, в данной ситуации) = -1, направо = 1.
## А бездействие = 0. -1 и 1 являются true и запускают дальнейшие штуки в коде
## Input - система обработки ввода, которая позволяет управлять игрой с помощью того или иного устройства ввода. В данном случае переменной назначаются две кнопки,
## которые, при их нажатии, делают значение переменной true, активируя все последующие опции.
## get_axis - необходима для получения значения оси ввода.
## Возможна реализация, при которой путём отнимания лево от права и верха от низа можно получить движение по оси для стиков геймпада.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run
		if velocity.y == 0:
			if run == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")

## move_toward функция, вшитая в Годот, которая используется для постепенного изменения значения от одного числа к другому.
## Она возвращает новое значение, которое ближе к целевому значению на определенную величину.
## В контексте кода она делает остановку персонажа плавным, не делая скорость мгновенно 0, а постепенно приближаясь к этому значению. За постепенность отвечает SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
		$AttackDirection.rotation_degrees = 0

## is_action_pressed - метод, который проверяет была ли нажата указанная в операторе кнопка и возвращает булеан
	if Input.is_action_pressed("run") and not recovery:
		stats.stamina_cost = stats.run_cost
		run = 1.5
		stats.stamina -= stats.run_cost
	else:
		run = 1

	if Input.is_action_just_pressed("attack") and not recovery:
		stats.stamina_cost = stats.attack_cost
		if attack_cooldown == false and stats.stamina > stats.stamina_cost:
			state = ATTACK

## is_action_just_pressed, в отличие от is_action_pressed, возвращает true единожды, а не каждый тик зажатия кнопки.
	if Input.is_action_just_pressed("block_and_slide") and velocity.x != 0 and not recovery:
		stats.stamina_cost = stats.slide_cost
		if stats.stamina > stats.stamina_cost:
			state = SLIDE

	elif Input.is_action_pressed("block_and_slide") and velocity.x == 0 and not recovery:
		stats.stamina_cost = stats.block_cost
		if stats.stamina > 1:
			state = BLOCK

func attack_state():
	damage_multiplier = 1
	## Как работает комбо я пока плохо понимаю
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO1
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func block_state():
	stats.stamina -= stats.block_cost
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play("Block")
	## А вот это уже метод на отпускание кнопки. Единовременно возвращает true по отжатии кнопки действия в операторе
	if Input.is_action_just_released("block_and_slide") or recovery:
		state = MOVE

func slide_state():
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = MOVE

func death_state():
	velocity.x = 0
	animPlayer.play("Death")
## await - ключевое слово для ожидания окончания указанного после него события (в нашем случае - анимации)
	await animPlayer.animation_finished
## метод для удаление объекта из памяти. После вызова Godot удаляет его после следующего кадра.
	queue_free()
## уже знакомый нам метод просит доступ к файлу меню. Логичней было бы перед этим показать экран смерти и предложить рестарт ИЛИ выйти в меню, но это рання реализация
## По какой-то причине у меня (и ещё у какого-то энного количества людей в комментариях под роликом) не сработал более простой возврат к экрану главногоменю.
## На помощь пришла bind (связывать) - превращает наш запрос на смену сцены в функцию, ожидающую вызов, а вызов обеспечивает...
## ...call_deferred (отложенный вызов) - откладывает вызов функции до следующего кадра игры. ГПТ говорит, что это полезно, когда нужно выполнить какое-то действие, но
## лучше сделать это после завершения текущего кадра.
## Так что я из будущего ЗАМОМНИ эту проблему, так как она ой как серьёзно сможет ввести в ступор при самостоятельном написании кода, когда не будет возможности чекнуть коммы
	get_tree().change_scene_to_file.bind("res://scene/Menu/menu.tscn").call_deferred()

func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false

func combo_state1():
	damage_multiplier = 1.2
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost: 
		state = COMBO2
	animPlayer.play("Combo1")
	await animPlayer.animation_finished
	state = MOVE

func combo2():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func combo_state2 ():
	damage_multiplier = 2
	animPlayer.play("Combo2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false

func damage_state():
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_received(enemy_damage):
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_anim()
	stats.health -= enemy_damage
	## Проверка на смэрть
	if stats.health <= 0:
		stats.health = 0
		state = DEATH

func _on_stats_no_stamina():
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false

func damage_anim():
	velocity.x = 0
	self.modulate = Color(1, 0.3, 0.3, 1)
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.1)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)

func steps():
	leafs.emitting= true
	leafs.one_shot = true

