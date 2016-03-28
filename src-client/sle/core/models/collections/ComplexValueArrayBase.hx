package sle.core.models.collections;

import sle.shim.ActionDump;
import sle.shim.ActionType;
import sle.shim.Error;

class ComplexValueArrayBase<T:ValueBase> extends ValueBase
{
    public var length(get, never):UInt;

    private var _factory:Void->T;
    private var _data:Array<T>;

    public function new(factory:Void->T)
    {
        super();

        _factory = factory;

        _data = new Array<T>();
    }

    public function get_length():UInt return _data.length;
    public function get(key:Int):T return _data[key];

    override public function process(action:ActionDump):Void
    {
        if (action.path.length > 0)
        {
            this.get(Std.parseInt(action.path.shift())).process(action);
        }
        else
        {
            switch (action.type)
            {
                case ActionType.ARRAY_PUSH:
                    var element = createElement(action);
                    _data.push(element);
                    updateElement(element, action);

                case ActionType.ARRAY_POP:
                    _data.pop();

                case ActionType.ARRAY_UNSHIFT:
                    var element = createElement(action);
                    _data.unshift(element);
                    updateElement(element, action); 

                case ActionType.ARRAY_SHIFT:
                    _data.shift();

                case ActionType.ARRAY_INSERT:
                    var element = createElement(action);
                    _data.insert(cast action.key, element);
                    updateElement(element, action);

                case ActionType.ARRAY_REMOVE:
                    _data.splice(cast action.key, 1);

                case ActionType.ARRAY_INDEX:
                    var element = createElement(action);
                    _data[cast action.key] = element;
                    updateElement(element, action);

                default:
                    throw new Error('Wrong action type "${action.type}" for ValueArray');
            }
        }
    }

    private function createElement(action:ActionDump):T
    {
        return Reflect.hasField(action.newValue, '__type')
            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
            : _factory();
    }

    private function updateElement(element:T, action:ActionDump):Void
    {
        for(fieldName in Reflect.fields(action.newValue))
        {
            if(fieldName == '__type')
                continue;

            element.process({
                path:       [],
                type:       ActionType.PROP_CHANGE,
                key:        fieldName,
                newValue:   Reflect.field(action.newValue, fieldName)
            });
        }
    }
}
