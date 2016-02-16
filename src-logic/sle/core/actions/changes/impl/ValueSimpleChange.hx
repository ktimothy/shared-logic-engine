package sle.core.actions.changes.impl;

import sle.core.actions.changes.base.SimpleChangeBase;
import sle.core.models.ValueBase;

import sle.shim.ActionType;
import sle.shim.Error;

@:final
class ValueSimpleChange extends SimpleChangeBase<String, Dynamic>
{
    private var _oldValue:Dynamic;

    public function new(model:ValueBase, key:String, actionType:ActionType, oldValue:Dynamic, newValue:Dynamic)
    {
        super(model, key, actionType, newValue);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        switch (this.type)
        {
            case ActionType.PROP_CHANGE:
                Reflect.callMethod(_model, Reflect.field(_model, 'set_' + _key), [_oldValue]);

            default:
                throw new Error('This action is not supported in ValueSimpleChange: ${this.type}!');
        }
    }
}
