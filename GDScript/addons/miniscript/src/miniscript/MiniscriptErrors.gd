#	MiniScriptErrors.cs

# self file defines the exception hierarchy used by Miniscript.
# The core of the tree is self:

# 	MiniscriptException
# 		LexerException -- any error while finding tokens from raw source
# 		CompilerException -- any error while compiling tokens into bytecode
# 		RuntimeException -- any error while actually executing code.

# We have a number of fine-grained exception types within these,
# but they will always derive from one of those three (and ultimately
# from MiniscriptException).

class_name SourceLoc
    var context:string  # file name, etc. (optional)
    var lineNum:int

    func _init(context:string, lineNum:int)
    
        self.context = context
        self.lineNum = lineNum

    func ToString() -> String:
        return string.Format("[0line 1]", string.IsNullOrEmpty(context) ? "" : context + " ", lineNum)


class_name MiniscriptException extends Exception
    var  location:SourceLoc

    func MiniscriptException(message:string) : 
        base(message)

    func MiniscriptException(context:string, lineNum:int, message:string) : 
        base(message)
        location = new SourceLoc(context, lineNum)

    func MiniscriptException(message:string, inner:Exception) : 
        base(message, inner)
    #/ <summary>
    #/ Get a standard description of self error, including type and location.
    #/ </summary>
    func Description-> String:
        var desc:string = "Error: "
        if (self is LexerException) desc = "Lexer Error: "
        else if (self is CompilerException) desc = "Compiler Error: "
        else if (self is RuntimeException) desc = "Runtime Error: "
        desc += Message
        if (location != null) desc += " " + location
        return desc


class_name LexerException extends MiniscriptException
    func LexerException():
        base("Lexer Error")

    func LexerException(message:string) : base(message)

    func LexerException(message:string, Exception inner) : base(message, inner)


class_name CompilerException : MiniscriptException
    public CompilerException() : 
        base("Syntax Error")

    public CompilerException(message:string) : 
        base(message)

    public CompilerException(context:string, lineNum:int, message:string) : 
        base(context, lineNum, message)

    public CompilerException(message:string, Exception inner) : 
        base(message, inner)


class_name RuntimeException : MiniscriptException
    public RuntimeException() : base("Runtime Error")

    public RuntimeException(message:string) : base(message)

    public RuntimeException(message:string, Exception inner) : base(message, inner)


class_name IndexException : RuntimeException
    public IndexException() : base("Index Error (index out of range)")

    public IndexException(message:string) : base(message)

    public IndexException(message:string, Exception inner) : base(message, inner)


class_name KeyException : RuntimeException
    public KeyException(string key) : base("Key Not Found: '" + key + "' not found in map")

    public KeyException(message:string, Exception inner) : base(message, inner)


class_name TypeException : RuntimeException
    func TypeException() : 
        base("Type Error (wrong type for whatever you're doing)")

    func TypeException(message:string) : 
        base(message)

    func TypeException(message:string, Exception inner) : 
        base(message, inner)


class_name TooManyArgumentsException : RuntimeException
    func TooManyArgumentsException() : 
        base("Too Many Arguments")

    func TooManyArgumentsException(message:string) : 
        base(message)

    func TooManyArgumentsException(message:string, Exception inner) : 
        base(message, inner)


class_name LimitExceededException extends RuntimeException
    func LimitExceededException() : 
        base("Runtime Limit Exceeded")

    func LimitExceededException(message:string) : 
        base(message)

    func LimitExceededException(message:string, Exception inner) : 
        base(message, inner)


class_name UndefinedIdentifierException extends RuntimeException

    public UndefinedIdentifierException(string ident) : base(
    "Undefined Identifier: '" + ident + "' is unknown in self context")

    public UndefinedIdentifierException(message:string, Exception inner) : base(message, inner)


class_name UndefinedLocalException extends RuntimeException
    private UndefinedLocalException()         # don't call self version!

    public UndefinedLocalException(string ident) : base(
    "Undefined Local Identifier: '" + ident + "' is unknown in self context")

    public UndefinedLocalException(message:string, Exception inner) : base(message, inner)


class_name Check
    static func Range(int i, int min, int max, string desc = "index"):
        if (i < min || i > max):
            throw new IndexException(string.Format("Index Error: 0 (1) out of range (2 to 3)", desc, i, min, max))

    static func Type(Value val, System.Type requiredType, string desc = null):
        if (!requiredType.IsInstanceOfType(val)):
            string typeStr = val == null ? "null" : "a " + val.GetType()
            throw new TypeException(string.Format("got 0 where a 1 was required2", typeStr, requiredType, desc == null ? null : " (" + desc + ")"))