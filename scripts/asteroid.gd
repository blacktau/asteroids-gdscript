class_name Asteroid extends Area2D

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}

signal exploded(position, size)

@export var size := AsteroidSize.LARGE

@onready var sprite := $Sprite2D
@onready var cshape := $CollisionShape2D

var speed := 50.0

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 10
		return 0

func _ready():
	rotation = randf_range(0, 2*PI)
	
	match size:
		AsteroidSize.LARGE:
			_handle_large_asteroid()
		AsteroidSize.MEDIUM:
			_handle_medium_asteroid()
		AsteroidSize.SMALL:
			_handle_small_asteroid()

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var radius = cshape.shape.radius
	var screen_size := get_viewport_rect().size
	
	if (global_position.y + radius) < 0:
		global_position.y = screen_size.y + radius
	elif (global_position.y - radius) > screen_size.y:
		global_position.y = -radius
	
	if (global_position.x + radius) < 0:
		global_position.x = screen_size.x + radius
	elif (global_position.x - radius) > screen_size.x:
		global_position.x = -radius

func _handle_large_asteroid():
	speed = randf_range(50.0, 100.0)
	match randi_range(1, 3):
		1: 
			sprite.texture = preload("res://assets/sprites/asteroid_l1.png")
		2: 
			sprite.texture = preload("res://assets/sprites/asteroid_l2.png")
		3: 
			sprite.texture = preload("res://assets/sprites/asteroid_l3.png")
	cshape.shape = preload("res://resources/asteroid_collision_large.tres")
	#cshape.set_deferred("shape", preload("res://resources/asteroid_collision_large.tres"))
			
func _handle_medium_asteroid():
	speed = randf_range(100, 150)
	match randi_range(1, 3):
		1: 
			sprite.texture = preload("res://assets/sprites/asteroid_m1.png")
		2: 
			sprite.texture = preload("res://assets/sprites/asteroid_m2.png")
		3: 
			sprite.texture = preload("res://assets/sprites/asteroid_m3.png")
	#cshape.shape = preload("res://resources/asteroid_collision_medium.tres")
	cshape.set_deferred("shape", preload("res://resources/asteroid_collision_medium.tres"))

func _handle_small_asteroid():
	speed = randf_range(100, 200)
	match randi_range(1, 3):
		1: 
			sprite.texture = preload("res://assets/sprites/asteroid_sm1.png")
		2: 
			sprite.texture = preload("res://assets/sprites/asteroid_sm2.png")
		3: 
			sprite.texture = preload("res://assets/sprites/asteroid_sm3.png")	
	#cshape.shape = preload("res://resources/asteroid_collision_small.tres")
	cshape.set_deferred("shape", preload("res://resources/asteroid_collision_small.tres"))
	
func explode():
	emit_signal("exploded", global_position, size, points)	
	queue_free()


func _on_body_entered(body):
	if body is Player:
		body.die()

