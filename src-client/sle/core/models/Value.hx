package sle.core.models;

import sle.core.models.collections.ComplexValueMapBase;
import sle.shim.Error;
import sle.shim.ActionDump;

@:autoBuild(sle.core.macro.ValueMacro.build())
class Value extends ValueBase
{
    public function new() super();

    override public function process(action:ActionDump):Void
    {
        throw new Error('This model has no field "${action.path[0]}"');
    }
}