package sle.core.models.collections;

import sle.shim.ActionDump;

class ComplexValueArrayBase<T:ValueBase> extends ValueBase
{
    private var _factory:Void->T;
    private var _data:Array<T>;

    public function new(factory:Void->T)
    {
        super();

        _factory = factory;

        _data = new Array<T>();
    }

    public function get(key:Int):T return _data[key];
    public function set(key:Int, value:T):Void _data[key] = value;

    override public function process(action:ActionDump):Void
    {
        if(action.path.length == 1)
        {
            var inst:T = Reflect.hasField(action.newValue, '__type')
                ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                : _factory();

            set(Std.parseInt(action.path[0]), inst);

            for(fieldName in Reflect.fields(action.newValue))
            {
                if(fieldName == '__type')
                    continue;

                inst.process({
                    opName:     VAR,
                    path:       [fieldName],
                    newValue:   Reflect.field(action.newValue, fieldName)
                });
            }
        }
        else
        {
            get(Std.parseInt(action.path.shift())).process(action);
        }
    }
}