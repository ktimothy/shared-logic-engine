package sle.core.models.collections.impl;

import sle.shim.Constructible;

@:final
@:generic
class ComplexValueArray<T:(ValueBase, Constructible)> extends ComplexValueArrayBase<T>
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
