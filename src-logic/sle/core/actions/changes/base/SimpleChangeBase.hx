package sle.core.actions.changes.base;

import sle.core.models.ValueBase;

import sle.shim.ActionDump;
import sle.shim.ActionType;

class SimpleChangeBase<TKey, TValue> extends ChangeBase<TKey>
{
    private var _newValue:Dynamic;

    private function new(model:ValueBase, key:TKey, actionType:ActionType, newValue:TValue)
    {
        super(model, key, actionType);

        _newValue = newValue;
    }

    @:final
    inline override public function toObject():ActionDump
    {
        return {
            path: _path,
            key: _key,
            newValue: _newValue,
            type: this.type
        };
    }
}
