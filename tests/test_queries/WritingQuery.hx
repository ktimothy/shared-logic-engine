package test_queries;

import test_models.TestDump;
import sle.core.queries.QueryBase;

class WritingQuery extends QueryBase<TestDump>
{
    override public function execute(?params:Dynamic):Dynamic
    {
        // try to write - this must cause a runtime error
        model.bool = false;

        return params;
    }
}
