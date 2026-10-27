extends Node

var active_slot_index: int = 0

# Сигнал передает имя предмета
signal item_collected(item_name: String)

var name_user

func set_info(_name):
 name_user = _name

# Сигнал уведомления об обновлении инвентаря
signal inventory_updated

# Максимальное количество предметов в инвентаре (из PHASE_13)
@export var max_inventory_size: int = 10

var inventory: Array[ItemData] = []

func add_item(item: ItemData):
 # 1. Сначала проверяем, есть ли уже такой предмет (Логика стаканья из PHASE_12)
 var item_found = false
 for current_item in inventory:
  if current_item.name == item.name:
   current_item.amount += 1
   item_found = true
   inventory_updated.emit() # Оповещаем UI об изменениях
   return # Предмет успешно уложен в существующий слот, выходим!

 # 2. Если предмет НОВЫЙ, проверяем ограничение инвентаря (Логика из PHASE_13)
 if inventory.size() < max_inventory_size:
  item.amount = 1
  inventory.append(item) # Добавляем предмет в инвенварь
  inventory_updated.emit() # Оповещаем UI об изменениях
