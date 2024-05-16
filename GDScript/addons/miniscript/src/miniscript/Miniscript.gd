class_name Error

enum Type{
    Syntax
}

var lineNum:int
var type:Type
var description:string

func _init( lineNum:int,  type:Type,  description:string = null)
    self.lineNum = lineNum;
    self.type = type;
    if (description == null):
        self.description = type.ToString()
    else
        self.description = description

static func Assert(bool condition):
    if (!condition)
        print("Internal assertion failed.")

class_name Script
    var errors:Array[Error]
    func Compile(string source):
        pass