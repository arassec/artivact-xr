extends Node


func update(item: ArtivactItem):
	var descriptionLabel = find_child("DescriptionLabel")
	if descriptionLabel != null:
		descriptionLabel.text = item.description.translate()

	var categoryTabs = find_child("CategoryPropertiesTabContainer")
	for tab in categoryTabs.get_children():
		categoryTabs.remove_child(tab)
		tab.queue_free()
		
	var propertyCategories = CollectionStore.get_artivact_content_json().propertyCategories
	for propertyCategory in propertyCategories:
		var propertyContainer = _create_property_category_tab_content(propertyCategory, item)
		categoryTabs.add_child(propertyContainer)


func _create_property_category_tab_content(propertyCategory: Variant, itemDataInput: Variant):
	var marginContainer = MarginContainer.new()
	marginContainer.name = propertyCategory.translate()
	marginContainer.add_theme_constant_override("margin_left", 20)
	marginContainer.add_theme_constant_override("margin_top", 20)
	
	var categoryContainer = GridContainer.new()
	categoryContainer.columns = 2
	categoryContainer.add_theme_constant_override("h_separation", 25)
	categoryContainer.add_theme_constant_override("v_separation", 10)

	for propertyDefinition in propertyCategory.properties:
		var propertyKeyLabel = Label.new()
		propertyKeyLabel.text = propertyDefinition.translate()
		propertyKeyLabel.add_theme_font_size_override("font_size", 24)
		categoryContainer.add_child(propertyKeyLabel)

		if itemDataInput.properties.has(propertyDefinition.id):
			var propertyValueLabel = Label.new()
			propertyValueLabel.text = itemDataInput.properties[propertyDefinition.id].translate()
			propertyValueLabel.add_theme_font_size_override("font_size", 24)
			categoryContainer.add_child(propertyValueLabel)
		else:
			var emptyLabel = Label.new();
			categoryContainer.add_child(emptyLabel);

	marginContainer.add_child(categoryContainer)

	return marginContainer
