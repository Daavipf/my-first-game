extends Node

var gravity = 1500.0

var unlocked_abilites = {
	"wall_jump":false,
	"double_jump":false,
	"dash":false
}

func unlock_ability(skill_name: String):
	if unlocked_abilites.has(skill_name):
		unlocked_abilites[skill_name] = true
	else:
		push_error("Tentou desbloquear uma habilidade que não existe")
