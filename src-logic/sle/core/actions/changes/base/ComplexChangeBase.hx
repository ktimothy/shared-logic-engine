package sle.core.actions.changes.base;

import sle.core.models.ValueBase;

import sle.shim.ActionDump;
import sle.shim.ActionType;

class ComplexChangeBase<TKey, TValue:ValueBase> extends ChangeBase<TKey>
{
    private var _newValue:TValue;
    private var _expectedTypeName:String;

    private function new(model:ValueBase, key:TKey, actionType:ActionType, newValue:TValue, expectedTypeName:String)
    {
        super(model, key, actionType);

        _newValue = newValue;
        _expectedTypeName = expectedTypeName;
    }

    @:final
    inline override public function toObject():ActionDump
    {
        return {
            path: _path,
            key: _key,
            newValue: (_newValue == null ? null : _newValue.toObject(_expectedTypeName)),
            type: this.type
        };
    }
}
