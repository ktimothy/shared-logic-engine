package sle.core.models.collections;

import sle.shim.ActionDump;

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
    public function set(key:Int, value:T):Void _data[key] = value;

    override public function process(action:ActionDump):Void
    {
        if(action.path.length > 1)
            throw new sle.core.Error('Got a complex action for SimpleValueArray: $action');

        switch (action.opName)
        {
            case PUSH:      _data.push(action.newValue);
            case POP:       _data.pop();
            case UNSHIFT:   _data.unshift(action.newValue);
            case SHIFT:     _data.shift();
            case INSERT:    _data.insert(Std.parseInt(action.path[0]), action.newValue);
            case REMOVE:    _data.remove(action.newValue);
            case INDEX:     _data[Std.parseInt(action.path[0])] = action.newValue;
            default:        throw new Error('Wrong action type "${action.opName}" for ValueArray');
        }
    }
}