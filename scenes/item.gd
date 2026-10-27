extends Node2D 
#@export var item_id: String = 'mushrooms' 
@export var item_resources: ItemData
 # Если в Area2D находиться любое body, вызывается данная функция 
func _on_area_2d_body_entered(body: Node2D) -> void: 
	 # Проверка body = Player 
	if body.name == 'player': 
		 # Вызов сигнала с именем предмета 
		Global.item_collected.emit(item_resources) 
		 # Удаление предмета 
		queue_free()

@export var sprite: Sprite2D

func _ready() -> void:
	sprite.texture = item_resources.icon
