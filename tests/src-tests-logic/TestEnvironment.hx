package ;

import sle.shim.IEnvironment;

class TestEnvironment implements IEnvironment
{
    public function new() {}

    public function getTime():Float { return 0; }

    public function createExchange(type:String, clientParams:Dynamic, serverParams:Dynamic):Void {}

    public function useExchange(type:String, id:Int):Dynamic { return null; }

    public function log(message:String):Void {}

    public function isActionAllowed(type:String):Bool { return false; }

    public function commit():Dynamic { return null; }

    public function rollback():Void {}
}