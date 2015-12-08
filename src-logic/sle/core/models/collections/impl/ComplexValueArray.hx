package sle.core.models.collections.impl;

typedef ConstructibleValueBase = {
    public function new():Void;
}

@:final
@:generic
class ComplexValueArray<T:(ValueBase, ConstructibleValueBase)> extends ComplexValueArrayBase<T>
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
