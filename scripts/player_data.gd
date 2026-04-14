extends Node

var player_name: String = ""
var gender: String = "" # "male" or "female"
var companion_name: String = ""
var current_slot: int = -1

# Game progress
var chapter: int = 1
var location: String = ""
var knowledge_points: int = 0


func setup(p_name: String, p_gender: String) -> void:
	player_name = p_name
	gender = p_gender
	if gender == "male":
		companion_name = "Lira"
	else:
		companion_name = "Arin"
	chapter = 1
	location = ""
	knowledge_points = 0


func reset() -> void:
	player_name = ""
	gender = ""
	companion_name = ""
	current_slot = -1
	chapter = 1
	location = ""
	knowledge_points = 0


func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"gender": gender,
		"companion_name": companion_name,
		"chapter": chapter,
		"location": location,
		"knowledge_points": knowledge_points,
	}


func from_dict(data: Dictionary) -> void:
	player_name = data.get("player_name", "")
	gender = data.get("gender", "")
	companion_name = data.get("companion_name", "")
	chapter = data.get("chapter", 1)
	location = data.get("location", "")
	knowledge_points = data.get("knowledge_points", 0)
