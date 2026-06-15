# res://burger.gd
extends Node3D

@export var coin_reward := 200
@export var slice_offset := 0.18
@export var slice_rotation := 12.0
@export var slice_duration := 0.15

var sliced := false
var shop_manager: Node
var _mesh_instances: Array[MeshInstance3D] = []

@onready var cut_area: Area3D = $Area3D


func _ready() -> void:
	add_to_group("sliceable")
	shop_manager = get_tree().get_first_node_in_group("shop_manager")
	_collect_mesh_instances(self)

	if cut_area:
		cut_area.body_entered.connect(_on_cut_area_body_entered)


func _collect_mesh_instances(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			_mesh_instances.append(child)
		_collect_mesh_instances(child)


func _on_cut_area_body_entered(body: Node) -> void:
	if sliced:
		return

	if body == null:
		return

	if body is CharacterBody3D:
		var multiplier := 1.0
		var combo_value = body.get("combo_multiplier")
		if combo_value is int or combo_value is float:
			multiplier = float(combo_value)
		slice(multiplier)


func slice(multiplier := 1.0) -> void:
	if sliced:
		return

	sliced = true

	if cut_area:
		cut_area.monitoring = false
		cut_area.monitorable = false

	if shop_manager == null:
		shop_manager = get_tree().get_first_node_in_group("shop_manager")

	if shop_manager and shop_manager.has_method("add_coins"):
		shop_manager.add_coins(int(coin_reward * multiplier))

	if _mesh_instances.is_empty():
		queue_free()
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	for i in range(_mesh_instances.size()):
		var mesh := _mesh_instances[i]
		if not is_instance_valid(mesh):
			continue

		var direction := 1.0 if (i % 2 == 0) else -1.0
		var target_position := mesh.position + Vector3(0.0, slice_offset * direction, 0.0)
		var target_rotation := mesh.rotation_degrees + Vector3(0.0, 0.0, slice_rotation * direction)

		tween.tween_property(mesh, "position", target_position, slice_duration)
		tween.tween_property(mesh, "rotation_degrees", target_rotation, slice_duration)

	await tween.finished
	await get_tree().create_timer(0.08).timeout
	queue_free()
