package ;

import haxe.unit.TestCase;

import sle.core.models.collections.ValueArray;

import sle.shim.ActionType;

import models.TestDump;

class ComplexValueArrayTest extends TestCase
{
    private var _array:ValueArray<Int>;

    public function testWrongActionTypeThrows()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [],
            type:       ActionType.PROP_CHANGE
        });

        // hack to avoid warning
        assertTrue(true);

        try
        {
            model.process({
                path:       ['complex_array'],
                key:        0,
                newValue:   [{ x: 0.0, y: 0.0 }],
                type:       ActionType.PROP_CHANGE
            });
        }
        catch(e:Dynamic)
        {
            return;
        }

        throw "Exception expected";
        
    }

    public function testPush()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({

            path:       ['complex_array'],
            key:        0,
            newValue:   { x: 1.0, y: 1.0 },
            type:     ActionType.ARRAY_PUSH
        });

        assertEquals(2, model.complex_array.length);

        assertEquals(1.0, model.complex_array[1].x);
        assertEquals(1.0, model.complex_array[1].y);
    }

    public function testUnshift()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        0,
            newValue:   { x: 1.0, y: 1.0 },
            type:       ActionType.ARRAY_UNSHIFT
        });

        assertEquals(2, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }

    public function testPop()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0}, { x: 1.0, y: 1.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        0,
            newValue:   0,
            type:       ActionType.ARRAY_POP
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(0.0, model.complex_array[0].x);
        assertEquals(0.0, model.complex_array[0].y);
    }

    public function testShift()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }, { x: 1.0, y: 1.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        0,
            newValue:   0,
            type:       ActionType.ARRAY_SHIFT
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }

    public function testInsert()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }, { x: 1.0, y: 1.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        1,
            newValue:   { x: 7.0, y: 7.0 },
            type:       ActionType.ARRAY_INSERT
        });

        assertEquals(3, model.complex_array.length);

        assertEquals(0.0, model.complex_array[0].x);
        assertEquals(0.0, model.complex_array[0].y);

        assertEquals(7.0, model.complex_array[1].x);
        assertEquals(7.0, model.complex_array[1].y);

        assertEquals(1.0, model.complex_array[2].x);
        assertEquals(1.0, model.complex_array[2].y);
    }

    public function testRemove()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }, { x: 7.0, y: 7.0 }, { x: 1.0, y: 1.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        1,
            newValue:   null,
            type:     ActionType.ARRAY_REMOVE
        });

        assertEquals(2, model.complex_array.length);

        assertEquals(0.0, model.complex_array[0].x);
        assertEquals(0.0, model.complex_array[0].y);

        assertEquals(1.0, model.complex_array[1].x);
        assertEquals(1.0, model.complex_array[1].y);
    }

    public function testIndex()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'complex_array',
            newValue:   [{ x: 0.0, y: 0.0 }],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['complex_array'],
            key:        0,
            newValue:   { x: 1.0, y: 1.0 },
            type:       ActionType.ARRAY_INDEX,
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }
}