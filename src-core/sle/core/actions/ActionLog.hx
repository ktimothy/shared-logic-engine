package sle.core.actions;

import sle.shim.ActionDump;

@:allow(sle.core.models.ValueBase)
@:allow(sle.core.ContextBase)
@:allow(sle.core.queries.Queries)
class ActionLog
{
    private static var _loggingEnabled:Bool = true;
    private static var _valueWriteEnabled:Bool = true;
    private static var _actions:Array<IAction> = [];

    public static function rollback()
    {
        ActionLog._loggingEnabled = false;

        var len = _actions.length;
        var action:IAction = null;

        while (len-- > 0)
        {
            action = _actions[len];

            if (action.type != ActionType.EVENT) action.rollback();
        }

        _actions = [];

        ActionLog._loggingEnabled = true;
    }

    inline public static function sendEvent(name:String, params:Dynamic):Void
    {
        _actions.push(new Event(name, params));
    }

    private static function commit():Array<ActionDump>
    {
        var result:Array<ActionDump> = [];

        for (action in _actions)
        {
            result.push(action.toObject());
        }

        _actions = [];

        return result;
    }

    #if tests
    public static function _commit():Array<ActionDump>
    {
        return commit();
    }
    #end

    #if debug
    private static function calculateActionsHash():String
    {
        var result = '';

        for (action in _actions)
        {
            result += '${action.toString()}';
        }

        return result;
    }
    #end
}
