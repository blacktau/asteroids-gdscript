extends Area2D

var movement_vector := Vector2(0, -1)
@export var speed := 500.0
@export var lifetime := 1.25

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var screen_size := get_viewport_rect().size
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func _ready():
	$AnimatedSprite2D.play("default")
	$Timer.start(lifetime)

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area is Asteroid:
		area.explode()
		queue_free()
