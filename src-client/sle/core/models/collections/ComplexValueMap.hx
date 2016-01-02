package sle.core.models.collections;

import sle.core.models.Constructable;

@:forward(process, exists, get, iterator, keys)
abstract ComplexValueMap<T:(ValueBase, Constructable)>(ComplexValueMapBase<T>) from ComplexValueMapBase<T> to ComplexValueMapBase<T>
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