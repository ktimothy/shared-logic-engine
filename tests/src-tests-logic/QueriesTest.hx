package ;

import queries.WritingQuery;
import queries.ExternalQuery;
import queries.SimpleQuery;
import sle.core.queries.Queries;
import models.TestDump;
import haxe.unit.TestCase;
import sle.shim.Error;

class QueriesTest extends TestCase
{
    private var model:TestDump;
    private var dump:Dynamic;
    private var queries:Queries<TestDump>;

    @:access(sle.core.models.ValueBase)
    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        model = new TestDump();
        model.fromObject(dump);
        queries = new Queries<TestDump>(model, null);
    }

    public function testSimple():Void
    {
        var params:Dynamic = {a: 4};

        assertEquals(params, queries.execute(SimpleQuery, params));
    }

    public function testExternal():Void
    {
        var params:Dynamic = [5,2];

        queries.addExternal("fuuu", ExternalQuery);
        assertEquals( params, queries.executeExternal("fuuu", params));
    }

    public function testWriteLock():Void
    {
        var error = null;

        try
        {
            queries.execute(WritingQuery, {});
        }
        catch(err:Error)
        {
            error = err;
        }

        assertTrue(error != null);
        assertEquals("Unable to write value!", error.message);

        // test that write is enabled now
        model.integer--;
    }
}
