package ;

import haxe.unit.TestCase;

import sle.shim.ActionDump;

import models.TestDump;
import models.Coords;
import models.CoordsInherited;

class ValueTest extends TestCase
{
    public function testIntegerIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            opName:     'var',
            path:       ['integer'],
            newValue:   -1
        }

        model.process(action);

        assertEquals(-1, model.integer);
    }

    public function testUnsignedIntegerIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            opName:     'var',
            path:       ['unsigned_integer'],
            newValue:   1
        }

        model.process(action);

        assertEquals(1, model.unsigned_integer);
    }

    public function testNumberIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            opName:     'var',
            path:       ['number'],
            newValue:   -1.1
        }

        model.process(action);

        assertEquals(-1.1, model.number);
    }

    public function testStringIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            opName:     'var',
            path:       ['string'],
            newValue:   'test'
        }

        model.process(action);

        assertEquals('test', model.string);
    }

    public function testBoolIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            opName:     'var',
            path:       ['bool'],
            newValue:   true
        }

        model.process(action);

        assertEquals(true, model.bool);
    }

    public function testChildIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            opName:     'var',
            path:       ['coords'],
            newValue:   {x: 1.0, y: 1.0}
        }

        model.process(action1);

        assertEquals(1.0, model.coords.x);
        assertEquals(1.0, model.coords.y);

        var action2:ActionDump = {
            opName:     'var',
            path:       ['coords', 'x'],
            newValue:   2.0
        }

        model.process(action2);

        assertEquals(2.0, model.coords.x);
    }

    public function testInheritedPropertiesAreProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            opName:     'var',
            path:       ['coordsInherited'],
            newValue:   {x: 1.0, y: 1.0, z: 1.0, __type:'models.CoordsInherited'}
        }

        model.process(action1);

        assertEquals(1.0, cast(model.coordsInherited, CoordsInherited).z);

        var action2:ActionDump = {
            opName:     'var',
            path:       ['coordsInherited', 'z'],
            newValue:   2.0
        }

        model.process(action2);

        assertEquals(2.0, cast(model.coordsInherited, CoordsInherited).z);
    }
}
