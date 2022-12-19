extends Entity


var player_velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO

var dash = load_ability("Dash")

func _ready():
	var overlay = load("res://utilities/debug_overlay/debug_overlay.tscn").instantiate()
	add_child(overlay)
	overlay.add_value("Health", self, "current_health", false)
	overlay.add_value("Stamina", self, "current_stamina", false)
	overlay.add_value("Mana", self, "current_mana", false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#GameData.InitializePlayerValues()


## This function handles the mouse click events and spring arm movement
func _unhandled_input(event):
	
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("toggle_mouse_captured"):
		$PauseMenu.pause()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	
	if Input.is_action_just_pressed("shift"):
		dash.execute(self, get_direction(get_input_vector()), GameData.skill_values["dash_speed"])


## This is the physics process function that runs each frame
## All changes to player position / movement need to be run here
func _physics_process(delta):
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	move_and_slide()
	jump()
	apply_controller_rotation()
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-75), deg_to_rad(75))
	regen_health(delta)
	regen_stamina(delta)
	regen_mana(delta)

	

