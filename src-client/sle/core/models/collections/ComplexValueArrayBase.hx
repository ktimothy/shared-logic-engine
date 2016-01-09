package sle.core.models.collections;

import sle.shim.ActionDump;

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
    public function set(key:Int, value:T):Void _data[key] = value;

    override public function process(action:ActionDump):Void
    {
        if(action.path.length == 1)
        {

            switch (action.opName)
            {
                case PUSH:
                    var element = createElement(action);
                    _data.push(element);
                    updateElement(element, action);

                case POP:
                    _data.pop();

                case UNSHIFT:
                    var element = createElement(action);
                    _data.unshift(element);
                    updateElement(element, action); 

                case SHIFT:
                    _data.shift();

                case INSERT:
                    var element = createElement(action);
                    _data.insert(Std.parseInt(action.path[0]), element);
                    updateElement(element, action);

                case REMOVE:
                    throw new Error('Remove action for ComplexValueArray is not implemented yet');

                case INDEX:
                    var element = createElement(action);
                    _data[Std.parseInt(action.path[0])] = element;
                    updateElement(element, action);

                default:
                    throw new Error('Wrong action type "${action.opName}" for ValueArray');
            }
        }
        else
        {
            get(Std.parseInt(action.path.shift())).process(action);
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
                opName:     VAR,
                path:       [fieldName],
                newValue:   Reflect.field(action.newValue, fieldName)
            });
        }
    }
}