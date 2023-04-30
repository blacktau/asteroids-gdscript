class_name Player extends CharacterBody2D

signal bullet_fired(bullet)
signal died
signal thrusting
signal coasting

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var rate_of_fire := 0.2

@onready var gun := $Gun
@onready var sprite := $AnimatedSprite2D
@onready var shooting_sound := $ShootingSound
@onready var collision_poly := $CollisionPolygon2D

var bullet_scene := preload("res://scenes/bullet.tscn")

var shoot_cooldown := false
var alive := true
var under_thrust := false

func _process(_delta):
	if !alive:
		return

	if Input.is_action_pressed("fire"):
		if !shoot_cooldown:
			shoot_cooldown = true
			fire_bullet()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cooldown = false
	
	if Input.is_action_pressed("thrust"):
		under_thrust = true
		emit_signal("thrusting")
		$AnimatedSprite2D.play("thrusting")
	else:
		$AnimatedSprite2D.play("coasting")
		emit_signal("coasting")
		under_thrust = false


func _physics_process(delta):
	if !alive:
		return

	var input_vector := Vector2(0,  -Input.get_action_strength("thrust"))
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("turn_right"):
		rotate(deg_to_rad(rotation_speed*delta))

	if Input.is_action_pressed("turn_left"):
		rotate(deg_to_rad(-rotation_speed*delta))

	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 2)

	move_and_slide()
	
	var screen_size := get_viewport_rect().size
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0


func start():
	velocity = Vector2.ZERO
	alive = true
	show()


func fire_bullet():
	var b = bullet_scene.instantiate()
	b.global_position = gun.global_position
	b.rotation = rotation
	shooting_sound.play()
	emit_signal("bullet_fired", b)


func die():
	if alive == true:
		alive = false
		sprite.visible = false
		collision_poly.set_deferred("disabled", true)
		emit_signal("died")


func respawn(pos):
	if !alive:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		collision_poly.set_deferred("disabled", false)

