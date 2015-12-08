package test_context;

import sle.core.Const;
import sle.core.CommandParamsBase;
import test_models.InnerModel;
import test_models.TestDump;
import sle.core.models.collections.ValueArray;
import sle.core.ContextBase;
import sle.core.queries.QueryBase;
import sle.core.commands.CommandBase;
import sle.core.Utils;

class DemoContext extends ContextBase<TestDump>
{
    public static function main() {}

    override private function init()
    {
        this.commands.addExternal('incrementInteger', IncrementIntegerCommand);
        this.queries.addExternal('getInteger', GetIntegerQuery);

        this.commands.addExternal('pushBareArray', PushBareArrayCommand);
        this.commands.addExternal('popBareArray', PopBareArrayCommand);
        this.queries.addExternal('getBareArrayLength', GetBareArrayLengthQuery);

        this.commands.addExternal('setNothingToNull', SetNothingToNullCommand);
        this.commands.addExternal('setNothingToValue', SetNothingToValueCommand);
        this.commands.addExternal('shuffleArray', ShuffleArrayCommand);
    }
}

class IncrementIntegerCommand extends CommandBase<TestDump>
{
    override public function execute(?args:Const<CommandParamsBase>):Void
    {
        this.model.integer += 1;
    }
}

class GetIntegerQuery extends QueryBase<TestDump>
{
    override public function execute(?params:Dynamic):Dynamic
    {
        return this.model.integer;
    }
}

class PushBareArrayCommand extends CommandBase<TestDump>
{
    override public function execute(?args:Const<CommandParamsBase>):Void
    {
        this.model.bare_array.push(this.model.bare_array.length);
    }
}

class PopBareArrayCommand extends CommandBase<TestDump>
{
    override public function execute(?args:Const<CommandParamsBase>):Void
    {
        this.model.bare_array.pop();
    }
}

class GetBareArrayLengthQuery extends QueryBase<TestDump>
{
    override public function execute(?params:Dynamic):Dynamic
    {
        return this.model.bare_array.length;
    }
}

class SetNothingToNullCommand extends CommandBase<TestDump>
{
    override public function execute(?params:Const<CommandParamsBase>):Void
    {
        this.model.nothing = null;
    }
}

class SetNothingToValueCommand extends CommandBase<TestDump>
{
    override public function execute(?params:Const<CommandParamsBase>):Void
    {
        this.model.nothing = new InnerModel();
    }
}

class ShuffleArrayCommand extends CommandBase<TestDump>
{
    override public function execute(?params:Const<CommandParamsBase>):Void
    {
        var array:ValueArray<Int> = model.bare_array;
        var len:Int = array.length;
        var seed:Float = 123.321;
        var nextSeed:Float = 0;

        for(i in 0...len)
        {
            var rnd = Utils.random(seed);
            seed = rnd.nextSeed;

            var element:Int = array.shift();
            var index:Int = Math.round(rnd.result * array.length);

            array.insert(index, element);
        }
    }
}
