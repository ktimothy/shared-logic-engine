package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;

import sle.core.models.Constructable;

class ComplexValueMapBase<T:(ValueBase, Constructable)> extends ValueBase
{
    private var _data:StringMap<T>;

    public function new()
    {
        super();

        _data = new StringMap<T>();
    }

    public function get(key:String):T return _data.get(key);
    public function set(key:String, value:T):Void _data.set(key, value);
    public function remove(key:String):Bool return _data.remove(key);
    public function exists(key:String):Bool return _data.exists(key);

    override public function process(action:ActionDump):Void
    {
        if(action.path.length == 1)
        {
            var inst:T = Reflect.hasField(action.newValue, '__type')
                ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                : Factory.make();

            this.set(action.path[0], inst);

            for(fieldName in Reflect.fields(action.newValue))
            {
                if(fieldName == '__type')
                    continue;

                inst.process({
                    opName:     'var',
                    path:       [fieldName],
                    newValue:   Reflect.field(action.newValue, fieldName)
                });
            }
        }
        else
        {
            get(action.path.shift()).process(action);
        }
    }
}

class Factory
{
    @:generic public static function make<T:(ValueBase, Constructable)>():T return new T();
}