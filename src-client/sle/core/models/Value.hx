package sle.core.models;

import sle.core.models.collections.ComplexValueMapBase;

@:autoBuild(sle.core.macro.ValueMacro.build())
class Value extends ValueBase
{
    public function new() super();

    private var fgsfds:ComplexValueMapBase<Value> = new ComplexValueMapBase<Value>();

    override public function process(action:sle.shim.ActionDump):Void
    {
        throw new Error('This model has no field "${action.path[0]}"');
    }
}