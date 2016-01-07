package sle.core.actions;

import sle.shim.ActionType;

interface IAction
{
    var type(default, null):ActionType;

    function rollback():Void;
    function toObject():Dynamic;

    #if debug
    function toString():String;
    #end
}
