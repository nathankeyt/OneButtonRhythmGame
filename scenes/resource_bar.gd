extends ProgressBar

func _ready() -> void:
	BattleManager.resource_updated.connect(update_resource)

func update_resource(amount: int) -> void:
	value = amount
