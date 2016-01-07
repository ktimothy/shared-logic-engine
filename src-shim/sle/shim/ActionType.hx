package sle.shim;

@:enum
abstract ActionType(String) to String
{
    var INDEX = 'index';
    var INSERT = 'insert';
    var POP = 'pop';
    var PUSH = 'push';
    var REMOVE = 'remove';
    var SHIFT = 'shift';
    var UNSHIFT = 'unshift';
    var VAR = 'var';
    var EVENT = 'event';

    public function new(value:String)
    {
        this = switch(value)
        {
            case 'index', 'insert', 'pop', 'push', 'remove', 'shift', 'unshift', 'var', 'event': value;
            default: throw 'Invalid action type: "$value"';
        }
    }
}
