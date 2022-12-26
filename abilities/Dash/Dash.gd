extends Node3D

#@export var dash_speed : float = 40

func execute(s: Node, direction: Vector3, dash_speed: float) -> void:
	if s.current_stamina >= 20 and s.velocity != Vector3.ZERO and dash_speed != 0:
		s.velocity.x = direction.x * dash_speed
		s.velocity.z = direction.z * dash_speed
		s.current_stamina -= 20
