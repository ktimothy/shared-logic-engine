package sle.shim;

interface IEnvironment
{
    function getTime():Float;
    function createExchange(type:String, clientParams:Dynamic, serverParams:Dynamic):Void;
    function useExchange(type:String, id:Int):Dynamic;
    function log(message:String):Void;
    function isActionAllowed(type:String):Bool;
    function commit():Dynamic;
    function rollback():Void;
}
