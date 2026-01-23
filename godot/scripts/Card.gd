extends Node3D

@export var color: Color = Color(0.2, 0.2, 0.2, 1.0)

@onready var mesh: MeshInstance3D = $Mesh

func _ready() -> void:
    if mesh.material_override is StandardMaterial3D:
        var mat := mesh.material_override as StandardMaterial3D
        mat.albedo_color = color
