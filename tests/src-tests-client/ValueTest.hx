package ;

import haxe.unit.TestCase;

import sle.shim.ActionDump;
import sle.shim.ActionType;

import models.TestDump;
import models.Coords;
import models.CoordsInherited;

class ValueTest extends TestCase
{
    public function testIntegerIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            path:       [],
            key:        'integer',
            newValue:   -1,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action);

        assertEquals(-1, model.integer);
    }

    public function testUnsignedIntegerIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            path:       [],
            key:        'unsigned_integer',
            newValue:   1,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action);

        assertEquals(1, model.unsigned_integer);
    }

    public function testNumberIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            path:       [],
            key:        'number',
            newValue:   -1.1,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action);

        assertEquals(-1.1, model.number);
    }

    public function testStringIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            path:       [],
            key:        'string',
            newValue:   'test',
            type:       ActionType.PROP_CHANGE
        }

        model.process(action);

        assertEquals('test', model.string);
    }

    public function testBoolIsProcessedProperly()
    {
        var model = new TestDump();

        var action:ActionDump = {
            path:       [],
            key:        'bool',
            newValue:   true,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action);

        assertEquals(true, model.bool);
    }

    public function testChildIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            path:       [],
            key:        'coords',
            newValue:   { x: 1.0, y: 1.0 },
            type:       ActionType.PROP_CHANGE
        }

        model.process(action1);

        assertEquals(1.0, model.coords.x);
        assertEquals(1.0, model.coords.y);

        var action2:ActionDump = {
            path:       ['coords'],
            key:        'x',
            newValue:   2.0,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action2);

        assertEquals(2.0, model.coords.x);
    }

    public function testInheritedPropertiesAreProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            path:       [],
            key:        'coordsInherited',
            newValue:   { x: 1.0, y: 1.0, z: 1.0, __type:'models.CoordsInherited' },
            type:       ActionType.PROP_CHANGE
        }

        model.process(action1);

        assertEquals(1.0, cast(model.coordsInherited, CoordsInherited).z);

        var action2:ActionDump = {
            path:       ['coordsInherited'],
            key:        'z',
            newValue:   2.0,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action2);

        assertEquals(2.0, cast(model.coordsInherited, CoordsInherited).z);
    }

    public function testSimpleMapIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            path:       [],
            key:        'bare_map',
            newValue:   { test_property: 'test_value' },
            type:       ActionType.PROP_CHANGE
        }

        model.process(action1);

        assertEquals('test_value', model.bare_map['test_property']);

        var action2:ActionDump = {
            path:       ['bare_map'],
            key:        'test_property',
            newValue:   'test_value_2',
            type:       ActionType.PROP_CHANGE
        }

        model.process(action2);

        assertEquals('test_value_2', model.bare_map['test_property']);
    }

    public function testComplexMapIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            path:       [],
            key:        'complex_map',
            newValue:   { test_property: { x: true } },
            type:       ActionType.PROP_CHANGE
        }

        model.process(action1);

        assertEquals(true, model.complex_map['test_property'].x);

        var action2:ActionDump = {
            path:       ['complex_map'],
            key:        'test_property',
            newValue:   { x: false },
            type:       ActionType.PROP_CHANGE
        }

        model.process(action2);

        assertEquals(false, model.complex_map['test_property'].x);

        var action3:ActionDump = {
            path:       ['complex_map', 'test_property'],
            key:        'x',
            newValue:   true,
            type:       ActionType.PROP_CHANGE
        }

        model.process(action3);

        assertEquals(true, model.complex_map['test_property'].x);
    }

    // Commented out until nested maps support fix for logic
    /*
    public function testNestedSimpleMapIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            opName:     VAR,
            path:       ['nested_simple_map'],
            newValue:   {foo: {bar: 'test1'}}
        }

        model.process(action1);

        assertTrue(model.nested_simple_map.exists('foo'));
        assertTrue(model.nested_simple_map['foo'].exists('bar'));
        assertEquals('test1', model.nested_simple_map['foo']['bar']);

        var action2:ActionDump = {
            opName:     VAR,
            path:       ['nested_simple_map', 'foo'],
            newValue:   {baz: 'test2'}
        }

        model.process(action2);

        assertTrue(model.nested_simple_map.exists('foo'));
        assertTrue(model.nested_simple_map['foo'].exists('baz'));
        assertEquals('test2', model.nested_simple_map['foo']['baz']);

        var action3:ActionDump = {
            opName:     VAR,
            path:       ['nested_simple_map', 'foo', 'baz'],
            newValue:   'test3'
        }

        model.process(action3);

        assertTrue(model.nested_simple_map.exists('foo'));
        assertTrue(model.nested_simple_map['foo'].exists('baz'));
        assertEquals('test3', model.nested_simple_map['foo']['baz']);
    }
    */

    // Commented out until nested maps support fix for logic
    /*
    public function testNestedComplexMapIsProcessedProperly()
    {
        var model = new TestDump();

        var action1:ActionDump = {
            opName:     VAR,
            path:       ['nested_complex_map'],
            newValue:   {foo: {bar: {x: true}}}
        }

        model.process(action1);

        assertTrue(model.nested_complex_map.exists('foo'));
        assertTrue(model.nested_complex_map['foo'].exists('bar'));
        assertEquals(true, model.nested_complex_map['foo']['bar'].x);

        var action2:ActionDump = {
            opName:     VAR,
            path:       ['nested_complex_map', 'foo'],
            newValue:   {baz: {x: false}}
        }

        model.process(action2);

        assertTrue(model.nested_complex_map.exists('foo'));
        assertTrue(model.nested_complex_map['foo'].exists('baz'));
        assertEquals(false, model.nested_complex_map['foo']['baz'].x);

        var action3:ActionDump = {
            opName:     VAR,
            path:       ['nested_complex_map', 'foo', 'baz'],
            newValue:   {x: true}
        }

        model.process(action3);

        assertTrue(model.nested_complex_map.exists('foo'));
        assertTrue(model.nested_complex_map['foo'].exists('baz'));
        assertEquals(true, model.nested_complex_map['foo']['baz'].x);

        var action4:ActionDump = {
            opName:     VAR,
            path:       ['nested_complex_map', 'foo', 'baz', 'x'],
            newValue:   false
        }

        model.process(action4);

        assertTrue(model.nested_complex_map.exists('foo'));
        assertTrue(model.nested_complex_map['foo'].exists('baz'));
        assertEquals(false, model.nested_complex_map['foo']['baz'].x);
    }
    */
}
