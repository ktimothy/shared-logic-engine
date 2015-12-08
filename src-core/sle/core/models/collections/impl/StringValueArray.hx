package sle.core.models.collections.impl;

@:final
class StringValueArray extends SimpleValueArrayBase<String>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.StringValueArray';
    }

    override private function getDefaultValue():String
    {
        return null;
    }

    override private function genericUpdateHash(oldValue:String, newValue:String):Void
    {
        this.updateHash(this.hashOfString(oldValue), this.hashOfString(newValue));
    }
}
