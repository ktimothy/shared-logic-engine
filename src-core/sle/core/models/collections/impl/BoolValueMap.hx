package sle.core.models.collections.impl;

@:final
class BoolValueMap extends SimpleValueMapBase<Bool>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.BoolValueMap';
    }

    override private function getDefaultValue():Bool
    {
        return false;
    }

    override private function genericUpdateHash(oldValue:Bool, newValue:Bool):Void
    {
        this.updateHash(this.hashOfBool(oldValue), this.hashOfBool(newValue));
    }
}
