package sle.core.models.collections;

class ValueArrayBase<T> extends ValueBase
{
    public var length(get, never):Int;

    public var _typeName:String;

    private var _data:Array<T>;

    public function new()
    {
        super();

        _data = new Array<T>();
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
        _data = new Array<T>();
    }

    public function get(index:Int):T
    {
        return _data[index];
    }

    public function set(index, value:T):T { throw new Error('Not implemented!'); }

    public function iterator():Iterator<T>
    {
        return _data.iterator();
    }

    public function indexOf(value:T, fromIndex:Int = 0):Int
    {
        return Utils.indexOf(_data, value, fromIndex);
    }

    public function lastIndexOf(value:T, ?fromIndex:Int):Int
    {
        return Utils.lastIndexOf(_data, value, fromIndex == null ? _data.length - 1 : fromIndex);
    }

    public function get_length():Int
    {
        return _data.length;
    }

    public function push(value:T):Int { throw new Error('Not implemented!'); }

    public function pop():T { throw new Error('Not implemented!'); }

    public function shift():T { throw new Error('Not implemented!'); }

    public function unshift(value:T):Void { throw new Error('Not implemented!'); }

    public function insert(index:Int, value:T):Void { throw new Error('Not implemented!'); }

    public function remove(index:Int):T { throw new Error('Not implemented!'); }
}
