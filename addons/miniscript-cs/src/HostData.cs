using Godot;

namespace Miniscript;

public class HostData
{
    public Node Node { get; }
    public ScriptEngine Engine { get; }

    public HostData(Node n, ScriptEngine e)
    {
        Node = n;
        Engine = e;
    }
}