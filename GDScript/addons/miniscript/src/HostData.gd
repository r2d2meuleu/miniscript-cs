class HostData
{
    var Node:Node:
        get:
            return Node
    var Node2D:Node2D:
        get:
            return Node as Node2D
    var Node3D:Node3D:
        get:
            return Node as Node3D

    var Engine:ScriptEngine { get; }

    func _init(n:Node , e:ScriptEngine)
    {
        Node = n;
        Engine = e;
    }
}