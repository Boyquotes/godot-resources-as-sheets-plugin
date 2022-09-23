tool
extends SheetsDockEditor

onready var recent_container := $"HBoxContainer/Control2/HBoxContainer/HFlowContainer"
onready var contents_label := $"HBoxContainer/HBoxContainer/Panel/Label"
onready var button_box := $"HBoxContainer/HBoxContainer/Control/VBoxContainer/HBoxContainer"
onready var value_input := $"HBoxContainer/HBoxContainer/Control/VBoxContainer/LineEdit"

var _stored_value
var _stored_type := 0


func _ready():
	if recent_container.get_child(1).get_item_count() < 3:
		recent_container.get_child(1).add_item("Add")
		recent_container.get_child(1).add_item("Erase")
		recent_container.get_child(1).add_item("Delete From Recent")
		recent_container.get_child(1).select(0)


func try_edit_value(value, type, propert_hint) -> bool:
	if (
		type != TYPE_ARRAY and type != TYPE_STRING_ARRAY
		and type != TYPE_INT_ARRAY and type != TYPE_REAL_ARRAY
	):
		return false

	_stored_type = type
	_stored_value = value.duplicate()  # Generic arrays are passed by reference
	contents_label.text = str(value)
	
	var is_generic_array = _stored_type == TYPE_ARRAY
	button_box.get_child(1).visible = is_generic_array or _stored_type == TYPE_STRING_ARRAY
	button_box.get_child(2).visible = is_generic_array or _stored_type == TYPE_INT_ARRAY
	button_box.get_child(3).visible = is_generic_array or _stored_type == TYPE_REAL_ARRAY
	button_box.get_child(4).visible = is_generic_array

	return true


func _add_value(value):
	_stored_value.append(value)
	var values = sheet.get_edited_cells_values()
	var cur_value
	for i in values.size():
		cur_value = values[i]
		cur_value.append(value)
		values[i] = cur_value

	sheet.set_edited_cells_values(values)


func _remove_value(value):
	_stored_value.erase(value)
	var values = sheet.get_edited_cells_values()
	var cur_value
	for i in values.size():
		cur_value = values[i]
		if cur_value.has(value): # erase() not defined in PoolArrays
			cur_value.remove(cur_value.find(value))
		
		values[i] = cur_value

	sheet.set_edited_cells_values(values)


func _add_recent(value):
	for x in recent_container.get_children():
		if x.text == str(value):
			return

	var node := Button.new()
	node.text = str(value)
	node.connect("pressed", self, "_on_recent_clicked", [node, value])
	recent_container.add_child(node)


func _on_recent_clicked(button, value):
	var val = recent_container.get_child(1).selected
	value_input.text = str(value)
	if val == 0:
		_add_value(value)

	if val == 1:
		_remove_value(value)

	if val == 2:
		button.queue_free()


func _on_Remove_pressed():
	_remove_value(str2var(value_input.text))


func _on_ClearRecent_pressed():
	for i in recent_container.get_child_count():
		if i == 0: continue
		recent_container.get_child(i).free()
	

func _on_Float_pressed():
	_add_value(float(value_input.text))


func _on_Int_pressed():
	_add_value(int(value_input.text))


func _on_String_pressed():
	_add_value(value_input.text)
	_add_recent(value_input.text)


func _on_Variant_pressed():
	_add_value(str2var(value_input.text))
