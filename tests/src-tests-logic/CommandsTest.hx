package ;

import commands.ExternalCommand;
import commands.TestCommand;
import sle.core.commands.Commands;
import sle.core.queries.Queries;
import models.TestDump;
import haxe.unit.TestCase;

class CommandsTest extends TestCase
{
    private var model:TestDump;
    private var dump:Dynamic;
    private var queries:Queries<TestDump>;
    private var commands:Commands<TestDump>;

    @:access(sle.core.models.ValueBase)
    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        model = new TestDump();
        model.fromObject(dump);
        queries = new Queries<TestDump>(model, null);
        commands = new Commands<TestDump>(model, queries, null);
    }

    public function testSimple():Void
    {
        commands.execute(TestCommand, "ololo");

        assertEquals("ololo", model.string);
    }

    public function testExternal():Void
    {
        commands.addExternal("oops", ExternalCommand);
        commands.executeExternal("oops", { arg: "ololosh" });

        assertEquals("ololosh", model.string);
    }
}
