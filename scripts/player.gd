extends CharacterBody2D

var speed = 40
@export var anim: AnimatedSprite2D
@onready var name_label: Label = $Label

@export var hand_texture: Sprite2D # из PHASE_06: export var hand_texture = Sprite2D
@export var item_world_scene: PackedScene # из PHASE_11: export var item_world_scene: PackedScene

var active_slot_index: int = 0 # из раздела ВЫБОР ПРЕДМЕТОВ

func _physics_process(_delta):
 var input = Vector2(Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left'), Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up'))
 velocity = input.normalized() * speed
	
 if is_sitting:
  velocity = Vector2.ZERO
  move_and_slide()
  return
  
 if input.x > 0:
  anim.flip_h = true
 elif input.x < 0:
  anim.flip_h = false
  
 if input != Vector2.ZERO:
  anim.play('walk')
 else:
  anim.play('idle')
  
 move_and_slide()

var is_sitting = false

func _unhandled_input(event):
 # PHASE_06 // TOOLS
 if event.is_action_pressed("use_tool"):
  if Global.inventory.size() > 0:
   var item = Global.inventory[0]
   if item.is_tool:	hand_texture = item.icon

 # PHASE_07 // SIT_LOGIC
 if event.is_action_pressed('interact'):
  if is_sitting:
   is_sitting = false
   anim.play('idle')
  else:
   is_sitting = true
   anim.play('sit')

 # ВЫБОР ПРЕДМЕТОВ (КОЛЕСИКО МЫШИ)
 if event.is_action_pressed("next_item"):
  change_selection(1)
 if event.is_action_pressed("prev_item"):
  change_selection(-1)

 # PHASE_11 // DROP_LOGIC
 if event.is_action_pressed("drop_item"): # Назначьте в Input Map действие drop_item
  drop_item()

func _ready() -> void:
 if Global.name_user != null and Global.name_user != "":
  name_label.text = Global.name_user
 else:
  name_label.text = "Без имени"

var equipped_tool: ItemData

# ВЫБОР ПРЕДМЕТОВ — Функция обновления визуализации руки
func update_hand_visual():
 var item = Global.inventory[Global.active_slot_index]
 if item:
  hand_texture = item.icon
  equipped_tool = item if item.is_tool else null
 else:
  hand_texture = null
  equipped_tool = null

# ВЫБОР ПРЕДМЕТОВ — Функция смены выбора
func change_selection(direction: int):
 if Global.inventory.size() == 0: return
	
 Global.active_slot_index = (Global.active_slot_index + direction) % Global.inventory.size()
 if Global.active_slot_index < 0: Global.active_slot_index = Global.inventory.size() - 1
	
 update_hand_visual()

# PHASE_11 // DROP_LOGIC — Функция выброса предмета
func drop_item():
 if Global.inventory.size() > 0:
  var item_to_drop = Global.inventory[Global.active_slot_index]
  Global.inventory.remove_at(Global.active_slot_index)
  
  spawn_dropped_item(item_to_drop)
  
  Global.active_slot_index = clamp(Global.active_slot_index, 0, Global.inventory.size() - 1)
  Global.inventory_updated.emit()
  update_hand_visual()

# PHASE_11 // DROP_LOGIC — Функция спавна предмета в мире
func spawn_dropped_item(item_to_drop: ItemData):
 var new_item = item_world_scene.instantiate()
 new_item.item_resources = item_to_drop
	
 var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
 new_item.position = self.position + random_offset
	
 get_tree().current_scene.add_child(new_item)
