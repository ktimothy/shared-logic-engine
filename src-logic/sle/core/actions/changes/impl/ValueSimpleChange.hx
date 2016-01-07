package sle.core.actions.changes.impl;

import sle.shim.ActionType;

import sle.core.actions.changes.base.SimpleChangeBase;
import sle.core.models.ValueBase;

@:final
class ValueSimpleChange extends SimpleChangeBase
{
    private var _oldValue:Dynamic;

    public function new(model:ValueBase, propName:String, actionType:ActionType, oldValue:Dynamic, newValue:Dynamic)
    {
        super(model, propName, actionType, newValue);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        Reflect.callMethod(_model, Reflect.field(_model, 'set_' + _propName), [_oldValue]);
    }
}
