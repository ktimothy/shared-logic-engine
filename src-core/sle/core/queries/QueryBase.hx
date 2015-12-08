package sle.core.queries;

import sle.shim.IEnvironment;

@:allow(sle.core.queries.Queries)

/**
* Базовый класс для любого Query.
* Как видно, запрос может быть создан только в обработчике запросов - sle.core.queries.Queries.
**/
class QueryBase<T>
{
    private var environment:IEnvironment;
    private var model:T;
    private var queries:Queries<T>;

    @:final
    private function new(model:T, queriesRunner:Queries<T>, environment:IEnvironment)
    {
        this.model = model;
        this.queries = queriesRunner;
        this.environment = environment;
    }

    public function execute(?params:Dynamic):Dynamic
    {
        throw new Error("Should be overriden in implementation!");
    }
}
