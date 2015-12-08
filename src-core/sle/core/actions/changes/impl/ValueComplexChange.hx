package sle.core.actions.changes.impl;

import sle.core.actions.changes.base.ComplexChangeBase;
import sle.core.models.ValueBase;

@:final
class ValueComplexChange extends ComplexChangeBase
{
    private var _oldValue:ValueBase;

    public function new(model:ValueBase, propName:String, actionType:ActionType, oldValue:ValueBase, newValue:ValueBase, expectedTypeName:String)
    {
        super(model, propName, actionType, newValue, expectedTypeName);

        _oldValue = oldValue;
    }

    override public function rollback():Void
    {
        Reflect.callMethod(_model, Reflect.field(_model, 'set_' + _propName), [_oldValue]);
    }
}
