package sle.core.actions.changes.base;

import sle.shim.ActionDump;

import sle.core.models.ValueBase;

class SimpleChangeBase extends ChangeBase
{
    private var _newValue:Dynamic;

    private function new(model:ValueBase, propName:String, actionType:ActionType, newValue:Dynamic)
    {
        super(model, propName, actionType);

        _newValue = newValue;
    }

    @:final
    inline override public function toObject():ActionDump
    {
        return {
            path: _path,
            newValue: _newValue,
            opName: this.type
        };
    }
}
