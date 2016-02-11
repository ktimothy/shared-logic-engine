package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;
import sle.shim.Error;

class SimpleValueMapBase<T> extends ValueBase
{
    private var _data:StringMap<T>;

    public function new()
    {
        super();

        _data = new StringMap<T>();
    }

    public function get(key:String):T return _data.get(key);
    public function set(key:String, value:T):Void _data.set(key, value);
    public function remove(key:String):Bool return _data.remove(key);
    public function exists(key:String):Bool return _data.exists(key);

    override public function process(action:ActionDump):Void
    {
        if(action.path.length > 1)
            throw new Error('Got a complex action for SimpleValueMap: $action');

        this.set(action.path[0], action.newValue);
    }
}