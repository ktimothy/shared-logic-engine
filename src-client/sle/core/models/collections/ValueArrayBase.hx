package sle.core.models.collections;

import sle.shim.ActionDump;
import sle.shim.Error;

class ValueArrayBase<T>
{
    private var _data:Array<T>;

    public function new()
    {
        _data = [];
    }

    @:arrayAccess public inline function get(index:Int):T return _data[index];    

    @:arrayAccess public inline function set(index:Int, value:T):Void throw new Error('Not allowed');

    public function process(action:ActionDump):Void
    {
        throw new Error('Not implemented');
    }
}