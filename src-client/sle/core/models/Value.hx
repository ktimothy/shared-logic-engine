package sle.core.models;

@:autoBuild(sle.core.macro.ValueMacro.build())
class Value extends ValueBase
{
    public function new() super();

    override public function process(action:sle.shim.ActionDump):Void
    {
        throw new Error('This model has no field "${action.path[0]}"');
    }
}