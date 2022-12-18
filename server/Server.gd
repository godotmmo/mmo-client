extends Node

var network = ENetMultiplayerPeer.new()
var ip = "godotmmo.playit.gg"
#var ip = "127.0.0.1"

var port = 43578
var serverID = 1


func _ready():
	ConnectToServer()
	

func ConnectToServer():
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	print("Set multi peer")
	
	network.peer_disconnected.connect(_OnConnectionFailed)
	network.peer_connected.connect(_OnConnectionSucceeded)
	#print(network.get_connection_status())
	
#func _process(delta):
#	if network.get_connection_status() == 2:
#		print("connected")
	
	
func _OnConnectionFailed(server_id):
	print("Failed to connect")
	
	
func _OnConnectionSucceeded(server_id):
	print("Succesfully connected to server id: %d" % server_id)
	

@rpc(call_local)
func FetchSkillData(skill_name, requester):
	rpc_id(serverID, "FetchSkillData", skill_name, requester)
	

@rpc
func ReturnSkillData(skill_data, skill_name, requester):
	instance_from_id(requester).SetAbilityValue(skill_data, skill_name)



