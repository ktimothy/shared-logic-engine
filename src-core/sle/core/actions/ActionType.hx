package sle.core.actions;

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
}
