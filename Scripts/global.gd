extends Node

var gravity = 1500.0

var unlocked_abilities = {
	"wall_jump":false,
	"double_jump":false,
	"dash":false
}

func unlock_ability(skill_name: String):
	if unlocked_abilities.has(skill_name):
		unlocked_abilities[skill_name] = true
	else:
		push_error("Tentou desbloquear uma habilidade que não existe")
