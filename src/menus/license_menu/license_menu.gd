class_name LicenseMenu
extends Menu

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")
const CANCEL_ACTION = &"ui_cancel"
const LICENSE_NAME_SEPARATOR = " & "
const LICENSE_TEXT_SEPARATOR = "\n=========================\n"
const META_INDEX_NAME = &"index"
const PATHS_SEPARATOR = "\n"
const TEXT_PROPERTY = &"text"
const TREE_ITEM_COLUMN = 0
const TREE_COLUMN_CLIP_CONTENT = true
const URL_FORMAT_STRING = "[url]%s[/url]"

@export var tree: Tree
@export var component_name: Label
@export var version: Label
@export var description: RichTextLabel
@export var contact: RichTextLabel
@export var contact_container: CanvasItem
@export var web: RichTextLabel
@export var web_container: CanvasItem
@export var paths: RichTextLabel
@export var paths_container: CanvasItem
@export var license_name: RichTextLabel
@export var license_text: RichTextLabel

var category_cache: Dictionary
var licenses: Array[Component] = []

@onready var text_scroll_bar: ScrollBar = license_text.get_v_scroll_bar()


func _ready() -> void:
	super()
	license_text.gui_input.connect(_on_license_text_gui_input)
	license_text.meta_clicked.connect(_on_meta_clicked)
	tree.item_activated.connect(_on_item_activated)
	tree.item_selected.connect(_on_item_selected)
	tree.set_column_clip_content(TREE_ITEM_COLUMN, TREE_COLUMN_CLIP_CONTENT)
	web.meta_clicked.connect(_on_meta_clicked)
	var result: Licenses.LoadResult = Licenses.load(
			Licenses.get_license_data_filepath()
	)
	if result.err_msg:
		return

	licenses = result.components
	licenses.append_array(Licenses.get_required_engine_components())
	licenses.sort_custom(Licenses.compare_components_ascending)

	var root: TreeItem = tree.create_item()
	for license in licenses:
		add_component(license, root, licenses.find(license))


func add_component(component: Component, root: TreeItem, index: int) -> void:
	var parent: TreeItem = create_category_item(component.category, root)
	add_tree_item(component, index, parent)


func add_tree_item(component: Component, index: int, parent: TreeItem) -> void:
	var item: TreeItem = tree.create_item(parent)
	item.set_meta(META_INDEX_NAME, index)
	item.set_text(TREE_ITEM_COLUMN, component.name)
	item.set_text_overrun_behavior(
			TREE_ITEM_COLUMN, TextServer.OVERRUN_TRIM_ELLIPSIS
	)


func create_category_item(category: String, root: TreeItem) -> TreeItem:
	if category in category_cache:
		return category_cache[category]

	var category_item: TreeItem
	category_item = tree.create_item(root)
	category_item.set_text(TREE_ITEM_COLUMN, category)
	category_cache[category] = category_item
	return category_item


func focus_tree() -> void:
	if not is_node_ready():
		await ready

	# Find first item that isn't a category.
	var item: TreeItem = tree.get_root()
	while item.get_child_count() > 0:
		item = item.get_first_child()

	tree.grab_focus()
	tree.set_selected(item, TREE_ITEM_COLUMN)


func set_component(component: Component) -> void:
	pressed_sound_requested.emit()
	component_name.text = component.name

	version.text = component.version
	version.visible = not version.text.is_empty()

	description.text = component.description
	description.visible = not description.text.is_empty()

	contact.text = component.contact
	contact_container.visible = not contact.text.is_empty()

	paths.text = PATHS_SEPARATOR.join(component.paths)
	paths_container.visible = not paths.text.is_empty()

	web.text = URL_FORMAT_STRING % component.web
	web_container.visible = not component.web.is_empty()

	license_name.clear()
	license_text.clear()
	text_scroll_bar.ratio = 0.0
	for index in range(len(component.licenses)):
		var license: Component.License = component.licenses[index]
		if index > 0:
			license_name.append_text(LICENSE_NAME_SEPARATOR)
			license_text.append_text(LICENSE_TEXT_SEPARATOR)

		license_name.append_text(license.name)
		license_text.append_text(license.get_license_text())


func _on_item_activated() -> void:
	var item: TreeItem = tree.get_selected()
	if item.has_meta(META_INDEX_NAME):
		license_text.grab_focus()

	else:
		item.collapsed = not item.collapsed


func _on_item_selected() -> void:
	var item: TreeItem = tree.get_selected()
	if not item.has_meta(META_INDEX_NAME):
		return

	set_component(licenses[item.get_meta(META_INDEX_NAME)])


func _on_license_text_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(CANCEL_ACTION):
		pressed_sound_requested.emit()
		tree.grab_focus()
		accept_event()

	elif event.is_action_pressed(&"ui_up"):
		text_scroll_bar.value -= text_scroll_bar.page
		license_text.accept_event()

	elif event.is_action_pressed(&"ui_down"):
		text_scroll_bar.value += text_scroll_bar.page
		license_text.accept_event()


func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))  # Open url in default browser.
