# Remove the class_name if it's already a global class
extends Resource

enum Type {COMMON, UNCOMMON, RARE, MAIN}

@export var id: String
@export var type: Type  
@export var name: String  
@export_multiline var description: String  
@export var texture: Texture2D
@export var stackable: bool = true
@export var max_stack_size: int = 64

# Remove _ready and _process functions since Resources don't need them
