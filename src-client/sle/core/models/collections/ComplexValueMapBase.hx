package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;

class ComplexValueMapBase<T:ValueBase> extends ValueBase
{
    private var _factory:Void->T;
    private var _data:StringMap<T>;

    public function new(factory:Void->T)
    {
        super();

        _factory = factory;

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
                : _factory();

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