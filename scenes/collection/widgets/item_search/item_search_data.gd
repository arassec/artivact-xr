extends Control

@export var TAB_MARGIN = 25
@export var FONT_SIZE = 32


func initialize(item: ArtivactItem):
	find_child("TitleLabel").text = item.title.translate()
	
	var tabContainer = find_child("ItemDataTabContainer")
		
	var itemDescription = item.description.translate()
	if itemDescription && itemDescription != "":
		var marginContainer = MarginContainer.new()
		marginContainer.name = tr("COLL_ITEM_DESCRIPTION")
		marginContainer.add_theme_constant_override("margin_left", TAB_MARGIN)
		marginContainer.add_theme_constant_override("margin_top", TAB_MARGIN)

		var descriptionLabel = Label.new()
		descriptionLabel.text = itemDescription
		descriptionLabel.autowrap_mode = TextServer.AUTOWRAP_WORD
		descriptionLabel.custom_minimum_size = Vector2(500, 300)
		descriptionLabel.size = Vector2(500, 300)
		descriptionLabel.clip_text = true
		descriptionLabel.add_theme_font_size_override("font_size", FONT_SIZE)

		marginContainer.add_child(descriptionLabel)
		tabContainer.add_child(marginContainer)

	var propertyCategories = CollectionStore.get_artivact_properties_configuration_json(CollectionStore.get_selected_collection()).propertyCategories
	for propertyCategory in propertyCategories:
		var propertyContainer = _create_property_category_tab_content(propertyCategory, item)
		tabContainer.add_child(propertyContainer)


func _create_property_category_tab_content(propertyCategory: Variant, itemDataInput: Variant):
	var marginContainer = MarginContainer.new()
	marginContainer.name = propertyCategory.translate()
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
