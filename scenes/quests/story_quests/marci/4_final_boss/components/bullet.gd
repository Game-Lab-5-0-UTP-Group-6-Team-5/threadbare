extends Area2D

@export var speed := 540.0
var direction := Vector2.ZERO

func _ready():
	# Conectamos la señal correctamente
	area_entered.connect(_on_area_entered)
	
	# Si tienes un sprite animado, descomenta esta línea:
	# $AnimatedSprite2D.play("default")
	
	rotation = direction.angle()

func _process(delta):
	global_position += direction * speed * delta

	if global_position.length() > 10000:
		queue_free()

func _on_area_entered(area):
	# Solo necesitamos verificar una vez
	if area.is_in_group("enemies"):
		# Verificamos si tiene la función para evitar crashes
		if area.has_method("take_damage"):
			area.take_damage(1)
		
		queue_free()
