package sle.core.models.collections.impl;

@:final
class FloatValueMap extends SimpleValueMapBase<Float>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.FloatValueMap';
    }

    override private function getDefaultValue():Float
    {
        return 0;
    }

    override private function genericUpdateHash(oldValue:Float, newValue:Float):Void
    {
        this.updateHash(this.hashOfFloat(oldValue), this.hashOfFloat(newValue));
    }

    override private function equals(oldValue:Float, newValue:Float):Bool
    {
        if (Math.isNaN(oldValue) && Math.isNaN(newValue)) return true;
        return oldValue == newValue;
    }
}
