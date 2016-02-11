package sle.core.actions.changes.impl;

import sle.shim.ActionType;
import sle.shim.Error;

import sle.core.models.collections.ValueArrayBase;
import sle.core.models.ValueBase;
import sle.core.actions.changes.base.SimpleChangeBase;
import sle.core.Utils;

@:final
class SimpleValueArrayChange<T> extends SimpleChangeBase
{
    private var _oldValue:T;
    private var _index:Int;

    public function new(model:ValueArrayBase<T>, index:Int, actionType:ActionType, oldValue:T, newValue:T)
    {
        super(model, Utils.intToString(index), actionType, newValue);

        _oldValue = oldValue;
        _index = index;
    }

    override public function rollback():Void
    {
        var model:ValueArrayBase<T> = cast _model;

        switch(this.type)
        {
            case ActionType.INDEX:
                model.set(_index, _oldValue);

            case ActionType.PUSH:
                model.pop();

            case ActionType.POP:
                model.push(_oldValue);

            case ActionType.SHIFT:
                model.unshift(_oldValue);

            case ActionType.UNSHIFT:
                model.shift();

            case ActionType.INSERT:
                model.remove(_index);

            case ActionType.REMOVE:
                model.insert(_index, _oldValue);

            default:
                throw new Error('This action is not supported in SimpleValueArrayChange!');
        }

    }
}
