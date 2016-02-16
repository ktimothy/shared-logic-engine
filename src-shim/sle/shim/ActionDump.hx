package sle.shim;

/**
 * This data structure is used as a result of serialization of an action where
 * action itself could be a value change in some model or an event.
 **/
typedef ActionDump = {

    // path to model which has changed
    // null, if it's an event
    path:Array<String>,

    // name of preperty, which has changed
    // OR string key of ValueMap, which has changed
    // OR index of ValueArray, which has changed
    key:Dynamic,

    // new value of a changed property
    newValue:Dynamic,

    // could be a data change or an event
    type:ActionType
};
