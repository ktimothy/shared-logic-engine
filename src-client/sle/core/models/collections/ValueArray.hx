package sle.core.models.collections;

class ValueArray<T>
{
    private var _data:Array<T>;

    public function new()
    {
        _data = [];
    }

    @:arrayAccess inline function get(index:Int):T return _data[index];    

    @:arrayAccess inline function set(index:Int, value:T):Void throw new Error('Not allowed');
}