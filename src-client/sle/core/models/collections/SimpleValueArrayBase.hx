package sle.core.models.collections;

import sle.shim.ActionDump;

class SimpleValueArrayBase<T> extends ValueBase
{
    private var _data:Array<T>;

    public function new()
    {
        super();

        _data = new Array<T>();
    }

    public function get(key:Int):T return _data[key];
    public function set(key:Int, value:T):Void _data[key] = value;

    override public function process(action:ActionDump):Void
    {
        if(action.path.length > 1)
            throw new sle.core.Error('Got a complex action for SimpleValueArray: $action');

        this.set(Std.parseInt(action.path[0]), action.newValue);
    }
}