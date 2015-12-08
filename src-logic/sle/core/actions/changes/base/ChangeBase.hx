package sle.core.actions.changes.base;

import sle.shim.ActionDump;

import sle.core.models.ValueBase;
import sle.core.Utils;

class ChangeBase implements IAction
{
    public var type(default, null):ActionType;

    private var _model:ValueBase;
    private var _propName:String;
    private var _path:Array<String>;

    private function new(model:ValueBase, propName:String, actionType:ActionType)
    {
        _model = model;
        _propName = propName;
        _path = this.getPath();

        this.type = actionType;
    }

    inline private function getPath():Array<String>
    {
        var target:ValueBase = _model;
        var path:Array<String> = [];

        // у всех моделей, кроме корневой, всегда есть name и parent (у нее нет ни того, ни другого)
        // цикл завершится как раз на корневой модели, поэтому проверка на target != null не нужна
        while(target.__parent != null)
        {
            path.push(target.__name);
            target = target.__parent;
        }

        path.reverse();
        path.push(_propName);

        return path;
    }

    public function rollback():Void { throw new Error('Not implemented!'); }

    public function toObject():ActionDump { throw new Error('Not implemented!'); }


    #if debug
    @:final
    public function toString():String
    {
        return Utils.hash(this.toObject());
    }
    #end
}
