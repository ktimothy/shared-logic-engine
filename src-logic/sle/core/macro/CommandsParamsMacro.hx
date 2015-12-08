package sle.core.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

@:dce
class CommandsParamsMacro
{
    public static function build():Array<Field>
    {
        var fields = haxe.macro.Context.getBuildFields();
        var pos:Position = Context.currentPos();

        for (field in fields)
        {
            if(field.name != 'execute') continue;

            switch (field.kind)
            {
                case FFun(def):
                    // allow only Void return type for 'execute' method
                    switch(def.ret)
                    {
                        case TPath(_ => {name: 'Void'}):
                        default:
                            throw new Error("Method 'execute' must return Void!", field.pos);
                    }

                    // allow only simple types and Const<T>
                    for(arg in def.args)
                    {
                        switch(arg.type)
                        {
                            case TPath({name: 'String' | 'Const' | 'Int' | 'Bool' | 'Float'}):
                                // these types are valid
                                // not that we do not check parameter of Const -it is because ConstMacro will do it for us

                            case TPath({name: t}):
                                throw new Error('Invalid type of argument - ${t}! Only Const<T>, String, Bool, Int, Float are allowed!', field.pos);

                            case null:
                                throw new Error('Argument should have a type! Only Const<T>, String, Bool, Int, Float are allowed!', field.pos);

                            default:
                                throw new Error('Invalid type of argument! Only Const<T>, String, Bool, Int, Float are allowed!', field.pos);
                        }
                    }
                default:
                    continue;
            }
        }

        return fields;
    }
}
#end
