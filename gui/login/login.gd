extends Control

# UI state nodes
@onready var login_screen = get_node("Login")
@onready var create_account_screen = get_node("CreateAccount")
# login nodes
@onready var username_input = get_node("Login/HBoxContainer/VBoxContainer/Username")
@onready var userpassword_input = get_node("Login/HBoxContainer/VBoxContainer/Password")
@onready var login_button = get_node("Login/HBoxContainer/VBoxContainer/LoginButton")
@onready var create_account_button = get_node("Login/HBoxContainer/VBoxContainer/CreateUsernameButton")
# create new account nodes
@onready var create_username_input = get_node("CreateAccount/HBoxContainer/VBoxContainer/Username")
@onready var create_password_input = get_node("CreateAccount/HBoxContainer/VBoxContainer/Password2")
@onready var create_confirm_password_input = get_node("CreateAccount/HBoxContainer/VBoxContainer/ConfirmPassword")
@onready var confirm_button = get_node("CreateAccount/HBoxContainer/VBoxContainer/Confirm")
@onready var back_button = get_node("CreateAccount/HBoxContainer/VBoxContainer/Back")

func _on_LoginButton_pressed():
	print("pressed")
	pass


func _on_login_button_button_down():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide valid username and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username: String = username_input.get_text()
		var password: String = userpassword_input.get_text()
		print("Attempting to login")
		Gateway.ConnectToServer(username, password, false)


func _on_create_username_button_pressed():
	login_screen.hide()
	create_account_screen.show()


func _on_back_pressed():
	create_account_screen.hide()
	login_screen.show()


func _on_confirm_pressed():
	
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_password_input.get_text() == "":
		print("Please provide a valid password")
	elif create_confirm_password_input.get_text() == "":
		print("Please confirm your password")
	elif create_password_input.get_text() != create_confirm_password_input.get_text():
		print("Passwords do not match")
	elif create_password_input.get_text().length() <= 6:
		print("Password must be at least 7 characters long")
	else:
		print("Create username request sent")
		confirm_button.disabled = true
		back_button.disabled = true
		var username = create_username_input.get_text()
		var password = create_password_input.get_text()
		Gateway.ConnectToServer(username, password, true)
