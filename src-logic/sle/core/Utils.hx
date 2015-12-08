package sle.core;

class Utils
{
    // TODO: remove this code when SpiderMonkey bug is fixed
    public static inline function indexOf<T>(array:Array<T>, element:T, fromIndex:Int):Int
    {
        var result:Int = -1;

        if (fromIndex > 0 && fromIndex < array.length)
        {
            #if js
            for (i in fromIndex...array.length)
            {
                if (array[i] == element)
                {
                    result = i;
                    break;
                }
            }

            #else

            result = array.indexOf(element, fromIndex);

            #end
        }

        return result;
    }

    // TODO: remove this code when SpiderMonkey bug is fixed
    public static inline function lastIndexOf<T>(array:Array<T>, element:T, fromIndex:Int):Int
    {
        var result:Int = -1;

        if (fromIndex > 0 && fromIndex < array.length)
        {
            #if js

            do
            {
                if (array[fromIndex] == element)
                {
                    result = fromIndex;
                    break;
                }
            }
            while (fromIndex-- > 0);

            #else

            result = array.lastIndexOf(element, fromIndex);

            #end

        }

        return result;
    }

    #if (debug || tests)
    public static function hash(target:Dynamic):String
    {
        if (target == null) return 'null';

        if (Std.is(target, Bool)) return target ? '"true"' : '"false"';
        if (Std.is(target, String)) return '"$target"';

        if (Std.is(target, Float)) return Std.string(target);

        // (Array)
        if (Std.is(target, Array))
        {
            var source:Array<Dynamic> = cast target;
            var array:Array<String> = [];

            for (value in source)
            {
                array.push(hash(value));
            }

            return "[" + array.join(", ") + "]";
        }
        // (Object)
        else
        {
            // получаем список имен полей объекта
            var targetFieldNames = Reflect.fields(target);

            // сортируем имена полей в алфавитном порядке
            targetFieldNames.sort(Reflect.compare);

            // получаем сортированный массив полей, готовый для упаковки в json
            var jsonFields:Array<String> = [];

            for (name in targetFieldNames)
            {
                var value = hash(Reflect.field(target, name));
                jsonFields.push('"$name"' + ': ' + value);
            }

            return '{' + jsonFields.join(', ') + '}';
        }
    }
    #end

    public static function random(seed:Float):RandomResult
    {
        var nextSeed = (seed * 9301 + 49297) % 233280;
        var result = nextSeed / 233280.0;
        return {result: result, nextSeed: nextSeed};
    }

    inline public static function sortStringArray(a:Array<String>):Array<String>
    {
        #if cs
        cs.system.Array.Sort(((untyped a).__a : cs.system.Array), 0, a.length, cs.system.StringComparer.Ordinal);
        #elseif (js || flash)
        (untyped a.sort)();
        #else
        a.sort(Reflect.compare);
        #end

        return a;
    }

    inline public static function intToString(value:Int):String
    {
        #if (js || flash)
        return untyped String(value);
        #else
        return Std.string(value);
        #end
    }
}

typedef RandomResult = {
    result:Float,
    nextSeed: Float
}
