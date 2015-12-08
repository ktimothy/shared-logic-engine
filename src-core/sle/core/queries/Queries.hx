package sle.core.queries;

import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;
import sle.core.macro.CommandsQueriesMacroTools;

import sle.core.actions.ActionLog;
import sle.core.queries.QueryBase;

import sle.shim.IEnvironment;

@:final
class Queries<T>
{
    private var _environment:IEnvironment;

    private var _externalQueryClasses:Map<String, Dynamic>;

    private var _numOfRunningQueries(default, set):Int;

    private var _model:T;

    private var _extQueries:Map<String, Void -> QueryBase<T>>;

    public function new(model:T, environment:IEnvironment)
    {
        _environment = environment;
        _model = model;
        _externalQueryClasses = new Map<String, QueryBase<T>>();
        _extQueries = new Map();
        _numOfRunningQueries = 0;
    }

    macro public function addExternal(contextExpr:Expr, queryNameExpr:Expr, queryClassExpr:Expr):Expr
    {
        var newCmd:String = CommandsQueriesMacroTools.getQueryCreationCode(contextExpr, queryClassExpr);
        var ctxName:String = CommandsQueriesMacroTools.getContextName(contextExpr);
        var funName:String = ExprTools.toString(queryNameExpr);

        var code:String = '${ctxName}.__addExt(${funName}, function(){ return ${newCmd}; })';

        return Context.parse(code, Context.currentPos());
    }

    @:noCompletion
    public function __addExt(qrName:String, constructor:Void -> QueryBase<T>):Void
    {
        _extQueries[qrName] = constructor;
    }

    @:generic
    @:noCompletion
    public inline function __getQry<C:ConstructableQuery>():C
    {
        return new C(_model, this, _environment);
    }

    public function executeExternal(name:String, ?params:Dynamic):Dynamic
    {
        var query:QueryBase<T> = _extQueries[name]();

        return this.__execute(query, params);
    }

    macro public function execute(contextExpr:Expr, queryClassExpr:Expr, queryArgs:Expr):Expr
    {
        var newQuery:String = CommandsQueriesMacroTools.getQueryCreationCode(contextExpr, queryClassExpr);
        var ctxName:String = CommandsQueriesMacroTools.getContextName(contextExpr);
        var args:String = ExprTools.toString(queryArgs);

        var code:String = '${ctxName}.__execute(${newQuery}, ${args})';

        return Context.parse(code, Context.currentPos());
    }

    @:noCompletion
    public function __execute(query:QueryBase<T>, params:Dynamic = null):Dynamic
    {
        _numOfRunningQueries++;

        var result:Dynamic;

        // обрабатываем ошибку в запросе и его вложенных запросах
        // вызов первого запроса делаем в try...catch, чтобы поймать возможную ошибку
        // вызов вложенных запросов (которые может запустить первый) и так будут в стеке первого, а значит их ошибки поймаются в этом блоке
        if(_numOfRunningQueries == 1)
        {
            try
            {
                result = query.execute(params);
            }
            catch(error:Dynamic)
            {
                // цепочка запросов прервана, надо сбросить счетчик выполняющихся запросов, чтобы безопасно прокинуть ошибку наверх
                _numOfRunningQueries = 0;

                throw error;
            }
        }
        else
        {
            result = query.execute(params);
        }

        _numOfRunningQueries--;

        return result;
    }

    private function set__numOfRunningQueries(value:Int):Int
    {
        ActionLog._valueWriteEnabled = value == 0;

        return _numOfRunningQueries = value;
    }
}

typedef ConstructableQuery = {
    private function new(model:Dynamic, queries:Dynamic, environment:IEnvironment):Void;
    public function execute(?params:Dynamic):Dynamic;
}
