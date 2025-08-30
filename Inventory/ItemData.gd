extends Resource
class_name ItemData

enum Type { COMMON, UNCOMMON, RARE }

@export var id: String
@export var name: String
@export var texture: Texture2D
@export var type: Type
@export var description: String
@export var stackable: bool = true
@export var max_stack_size: int = 64
