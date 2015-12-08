package ;

import sle.core.models.collections.ValueMap;
import sle.core.actions.ActionLog;
import TestUtils;
import test_models.InnerObject;
import test_models.Coords;
import test_models.InnerModel;
import test_models.TestDump;
import haxe.unit.TestCase;
import sle.core.Utils;

class ModelTest extends TestCase
{
    private var model:TestDump;
    private var dump:Dynamic;

    @:access(sle.core.models.ValueBase)
    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        model = new TestDump();
        model.fromObject(dump);
    }

    @:access(sle.core.models.ValueBase)
    public function testFromObjectAndToObject():Void
    {
        var modelDump:Dynamic = model.toObject();

        assertEquals(Utils.hash(modelDump), Utils.hash(dump));
    }

    @:access(sle.core.models.ValueBase)
    public function testFromArrayAndToArray():Void
    {
        var a1:Array<Dynamic> = model.toArray();
        var d1:Dynamic = model.toObject();

        var m:TestDump = new TestDump();
        m.fromArray(a1);

        var a2:Array<Dynamic> = m.toArray();
        var d2:Dynamic = m.toObject();

        assertEquals(Utils.hash(a1), Utils.hash(a2));
        assertEquals(Utils.hash(d1), Utils.hash(d2));
    }

    @:access(sle.core.models.ValueBase)
    public function testFromObjectHashIntegrity():Void
    {
        var hash:Float = model.__hash;
        var modelDump:Dynamic = model.toObject();

        for(i in 0...100)
        {
            model.fromObject(model.toObject());

            assertEquals(Utils.hash(modelDump), Utils.hash(model.toObject()));
            assertEquals(hash, model.__hash);
        }
    }

    @:access(sle.core.models.ValueBase)
    @:access(sle.core.actions.ActionLog)
    private function testStateHashIntegrity():Void
    {
        var hash:Float = model.__hash;

        model.nothing = new InnerModel();
        model.nothing = null;
        model.nothing = new InnerModel();
        model.nothing = null;

        var n:InnerModel = new InnerModel();
        n.integer = 123;
        model.nothing = n;

        model.nothing.string = "ewrwe";

        var c1 = new Coords();
        c1.x = 34.35;
        c1.y = 214.50000000001;

        var c2 = new Coords();
        c2.x = 34.35;
        c2.y = 214.50000000001;

        model.nothing.coords = c1;
        model.nothing.coords = c2;
        model.nothing.object = new InnerObject();
        model.nothing.object.y = "hi bitch";
        model.nothing.coords = null;

        model.nothing = null;


        // bare map
        model.bare_map = null;
        model.bare_map = new ValueMap<String>();
        model.bare_map["a"] = "x";
        model.bare_map["b"] = "x";
        model.bare_map["c"] = "?";

        model.number *= 1.89123;
        model.number /= 1.89123;


        assertEquals(Utils.hash(TestUtils.getTestDump()), Utils.hash(model.toObject()));
        assertEquals(hash, model.__hash);

        model.fromObject(model.toObject());

        assertEquals(hash, model.__hash);
    }
}
