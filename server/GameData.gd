extends Node

var skill_values: Dictionary = {
	"dash_speed": 0.0
}

	
func GetSkillDataFromServer(skill_name: String, requester: int) -> void:
	Server.FetchSkillData(skill_name, requester)
	
	
func InitializePlayerValues() -> void:
	GetSkillDataFromServer("dash_speed", get_instance_id())


func SetAbilityValue(value: String, skill_name: String) -> void:
	skill_values[skill_name] = value
	
func GetAbilityValue(skill_name: String) -> float:
	return skill_values[skill_name]
	
