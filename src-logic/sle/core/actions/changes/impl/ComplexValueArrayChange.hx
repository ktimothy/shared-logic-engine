package sle.core.actions.changes.impl;

import sle.core.models.collections.ComplexValueArrayBase;
import sle.core.actions.changes.base.ComplexChangeBase;
import sle.core.models.ValueBase;
import sle.core.Utils;

@:final
class ComplexValueArrayChange<T:ValueBase> extends ComplexChangeBase
{
    private var _oldValue:T;
    private var _index:Int;

    public function new(model:ComplexValueArrayBase<T>, index:Int, actionType:ActionType, oldValue:T, newValue:T, expectedTypeName:String)
    {
        super(model, Utils.intToString(index), actionType, newValue, expectedTypeName);

        _oldValue = oldValue;
        _index = index;
    }

    override public function rollback():Void
    {
        var model:ComplexValueArrayBase<T> = cast _model;

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
                throw new Error('This action is not supported in ComplexValueArrayChange!');
        }
    }
}
