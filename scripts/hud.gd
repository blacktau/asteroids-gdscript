extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

@onready var lives = $Lives

var uilife = preload("res://scenes/ui_life.tscn")

func init_lives(count):
	for ul in lives.get_children():
		ul.queue_free()
	for i in count:
		var ui = uilife.instantiate()
		lives.add_child(ui)
