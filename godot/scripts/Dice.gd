extends RigidBody3D

var _faces: Array = []
@onready var hit_sound: AudioStreamPlayer3D = $HitSound
var _last_hit_time_ms: int = 0
const HIT_COOLDOWN_MS := 120

func _ready() -> void:
	# Faces with their local normals (pointing outward from cube center)
	_faces = [
		{"node": $FaceTop, "value": 2, "name": "2", "local_normal": Vector3(0, 1, 0)},
		{"node": $FaceBottom, "value": 6, "name": "6", "local_normal": Vector3(0, -1, 0)},
		{"node": $FaceFront, "value": 5, "name": "5", "local_normal": Vector3(0, 0, 1)},
		{"node": $FaceBack, "value": 1, "name": "1", "local_normal": Vector3(0, 0, -1)},
		{"node": $FaceRight, "value": 3, "name": "3", "local_normal": Vector3(1, 0, 0)},
		{"node": $FaceLeft, "value": 4, "name": "4", "local_normal": Vector3(-1, 0, 0)},
	]
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == null or body.name != "Table":
		return
	var now := Time.get_ticks_msec()
	if now - _last_hit_time_ms < HIT_COOLDOWN_MS:
		return
	_last_hit_time_ms = now
	if hit_sound != null:
		hit_sound.play()

func _get_global_normal(face: Dictionary) -> Vector3:
	# Transform local normal to global space using dice rotation
	var local_normal = face["local_normal"]
	var global_normal = transform.basis * local_normal
	return global_normal.normalized()

func get_top_value() -> int:
	var best_dot := -2.0  # dot product range is [-1, 1]
	var best_value := 1
	var best_name := ""
	
	# UP vector in world space (positive Y)
	var up = Vector3.UP
	
	for entry in _faces:
		var global_normal = _get_global_normal(entry)
		# dot product tells us how parallel the normal is to UP
		# highest dot product = most "pointing up" = top face
		var dot = global_normal.dot(up)
		if dot > best_dot:
			best_dot = dot
			best_value = entry["value"]
			best_name = entry["name"]
	
	print("Top face: %s (value: %d, dot: %.3f)" % [best_name, best_value, best_dot])
	return best_value

func get_top_name() -> String:
	var best_dot := -2.0
	var best_name := ""
	var up = Vector3.UP
	
	for entry in _faces:
		var global_normal = _get_global_normal(entry)
		var dot = global_normal.dot(up)
		if dot > best_dot:
			best_dot = dot
			best_name = entry["name"]
	
	return best_name
