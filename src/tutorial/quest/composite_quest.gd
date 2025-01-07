class_name CompositeQuest
extends Quest

@export var sub_quests: Array[Quest] = []


func set_is_started(value: bool) -> void:
	for quest in sub_quests:
		_connect_completed(quest)
		quest.set_is_started(value)

	super(value)


func set_is_completed(value: bool) -> void:
	for quest in sub_quests:
		quest.set_is_completed(value)

	super(value)


func _connect_completed(quest: Quest) -> void:
	var quest_completed: Signal = quest.completed
	var on_completed: Callable = _on_sub_quest_completed
	if not quest_completed.is_connected(on_completed):
		quest_completed.connect(on_completed)


func _is_quest_completed(quest: Quest) -> bool:
	return quest.is_completed


func _on_sub_quest_completed() -> void:
	if sub_quests.filter(_is_quest_completed).size() < sub_quests.size():
		return

	complete()
