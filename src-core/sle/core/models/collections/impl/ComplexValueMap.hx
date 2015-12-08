package sle.core.models.collections.impl;

typedef ConstructibleValueMap = {
    public function new():Void;
}

@:final
@:generic
class ComplexValueMap<T:(ValueBase, ConstructibleValueMap)> extends ComplexValueMapBase<T>
{
    public function new()
    {
        super();
    }

    override private function createElement():T
    {
        return new T();
    }
}
