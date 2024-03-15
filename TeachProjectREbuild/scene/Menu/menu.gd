extends Node2D

@onready var buttons = $buttons

## Дальнейший код написан наполовину автоматически, при подключения узла(ноды) "pressed" для кнопок Play и Quit

## Вшитая функция Godot, которую мы вызывает на самостоятельно(хотя это опция, но потом надо отдельно привязывать её), а с помощью тычка по нужному узлу(ноде) в списке,
## ПКМ - Присоединить и выбираем (автоматом что нужно, скорее всего, так что просто энтер) нужную сцену (в данной ситуации Menu)
## Сама опция названа функционально - срабатывает при нажатии чего-то (в данной ситуации кнопки Quit, которая и иницировала привязкой узла создание данной функции)
func _on_quit_pressed():
	buttons.play()
	await buttons.finished
	get_tree().quit()
## get_tree() - функция для доступа к дереву сцен. Нужна она здесь для того, чтобы получить возможность работать совместо с кнопкой Quit.
## Функция quit() - вшитая фича для выключения игры. Поэтому более ничего прописывать не нужно и её достаточно

## Ещё одна вшитая функция, описание которой аналогично функции выше: Мы её вызвали сами через узлы, название отражает суть - нажал - произошло что-то
## в данной ситуации произошёл запрос к дереву сцен, загрузка новой сцены из нужного файла (в данной ситуации Level, на котором и происходит весь игровой процесс)
func _on_play_pressed():
	buttons.play()
	await buttons.finished
	get_tree().change_scene_to_file("res://scene/Level/level.tscn")
