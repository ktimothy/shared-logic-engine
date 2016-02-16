package sle.core.actions.changes.impl;

import sle.core.models.collections.ValueMapBase;
import sle.core.actions.changes.base.SimpleChangeBase;

import sle.shim.ActionType;
import sle.shim.Error;

@:final
class SimpleValueMapChange<T> extends SimpleChangeBase<String, T>
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
            case ActionType.MAP_KEY:
                model.set(_key, _oldValue);

            case ActionType.MAP_INSERT:
                model.remove(_key);

            case ActionType.MAP_REMOVE:
                model.set(_key, _oldValue);

            default:
                throw new Error('This action is not supported in SimpleValueMapChange: ${this.type}!');
        }
    }
}
