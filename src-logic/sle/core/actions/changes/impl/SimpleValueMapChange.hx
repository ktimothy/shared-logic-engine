package sle.core.actions.changes.impl;

import sle.shim.ActionType;

import sle.core.models.collections.ValueMapBase;
import sle.core.actions.changes.base.SimpleChangeBase;

@:final
class SimpleValueMapChange<T> extends SimpleChangeBase
{
    private var _oldValue:T;

    public function new(model:ValueMapBase<T>, key:String, actionType:ActionType, oldValue:T, newValue:T)
    {
        super(model, key, actionType, newValue);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        var model:ValueMapBase<T> = cast _model;

        switch(this.type)
        {
            case ActionType.INDEX:
                model.set(_propName, _oldValue);

            case ActionType.INSERT:
                model.remove(_propName);

            case ActionType.REMOVE:
                model.set(_propName, _oldValue);

            default:
                throw new Error('This action is not supported in SimpleValueMapChange!');
        }
    }
}