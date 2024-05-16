@tool 
class_name MiniScriptPlugin extends EditorPlugin

func _enter_tree():
    if Engine.is_editor_hint():
        var script = load("res://GDScript/addons/miniscript/src/ScriptEngine.gd");
        var texture:Texture2D = load("res://addons/miniscript-cs/icon.png");
        add_custom_type("ScriptEngine", "Node", script, texture);

func _exit_tree():
    remove_custom_type ("ScriptEngine");