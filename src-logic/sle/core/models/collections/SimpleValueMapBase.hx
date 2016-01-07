package sle.core.models.collections;

import sle.shim.ActionType;

import sle.core.actions.ActionLog;
import sle.core.actions.changes.impl.SimpleValueMapChange;

class SimpleValueMapBase<T> extends ValueMapBase<T>
{
    public function new()
    {
        super();
    }

    private function getDefaultValue():T { throw new Error('Not implemented!'); }

    private function genericUpdateHash(oldValue:T, newValue:T):Void { throw new Error('Not implemented!'); }

    private function equals(oldValue:T, newValue:T):Bool
    {
        return oldValue == newValue;
    }

    @:final
    inline private function logChange(key:String, type:ActionType, oldValue:T, newValue:T):Void
    {
        if (ActionLog._loggingEnabled && this.__isRooted)
        {
            var change = new SimpleValueMapChange<T>(this, key, type, oldValue, newValue);
            ActionLog._actions.push(change);
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

        if (this.equals(oldValue, value)) return value;

        _data[key] = value;

        this.genericUpdateHash(oldValue, value);

        this.logChange(key, ActionType.INDEX, oldValue, value);

        return value;
    }

    @:final
    override private function insert(key:String, value:T):Void
    {
        var oldValue:T = this.getDefaultValue();

        _data[key] = value;

        this.genericUpdateHash(oldValue, value);

        this.logChange(key, ActionType.INSERT, oldValue, value);
    }

    @:final
    override public function remove(key:String):T
    {
        this.assertWriteEnabled();
        if (!_data.exists(key)) throw new Error('Key $key does not exist!');

        var oldValue:T = _data[key];
        var value:T = this.getDefaultValue();

        _data.remove(key);

        this.genericUpdateHash(oldValue, value);

        this.logChange(key, ActionType.REMOVE, oldValue, value);

        return oldValue;
    }

    @:final
    override private function fromObject(dump:Dynamic):Void
    {
        this.reset();

        for (field in Reflect.fields(dump))
        {
            if (field == '__type') continue;

            this.set(field, cast Reflect.field(dump, field));
        }
    }

    @:final
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

        var result:Dynamic = {};

        for (field in _data.keys())
        {
            Reflect.setField(result, field, _data[field]);
        }

        return result;
    }

    @:final
    override private function toArray(expectedTypeName:String = null):Dynamic
    {
        return this.toObject(expectedTypeName);
    }

    @:final
    inline override private function setRooted(value:Bool):Void
    {
        __isRooted = value;
    }
}
