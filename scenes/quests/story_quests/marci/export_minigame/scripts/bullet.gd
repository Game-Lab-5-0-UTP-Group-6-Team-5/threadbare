extends Area2D

@export var speed := 540.0
var direction := Vector2.ZERO

func _ready():
	# Conexión de señal (sintaxis moderna de Godot 4)
	area_entered.connect(_on_area_entered)
	
	# 1. Reproducir la animación del fuego
	$AnimatedSprite2D.play("default")
	
	# 2. ROTACIÓN (¡Importante para bolas de fuego!)
	# Esto hace que la bola de fuego gire para mirar hacia
	# la dirección en la que se está moviendo.
	rotation = direction.angle()

func _process(delta):
	global_position += direction * speed * delta

	# Limpieza si se va muy lejos
	if global_position.length() > 10000:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		if area.is_in_group("enemies"):
			area.take_damage(1)
		
		queue_free()
