extends Node2D

@onready var mobs = $".."
@onready var animationPlayer = $AnimationPlayer

var spawnCount = 0

var mushroom_preload = preload("res://scene/Mobs/mushroom.tscn")
var skeleton_preload = preload("res://scene/Mobs/skeleton.tscn")

func _ready():
	Signals.connect("day_time", Callable(self, "_on_time_changed"))

func _on_time_changed(state, day_count):
	spawnCount = 0
	var rng = randi_range(0, 2)
	if state == 1:
		for i in (day_count + rng):
			animationPlayer.play("spawn")
			await animationPlayer.animation_finished
			spawnCount += 1
	if spawnCount == day_count + rng:
		animationPlayer.play("idle")

func enemy_spawn():
	var rng = randi_range(1, 2)
	if rng == 1:
		mushroom_spawn()
	elif rng == 2:
		skeleton_spawn()

func mushroom_spawn():
	var mushroom = mushroom_preload.instantiate()
	mushroom.position = Vector2(self.position.x, 480)
	mobs.add_child(mushroom)

func skeleton_spawn():
	var skeleton = skeleton_preload.instantiate()
	skeleton.position = Vector2(self.position.x, 480)
	mobs.add_child(skeleton)

