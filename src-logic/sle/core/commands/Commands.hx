package sle.core.commands;

import sle.core.macro.CommandsQueriesMacroTools;
import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;

import sle.core.queries.Queries;

import sle.shim.IEnvironment;

@:dce
class Commands<T>
{
    private var _environment:IEnvironment;
    private var _model:T;
    private var _queries:Queries<T>;

    private var _extCmds:Map<String, Void -> CommandBase<T>>;

    public function new(model:T, queries:Queries<T>, environment:IEnvironment)
    {
        _model = model;
        _queries = queries;
        _environment = environment;

        _extCmds = new Map();
    }

    macro public function addExternal(contextExpr:Expr, cmdNameExpr:Expr, cmdClassExpr:Expr):Expr
    {
        var newCmd:String = CommandsQueriesMacroTools.getCommandCreationCode(contextExpr, cmdClassExpr);
        var ctxName:String = CommandsQueriesMacroTools.getContextName(contextExpr);
        var funName:String = ExprTools.toString(cmdNameExpr);

        var code:String = '${ctxName}.__addExt(${funName}, function(){ return ${newCmd}; })';

        return Context.parse(code, Context.currentPos());
    }

    public inline function executeExternal(commandName:String, ?params:Dynamic):Void
    {
        var command:CommandBase<T> = _extCmds[commandName]();

        command.execute(params);
    }

    macro public function execute(contextExpr:Expr, cmdClassExpr:Expr, ?cmdArgs:Expr):Expr
    {
        var newCmd:String = CommandsQueriesMacroTools.getCommandCreationCode(contextExpr, cmdClassExpr);
        var args:String = ExprTools.toString(cmdArgs);
        var code:String = '(${newCmd}).execute(${args})';

        return Context.parse(code, Context.currentPos());
    }

    @:noCompletion
    public function __addExt(commandName:String, commandConstrucionFunction:Void -> CommandBase<T>):Void
    {
        _extCmds[commandName] = commandConstrucionFunction;
    }

    @:generic
    @:noCompletion
    public inline function __getCmd<C:ConstructableCommand>():C
    {
        return new C(_model, _queries, this, _environment);
    }
}

typedef ConstructableCommand = {
    private function new(model:Dynamic, queries:Dynamic, commands:Dynamic, environment:IEnvironment):Void;
    public function execute(?params:Dynamic):Void;
}
