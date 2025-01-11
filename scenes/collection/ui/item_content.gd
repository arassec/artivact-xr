extends Control

@export var TAB_MARGIN = 25
@export var FONT_SIZE = 16


func _init():
	# Register for relevant signals:
	SignalBus.register(SignalBus.SignalType.COLL_ITEM_UPDATE_DATA, _update_item_data)


func _exit_tree():
	# Deregister signals:
	SignalBus.deregister(SignalBus.SignalType.COLL_ITEM_UPDATE_DATA, _update_item_data)


####################################################################################################
# Move the cursor on input events.
####################################################################################################
func _input(event):
	if event is InputEventMouseMotion:
		# Move our cursor
		var mouse_motion : InputEventMouseMotion = event
		$Cursor.position = mouse_motion.position - Vector2(20, 5)


func _update_item_data(item: ArtivactItem):
	find_child("TitleLabel").text = item.title.translate()
	
	var tabContainer = find_child("ItemDataTabContainer")
	
	for tab in tabContainer.get_children():
		tabContainer.remove_child(tab)
		tab.queue_free()
	
	if item.description != null:
		var marginContainer = MarginContainer.new()
		marginContainer.name = "Description"
		marginContainer.add_theme_font_size_override("font_size", FONT_SIZE)
		marginContainer.add_theme_constant_override("margin_left", TAB_MARGIN)
		marginContainer.add_theme_constant_override("margin_top", TAB_MARGIN)

		var descriptionLabel = Label.new()
		descriptionLabel.text = item.description.translate()
		descriptionLabel.autowrap_mode = TextServer.AUTOWRAP_WORD
		descriptionLabel.custom_minimum_size = Vector2(500, 300)
		descriptionLabel.size = Vector2(500, 300)
		descriptionLabel.clip_text = true
		descriptionLabel.add_theme_font_size_override("font_size", FONT_SIZE)

		marginContainer.add_child(descriptionLabel)
		tabContainer.add_child(marginContainer)

	var propertyCategories = CollectionStore.get_artivact_properties_configuration_json().propertyCategories
	for propertyCategory in propertyCategories:
		var propertyContainer = _create_property_category_tab_content(propertyCategory, item)
		tabContainer.add_child(propertyContainer)


func _create_property_category_tab_content(propertyCategory: Variant, itemDataInput: Variant):
	var marginContainer = MarginContainer.new()
	marginContainer.name = propertyCategory.translate()
	marginContainer.add_theme_font_size_override("font_size", FONT_SIZE)
	marginContainer.add_theme_constant_override("margin_left", TAB_MARGIN)
	marginContainer.add_theme_constant_override("margin_top", TAB_MARGIN)
	
	var categoryContainer = GridContainer.new()
	categoryContainer.columns = 2
	categoryContainer.add_theme_constant_override("h_separation", 25)
	categoryContainer.add_theme_constant_override("v_separation", 10)

	for propertyDefinition in propertyCategory.properties:
		var propertyKeyLabel = Label.new()
		propertyKeyLabel.text = propertyDefinition.translate()
		propertyKeyLabel.add_theme_font_size_override("font_size", FONT_SIZE)
		categoryContainer.add_child(propertyKeyLabel)

		if itemDataInput.properties.has(propertyDefinition.id):
			var propertyValueLabel = Label.new()
			propertyValueLabel.text = itemDataInput.properties[propertyDefinition.id].translate()
			propertyValueLabel.add_theme_font_size_override("font_size", FONT_SIZE)
			categoryContainer.add_child(propertyValueLabel)
		else:
			var emptyLabel = Label.new();
			categoryContainer.add_child(emptyLabel);

	marginContainer.add_child(categoryContainer)

	return marginContainer
