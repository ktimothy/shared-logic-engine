package ;

import haxe.unit.TestCase;

/**
 * Tests that models have their fields compiled properly
 */
class TestDumpFieldsTest extends TestCase
{
    public function testAllFieldsAreThere()
    {
        var testDumpFields = Type.getInstanceFields(models.TestDump);

        var expectedFields = [
            'integer',
            'unsigned_integer',
            'number',
            'string',
            'bool',
            'bare_array',
            'complex_array',
            'bare_map',
            'complex_map',
            'coords',
            'inner',
            'coordsInherited',
            'nothing'
        ];

        // check that all fields are there
        for(expectedField in expectedFields)
            assertTrue(testDumpFields.indexOf(expectedField) != -1);

        // check that there are no extra fields
        assertEquals(expectedFields.length, testDumpFields.length);
    }
}
