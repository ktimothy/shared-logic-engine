package sle.core.commands;

import sle.core.queries.Queries;

import sle.shim.IEnvironment;
import sle.shim.Error;

@:autoBuild(sle.core.macro.CommandsParamsMacro.build())
@:allow(sle.core.commands.Commands)
class CommandBase<T>
{
    private var model:T;
    private var queries:Queries<T>;
    private var commands:Commands<T>;
    private var environment:IEnvironment;

    @:final
    @:private
    private function new(model:T, queries:Queries<T>, commands:Commands<T>, environment:IEnvironment)
    {
        this.model = model;
        this.queries = queries;
        this.commands = commands;
        this.environment = environment;
    }

    private function execute(?params:Dynamic):Void
    {
        throw new Error("Must override in implementation!");
    }
}
