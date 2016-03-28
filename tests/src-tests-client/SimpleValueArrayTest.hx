package ;

import haxe.unit.TestCase;

import sle.core.models.collections.ValueArray;

import sle.shim.ActionType;

import models.TestDump;

class SimpleValueArrayTest extends TestCase
{
    private var _array:ValueArray<Int>;

    public function testWrongActionTypeThrows()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [],
            type:       ActionType.PROP_CHANGE
        });

        // hack to avoid warning
        assertTrue(true);

        try
        {
            model.process({
                path:       ['bare_array'],
                key:        0,
                newValue:   [1],
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
            key:        'bare_array',
            newValue:   [1],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        0,
            newValue:   2,
            type:       ActionType.ARRAY_PUSH
        });

        assertEquals(2, model.bare_array.length);
        assertEquals(2, model.bare_array[1]);
    }

    public function testUnshift()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        0,
            newValue:   2,
            type:       ActionType.ARRAY_UNSHIFT
        });

        assertEquals(2, model.bare_array.length);
        assertEquals(2, model.bare_array[0]);
    }

    public function testPop()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1, 2],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        0,
            newValue:   0,
            type:       ActionType.ARRAY_POP
        });

        assertEquals(1, model.bare_array.length);
        assertEquals(1, model.bare_array[0]);
    }

    public function testShift()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1, 2],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        0,
            newValue:   0,
            type:       ActionType.ARRAY_SHIFT
        });

        assertEquals(1, model.bare_array.length);
        assertEquals(2, model.bare_array[0]);
    }

    public function testInsert()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1, 2],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        1,
            newValue:   7,
            type:       ActionType.ARRAY_INSERT
        });

        assertEquals(3, model.bare_array.length);
        assertEquals(1, model.bare_array[0]);
        assertEquals(7, model.bare_array[1]);
        assertEquals(2, model.bare_array[2]);
    }

    public function testRemove()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1, 7, 2],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        1,
            newValue:   null,
            type:       ActionType.ARRAY_REMOVE

        });

        assertEquals(2, model.bare_array.length);
        assertEquals(1, model.bare_array[0]);
        assertEquals(2, model.bare_array[1]);   
    }

    public function testIndex()
    {
        var model = new TestDump();

        model.process({
            path:       [],
            key:        'bare_array',
            newValue:   [1],
            type:       ActionType.PROP_CHANGE
        });

        model.process({
            path:       ['bare_array'],
            key:        0,
            newValue:   2,
            type:       ActionType.ARRAY_INDEX
        });

        assertEquals(2, model.bare_array[0]);
    }
}