package ;

import haxe.unit.TestCase;

import sle.core.models.collections.ValueArray;

import models.TestDump;

class ComplexValueArrayTest extends TestCase
{
    private var _array:ValueArray<Int>;

    public function testWrongActionTypeThrows()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   []
        });

        // hack to avoid warning
        assertTrue(true);

        try
        {
            model.process({
                opName:     VAR,
                path:       ['complex_array', '0'],
                newValue:   [{x: 0.0, y: 0.0}]
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
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}]
        });

        model.process({
            opName:     PUSH,
            path:       ['complex_array', '0'],
            newValue:   {x: 1.0, y: 1.0}
        });

        assertEquals(2, model.complex_array.length);

        assertEquals(1.0, model.complex_array[1].x);
        assertEquals(1.0, model.complex_array[1].y);
    }

    public function testUnshift()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}]
        });

        model.process({
            opName:     UNSHIFT,
            path:       ['complex_array', '0'],
            newValue:   {x: 1.0, y: 1.0}
        });

        assertEquals(2, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }

    public function testPop()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}, {x: 1.0, y: 1.0}]
        });

        model.process({
            opName:     POP,
            path:       ['complex_array', '0'],
            newValue:   0
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(0.0, model.complex_array[0].x);
        assertEquals(0.0, model.complex_array[0].y);
    }

    public function testShift()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}, {x: 1.0, y: 1.0}]
        });

        model.process({
            opName:     SHIFT,
            path:       ['complex_array', '0'],
            newValue:   0 
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }

    public function testInsert()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}, {x: 1.0, y: 1.0}]
        });

        model.process({
            opName:     INSERT,
            path:       ['complex_array', '1'],
            newValue:   {x: 7.0, y: 7.0}
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
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}, {x: 7.0, y: 7.0}, {x: 1.0, y: 1.0}]
        });

        model.process({
            opName:     REMOVE,
            path:       ['complex_array', '1'],
            newValue:   null
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
            opName:     VAR,
            path:       ['complex_array'],
            newValue:   [{x: 0.0, y: 0.0}]
        });

        model.process({
            opName:     INDEX,
            path:       ['complex_array', '0'],
            newValue:   {x: 1.0, y: 1.0}
        });

        assertEquals(1, model.complex_array.length);

        assertEquals(1.0, model.complex_array[0].x);
        assertEquals(1.0, model.complex_array[0].y);
    }
}