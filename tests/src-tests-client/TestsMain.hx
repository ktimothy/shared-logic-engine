package;

#if flash
import flash.display.StageScaleMode;
import flash.Lib;
#end


class TestsMain
{
    public static function main():Void
    {
        #if flash
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        #end

        var r = new haxe.unit.TestRunner();

        r.add(new ValueTest());
        
        r.run();
    }
}
