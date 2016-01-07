package sle.core.actions.changes.base;

import sle.shim.ActionDump;
import sle.shim.ActionType;

import sle.core.models.ValueBase;

class ComplexChangeBase extends ChangeBase
{
    private var _newValue:ValueBase;
    private var _expectedTypeName:String;

    private function new(model:ValueBase, propName:String, actionType:ActionType, newValue:ValueBase, expectedTypeName:String)
    {
        super(model, propName, actionType);

        _newValue = newValue;
        _expectedTypeName = expectedTypeName;
    }

    @:final
    inline override public function toObject():ActionDump
    {
        return {
            path: _path,
            newValue: (_newValue == null ? null : _newValue.toObject(_expectedTypeName)),
            opName: this.type
        };
    }
}
