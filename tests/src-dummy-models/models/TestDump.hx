package models;

import sle.core.models.collections.ValueMap;
import sle.core.models.collections.ValueArray;
import sle.core.models.Value;

class TestDump extends Value
{
    public var integer:Int;
    public var unsigned_integer:UInt;
    public var number:Float;
    public var string:String;
    public var bool:Bool;

    public var bare_array:ValueArray<Int>;
    public var complex_array:ValueArray<Coords>;

    public var bare_map:ValueMap<String>;
    public var complex_map:ValueMap<XObject>;

    public var nested_simple_map:ValueMap<ValueMap<String>>;
    public var nested_complex_map:ValueMap<ValueMap<XObject>>;

    public var coords:Coords;
    public var inner:InnerModel;

    public var coordsInherited:Coords;

    public var nothing:InnerModel;

    public function new()
    {
        super();

        var keepMe:CoordsInherited;
    }
}
