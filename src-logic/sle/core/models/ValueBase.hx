package sle.core.models;

import sle.core.actions.ActionLog;
import sle.shim.Error;

class ValueBase
{
    private static inline var PRECISION:Float = 1e4;
    private static inline var DIVISOR:Float = 1e6;

    @:allow(sle.core.actions.changes.base.ChangeBase)
    private var __name:String;

    @:allow(sle.core.actions.changes.base.ChangeBase)
    private var __parent:ValueBase;

    @:allow(sle.core.ContextBase)
    private var __hash:Float;

    private var __isRooted:Bool;

    public function new()
    {
        __name = null;
        __parent = null;
        __hash = 1;
        __isRooted = false;
    }

    @:dce
    public function getTypeName():String { throw new Error('Not implemented!'); }

    @:allow(sle.core.ContextBase)
    private function fromObject(dump:Dynamic):Void { throw new Error('Not implemented!'); }

    @:allow(sle.core.ContextBase)
    private function fromArray(dumpArray:Dynamic):Void { throw new Error('Not implemented!'); }

    @:allow(sle.core.ContextBase)
    @:allow(sle.core.actions.changes.base.ChangeBase)
    private function toObject(expectedTypeName:String = null):Dynamic { throw new Error('Not implemented!'); }

    @:allow(sle.core.ContextBase)
    private function toArray(expectedTypeName:String = null):Dynamic { throw new Error('Not implemented!'); }

    @:allow(sle.core.ContextBase)
    private function setRooted(value:Bool):Void { throw new Error('Not implemented!'); }

    private function init() {}

    @:final
    inline private function removeParent(value:ValueBase):Void
    {
        value.__parent = null;
        value.__name = null;
    }

    @:final
    inline private function setParent(value:ValueBase, key:String, allowReparent:Bool = false):Void
    {
        if (value.__parent != null && !allowReparent) new Error(throw 'Unable to re-parent value!');

        value.__parent = this;
        value.__name = key;
    }

    @:final
    private function updateHash(fieldOldHash:Float, fieldNewHash:Float):Void
    {
        var myOldHash = __hash;

        fieldOldHash = round(fieldOldHash);
        fieldNewHash = round(fieldNewHash);

        var myNewHash:Float = round(myOldHash - fieldOldHash + fieldNewHash);

        __hash = myNewHash;

        if (__parent != null) __parent.updateHash(myOldHash, myNewHash);
    }

    @:final
    private function round(float:Float):Float
    {
        var modulo = (float > DIVISOR || float < -DIVISOR) ? float %= DIVISOR : float;
        return Math.round(modulo * PRECISION) / PRECISION;
    }

    @:final
    inline private function hashOfBool(value:Bool):Float
    {
        return value ? 1 : 0;
    }

    @:final
    inline private function hashOfInt(value:Int):Float
    {
        return value;
    }

    @:final
    inline private function hashOfFloat(value:Float):Float
    {
        // haxe generates invalid bytecode for Math.isNaN: it leaves exactly call to static method isNaN of class Math
        // but actionscript does not have Math.isNaN function, it only appears after patching Math class at runtime
        // I do not want haxe neither to patch sle.core flash classes at runtime nor to poop into my output with its classes

        // the same happens to Math.isFinite

        // platform-dependent code
        #if flash

        if (untyped __global__["isNaN"](value)) return 0;
        if (!(untyped __global__["isFinite"](value))) return ((value > 0) ? 1 : -1);

        #else
        if (Math.isNaN(value)) return 0;
        if (!Math.isFinite(value)) return ((value > 0) ? 1 : -1);
        #end

        return value;
    }

    @:final
    inline private function hashOfString(value:String):Float
    {
        var result:Int = 0;

        if (value != null)
        {
            var len = value.length;
            while (len-- > 0)
            {
                result += StringTools.fastCodeAt(value, len);
            }
        }

        return result;
    }

    @:final
    inline private function hashOfValueBase(value:ValueBase):Float
    {
        return value == null ? 0 : value.__hash;
    }

    @:final
    inline private function assertWriteEnabled():Void
    {
        if (!ActionLog._valueWriteEnabled) throw new Error('Unable to write value!');
    }
}
