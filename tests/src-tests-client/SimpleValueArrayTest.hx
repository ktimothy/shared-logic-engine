package ;

import haxe.unit.TestCase;

import sle.core.models.collections.ValueArray;

import models.TestDump;

class SimpleValueArrayTest extends TestCase
{
    private var _array:ValueArray<Int>;

    public function testWrongActionTypeThrows()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   []
        });

        // hack to avoid warning
        assertTrue(true);

        try
        {
            model.process({
                opName:     VAR,
                path:       ['bare_array', '0'],
                newValue:   [1] 
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
            path:       ['bare_array'],
            newValue:   [1]
        });

        model.process({
            opName:     PUSH,
            path:       ['bare_array', '0'],
            newValue:   2 
        });

        assertEquals(2, model.bare_array.length);
        assertEquals(2, model.bare_array[1]);
    }

    public function testUnshift()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1]
        });

        model.process({
            opName:     UNSHIFT,
            path:       ['bare_array', '0'],
            newValue:   2
        });

        assertEquals(2, model.bare_array.length);
        assertEquals(2, model.bare_array[0]);
    }

    public function testPop()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1, 2]
        });

        model.process({
            opName:     POP,
            path:       ['bare_array', '0'],
            newValue:   0 
        });

        assertEquals(1, model.bare_array.length);
        assertEquals(1, model.bare_array[0]);
    }

    public function testShift()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1, 2]
        });

        model.process({
            opName:     SHIFT,
            path:       ['bare_array', '0'],
            newValue:   0 
        });

        assertEquals(1, model.bare_array.length);
        assertEquals(2, model.bare_array[0]);
    }

    public function testInsert()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1, 2]
        });

        model.process({
            opName:     INSERT,
            path:       ['bare_array', '1'],
            newValue:   7
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
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1, 7, 2]
        });

        model.process({
            opName:     REMOVE,
            path:       ['bare_array', '1'],
            newValue:   null
        });

        assertEquals(2, model.bare_array.length);
        assertEquals(1, model.bare_array[0]);
        assertEquals(2, model.bare_array[1]);   
    }

    public function testIndex()
    {
        var model = new TestDump();

        model.process({
            opName:     VAR,
            path:       ['bare_array'],
            newValue:   [1]
        });

        model.process({
            opName:     INDEX,
            path:       ['bare_array', '0'],
            newValue:   2
        });

        assertEquals(2, model.bare_array[0]);
    }
}