package sle.core.actions.changes.impl;

import sle.shim.ActionType;
import sle.shim.Error;

import sle.core.models.collections.ComplexValueMapBase;
import sle.core.models.ValueBase;
import sle.core.actions.changes.base.ComplexChangeBase;

@:final
class ComplexValueMapChange<T:ValueBase> extends ComplexChangeBase
{
    private var _oldValue:T;

    public function new(model:ComplexValueMapBase<T>, key:String, actionType:ActionType, oldValue:T, newValue:T, expectedTypeName:String)
    {
        super(model, key, actionType, newValue, expectedTypeName);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        var model:ComplexValueMapBase<T> = cast _model;

        switch(this.type)
        {
            case ActionType.INDEX:
                model.set(_propName, _oldValue);

            case ActionType.INSERT:
                model.remove(_propName);

            case ActionType.REMOVE:
                model.set(_propName, _oldValue);

            default:
                throw new Error('This action is not supported in ComplexValueMapChange!');
        }
    }
}
