package commands;

import sle.core.Const;
import sle.core.commands.CommandBase;
import models.TestDump;

class ExternalCommand extends CommandBase<TestDump>
{
    override public function execute(?params:Const<{arg:String}>):Void
    {
        commands.execute(TestCommand, params.arg);
    }
}
