extends Node

@onready var pause_menu = $"../CanvasLayer/PauseMenu"

var game_paused: bool = false
var save_path = "user://savegame.save"
@onready var player = $"../Player/Player"


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused

	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed():
	game_paused = !game_paused

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/Menu/menu.tscn")

func _on_pause_button_pressed():
	game_paused = !game_paused

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(Global.gold)
	file.store_var(player.position.x)
	file.store_var(player.position.y)

func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	Global.gold = file.get_var(Global.gold)
	player.position.x = file.get_var(player.position.x)
	player.position.x = file.get_var(player.position.y)


func _on_save_pressed():
	save_game()
	game_paused = !game_paused


func _on_load_pressed():
	load_game()
	game_paused = !game_paused
