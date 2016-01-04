package sle.core.models;

import sle.shim.ActionDump;

typedef Processable = {
    public function process(action:ActionDump):Void;
}