extends Node

var gateway_client = ENetMultiplayerPeer.new()
var gateway_api: MultiplayerAPI = MultiplayerAPI.create_default_interface()

var ip: String = "december-antique.at.ply.gg"
var port: int = 44122

var username: String
var password: String
var peer_id

var cert = load("res://resources/certification/X509_Certificate.crt")



func _ready():
	pass
	
	
func _process(_delta):
	if !multiplayer.has_multiplayer_peer():
		return
	else:
		multiplayer.poll()

	
func ConnectToServer(_username, _password):
	username = _username
	password = _password
	
	# This defines our 'network' as a client peer
	gateway_client.create_client(ip, port)
	
	gateway_client.host.dtls_client_setup(cert, ip, false)
	
	# This creates a new multiplayer api instance on the current path and allows
	# for a secondary connection
	get_tree().set_multiplayer(gateway_api, get_path())
	gateway_api.set_multiplayer_peer(gateway_client)
	#print(multiplayer.get_multiplayer_peer().get_unique_id())
	gateway_api.connection_failed.connect(_OnConnectionFailed)
	gateway_client.peer_disconnected.connect(_OnConnectionDisconnected)
	gateway_api.connected_to_server.connect(_OnConnectionSucceeded)
	
	
func _OnConnectionFailed(_server_id):
	print("Failed to connect to gateway server")
	get_node("res://gui/login/login.tscn/NinePatchRect/HBoxContainer/VBoxContainer/LoginButton")
	pass


func _OnConnectionDisconnected(_server_id):
	print("Disconnected")
	
	
func _OnConnectionSucceeded():
	#print("Succesfully connected to gateway server id: %d" % server_id)
	LoginRequest(username, password)


@rpc(call_local)
func LoginRequest(_username, _password):
	#var peer_id = gateway.get_multiplayer_peer().get_unique_id()
	peer_id = 1
	print("Requesting login user. uid: " + str(peer_id))
	rpc_id(peer_id, "LoginRequest", _username, _password)
	username = ""
	password = ""


@rpc
func ReturnLoginRequest(result, token):
	print("results received")
	# if valid login request, set server token and connect to game server
	if result == true:
		Server.token = token
		Server.ConnectToServer()
	else:
		# if invalid login, unlock the login button
		print("Please provide a correct username and password")
		print(get_node("."))
		get_node("/root/login_screen/NinePatchRect/HBoxContainer/VBoxContainer/LoginButton").disabled = false
	multiplayer.disconnect("connection_failed", _OnConnectionFailed)
	gateway_client.disconnect("peer_disconnected", _OnConnectionDisconnected)
	gateway_api.disconnect("connected_to_server", _OnConnectionSucceeded)

	
	
