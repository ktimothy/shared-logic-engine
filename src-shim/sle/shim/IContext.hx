package sle.shim;

interface IContext
{
    public function fromObject(dump:Dynamic):Void;
    public function toObject():Dynamic;
    public function fromArray(dumpArray:Dynamic):Void;
    public function toArray():Dynamic;

    #if debug
    public function execute(name:String, params:Dynamic, ?hashToCheck:String):CommandResult;
    #else
    public function execute(name:String, params:Dynamic, ?hashToCheck:Float):CommandResult;
    #end

    public function query(queryName:String, ?params:Dynamic):QueryResult;
}