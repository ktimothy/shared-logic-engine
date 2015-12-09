package sle.core.models.collections;

@:forward(exists, remove, iterator, keys)
abstract ValueMap<T>(ValueMapBase<T>)
{
    public inline function new()
    {
        this = new ValueMapBase<T>();
    }

    @:arrayAccess
    public function arrayRead(key:String):T
    {
        return this.get(key);   
    }

    @:arrayAccess
    public function arrayWrite(key:String, value:T):T
    {
        throw new Error('Not allowed');
    }
}