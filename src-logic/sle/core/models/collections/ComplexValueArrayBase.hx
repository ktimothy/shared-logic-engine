package sle.core.models.collections;

import sle.shim.ActionType;
import sle.shim.Error;

import sle.core.actions.changes.impl.ComplexValueArrayChange;
import sle.core.actions.ActionLog;
import sle.core.Utils;

class ComplexValueArrayBase<T:ValueBase> extends ValueArrayBase<T>
{
    public var _elementExpectedTypeName:String;

    public function new()
    {
        super();
    }

    private function createElement():T { throw 'Not implemented!'; }

    @:final
    inline private function logChange(index:Int, type:ActionType, oldValue:T, newValue:T):Void
    {
        if (ActionLog._loggingEnabled && this.__isRooted)
        {
            var change = new ComplexValueArrayChange<T>(this, index, type, oldValue, newValue, _elementExpectedTypeName);
            ActionLog._actions.push(change);
        }
    }

    @:final
    inline private function reparentAll():Void
    {
        for (index in 0..._data.length)
        {
            var value = _data[index];
            if (value != null) this.setParent(value, Utils.intToString(index), true);
        }
    }

    @:final
    override private function setRooted(value:Bool):Void
    {
        if (__isRooted == value) return;

        __isRooted = value;

        for (element in _data)
        {
            if (element != null) element.setRooted(value);
        }
    }

    @:final
    override public function set(index:Int, value:T):T
    {
        this.assertWriteEnabled();
        if (index < 0) throw new Error('Index must be >= 0!');
        if (_data.length < index) throw new Error('Unable to set - index is out of bounds!');

        if (_data.length == index)
        {
            this.push(value);
            return value;
        }

        var oldValue:T = _data[index];

        if (oldValue == value) return value;

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        if (value != null)
        {
            this.setParent(value, Utils.intToString(index));
            value.setRooted(__isRooted);
        }

        _data[index] = value;

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.INDEX, oldValue, value);

        return value;
    }

    @:final
    override public function push(value:T):Int
    {
        this.assertWriteEnabled();

        var index:Int = _data.length;
        var oldValue:T = null;

        if (value != null)
        {
            this.setParent(value, Utils.intToString(index));
            value.setRooted(__isRooted);
        }

        var result:Int = _data.push(value);

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.PUSH, oldValue, value);

        return result;
    }

    @:final
    override public function pop():T
    {
        this.assertWriteEnabled();
        if (_data.length == 0) throw new Error('Unable to preform pop on an empty array!');

        var index:Int = _data.length - 1;
        var oldValue = _data.pop();
        var value:T = null;

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.POP, oldValue, value);

        return oldValue;
    }

    @:final
    override public function shift():T
    {
        this.assertWriteEnabled();
        if (_data.length == 0) throw new Error('Unable to preform shift on an empty array!');

        var index:Int = 0;
        var value:T = null;
        var oldValue:T = _data.shift();

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        this.reparentAll();

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.SHIFT, oldValue, value);

        return oldValue;
    }

    @:final
    override public function unshift(value:T):Void
    {
        this.assertWriteEnabled();

        var index:Int = 0;
        var oldValue:T = null;

        if (value != null)
        {
            this.setParent(value, Utils.intToString(index));
            value.setRooted(__isRooted);
        }

        _data.unshift(value);

        this.reparentAll();

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.UNSHIFT, oldValue, value);
    }

    @:final
    override public function insert(index:Int, value:T):Void
    {
        this.assertWriteEnabled();
        if (index < 0) throw new Error('Index must be >= 0!');
        if (index > _data.length) throw new Error('Unable to insert - index is out of bounds!');

        var oldValue:T = null;

        if (value != null)
        {
            this.setParent(value, Utils.intToString(index));
            value.setRooted(__isRooted);
        }

        _data.insert(index, value);

        this.reparentAll();

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.INSERT, oldValue, value);
    }

    @:final
    override public function remove(index:Int):T
    {
        this.assertWriteEnabled();
        if (index < 0) throw new Error('Index must be >= 0!');
        if (index >= _data.length) throw new Error('Unable to remove - index is out of bounds!');

        var result:Array<T> = _data.splice(index, 1);
        var oldValue:T = result[0];
        var value:T = null;

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        this.reparentAll();

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(index, ActionType.REMOVE, oldValue, value);

        return oldValue;
    }

    @:final
    override private function fromObject(dump:Array<Dynamic>):Void
    {
        this.reset();

        for (v in dump)
        {
            var value:T = null;

            if (v != null)
            {
                if (!Reflect.hasField(v, '__type') || Reflect.field(v, '__type') == _elementExpectedTypeName)
                {
                    value = this.createElement();
                }
                else
                {
                    var cl = Type.resolveClass(Reflect.field(v, '__type'));
                    value = Type.createInstance(cl, []);
                }

                value.fromObject(v);
            }

            this.push(value);
        }
    }

    @:final
    override private function fromArray(dumpArray:Dynamic):Void
    {
        this.reset();

        var array:Array<Dynamic> = cast dumpArray;

        for (v in array)
        {
            var value:T = null;

            if (v != null)
            {
                if (!Reflect.hasField(v, '__type') || Reflect.field(v, '__type') == _elementExpectedTypeName)
                {
                    value = this.createElement();
                }
                else
                {
                    var cl = Type.resolveClass(Reflect.field(v, '__type'));
                    value = Type.createInstance(cl, []);
                }

                value.fromArray(v);
            }

            this.push(value);
        }
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
            result.push(value == null ? null : value.toObject(_elementExpectedTypeName));
        }

        return result;
    }

    @:final
    override private function toArray(expectedTypeName:String = null):Dynamic
    {
        if (expectedTypeName != this.getTypeName())
        {
            throw new Error('Unable to serialize ${this.getTypeName()} as $expectedTypeName!');
        }

        var result = new Array<Dynamic>();

        for (value in _data)
        {
            result.push(value == null ? null : value.toArray(_elementExpectedTypeName));
        }

        return result;
    }
}
