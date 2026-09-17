extends Node 

# Сигнал передает имя предмета 
signal item_collected(item_name: String)
var name_user 
func set_info(_name): 
	name_user = _name
