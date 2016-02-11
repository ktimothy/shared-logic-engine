package sle.core.models;

import sle.shim.ActionDump;
import sle.shim.Error;

class ValueBase
{
    public function new(){}

    public function process(action:ActionDump):Void
    {
        throw new Error('This should never happen');
    }
}