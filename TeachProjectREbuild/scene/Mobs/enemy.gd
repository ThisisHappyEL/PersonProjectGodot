extends CharacterBody2D
class_name Enemy

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER,
}
## необычная переменная - setget. Делается путём постановки не = после названия, а :. Её нельзя менять так просто как обычную переменную и для этого нужно использование
## метода set(value).
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()


@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = Vector2.ZERO
var direction = Vector2.ZERO
var damage = 20
var moveSpeed = 150

func _ready():
	state = CHASE

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if state == CHASE:
		chase_state()

	move_and_slide()

	player = Global.player_pos

## На этом этапе узнал про переименовывание слоёв коллизии и их взаимодействие друг с другом. Не знаю куда ещё поместить об этом заметку, так что пусть будет тут.
## У charapterbody2d есть группа свойств - collision. Там есть таблица с слоями, каждый из которых можно как-то обозвать для удобства в основных настройках проекта в разделе
## "Имена слоя". Посмотреть же их можно в той группе свойств тыкнув на 3 точечки справа от таблиц Layer (собственный объекта) и Mask (взаимодействие или игнорирование им других)
## По обучающему материалу игрок занял второй слой, враги 3, а объекты мира, такие как почва - 1. С 1 взаимодействуют все, чтобы не падать, но по задумке автора персонаж должен
## уметь проходить сквозь врагов, поэтому на текущем этапе его маска коллизий включает только 1 (то есть землю)

## Ещё одна маленькая заметка оттуда же. Если хочется, чтобы какой-либо объект был на переднем плане, а остальные на задних, то нужно перетянуть их в древе сцены ниже других.

## Ещё один забавный эффект, который так и просится для реализации толкания камней - Если отключить моба в маске у игрока, но включить игрока в масках мобов, то он их начнёт толкать

## Занятный момент. По уроку сделал ключ AttackRange (который, в свою очередь является Area2D) и в маске коллизий указал взаимодействие со вторым слоем(который принадлежит игроку)
## И этого хватило, чтобы грибок проигрывал анимацию атаки при приближении игрока

func _on_attack_range_body_entered(_body):
	state = ATTACK

func idle_state():
	animPlayer.play("Idle")
	## Переход в стадию погони/патрулирования
	state = CHASE

func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = RECOVER

func chase_state():
	animPlayer.play("Run")
## normalized нужен для того, чтобы эти значения превратились максимально близко в 1 и -1 (гпт говорит, что -1 он не возвращает)
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	velocity.x = direction.x * moveSpeed

func damage_state():
	velocity.x = 0
	damage_anim()
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = IDLE

func death_state():
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()

func recover_state():
	velocity.x = 0
	animPlayer.play("Recover")
	await animPlayer.animation_finished
	state = IDLE

## Новая функция-обработчик, созданная с помощью узла "area_entered у Area2D "HitBox" грибочка
func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage)

func damage_anim():
	direction = (player - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 200 
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.1)

func _on_run_timeout():
	moveSpeed = move_toward(moveSpeed, randi_range(120, 170), 100)
