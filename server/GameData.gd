extends Node

var skill_values = {
	"dash_speed": 0
}

func _ready():
	pass
	
	
func GetSkillDataFromServer(skill_name, requester) -> void:
	Server.FetchSkillData(skill_name, requester)
	
	
func InitializePlayerValues() -> void:
	GetSkillDataFromServer("dash_speed", get_instance_id())


func SetAbilityValue(value, skill_name):
	skill_values[skill_name] = value
	
func GetAbilityValue(skill_name) -> float:
	return skill_values[skill_name]
