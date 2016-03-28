package sle.core.models.collections;

import haxe.ds.StringMap;

import sle.shim.ActionDump;
import sle.shim.ActionType;
import sle.shim.Error;

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
    public function exists(key:String):Bool return _data.exists(key);

    override public function process(action:ActionDump):Void
    {
        if (action.path.length > 0)
        {
            this.get(action.path.shift()).process(action);
        }
        else
        {
            switch (action.type)
            {
                case ActionType.MAP_KEY | ActionType.MAP_INSERT:

                    if (action.newValue == null)
                    {
                        _data.set(cast action.key, null);
                    }
                    else
                    {
                        var inst:T = Reflect.hasField(action.newValue, '__type')
                        ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                        : _factory();

                        _data.set(cast action.key, inst);

                        for(fieldName in Reflect.fields(action.newValue))
                        {
                            if(fieldName == '__type')
                                continue;

                            inst.process({
                                path:       [],
                                key:        fieldName,
                                newValue:   Reflect.field(action.newValue, fieldName),
                                type:       ActionType.PROP_CHANGE
                            });
                        }
                    }

                case ActionType.MAP_REMOVE:
                    _data.remove(cast action.key);

                default:
                    throw new Error('Wrong action type "${action.type}" for ValueMap');
            }
        }
    }
}
