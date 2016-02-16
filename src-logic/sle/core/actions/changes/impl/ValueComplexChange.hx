package sle.core.actions.changes.impl;

import sle.core.actions.changes.base.ComplexChangeBase;
import sle.core.models.ValueBase;

import sle.shim.ActionType;
import sle.shim.Error;

@:final
class ValueComplexChange extends ComplexChangeBase<String, ValueBase>
{
    private var _oldValue:ValueBase;

    public function new(model:ValueBase, key:String, actionType:ActionType, oldValue:ValueBase, newValue:ValueBase, expectedTypeName:String)
    {
        super(model, key, actionType, newValue, expectedTypeName);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        switch (this.type)
        {
            case ActionType.PROP_CHANGE:
                Reflect.callMethod(_model, Reflect.field(_model, 'set_' + _key), [_oldValue]);

            default:
                throw new Error('This action is not supported in ValueComplexChange: ${this.type}!');
        }
    }
}
