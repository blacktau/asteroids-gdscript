extends Node2D


@onready var bullets := $Bullets
@onready var player := $Player
@onready var asteroids := $Asteroids
@onready var hud := $UI/HUD
@onready var game_over_screen := $UI/GameOverScreen
@onready var player_spawn_pos := $PlayerSpawnPos
@onready var player_spawn_area := $PlayerSpawnPos/PlayerSpawnArea


var asteroid_scene := preload("res://scenes/asteroid.tscn")
var asteroid_count := 5
var next_life := 10000

var score := 0:
	set(value):
		score = value
		hud.score = score
		if score > next_life:
			lives += 1
			next_life += 10000


var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)


# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()


func _on_player_fired(bullet):
	bullets.add_child(bullet)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func new_game():
	score = 0
	lives = 3
	player.connect("bullet_fired", _on_player_fired)
	player.connect("died", _on_player_died)
	game_over_screen.visible = false
	
	spawn_asteroid_cluster()

	player.start()


func spawn_asteroid_cluster():
	var screen_size = get_viewport_rect().size

	for i in range(0, asteroid_count):
		var pos := Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		spawn_asteroid(pos, Asteroid.AsteroidSize.LARGE)


func spawn_asteroid(pos, size):
	var a := asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)


func _on_player_died():
	lives -= 1
	if $RocketSound.playing:
		$RocketSound.stop()
	$PlayerExplosionSound.play()
	
	player.global_position = player_spawn_pos.global_position
	
	if lives <= 0:
		await get_tree().create_timer(1).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0,1).timeout
		
		player.call_deferred("respawn", player_spawn_pos.global_position)


func _on_asteroid_exploded(pos, size, points):
	score += points
	$AsteroidExplosionSound.play()
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				if asteroids.get_child_count() == 1:
					await get_tree().create_timer(0,1).timeout
					asteroid_count += 1
					call_deferred("spawn_asteroid_cluster")


func _on_player_thrusting():
	if !$RocketSound.playing:
		$RocketSound.play()


func _on_player_coasting():
	if $RocketSound.playing:
		$RocketSound.stop()
