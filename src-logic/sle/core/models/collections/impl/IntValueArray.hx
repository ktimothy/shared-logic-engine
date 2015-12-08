package sle.core.models.collections.impl;

@:final
class IntValueArray extends SimpleValueArrayBase<Int>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.IntValueArray';
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
