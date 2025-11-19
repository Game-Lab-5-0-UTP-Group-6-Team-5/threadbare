extends Area2D
class_name Fireball

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

# Si el jugador hace parry, el boss puede ser golpeado
var can_be_parried: bool = true  

func _ready() -> void:
	# Asegurar que exista Sprite y Collision
	monitoring = true
	monitorable = true

	# Conectar colisión
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Destruir después de unos segundos
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func shoot_toward(target_pos: Vector2) -> void:
	# Dirección del disparo
	direction = (target_pos - global_position).normalized()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
		return

	if body.is_in_group("boss") and not can_be_parried:
		print("🔥 Fireball golpeó al Boss tras parry")
		if body.has_method("take_damage"):
			body.take_damage(20)
		queue_free()
		return

	if not body.is_in_group("boss") and not body.is_in_group("player"):
		queue_free()

func _on_timer_timeout():
	queue_free()
