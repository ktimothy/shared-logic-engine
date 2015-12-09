package;

import haxe.unit.TestCase;

import sle.shim.ActionDump;

class BatchTest extends TestCase
{
    private var dump:Dynamic;
    private var context:DemoContext;
    private var batch:Array<CommandResult>;

    override public function setup():Void
    {
        dump = TestUtils.getTestDump();

        context = new DemoContext(new TestEnvironment());
        context.fromObject(dump);
    }

    public function testBatch():Void
    {
        batch = [];

        for(i in 0...100) this.execute('incrementInteger');
        for(i in 0...10) this.execute('pushBareArray');
        this.execute('shuffleArray');
        for(i in 0...10) this.execute('popBareArray');
        this.execute('shuffleArray');
        this.execute('setNothingToNull');
        this.execute('setNothingToValue');
        this.execute('setNothingToNull');
        this.execute('setNothingToValue');
        this.execute('setNothingToNull');
        this.execute('setNothingToValue');
        for(i in 0...100) this.execute('incrementInteger');

        var hash = batch[batch.length - 1].hash;

        // ok now there is a batch with 200+ commands in it
        // lets just reinit context and run all thoose commands again
        this.setup();

        var result:CommandResult = null;
        for(command in batch) result = context.execute(command.name, command.hash);

        assertEquals(hash, result.hash);
    }

    private function execute(commandName:String, ?hash = null):Void
    {
        var result:CommandResult = context.execute(commandName, null, hash);

        batch.push(result);
    }
}


typedef CommandResult = {
    public var name:String;
    public var params:Dynamic;
    public var actions:Array<ActionDump>;
    public var exchangables:Array<Dynamic>;
    
    public var error: {
        message: String,
        stack: String
    };

#if debug
    public var hash:String;
    #else
    public var hash:Float;
#end
};