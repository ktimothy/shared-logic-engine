package sle.shim;

@:enum
abstract ActionType(String) to String
{
    var EVENT = 'event';

    var PROP_CHANGE = 'prop_change';

    var ARRAY_PUSH = 'array_push';
    var ARRAY_POP = 'array_pop';
    var ARRAY_SHIFT = 'array_shift';
    var ARRAY_UNSHIFT = 'array_unshift';
    var ARRAY_INDEX = 'array_index';
    var ARRAY_INSERT = 'array_insert';
    var ARRAY_REMOVE = 'array_remove';

    var MAP_KEY = 'map_key';
    var MAP_INSERT = 'map_insert';
    var MAP_REMOVE = 'map_remove';
}
