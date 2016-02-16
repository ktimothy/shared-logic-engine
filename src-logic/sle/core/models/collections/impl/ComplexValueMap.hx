package sle.core.models.collections.impl;

import sle.shim.Constructible;

@:final
@:generic
class ComplexValueMap<T:(ValueBase, Constructible)> extends ComplexValueMapBase<T>
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
