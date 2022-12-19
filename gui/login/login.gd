extends Control

@onready var username_input = get_node("NinePatchRect/HBoxContainer/VBoxContainer/Username")
@onready var userpassword_input = get_node("NinePatchRect/HBoxContainer/VBoxContainer/Password")
@onready var login_button = get_node("NinePatchRect/HBoxContainer/VBoxContainer/LoginButton")

func _on_LoginButton_pressed():
	print("pressed")
	pass



func _on_login_button_button_down():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide valid username and password")
	else:
		login_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting to login")
		Gateway.ConnectToServer(username, password)
