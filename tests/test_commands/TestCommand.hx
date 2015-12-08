package test_commands;

import test_queries.SimpleQuery;
import test_models.TestDump;
import sle.core.commands.CommandBase;


class TestCommand extends CommandBase<TestDump>
{
    override public function execute(?params:String):Void
    {
        var string:String = "test_string";
        var queryResult:String = this.queries.execute(SimpleQuery, string);

        model.string = params;
        model.inner.string = queryResult + string + params;
    }
}
