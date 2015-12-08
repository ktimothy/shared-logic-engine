package test_queries;

import test_models.TestDump;
import sle.core.queries.QueryBase;

class ExternalQuery extends QueryBase<TestDump>
{
    override public function execute(?params:Dynamic):Dynamic
    {
        return this.queries.execute(SimpleQuery, params);
    }
}
