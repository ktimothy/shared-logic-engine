package queries;

import models.TestDump;
import sle.core.queries.QueryBase;

class SimpleQuery extends QueryBase<TestDump>
{
    override public function execute(?params:Dynamic):Dynamic
    {
        return params;
    }
}
