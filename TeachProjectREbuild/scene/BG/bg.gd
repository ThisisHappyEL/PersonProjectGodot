extends ParallaxBackground
## Константа,содержащая в себе скорость (вероятно в пикселях), с которой двигается бэкграунд
const SPEED = 100

## Функция, которая и запускает движение бэкрганда
## _process - функция, которая вшита в Godot (на это указывает нижнее подчёркивание перед названием)
## Она представляет из себя нечто, что срабатывает каждый кадр в игре
## delta - это время, которое прошло с момента отображения предыдущего кадра.
## Расчёт ведётся на основании реального времени, что делает движение более плавным и независымым от частоты кадров
func _process(delta):
	scroll_offset.x -= SPEED * delta
## scroll_offset - встроенное свойство ParallaxBackground, которое отвечает за смещение фона на сцене
