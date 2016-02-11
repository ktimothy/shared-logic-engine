package sle.core.models.collections;

import sle.shim.ActionType;
import sle.shim.Error;

import sle.core.actions.changes.impl.SimpleValueArrayChange;
import sle.core.actions.ActionLog;

class SimpleValueArrayBase<T> extends ValueArrayBase<T>
{
    public function new()
    {
        super();
    }

    private function getDefaultValue():T { throw new Error(throw 'Not implemented!'); }

    private function genericUpdateHash(oldValue:T, newValue:T):Void { throw new Error('Not implemented!'); }

    private function equals(oldValue:T, newValue:T):Bool
    {
        return oldValue == newValue;
    }

    @:final
    inline private function logChange(index:Int, type:ActionType, oldValue:T, newValue:T):Void
    {
        if (ActionLog._loggingEnabled && this.__isRooted)
        {
            var change = new SimpleValueArrayChange<T>(this, index, type, oldValue, newValue);
            ActionLog._actions.push(change);
        }
    }

    @:final
    override public function set(index:Int, value:T):T
    {
        this.assertWriteEnabled();

        if (index < 0) throw new Error("Index must be >= 0!");
        if (_data.length < index) throw new Error("Unable to set - index is out of bounds!");

        if (_data.length == index)
        {
            this.push(value);
            return value;
        }

        var oldValue:T = _data[index];

        if (this.equals(oldValue, value)) return value;

        _data[index] = value;

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.INDEX, oldValue, value);

        return value;
    }

    @:final
    override public function push(value:T):Int
    {
        this.assertWriteEnabled();

        var index:Int = _data.length;
        var oldValue:T = this.getDefaultValue();
        var result:Int = _data.push(value);

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.PUSH, oldValue, value);

        return result;
    }

    @:final
    override public function pop():T
    {
        this.assertWriteEnabled();
        if (_data.length == 0) throw new Error('Unable to preform pop on an empty array!');

        var index:Int = _data.length - 1;
        var oldValue:T = _data.pop();
        var value:T = this.getDefaultValue();

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.POP, oldValue, value);

        return oldValue;
    }

    @:final
    override public function shift():T
    {
        this.assertWriteEnabled();
        if (_data.length == 0) throw new Error('Unable to preform shift on an empty array!');

        var index:Int = 0;
        var oldValue:T = _data.shift();
        var value:T = this.getDefaultValue();

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.SHIFT, oldValue, value);

        return oldValue;
    }

    @:final
    override public function unshift(value:T):Void
    {
        this.assertWriteEnabled();

        var index:Int = 0;
        var oldValue:T = this.getDefaultValue();

        _data.unshift(value);

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.UNSHIFT, oldValue, value);
    }

    @:final
    override public function insert(index:Int, value:T):Void
    {
        this.assertWriteEnabled();

        if (index < 0) throw new Error('Index must be >= 0!');
        if (index > _data.length) throw new Error('Unable to insert - index is out of bounds!');

        var oldValue:T = this.getDefaultValue();

        _data.insert(index, value);

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.INSERT, oldValue, value);
    }

    @:final
    override public function remove(index:Int):T
    {
        this.assertWriteEnabled();

        if(index < 0) throw new Error('Index must be >= 0!');
        if (index >= _data.length) throw new Error('Can not remove - index is out of bounds!');

        var result:Array<T> = _data.splice(index, 1);
        var oldValue:T = result[0];
        var value:T = this.getDefaultValue();

        this.genericUpdateHash(oldValue, value);

        this.logChange(index, ActionType.REMOVE, oldValue, value);

        return oldValue;
    }

    @:final
    override private function fromObject(dump:Dynamic):Void
    {
        this.reset();

        var array:Array<Dynamic> = cast dump;

        for (value in array)
        {
            this.push(value);
        }
    }

    @final
    override private function fromArray(dumpArray:Dynamic):Void
    {
        this.fromObject(dumpArray);
    }

    @:final
    override private function toObject(expectedTypeName:String = null):Dynamic
    {
        if (expectedTypeName != this.getTypeName())
        {
            throw new Error('Unable to serialize ${this.getTypeName()} as $expectedTypeName!');
        }

        var result = new Array<Dynamic>();

        for (value in _data)
        {
            result.push(value);
        }

        return result;
    }

    @:final
    override private function toArray(expectedTypeName:String = null):Dynamic
    {
        return this.toObject(expectedTypeName);
    }

    @:final
    override private function setRooted(value:Bool):Void
    {
        __isRooted = value;
    }
}
