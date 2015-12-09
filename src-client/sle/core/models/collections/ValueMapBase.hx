package sle.core.models.collections;

class ValueMapBase<T>
{
    private var _data:Map<String, T>;

    public function new()
    {
        _data = new Map<String, T>();
    }

    public inline function exists(key:String):Bool return _data.exists(key);

    public inline function remove(key:String):Bool return _data.remove(key);

    public inline function keys():Iterator<String> return _data.keys();

    public inline function iterator():Iterator<T> return _data.iterator();

    public inline function get(key:String):T return _data.get(key);

    public inline function set(key:String, value:T):Void _data.set(key, value);
}