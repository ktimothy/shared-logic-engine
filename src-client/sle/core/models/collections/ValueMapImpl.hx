package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;

import sle.core.models.ValueBase;
import sle.core.models.Constructable;

enum ValueMapKind
{
    Simple;
    Complex;
}

class ValueMapImpl<T> extends ValueBase
{
    private var _kind:ValueMapKind;
    private var _factory:Void->T;
    private var _data:StringMap<T>;

    public function new(type:ValueMapKind, factory:Void->T)
    {
        super();

        _kind = type;
        _factory = factory;
        _data = new StringMap<T>();
    }

    public function get(key:String):T return _data.get(key);
    public function set(key:String, value:T):Void _data.set(key, value);
    public function remove(key:String):Bool return _data.remove(key);
    public function exists(key:String):Bool return _data.exists(key);

    override public function process(action:ActionDump):Void
    {
        switch(_kind)
        {
            case Simple:

                if(action.path.length > 1)
                    throw new sle.core.Error('Expected a simple action (path.length == 1), got complex: $action');

                set(action.path[0], action.newValue);

            case Complex:

                // trace('Processing action: $action');

                if(action.path.length == 1)
                {
                    var inst:T = Reflect.hasField(action.newValue, '__type')
                        ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                        : _factory();

                    set(action.path[0], inst);

                    for(fieldName in Reflect.fields(action.newValue))
                    {
                        if(fieldName == '__type')
                            continue;

                        (cast inst).process({
                            opName:     'var',
                            path:       [fieldName],
                            newValue:   Reflect.field(action.newValue, fieldName)
                        });
                    }
                }
                else
                {
                    (cast get(action.path.shift())).process(action);
                }       
        }
    }
}