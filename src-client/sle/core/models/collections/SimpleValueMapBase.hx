package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;
import sle.shim.ActionType;
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
    public function exists(key:String):Bool return _data.exists(key);

    override public function process(action:ActionDump):Void
    {
        if(action.path.length > 0)
            throw new Error('Got a complex action for SimpleValueMap: $action');

        switch (action.type)
        {
            case ActionType.MAP_KEY:    _data.set(cast action.key, cast action.newValue);
            case ActionType.MAP_INSERT: _data.set(cast action.key, cast action.newValue);
            case ActionType.MAP_REMOVE: _data.remove(cast action.key);

            default: throw new Error('Wrong action type "${action.type}" for ValueMap');
        }
    }
}
