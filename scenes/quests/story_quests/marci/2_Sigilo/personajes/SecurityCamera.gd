@tool
class_name SecurityCamera
extends Node2D


signal player_detected(player: Node2D)


enum CameraState { IDLE, SUSPICIOUS, ALERT }


@export var normal_color: Color = Color(0.0, 1.0, 0.5)
@export var suspicious_color: Color = Color(1.0, 1.0, 0.0)
@export var alert_color: Color = Color(1.0, 0.0, 0.0)


@export_range(10, 120, 5) var rotation_speed: float = 30.0
@export_range(0, 3, 0.1) var pause_time: float = 1.0


@export_range(-360, 360, 5) var limit_start_angle: float = 180.0 
@export_range(-360, 360, 5) var limit_end_angle: float = 360.0


@export_range(20, 120, 5) var vision_cone_angle: float = 45.0
@export_range(100, 1000, 50) var detection_range: float = 400.0
@export_range(0.5, 5, 0.1) var time_to_detect: float = 2.0
@export var see_through_walls: bool = false
@export var guard_alert_range: float = 500.0 

@export var alert_sound: AudioStream
@export var suspicious_sound: AudioStream


var state: CameraState = CameraState.IDLE
var current_rotation_direction: int = 1
var initial_rotation: float = 0.0
var pause_timer: float = 0.0
var detection_progress: float = 0.0
var player_in_range: Node2D = null

@onready var rotating_part: Node2D = $RotatingPart
@onready var vision_area: Area2D = $RotatingPart/VisionArea
@onready var light: PointLight2D = $RotatingPart/Light
@onready var detection_ray: RayCast2D = $RotatingPart/DetectionRay
@onready var alert_audio: AudioStreamPlayer2D = $AlertAudio
@onready var suspicious_audio: AudioStreamPlayer2D = $SuspiciousAudio


func _ready() -> void:
	if rotating_part:
		rotating_part.rotation_degrees = limit_start_angle
	
	if not Engine.is_editor_hint():
		if vision_area:
			vision_area.body_entered.connect(_on_vision_area_body_entered)
			vision_area.body_exited.connect(_on_vision_area_body_exited)

		if alert_audio and alert_sound:
			alert_audio.stream = alert_sound
		if suspicious_audio and suspicious_sound:
			suspicious_audio.stream = suspicious_sound


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_update_rotation(delta)
	_update_detection(delta)
	_update_visuals()



func _update_rotation(delta: float) -> void:
	if state == CameraState.ALERT:
		return 
	
	if pause_timer > 0:
		pause_timer -= delta
		return
	
	if rotating_part:

		rotating_part.rotation_degrees += rotation_speed * delta * current_rotation_direction

		if rotating_part.rotation_degrees >= limit_end_angle:
			rotating_part.rotation_degrees = limit_end_angle
			current_rotation_direction = -1
			pause_timer = pause_time
			

		elif rotating_part.rotation_degrees <= limit_start_angle:
			rotating_part.rotation_degrees = limit_start_angle
			current_rotation_direction = 1
			pause_timer = pause_time


## --- DETECCIÓN DEL JUGADOR ---
func _update_detection(delta: float) -> void:
	var player_visible = _is_player_in_vision()
	
	if player_visible:
		detection_progress += delta / time_to_detect
		if detection_progress >= 1.0:
			detection_progress = 1.0
			if state != CameraState.ALERT:
				_trigger_alert()
		elif state == CameraState.IDLE:
			state = CameraState.SUSPICIOUS
			if suspicious_audio and not suspicious_audio.playing:
				suspicious_audio.play()
	else:
		if detection_progress > 0:
			detection_progress -= delta / (time_to_detect * 0.5)
			detection_progress = max(0.0, detection_progress)
		
		if detection_progress <= 0 and state == CameraState.SUSPICIOUS:
			state = CameraState.IDLE



func _is_player_in_vision() -> bool:
	if not player_in_range:
		return false
	
	var player_pos = player_in_range.global_position
	var origin_pos = rotating_part.global_position if rotating_part else global_position
	var to_player = (player_pos - origin_pos)
	var distance = to_player.length()
	
	if distance > detection_range:
		return false
	

	var current_rot = rotating_part.global_rotation if rotating_part else global_rotation
	var angle_to_player = rad_to_deg(to_player.angle() - current_rot)
	angle_to_player = wrapf(angle_to_player, -180, 180)
	
	if abs(angle_to_player) > vision_cone_angle / 2.0:
		return false
	
	if not see_through_walls and detection_ray:
		detection_ray.target_position = detection_ray.to_local(player_pos)
		detection_ray.force_raycast_update()
		if detection_ray.is_colliding():
			var collider = detection_ray.get_collider()
			if collider != player_in_range:
				return false
	
	return true



func _update_visuals() -> void:
	if not light:
		return
	
	match state:
		CameraState.IDLE:
			light.color = normal_color
			light.energy = 0.6
		CameraState.SUSPICIOUS:
			light.color = suspicious_color.lerp(alert_color, detection_progress)
			light.energy = 0.8 + (detection_progress * 0.5)
		CameraState.ALERT:
			light.color = alert_color
			light.energy = 2.0


## --- ALERTA ---
func _trigger_alert() -> void:
	state = CameraState.ALERT

	if light:
		light.color = alert_color
		light.energy = 2.0

	if alert_audio and not alert_audio.playing:
		alert_audio.play()

	if player_in_range:
		player_detected.emit(player_in_range)
	
	_alert_nearby_guards()
	
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(self):
		state = CameraState.IDLE
		detection_progress = 0.0



func _alert_nearby_guards() -> void:
	var guards = get_tree().get_nodes_in_group("guard_enemy")
	var target_pos = global_position
	if player_in_range:
		target_pos = player_in_range.global_position
	for guard in guards:
		if not is_instance_valid(guard):
			continue
		var distance = guard.global_position.distance_to(global_position)
		if distance <= guard_alert_range:
			
			if "last_seen_position" in guard:
				guard.last_seen_position = target_pos
			
			if "state" in guard:
				guard.state = 3



func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
