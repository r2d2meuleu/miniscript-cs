class_name ScriptEngine extends Node
    static var intrinsicsAdded:bool = false
    static var librariesLoaded:bool = false
    static libraries:String

    @export_group("Settings")
    @export var Node parent
    @export var compileOnSet:bool = true

    @export var discoverIntrinsics:bool = true

    @export var  maxExecutionTime:float = 0.02f


    @export_dir string additionalLibraries

    var _script

    @export_multiline var Script:string:
        get => _script
        set:
            _script = value
            if (compileOnSet && interpreter != null):
                Compile()
            
    var interpreter:Interpreter
    var  hostData:HostData

# todo how to manage this ?
#   var Running() => interpreter.Running() 
#   var bool Done() => interpreter.done

    static void AddIntrinsics(discover:bool):
        if (intrinsicsAdded) return
        intrinsicsAdded = true
        if (!discover) return
        var methods = AppDomain.CurrentDomain.GetAssemblies().ToList()
        # TODO update this lol
            .SelectMany(x => x.GetTypes())
            .Where(x => x.IsClass)
            .SelectMany(x => x.GetMethods(BindingFlags.Nonfunc | BindingFlags.Static | BindingFlags.func))
            .Where(x => x.GetCustomAttributes(typeof(Discover), false).FirstOrDefault() != null)

        GD.Print($"Discovered methods: :methods.Count()")
        foreach (var m in methods):
            m.Invoke(null, new object[]:)
        
    func _init():
        LoadLibraries()
        AddIntrinsics(discoverIntrinsics)

        parent ??= GetParent()
        hostData = createDataObject()

        SetupInterpreter()
    

    func LoadLibraries() -> String:
        if (!librariesLoaded):
            librariesLoaded = true
            var scripts = new List<string>()

            scanDir(scripts, "res://addons/miniscript-cs/src/lib/")
            if (!string.IsNullOrWhiteSpace(additionalLibraries)):
                scanDir(scripts, additionalLibraries)
            

            libraries = string.Join("\n\n", scripts)
        

        return libraries
    

    static scanDir(List<string> scripts, string path):
        if (!path.EndsWith("/")):
            path += "/"
        
        using var dir = DirAccess.Open(path)
        if (dir != null):
            dir.ListDirBegin()

            string fileName = dir.GetNext()
            while (fileName != ""):
                GD.Print($"ScriptEngine: found library :fileName")
                var content = FileAccess.GetFileAsString(path + fileName)
                scripts.Add(content)
                fileName = dir.GetNext()

    func SetupInterpreter():
        interpreter = new Interpreter()
        interpreter.hostData = hostData
        interpreter.standardOutput = OnStdOut
        interpreter.errorOutput = onErrOut
        Compile()
    

    func Compile():
        interpreter.Reset(LoadLibraries() + "\n\n" + Script)
        interpreter.Compile()
    
    func Run():
        interpreter.RunUntilDone(maxExecutionTime)
    
    func Restart():
        interpreter.Restart()
    
    func Stop():
        interpreter.Stop()
    
    func OnStdOut(string s, bool eol):
        GD.Print(s)
    
    func onErrOut(string s, bool eol):
        GD.PrintErr(s)
    
    func HostData createDataObject():
        return new HostData(parent, this)
    
    func Publish(string functionName, ValMap args = null):
        if (interpreter == null || !interpreter.Running()) return

        Value handler = interpreter.GetGlobalValue(functionName)
        if (handler == null) :
            GD.PrintErr($"ScriptEngine: :functionName function does not exist")
            return

        var eventList = interpreter.GetGlobalValue("_events") as ValList
        if (eventList == null):
            eventList = new ValList()
            interpreter.SetGlobalValue("_events", eventList)

        ValMap newEvent = new ValMap()
        newEvent["invoke"] = handler
        newEvent["args"] = args ?? new ValMap()

        eventList.values.Add(newEvent)

    func ClearEvents():
        var eventList = interpreter.GetGlobalValue("_events") as ValList
        if (eventList != null):
            eventList.values.Clear()