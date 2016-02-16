package sle.core.actions.changes.base;

import sle.shim.ActionDump;
import sle.shim.ActionType;
import sle.shim.Error;

import sle.core.models.ValueBase;
import sle.core.Utils;

class ChangeBase<TKey> implements IAction
{
    public var type(default, null):ActionType;

    private var _model:ValueBase;
    private var _key:TKey;
    private var _path:Array<String>;

    private function new(model:ValueBase, key:TKey, actionType:ActionType)
    {
        _model = model;
        _key = key;
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
            path.unshift(target.__name);
            target = target.__parent;
        }

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
