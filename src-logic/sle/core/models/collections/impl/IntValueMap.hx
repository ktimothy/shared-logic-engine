package sle.core.models.collections.impl;

@:final
class IntValueMap extends SimpleValueMapBase<Int>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.IntValueMap';
    }

    override private function getDefaultValue():Int
    {
        return 0;
    }

    override private function genericUpdateHash(oldValue:Int, newValue:Int):Void
    {
        this.updateHash(this.hashOfInt(oldValue), this.hashOfInt(newValue));
    }
}
