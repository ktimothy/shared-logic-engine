package sle.core.actions.changes.impl;

import sle.core.models.collections.ComplexValueArrayBase;
import sle.core.actions.changes.base.ComplexChangeBase;
import sle.core.models.ValueBase;

import sle.shim.ActionType;
import sle.shim.Error;

@:final
class ComplexValueArrayChange<T:ValueBase> extends ComplexChangeBase<Int, T>
{
    private var _oldValue:T;

    public function new(model:ComplexValueArrayBase<T>, key:Int, actionType:ActionType, oldValue:T, newValue:T, expectedTypeName:String)
    {
        super(model, key, actionType, newValue, expectedTypeName);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        var model:ComplexValueArrayBase<T> = cast _model;

        switch(this.type)
        {
            case ActionType.ARRAY_INDEX:
                model.set(_key, _oldValue);

            case ActionType.ARRAY_PUSH:
                model.pop();

            case ActionType.ARRAY_POP:
                model.push(_oldValue);

            case ActionType.ARRAY_SHIFT:
                model.unshift(_oldValue);

            case ActionType.ARRAY_UNSHIFT:
                model.shift();

            case ActionType.ARRAY_INSERT:
                model.remove(_key);

            case ActionType.ARRAY_REMOVE:
                model.insert(_key, _oldValue);

            default:
                throw new Error('This action is not supported in ComplexValueArrayChange: ${this.type}!');
        }
    }
}
