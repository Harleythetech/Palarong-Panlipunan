extends Node

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 5


func _ready() -> void:
	_ensure_save_dir()


func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.save" % slot


func save_game(slot: int) -> void:
	var config := ConfigFile.new()
	var data := PlayerData.to_dict()
	for key in data:
		config.set_value("player", key, data[key])
	config.set_value("meta", "timestamp", Time.get_datetime_string_from_system())
	config.save(_slot_path(slot))
	PlayerData.current_slot = slot


func load_game(slot: int) -> bool:
	var config := ConfigFile.new()
	if config.load(_slot_path(slot)) != OK:
		return false
	var data := {}
	for key in config.get_section_keys("player"):
		data[key] = config.get_value("player", key)
	PlayerData.from_dict(data)
	PlayerData.current_slot = slot
	return true


func get_slot_info(slot: int) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(_slot_path(slot)) != OK:
		return {"exists": false}
	return {
		"exists": true,
		"player_name": config.get_value("player", "player_name", "???"),
		"gender": config.get_value("player", "gender", ""),
		"chapter": config.get_value("player", "chapter", 1),
		"timestamp": config.get_value("meta", "timestamp", ""),
	}


func has_any_saves() -> bool:
	for i in range(1, MAX_SLOTS + 1):
		if FileAccess.file_exists(_slot_path(i)):
			return true
	return false


func get_first_empty_slot() -> int:
	for i in range(1, MAX_SLOTS + 1):
		if not FileAccess.file_exists(_slot_path(i)):
			return i
	return -1


func delete_save(slot: int) -> void:
	var path := _slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
