package ;

import test_context.TestContext;
import haxe.unit.TestCase;

class ContextTest extends TestCase
{
    private var dump:Dynamic;
    private var context:TestContext;

    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        context = new TestContext(new TestEnvironment());
        context.fromObject(dump);
    }

    public function testContext():Void
    {
        var commandResult = context.execute("command", { arg: "string_arg" });

        assertEquals(Std.string({ result: "query_arg", error: null }), Std.string(context.query("query", "query_arg")));
        assertEquals("test_stringtest_stringstring_arg", context.toObject().inner.string);
    }

    public function testQueryError():Void
    {
        var result:Dynamic = context.query('writing_query', {});

        assertTrue(result.result == null);
        assertEquals("Unable to write value!", result.error.message);
    }
}
