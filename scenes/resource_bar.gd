extends Panel

func _ready() -> void:
	BattleManager.resource_updated.connect(update_resource)

func update_resource(amount: int) -> void:
	material.set_shader_parameter("value", float(amount) / BattleManager.max_resources - 0.01)
