package sle.core.models.collections.impl;

@:final
class StringValueMap extends SimpleValueMapBase<String>
{
    public function new()
    {
        super();

        this._typeName = 'sle.core.models.collections.impl.StringValueMap';
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
