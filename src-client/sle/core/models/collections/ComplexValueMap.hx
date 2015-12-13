package sle.core.models.collections;

@:forward(process, exists, get, iterator, keys)
abstract ComplexValueMap<T:ValueBase>(ComplexValueMapBase<T>)
{
    public inline function new()
    {
        this = new ComplexValueMapBase<T>();
    }

    @:arrayAccess
    public inline function arrayRead(key:String):T return this.get(key);

    @:arrayAccess
    public inline function arrayWrite(key:String, value:T):T throw new Error('Not allowed');
}