package sle.core.models.collections;

import sle.shim.ActionDump;
import sle.shim.ActionType;
import sle.shim.Error;

class SimpleValueArrayBase<T> extends ValueBase
{
    public var length(get, never):UInt;

    private var _data:Array<T>;

    public function new()
    {
        super();

        _data = new Array<T>();
    }

    public function get_length():UInt return _data.length;
    public function get(key:Int):T return _data[key];

    override public function process(action:ActionDump):Void
    {
        if(action.path.length > 0)
            throw new Error('Got a complex action for SimpleValueArray: $action');

        switch (action.type)
        {
            case ActionType.ARRAY_PUSH:      _data.push(cast action.newValue);
            case ActionType.ARRAY_POP:       _data.pop();
            case ActionType.ARRAY_UNSHIFT:   _data.unshift(cast action.newValue);
            case ActionType.ARRAY_SHIFT:     _data.shift();
            case ActionType.ARRAY_INSERT:    _data.insert(cast action.key, cast action.newValue);
            case ActionType.ARRAY_REMOVE:    _data.splice(cast action.key, 1);
            case ActionType.ARRAY_INDEX:     _data[cast action.key] = cast action.newValue;

            default: throw new Error('Wrong action type "${action.type}" for ValueArray');
        }
    }
}
