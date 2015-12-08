package sle.core.actions;

import sle.shim.ActionDump;

import sle.core.Utils;

class Event implements IAction
{
    public var type(default, null):ActionType;

    private var _name:String;
    private var _params:Dynamic;

    public function new(name:String, params:Dynamic = null)
    {
        _name = name;
        _params = params;

        this.type = ActionType.EVENT;
    }

    public function rollback():Void
    {
        // do nothing
    }

    public function toObject():ActionDump
    {
        return {
            path: [_name],
            newValue: _params,
            opName: this.type
        };
    }

    #if debug
    public function toString():String
    {
        return Utils.hash(this.toObject());
    }
    #end
}
