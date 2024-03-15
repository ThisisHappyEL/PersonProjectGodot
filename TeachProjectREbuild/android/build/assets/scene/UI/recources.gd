extends CanvasLayer

@onready var gold_text = $Control/PanelContainer/HBoxContainer/goldText

func _process(_delta):
	gold_text.text = str(Global.gold)
