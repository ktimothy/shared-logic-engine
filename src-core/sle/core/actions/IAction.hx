package sle.core.actions;

interface IAction
{
    var type(default, null):ActionType;

    function rollback():Void;
    function toObject():Dynamic;

    #if debug
    function toString():String;
    #end
}
