package sle.core.models.collections.impl;

@:final
class UIntValueArray extends SimpleValueArrayBase<UInt>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.UIntValueArray';
    }

    override private function getDefaultValue():UInt
    {
        return 0;
    }

    override private function genericUpdateHash(oldValue:UInt, newValue:UInt):Void
    {
        this.updateHash(this.hashOfInt(oldValue), this.hashOfInt(newValue));
    }
}
