extends Node3D

var player_spawn = preload("res://scripts/entity_scripts/Player/PlayerTemplate.tscn")

func _ready():
	Server.MapNodeReady()


func SpawnNewPlayer(player_id, spawn_position):
	print("Map node spawing new player: " + str(player_id))
	var new_player = player_spawn.instance()
	new_player.postiion = spawn_position
	new_player.name = str(player_id)
	get_node("/root/Map/OtherPlayer").add_child(new_player)
		
		
func DespawnPlayer(player_id):
	get_node("/root/Map/OtherPlayer/" + str(player_id)).queue_free()
