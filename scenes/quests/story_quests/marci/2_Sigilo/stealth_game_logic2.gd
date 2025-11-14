# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
class_name StealthGameLogic2
extends Node


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 🟢 Busca todos los guardias del grupo "guard_enemy"
	var guards = get_tree().get_nodes_in_group("guard_enemy")

	if guards.is_empty():
		print("⚠️ No se encontraron guardias en el grupo 'guard_enemy'.")
		return

	print("🎮 StealthGameLogic listo. Conectando señales de", guards.size(), "guardias...")

	for guard in guards:
		# Verifica que el guardia tenga la señal player_detected
		if guard.has_signal("player_detected"):
			guard.player_detected.connect(_on_player_detected)
			print("✅ Señal conectada con:", guard.name)
		else:
			print("⚠️ El guardia", guard.name, "no tiene la señal 'player_detected'.")


## --- Cuando cualquier guardia detecta al jugador ---
func _on_player_detected(player: Node) -> void:
	print("🚨 El jugador fue detectado por un guardia:", player)
	
	# Si el jugador tiene el modo definido en su script Player.gd
	if player.has_variable("mode") and player.has_enum("Mode"):
		player.mode = player.Mode.DEFEATED
	
	# Espera 2 segundos antes de reiniciar
	await get_tree().create_timer(2.0).timeout

	# 🔁 Reinicia el nivel con efecto de transición si existe SceneSwitcher
	if Engine.has_singleton("SceneSwitcher"):
		SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)
	else:
		get_tree().reload_current_scene()
		print("🔁 Nivel recargado (SceneSwitcher no encontrado)")
