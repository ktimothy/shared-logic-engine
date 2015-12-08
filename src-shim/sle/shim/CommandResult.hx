package sle.shim;

typedef CommandResult = {
    public var name:String;
    public var params:Dynamic;
    public var actions:Array<ActionDump>;
    public var exchangables:Array<Dynamic>;
    
    public var error: {
        message: String,
        stack: String
    };
    
    #if debug
    public var hash:String;
    #else
    public var hash:Float;
    #end
}
