package sle.core.models.collections;

import sle.core.Utils;

class ValueMapBase<T> extends ValueBase
{
    public var _typeName:String;

    private var _data:Map<String, T>;

    public function new()
    {
        super();

        _data = new Map<String, T>();
    }

    @:final
    inline override public function getTypeName():String
    {
        return _typeName;
    }

    @:final
    inline private function reset():Void
    {
        __hash = 1;
        _data = new Map<String, T>();
    }

    public function exists(key:String):Bool
    {
        return _data.exists(key);
    }

    public function get(key:String):T
    {
        return _data[key];
    }

    private function insert(key:String, value:T):Void { throw new Error('Not implemented!'); }

    public function set(key:String, value:T):T { throw new Error('Not implemented!'); }

    public function remove(key:String):T { throw new Error('Not implemented!'); }

    public function keys():Iterator<String>
    {
        var it = _data.keys();
        var sortedKeys:Array<String> = [];

        while (it.hasNext()) sortedKeys.push(it.next());

        return Utils.sortStringArray(sortedKeys).iterator();
    }

    public function iterator():Iterator<T>
    {
        var sortedValues:Array<T> = [];
        var it = this.keys();

        while (it.hasNext()) sortedValues.push(_data[it.next()]);

        return sortedValues.iterator();
    }
}
