extends RefCounted
class_name SpawnCore

static func spawn_placeholders(_main: Node) -> void:
	pass

static func spawn_reward_coins(main: Node, count: int, center: Vector3) -> void:
	if main.reward_spawner == null:
		return
	if main.reward_spawner.has_method("spawn_coins"):
		main.reward_spawner.call("spawn_coins", count, center)

static func spawn_reward_coins_stack(main: Node, count: int, center: Vector3) -> void:
	if main.reward_spawner == null:
		return
	if main.reward_spawner.has_method("spawn_coin_stack"):
		main.reward_spawner.call("spawn_coin_stack", count, center)
		return
	spawn_reward_coins(main, count, center)

static func spawn_reward_tokens(main: Node, count: int, texture_path: String, center: Vector3) -> Array:
	if main.reward_spawner == null:
		return []
	if main.reward_spawner.has_method("spawn_tokens"):
		return main.reward_spawner.call("spawn_tokens", count, texture_path, center)
	return []
