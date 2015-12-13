package sle.core.models;

import sle.shim.ActionDump;

class ValueBase
{
    public function new(){}

    public function process(action:ActionDump):Void
    {
        throw new sle.core.Error('This should never happen');
    }
}