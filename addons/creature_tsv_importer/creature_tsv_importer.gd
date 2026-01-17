@tool
extends EditorPlugin

## Editor plugin to import creature data from a TSV file
## Expected TSV format: Name | Foe/Foefriend
## Creates or overwrites CharacterData resource files in the characters/data folder

const CharacterDataClass = preload("res://assets/characters/data/character_data.gd")

var file_dialog: FileDialog


func _enter_tree() -> void:
	# Add a menu item to access the importer
	add_tool_menu_item("Import Creatures from TSV", _open_import_dialog)


func _exit_tree() -> void:
	remove_tool_menu_item("Import Creatures from TSV")
	if file_dialog:
		file_dialog.queue_free()


func _open_import_dialog() -> void:
	print("Opening import dialog...")
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.tsv ; TSV Files"]
	file_dialog.file_selected.connect(_on_tsv_file_selected.bindv([]), CONNECT_ONE_SHOT)
	file_dialog.files_selected.connect(_on_tsv_files_selected, CONNECT_ONE_SHOT)
	file_dialog.canceled.connect(_on_dialog_canceled, CONNECT_ONE_SHOT)
	get_editor_interface().get_base_control().add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.7)
	print("Dialog opened")


func _on_tsv_file_selected(path: String) -> void:
	print("File selected signal received: ", path)
	_process_tsv([path])


func _process_tsv(paths: PackedStringArray) -> void:
	if paths.is_empty():
		print("No paths provided")
		return
	
	var tsv_path: String = paths[0]
	print("Opening TSV file: ", tsv_path)
	var file: FileAccess = FileAccess.open(tsv_path, FileAccess.READ)
	
	if file == null:
		printerr("Failed to open TSV file: ", tsv_path)
		return
	
	print("File opened successfully, starting import...")
	var data_dir: String = "res://assets/characters/data/"
	var import_count: int = 0
	var skip_count: int = 0
	
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		
		# Skip empty lines and header lines
		if line.is_empty() or line.begins_with("#"):
			continue
		
		print("Processing line: ", line)
		var columns: PackedStringArray = line.split("\t")
		print("Columns: ", columns)
		
		# Validate columns
		if columns.size() < 2:
			push_warning("Skipping invalid line (not enough columns): ", line)
			skip_count += 1
			continue
		
		var creature_name: String = columns[0].strip_edges()
		var foe_type: String = columns[1].strip_edges().to_lower()
		
		if creature_name.is_empty():
			skip_count += 1
			continue
		
		# Create or load CharacterData
		var filename: String = creature_name.to_lower().replace(" ", "_") + ".tres"
		var resource_path: String = data_dir + filename
		
		print("Creating/updating: ", resource_path)
		var character_data: CharacterDataClass
		
		if ResourceLoader.exists(resource_path):
			# Load existing resource
			print("  Loading existing resource")
			character_data = ResourceLoader.load(resource_path)
		else:
			# Create new resource
			print("  Creating new resource")
			character_data = CharacterDataClass.new()
		
		# Update attributes from TSV
		character_data.name = creature_name
		character_data.initially_hostile = (foe_type == "foe")
		print("  Name: ", creature_name, " | Hostile: ", character_data.initially_hostile)
		
		# Save the resource
		var error: Error = ResourceSaver.save(character_data, resource_path)
		
		if error == OK:
			import_count += 1
			print("  ✓ Created/Updated: ", resource_path)
		else:
			push_error("  ✗ Failed to save resource: ", resource_path, " (Error code: ", error, ")")
			skip_count += 1
	
	print("\nImport Summary:")
	print("  Imported: ", import_count)
	print("  Skipped: ", skip_count)
	
	# Refresh the file system
	get_editor_interface().get_resource_filesystem().scan()
	print("File system refreshed")


func _on_dialog_canceled() -> void:
	print("Dialog was canceled")


func _on_tsv_files_selected(paths: PackedStringArray) -> void:
	print("Files selected signal received: ", paths)
	_process_tsv(paths)
