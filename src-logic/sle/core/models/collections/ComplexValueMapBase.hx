package sle.core.models.collections;

import sle.core.actions.changes.impl.ComplexValueMapChange;
import sle.core.actions.ActionLog;

import sle.shim.ActionType;
import sle.shim.Error;

class ComplexValueMapBase<T:ValueBase> extends ValueMapBase<T>
{
    public var _elementExpectedTypeName:String;

    public function new()
    {
        super();
    }

    private function createElement():T { throw new Error('Not implemented!'); }

    @:final
    inline private function logChange(key:String, type:ActionType, oldValue:T, newValue:T):Void
    {
        if (ActionLog._loggingEnabled && this.__isRooted)
        {
            var change = new ComplexValueMapChange<T>(this, key, type, oldValue, newValue, _elementExpectedTypeName);
            ActionLog._actions.push(change);
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
    override public function set(key:String, value:T):T
    {
        this.assertWriteEnabled();

        if (!_data.exists(key))
        {
            this.insert(key, value);
            return value;
        }

        var oldValue:T = _data[key];

        if (oldValue == value) return value;

        _data[key] = value;

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        if (value != null)
        {
            this.setParent(value, key);
            value.setRooted(__isRooted);
        }

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(key, ActionType.MAP_KEY, oldValue, value);

        return value;
    }

    @:final
    override private function insert(key:String, value:T):Void
    {
        var oldValue:T = null;

        _data[key] = value;

        if (value != null)
        {
            this.setParent(value, key);
            value.setRooted(__isRooted);
        }

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(key, ActionType.MAP_INSERT, oldValue, value);
    }

    @:final
    override public function remove(key:String):T
    {
        this.assertWriteEnabled();
        if (!_data.exists(key)) throw new Error('Key $key does not exist!');

        var oldValue:T = _data[key];
        var value:T = null;

        _data.remove(key);

        if (oldValue != null)
        {
            this.removeParent(oldValue);
            oldValue.setRooted(false);
        }

        this.updateHash(this.hashOfValueBase(oldValue), this.hashOfValueBase(value));

        this.logChange(key, ActionType.MAP_REMOVE, oldValue, value);

        return oldValue;
    }

    @:final
    override private function fromObject(dump:Dynamic):Void
    {
        this.reset();

        for (key in Reflect.fields(dump))
        {
            var value:T = null;
            var v:Dynamic = Reflect.field(dump, key);

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

            _data[key] = value;
        }
    }

    @final
    override private function fromArray(dumpArray:Dynamic):Void
    {
        this.reset();

        for (key in Reflect.fields(dumpArray))
        {
            var value:T = null;
            var v:Dynamic = Reflect.field(dumpArray, key);

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

            _data[key] = value;
        }
    }

    @:final
    override private function toObject(expectedTypeName:String = null):Dynamic
    {
        if (expectedTypeName != this.getTypeName())
        {
            throw new Error('Unable to serialize ${this.getTypeName()} as $expectedTypeName!');
        }

        var result:Dynamic = {};

        for (key in _data.keys())
        {
            Reflect.setField(result, key, _data[key] == null ? null :  _data[key].toObject(_elementExpectedTypeName));
        }

        return result;
    }

    @final
    override private function toArray(expectedTypeName:String = null):Dynamic
    {
        if (expectedTypeName != this.getTypeName())
        {
            throw new Error('Unable to serialize ${this.getTypeName()} as $expectedTypeName!');
        }

        var result:Dynamic = {};

        for (key in _data.keys())
        {
            Reflect.setField(result, key, _data[key] == null ? null :  _data[key].toArray(_elementExpectedTypeName));
        }

        return result;
    }
}
