extends Resource
class_name NoteMapping

@export var note_mapping: Dictionary

func get_note(value: BattleManager.BeatType) -> Note:
	return note_mapping.get_or_add(value, null)
