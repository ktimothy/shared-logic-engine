package sle.core.actions.changes.impl;

import sle.core.models.collections.ComplexValueMapBase;
import sle.core.models.ValueBase;
import sle.core.actions.changes.base.ComplexChangeBase;

import sle.shim.ActionType;
import sle.shim.Error;

@:final
class ComplexValueMapChange<T:ValueBase> extends ComplexChangeBase<String, T>
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
            case ActionType.MAP_KEY:
                model.set(_key, _oldValue);

            case ActionType.MAP_INSERT:
                model.remove(_key);

            case ActionType.MAP_REMOVE:
                model.set(_key, _oldValue);

            default:
                throw new Error('This action is not supported in ComplexValueMapChange: ${this.type}!');
        }
    }
}
