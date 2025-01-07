extends Node

const MINUTE = 60

@export var quest: Quest
@export_range(50, 350, 0.001, "suffix:wpm") var words_per_minute := 200.0

var word_count_regex := RegEx.create_from_string("\\S+")

@onready var timer: Timer = $Timer


func _ready() -> void:
	quest.started.connect(timer.start.bind(get_read_time()))
	timer.timeout.connect(quest.complete)


func get_read_time() -> float:
	var word_count: int = word_count_regex.search_all(quest.objective).size()
	return word_count / words_per_minute * MINUTE
