extends Node3D

#@export var dash_speed : float = 40

func execute(s, direction, dash_speed) -> void:
	if s.current_stamina >= 20 and s.velocity != Vector3.ZERO and dash_speed != 0:
		s.velocity.x = direction.x * dash_speed
		s.velocity.z = direction.z * dash_speed
		s.current_stamina -= 20
