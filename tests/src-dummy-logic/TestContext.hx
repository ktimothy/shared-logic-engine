package ;

import sle.shim.IContext;
import sle.shim.IEnvironment;

import sle.core.ContextBase;

import commands.ExternalCommand;
import queries.ExternalQuery;
import queries.WritingQuery;
import models.TestDump;

class TestContext extends ContextBase<TestDump> implements IContext
{
    public function new(env:IEnvironment)
    {
        super(env);
    }

    override public function init():Void
    {
        this.queries.addExternal("query", ExternalQuery);
        this.queries.addExternal("writing_query", WritingQuery);
        this.commands.addExternal("command", ExternalCommand);
        //this.commands.addExternal("failing_command", FailingCommand);
    }
}
