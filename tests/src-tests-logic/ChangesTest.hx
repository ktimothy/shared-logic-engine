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
            { path: ["integer"],         newValue: 81,        opName: VAR },
            { path: ["number"],          newValue: 0.1,       opName: VAR },
            { path: ["string"],          newValue: "Omg!",    opName: VAR },
            { path: ["bool"],            newValue: false,     opName: VAR },
            { path: ["inner","integer"], newValue: 10,        opName: VAR },
            { path: ["inner","string"],  newValue: "bla-bla", opName: VAR }
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
            { path: ["bare_array","0"], newValue: 0,   opName: SHIFT   },
            { path: ["bare_array","1"], newValue: 0,   opName: POP     },
            { path: ["bare_array","1"], newValue: 2,   opName: PUSH    },
            { path: ["bare_array","0"], newValue: 12,  opName: UNSHIFT },
            { path: ["bare_array","1"], newValue: 4,   opName: INSERT  },
            { path: ["bare_array","1"], newValue: -12, opName: INDEX   },
            { path: ["bare_array","3"], newValue: 0,   opName: REMOVE  },

            { path: ["inner","object", "z", "1"], newValue: 12, opName: INDEX   },
            { path: ["inner","object", "z", "3"], newValue: 8,  opName: PUSH    },
            { path: ["inner","object", "z", "0"], newValue: 14, opName: UNSHIFT },
            { path: ["inner","object", "z", "0"], newValue: 19, opName: INSERT  },
            { path: ["inner","object", "z", "1"], newValue: 0,  opName: REMOVE  },
            { path: ["inner","object", "z", "4"], newValue: 0,  opName: POP     },
            { path: ["inner","object", "z", "0"], newValue: 0,  opName: SHIFT   }
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
            { path: ["bare_map", "d"], newValue: "ololosh", opName: INSERT },
            { path: ["bare_map", "c"], newValue: "ololosh", opName: INDEX },
            { path: ["bare_map", "a"], newValue: null, opName: INDEX },
            { path: ["bare_map", "b"], newValue: null, opName: REMOVE }
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
            { path: ["coords"], newValue: null, opName: VAR },
            { path: ["coords"], newValue: { x: 1, y: 3 }, opName: VAR },
            { path: ["inner","coords"], newValue: { x: 0, y: 0 }, opName: VAR },
            { path: ["inner"], newValue: null, opName: VAR },
            { path: ["inner"], newValue: { integer: 0, string: null, object: { x: "3", y: null, z: null }, coords: { x: -1, y: -1 }}, opName: VAR }
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
            { path: ["complex_array","2"], newValue: { x: .3, y: .4 }, opName: INDEX   },
            { path: ["complex_array","0"], newValue: null,             opName: SHIFT   },
            { path: ["complex_array","1"], newValue: null,             opName: POP     },
            { path: ["complex_array","1"], newValue: null,             opName: PUSH    },
            { path: ["complex_array","2"], newValue: { x: 0, y: 0 },   opName: PUSH    },
            { path: ["complex_array","0"], newValue: { x: 3, y: 8 },   opName: UNSHIFT },
            { path: ["complex_array","1"], newValue: null,             opName: INSERT  },
            { path: ["complex_array","2"], newValue: null,             opName: REMOVE  }
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
            { path: ["complex_map", "nothing"], newValue: { x: false }, opName: INDEX },
            { path: ["complex_map", "uno"],     newValue: null,         opName: INDEX },
            { path: ["complex_map", "due"],     newValue: null,         opName: REMOVE },
            { path: ["complex_map", "tre"],     newValue: { x: true },  opName: INSERT }
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
            assertEquals(etalonChanges[i].opName, changes[i].opName);
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
        for(change in changes) changesStrs.push("    { path: [\"" + change.path.join("\",\"") + "\"], newValue: " + Utils.hash(change.newValue) + ", opName: \"" + change.opName + "\" }");
        return "[\n" + changesStrs.join(",\n") + "\n]";
    }
}
