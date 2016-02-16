package sle.core;

import haxe.CallStack;

import sle.shim.IContext;
import sle.shim.IEnvironment;
import sle.shim.CommandResult;
import sle.shim.QueryResult;
import sle.shim.ActionDump;
import sle.shim.Error;
import sle.shim.Constructible;

import sle.core.actions.ActionLog;
import sle.core.models.ValueBase;
import sle.core.commands.Commands;
import sle.core.queries.Queries;

@:generic
class ContextBase<T:(ValueBase, Constructible)> implements IContext
{
    private var model:T;
    private var queries:Queries<T>;
    private var commands:Commands<T>;
    private var env:IEnvironment;

    @:final
    public function new(environment:IEnvironment)
    {
        model = new T();
        model.setRooted(true);

        queries = new Queries(model, environment);
        commands = new Commands(model, queries, environment);
        env = environment;

        this.init();
    }

    private function init() { throw new Error('Not implemented!'); }


    @:final
    public function fromObject(dump:Dynamic):Void
    {
        ActionLog._loggingEnabled = false;
        model.fromObject(dump);
        ActionLog._loggingEnabled = true;
    }

    @:final
    public function toObject():Dynamic
    {
        return model.toObject(null);
    }

    @:final
    public function fromArray(dumpArray:Dynamic):Void
    {
        ActionLog._loggingEnabled = false;
        model.fromArray(dumpArray);
        ActionLog._loggingEnabled = true;
    }

    @:final
    public function toArray():Dynamic
    {
        return model.toArray();
    }

    @:final
    #if debug
    public function execute(name:String, params:Dynamic, ?hashToCheck:String):CommandResult
    #else
    public function execute(name:String, params:Dynamic, ?hashToCheck:Float):CommandResult
    #end
    {
        var result:CommandResult = {
            name: null,
            params: null,
            actions: null,
            exchangables: null,
            error: null,
            #if debug
            hash: null
            #else
            hash: Math.NaN
            #end
        }

        try
        {
            result.name = name;
            result.params = params;

            commands.executeExternal(name, params);

            #if debug // checking string'ish hash
            result.hash = ActionLog.calculateActionsHash();

            if (hashToCheck != null && hashToCheck != result.hash)
            {
                throw new Error("long_hash_mismatch\nclient:\n" + hashToCheck +  "\nserver:\n" + result.hash);
            }

            #else // checking number'ish hash

            result.hash = model.__hash;

            if (hashToCheck != null && hashToCheck != result.hash)
            {
                throw new Error("short_hash_mismatch");
            }
            #end

            result.actions = ActionLog.commit();
            result.exchangables = env.commit();
        }
        catch(error:Error)
        {
            ActionLog.rollback();
            env.rollback();

            result.error = {
                message: error.message,
                stack: error.stack
            };
        }
        catch(error:Dynamic)
        {
            ActionLog.rollback();
            env.rollback();

            result.error = {
                message: Std.string(error),
                stack: CallStack.toString(CallStack.exceptionStack())
            };
        }

        return result;
    }

    @:final
    public function query(queryName:String, ?params:Dynamic):QueryResult
    {
        var result:QueryResult = { result: null, error: null };

        try
        {
            result.result = queries.executeExternal(queryName, params);
        }
        catch(error:Error)
        {
            result.error = {
                message: error.message,
                stack: error.stack
            };
        }
        catch(error:Dynamic)
        {
            result.error = {
                message: Std.string(error),
                stack: CallStack.toString(CallStack.exceptionStack())
            };
        }

        return result;
    }
}
