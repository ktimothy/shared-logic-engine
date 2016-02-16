package ;

import haxe.PosInfos;
import haxe.unit.TestCase;

import sle.shim.ActionDump;
import sle.shim.ActionType;

import sle.core.Utils;
import sle.core.actions.ActionLog;

import models.XObject;
import models.InnerModel;
import models.Coords;
import models.InnerObject;
import models.TestDump;



class ChangesTest extends TestCase
{
    private var dump:Dynamic;
    private var model:TestDump;

    @:access(sle.core.models.ValueBase)
    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        model = new TestDump();
        model.fromObject(dump);
        model.setRooted(true);
    }


    public function testSimpleChanges():Void
    {
        model.integer = 81;
        model.number = 0.1;
        model.string = "Omg!";
        model.bool = false;

        model.inner.integer = 10;
        model.inner.string = "bla-bla";

        var etalonChanges:Array<ActionDump> = [
            { path: [],        key: "integer",  newValue: 81,        type: ActionType.PROP_CHANGE },
            { path: [],        key: "number",   newValue: 0.1,       type: ActionType.PROP_CHANGE },
            { path: [],        key: "string",   newValue: "Omg!",    type: ActionType.PROP_CHANGE },
            { path: [],        key: "bool",     newValue: false,     type: ActionType.PROP_CHANGE },
            { path: ["inner"], key: "integer",  newValue: 10,        type: ActionType.PROP_CHANGE },
            { path: ["inner"], key: "string",   newValue: "bla-bla", type: ActionType.PROP_CHANGE }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    public function testSimpleArrayChanges():Void
    {
        model.bare_array.shift();
        model.bare_array.pop();
        model.bare_array.push(2);
        model.bare_array.unshift(12);
        model.bare_array.insert(1, 4);
        model.bare_array[1] -= 16;
        model.bare_array.remove(3);

        model.inner.object.z[1] *= 6;
        model.inner.object.z.push(8);
        model.inner.object.z.unshift(14);
        model.inner.object.z.insert(0, 19);
        model.inner.object.z.remove(1);
        model.inner.object.z.pop();
        model.inner.object.z.shift();


        var etalonChanges:Array<ActionDump> = [
            { path: ["bare_array"], key: 0, newValue: 0,   type: ActionType.ARRAY_SHIFT   },
            { path: ["bare_array"], key: 1, newValue: 0,   type: ActionType.ARRAY_POP     },
            { path: ["bare_array"], key: 1, newValue: 2,   type: ActionType.ARRAY_PUSH    },
            { path: ["bare_array"], key: 0, newValue: 12,  type: ActionType.ARRAY_UNSHIFT },
            { path: ["bare_array"], key: 1, newValue: 4,   type: ActionType.ARRAY_INSERT  },
            { path: ["bare_array"], key: 1, newValue: -12, type: ActionType.ARRAY_INDEX   },
            { path: ["bare_array"], key: 3, newValue: 0,   type: ActionType.ARRAY_REMOVE  },

            { path: ["inner","object", "z"], key: 1, newValue: 12, type: ActionType.ARRAY_INDEX   },
            { path: ["inner","object", "z"], key: 3, newValue: 8,  type: ActionType.ARRAY_PUSH    },
            { path: ["inner","object", "z"], key: 0, newValue: 14, type: ActionType.ARRAY_UNSHIFT },
            { path: ["inner","object", "z"], key: 0, newValue: 19, type: ActionType.ARRAY_INSERT  },
            { path: ["inner","object", "z"], key: 1, newValue: 0,  type: ActionType.ARRAY_REMOVE  },
            { path: ["inner","object", "z"], key: 4, newValue: 0,  type: ActionType.ARRAY_POP     },
            { path: ["inner","object", "z"], key: 0, newValue: 0,  type: ActionType.ARRAY_SHIFT   }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    public function testSimpleMap():Void
    {
        model.bare_map["d"] = "ololosh";
        model.bare_map["c"] = "ololosh";
        model.bare_map["a"] = null;
        model.bare_map.remove("b");

        var etalonChanges:Array<ActionDump> = [
            { path: ["bare_map"], key: "d", newValue: "ololosh", type: ActionType.MAP_INSERT },
            { path: ["bare_map"], key: "c", newValue: "ololosh", type: ActionType.MAP_KEY },
            { path: ["bare_map"], key: "a", newValue: null, type: ActionType.MAP_KEY },
            { path: ["bare_map"], key: "b", newValue: null, type: ActionType.MAP_REMOVE }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    public function testComplexValues():Void
    {
        model.coords = null;

        var c = new Coords();
        c.x = 1;
        c.y = 3;
        model.coords = c;

        model.inner.coords = new Coords();
        model.inner = null;

        var newInnerModel:InnerModel = new InnerModel();

        c = new Coords();
        c.x = -1;
        c.y = -1;
        newInnerModel.coords = c;

        newInnerModel.object = new InnerObject();
        newInnerModel.object.x = "3";

        model.inner = newInnerModel;

        var etalonChanges:Array<ActionDump> = [
            { path: [], key: "coords", newValue: null, type: ActionType.PROP_CHANGE},
            { path: [], key: "coords", newValue: { x: 1, y: 3 }, type: ActionType.PROP_CHANGE },
            { path: ["inner"], key: "coords", newValue: { x: 0, y: 0 }, type: ActionType.PROP_CHANGE },
            { path: [], key: "inner", newValue: null, type: ActionType.PROP_CHANGE },
            { path: [], key: "inner", newValue: { integer: 0, string: null, object: { x: "3", y: null, z: null }, coords: { x: -1, y: -1 }}, type: ActionType.PROP_CHANGE }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    public function testComplexArray():Void
    {
        var c = new Coords();
        c.x = .3;
        c.y = .4;
        model.complex_array[2] = c;

        var c2 = new Coords();
        c2.x = 3;
        c2.y = 8;

        model.complex_array.shift();
        model.complex_array.pop();
        model.complex_array.push(null);
        model.complex_array.push(new Coords());
        model.complex_array.unshift(c2);
        model.complex_array.insert(1, null);
        model.complex_array.remove(2);

        var etalonChanges:Array<ActionDump> = [
            { path: ["complex_array"], key: 2, newValue: { x: .3, y: .4 }, type: ActionType.ARRAY_INDEX   },
            { path: ["complex_array"], key: 0, newValue: null,             type: ActionType.ARRAY_SHIFT   },
            { path: ["complex_array"], key: 1, newValue: null,             type: ActionType.ARRAY_POP     },
            { path: ["complex_array"], key: 1, newValue: null,             type: ActionType.ARRAY_PUSH    },
            { path: ["complex_array"], key: 2, newValue: { x: 0, y: 0 },   type: ActionType.ARRAY_PUSH    },
            { path: ["complex_array"], key: 0, newValue: { x: 3, y: 8 },   type: ActionType.ARRAY_UNSHIFT },
            { path: ["complex_array"], key: 1, newValue: null,             type: ActionType.ARRAY_INSERT  },
            { path: ["complex_array"], key: 2, newValue: null,             type: ActionType.ARRAY_REMOVE  }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    public function testComplexMap():Void
    {
        var obj:XObject = new XObject();
        obj.x = true;

        model.complex_map["nothing"] = new XObject();
        model.complex_map["uno"] = null;
        model.complex_map.remove("due");
        model.complex_map["tre"] = obj;

        var etalonChanges:Array<ActionDump> = [
            { path: ["complex_map"], key: "nothing", newValue: { x: false }, type: ActionType.MAP_KEY },
            { path: ["complex_map"], key: "uno",     newValue: null,         type: ActionType.MAP_KEY },
            { path: ["complex_map"], key: "due",     newValue: null,         type: ActionType.MAP_REMOVE },
            { path: ["complex_map"], key: "tre",     newValue: { x: true },  type: ActionType.MAP_INSERT }
        ];

        assertChangesEqual(etalonChanges, ActionLog._commit());
    }

    private function assertChangesEqual(etalonChanges:Array<ActionDump>, changes:Array<ActionDump>):Void
    {
        assertEquals(etalonChanges.length, changes.length);

        var len:Int = etalonChanges.length;
        for(i in 0...len)
        {
            assertEquals(etalonChanges[i].path.join("."), changes[i].path.join("."));
            assertEquals(etalonChanges[i].key, changes[i].key);
            assertEquals(etalonChanges[i].type, changes[i].type);
            assertEquals(etalonChanges[i].newValue, changes[i].newValue);
        }
    }

    override function assertEquals<T>(etalon:T, checked:T, ?c:PosInfos):Void
    {
        super.assertEquals(Utils.hash(etalon), Utils.hash(checked));
    }

    private function stringifyChanges(changes:Array<ActionDump>):String
    {
        var changesStrs:Array<String> = [];
        for(change in changes) changesStrs.push("    { path: [\"" + change.path.join("\",\"") + "\"], key: " + change.key + ", newValue: " + Utils.hash(change.newValue) + ", type: \"" + change.type + "\" }");
        return "[\n" + changesStrs.join(",\n") + "\n]";
    }
}
