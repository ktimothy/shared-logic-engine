package sle.core.macro;

#if macro

import haxe.macro.Expr.Position;
import sle.core.macro.UtilMacro;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ComplexTypeTools;

typedef PublicVarInfo =
{
    name:String,
    type:Type,
    pos:Position
}

@:dce
class ValueMacro
{
    private static var ACTION_LOG:String = 'sle.core.actions.ActionLog';
    private static var ACTION_TYPE:String = 'sle.core.actions.ActionType.VAR';
    private static var RESTRICTED:Array<String> = ['__name', '__parent', '__hash', '__isRooted', 'getTypeName'];

    public static function build():Array<Field>
    {
        var fields = haxe.macro.Context.getBuildFields();
        var fieldNamesToRemove:Array<String> = [];
        var fieldsToAdd:Array<Field> = [];
        var publicVars:Array<PublicVarInfo> = [];

        for (field in fields)
        {
            if (field.access.indexOf(AStatic) != -1)
                Context.fatalError('Static fields are not allowed!', field.pos);

            if (RESTRICTED.indexOf(field.name) != -1)
                Context.fatalError('Field named ${field.name} could not be declared!', field.pos);

            if (field.access.indexOf(APublic) == -1)
                continue;

            switch (field.kind)
            {
                case FVar(tPath, _):
                    processVar(field, fieldNamesToRemove, fieldsToAdd, publicVars);

                case FFun(_):
                    processFun(field, fields);

                case FProp(_):
                    // do nothing

                default:
                    Context.fatalError('Unsupported field kind: ' + field.kind, field.pos);
            }
        }

        // removing public vars
        fields = filterFieldsByName(fields, fieldNamesToRemove);

        // adding properties instead
        for (field in fieldsToAdd) fields.push(field);

        fields.push(genSetRooted(publicVars));
        fields.push(genGetTypeName());

        fields.push(genFromObject(publicVars));
        fields.push(genFromArray(publicVars));
        fields.push(genToObject(publicVars));
        fields.push(genToArray(publicVars));

        return fields;
    }

    private static function processVar(
        field:Field,
        fieldNamesToRemove:Array<String>,
        fieldsToAdd:Array<Field>,
        publicVars:Array<PublicVarInfo>):Void
    {
        switch (field.kind)
        {
            case FVar(fieldTPath, _):

                var fieldType = ComplexTypeTools.toType(fieldTPath);

                UtilMacro.assertTypeIsLegal(fieldType, field.pos);

                publicVars.push({name: field.name, type: fieldType, pos: field.pos});

                // remove plain var
                fieldNamesToRemove.push(field.name);

                // add property
                fieldsToAdd.push({
                    kind: FProp(
                        'default',
                        'set',
                        fieldTPath,
                        Context.parse(UtilMacro.genTypeDefaultValue(fieldType, field.pos), field.pos)
                    ),
                    meta: [{name: 'dump', pos: field.pos}],
                    name: field.name,
                    doc: null,
                    pos: field.pos,
                    access: [APublic]
                });

                var code = genSetterCode(field.name, fieldType, field.pos);

                // add setter
                fieldsToAdd.push({
                    kind: FFun(
                        {
                            args: [ {name: 'value', type: fieldTPath, opt: false, value: null} ],
                            params: [],
                            ret: fieldTPath,
                            expr: Context.parse(code, field.pos)
                        }
                    ),
                    meta: [],
                    name: 'set_' + field.name,
                    doc: null,
                    pos: field.pos,
                    access: [APublic]
                });

            default:
                Context.fatalError('FVar exprected!', field.pos);
        }
    }

    private static function processFun(field:Field, fields:Array<Field>):Void
    {
        switch (field.kind)
        {
            case FFun(func):
                if (field.name == 'new')
                {
                    if (func.params != null && func.params.length > 0)
                    {
                        Context.fatalError('ValueBase constructor should have no parameters!', field.pos);
                    }
                }
                else if (field.name.indexOf('set_') == 0)
                {
                    var propName = field.name.substring(4);

                    for (f in fields)
                    {
                        if ((propName == field.name) && (f.access.indexOf(APublic) != -1)) switch (f.kind)
                        {
                            case FVar(_):
                                Context.fatalError('set_$propName method is to be generated!', field.pos);
                            default:
                                continue;
                        }
                    }
                }
            default:
                Context.fatalError('FFun expected!', field.pos);
        }
    }

    private static function genGetTypeName():Field
    {
        var pos = Context.currentPos();
        var typeName = TypeTools.toString(Context.getLocalType());

        var code = '{ return "$typeName"; }';

        return {
            access: [APublic, AOverride],
            name: 'getTypeName',
            pos: pos,
            kind: FFun({
                args: [],
                expr: Context.parse(code, pos),
                ret: TPath({pack: [], name: 'String'})
            })
        };
    }

    private static function directlyDescendsValue(type:Type):Bool
    {
        return switch(type)
        {
            case TInst(_.get() => { superClass: { t: _.get() => { pack: ['sle', 'core', 'models'], name: 'Value' } } }, []):
                true;

            default:
                false;
        }
    }

    private static function getSuperType(type:Type, pos:Position):Type
    {
        if (directlyDescendsValue(type))
        {
            Context.fatalError('Wrong usage of getSuperType!', pos);
        }

        var type = Context.getLocalType();

        var result = switch(type)
        {
            case TInst(_.get() => { superClass: { t: _.get() => { pack: p, name: n } } }, []):
                ComplexTypeTools.toType(TPath({pack: p, name: n}));

            default:
                null;
        }

        if (result != null) return result;

        Context.fatalError('Unexpected type $type in getSuperType!', pos);
        return null; // this will never happen
    }

    private static function getPublicVarsCount(type:Type, pos:Position):Int
    {
        var result:Int = 0;

        if (!directlyDescendsValue(type))
        {
            result = getPublicVarsCount(getSuperType(type, pos), pos);
        }

        switch(type)
        {
            case TInst(_.get() => classType, _):

                for (classField in classType.fields.get())
                {
                    switch(classField.kind)
                    {
                        case FVar(ra, wa):
                            var meta = classField.meta.extract("dump");
                            if (meta != null && meta.length != 0) result += 1;

                        default:
                    }
                }

            default:
                Context.fatalError("getPublicVarsCount must be called on TInst, but was on $type", pos);
        }

        return result;
    }

    private static function sortPublicVars(publicVars:Array<PublicVarInfo>):Array<PublicVarInfo>
    {
        var vars = publicVars.slice(0);
        vars.sort(function(a:PublicVarInfo, b:PublicVarInfo):Int
        {
            if (a.name > b.name) return 1;
            if (a.name < b.name) return -1;

            return 0;
        });

        return vars;
    }

    private static function genSetterCode(fieldName, fieldType, pos):String
    {
        var typeIsSimple = UtilMacro.typeIsSimple(fieldType);

        var code = '{';

        code += 'if (!$ACTION_LOG._valueWriteEnabled)';
        code += '{';
        code += 'throw new sle.core.Error("Unable to write value!");';
        code += '}';

        code += 'if(${UtilMacro.genComparisonCode('this.$fieldName', 'value', fieldType, pos)})';
        code += '{';
        code += 'return value;';
        code += '}';

        code += 'var oldValue = this.$fieldName;';

        if (!typeIsSimple)
        {
            code += 'if (this.$fieldName != null)';
            code += '{';
            code += 'this.$fieldName.__name = null;';
            code += 'this.$fieldName.__parent = null;';
            code += 'this.$fieldName.setRooted(false);';
            code += '}';
            code += 'if (value != null)';
            code += '{';
            code += 'if (value.__parent != null) { throw new sle.core.Error("Unable to re-parent value!"); }';
            code += 'value.__parent = this;';
            code += 'value.__name = "$fieldName";';
            code += 'value.setRooted(this.__isRooted);';
            code += '}';
        }

        code += UtilMacro.genUpdateHashCode(fieldType, 'oldValue', 'value', pos);

        code += 'this.$fieldName = value;';
        code += 'if ($ACTION_LOG._loggingEnabled && this.__isRooted) {';

        if (typeIsSimple)
        {
            var changeClsName = 'sle.core.actions.changes.impl.ValueSimpleChange';
            code += 'var change = new $changeClsName(this, "$fieldName", $ACTION_TYPE, oldValue, value);';
        }
        else
        {
            var changeClsName = 'sle.core.actions.changes.impl.ValueComplexChange';
            var expectedTypeName = UtilMacro.getRealTypeName(fieldType, pos);
            code += 'var change = new $changeClsName(this, "$fieldName", $ACTION_TYPE, oldValue, value, "$expectedTypeName");';
        }

        code += '$ACTION_LOG._actions.push(change);';
        code += '}';
        code += 'return value;';
        code += '}';

        return code;
    }

    private static function filterFieldsByName(source:Array<Field>, deprecated:Array<String>):Array<Field>
    {
        var result:Array<Field>;

        if (deprecated.length > 0)
        {
            result = [];

            for (field in source)
            {
                var found = false;

                for (name in deprecated)
                {
                    if (name == field.name)
                    {
                        found = true;
                        break;
                    }
                }

                if (!found) result.push(field);
            }
        }
        else
        {
            result = source;
        }

        return result;
    }

    private static function genFromObject(publicVars:Array<PublicVarInfo>):Field
    {
        var pos = Context.currentPos();

        var code = '{';

        // setup parent class fields
        if (!directlyDescendsValue(Context.getLocalType()))
        {
            code += 'super.fromObject(dump);';
        }

        // setup own fields
        for (pv in publicVars)
        {
            code += 'if (!Reflect.hasField(dump, "${pv.name}"))';
            code += '{';
            code += 'throw new sle.core.Error("Field ${pv.name} not found in dump!");';
            code += '}';

            if (UtilMacro.typeIsSimple(pv.type))
            {
                code += 'this.${pv.name} = dump.${pv.name};';
            }
            else
            {
                // start of null check for nullable types
                code += 'if (dump.${pv.name} == null)';
                code += '{';
                code += 'this.${pv.name} = null;';
                code += '}';
                code += 'else';
                code += '{';

                var typeName = TypeTools.toString(pv.type);
                var realTypeName = UtilMacro.getRealTypeName(pv.type, pos);

                code += 'var ${pv.name};';

                code += 'if (!Reflect.hasField(dump.${pv.name}, "__type") || dump.${pv.name}.__type == "$realTypeName")';
                code += '{';
                code += '${pv.name} = new $typeName();';
                code += '}';
                code += 'else';
                code += '{';
                code += 'var cl = Type.resolveClass(dump.${pv.name}.__type);';
                code += '${pv.name} = Type.createInstance(cl, []);';
                code += '}';

                code += '${pv.name}.fromObject(dump.${pv.name});';
                code += 'this.${pv.name} = ${pv.name};';

                // end of null check for nullable types
                code += '}';
            }
        }

        code += 'this.init();';
        code += '}';

        return {
            kind: FFun({
                    args: [{
                        name: 'dump',
                        type: TPath({ name: 'Dynamic', pack: [], params: [] }),
                        opt: false,
                        value: null
                    }],
                    params: [],
                    ret: null,
                    expr: Context.parse(code, pos)
            }),
            name: 'fromObject',
            doc: null,
            pos: pos,
            access: [APrivate, AOverride]
        };
    }

    private static function genFromArray(publicVars:Array<PublicVarInfo>):Field
    {
        var pos = Context.currentPos();
        var type = Context.getLocalType();
        var startIndex = 1;
        var endIndex = 0;

        var vars = sortPublicVars(publicVars);

        var code = '{';

        // setup parent class fields
        if (!directlyDescendsValue(type))
        {
            code += 'super.fromArray(dumpArray);';

            startIndex += getPublicVarsCount(getSuperType(type, pos), pos);
        }

        endIndex = startIndex + vars.length;

        code += 'var array:Array<Dynamic> = cast dumpArray;';

        for (i in startIndex...endIndex)
        {
            var v = vars[i - startIndex];

            if (UtilMacro.typeIsSimple(v.type))
            {
                code += 'this.${v.name} = array[$i];';
            }
            else
            {
                code += 'if (array[$i] == null)';
                code += '{';
                code += 'this.${v.name} = null;';
                code += '}';
                code += 'else';
                code += '{';

                var typeName = TypeTools.toString(v.type);
                var realTypeName = UtilMacro.getRealTypeName(v.type, pos);

                code += 'var ${v.name};';

                if (UtilMacro.typeIsCollection(v.type, pos))
                {
                    code += '${v.name} = new $typeName();';
                }
                else
                {
                    code += 'if (array[$i][0] == "_" || array[$i][0] == "$realTypeName")';
                    code += '{';
                    code += '${v.name} = new $realTypeName();';
                    code += '}';
                    code += 'else';
                    code += '{';
                    code += 'var cl = Type.resolveClass(array[$i][0]);';
                    code += '${v.name} = Type.createInstance(cl, []);';
                    code += '}';
                }

                code += '${v.name}.fromArray(array[$i]);';
                code += 'this.${v.name} = ${v.name};';

                code += '}';
            }
        }

        code += 'this.init();';
        code += '}';

        return {
            kind: FFun({
                args: [{
                    name: 'dumpArray',
                    type: TPath({ name: 'Dynamic', pack: [] }),
                    opt: false,
                    value: null
                }],
                params: [],
                ret: null,
                expr: Context.parse(code, pos)
            }),
            name: 'fromArray',
            doc: null,
            pos: pos,
            access: [APrivate, AOverride]
        };
    }

    private static function genToObject(publicVars:Array<PublicVarInfo>):Field
    {
        var pos = Context.currentPos();

        var code = '{';

        if (!directlyDescendsValue(Context.getLocalType()))
        {
            var superType = getSuperType(Context.getLocalType(), pos);
            var superTypeName = TypeTools.toString(superType);

            code += 'var result:Dynamic = super.toObject("${superTypeName}");';
        }
        else
        {
            code += 'var result:Dynamic = {};';
        }

        for (pv in publicVars)
        {
            if (UtilMacro.typeIsSimple(pv.type))
            {
                code += 'Reflect.setField(result, "${pv.name}", this.${pv.name});';
            }
            else
            {
                var fieldTypeName = UtilMacro.getRealTypeName(pv.type, pos);
                code += 'Reflect.setField(result, "${pv.name}", this.${pv.name} == null ? null : this.${pv.name}.toObject("$fieldTypeName"));';
            }
        }

        var typeName = TypeTools.toString(Context.getLocalType());

        code += 'if (expectedTypeName != "$typeName")';
        code += '{';
        code += 'Reflect.setField(result, "__type", "$typeName");';
        code += '}';

        code += 'return result;';

        code += '}'; // end of method body

        return {
            kind: FFun({
                args: [{
                    name: 'expectedTypeName',
                    type: TPath({pack: [], name: 'String'}),
                    value: { expr: EConst(CIdent('null')), pos: pos }
                }],
                ret: TPath({ name: 'Dynamic', pack: [], params: [] }),
                expr: Context.parse(code, pos)
            }),
            name: 'toObject',
            pos: pos,
            access: [APrivate, AOverride]
        };
    }

    private static function genToArray(publicVars:Array<PublicVarInfo>):Field
    {
        var pos = Context.currentPos();
        var type = Context.getLocalType();
        var startIndex = 1;
        var endIndex = 0;

        var vars = sortPublicVars(publicVars);

        var code = '{';

        if (!directlyDescendsValue(Context.getLocalType()))
        {
            var superType = getSuperType(Context.getLocalType(), pos);
            var superTypeName = TypeTools.toString(superType);

            startIndex += getPublicVarsCount(superType, pos);

            code += 'var result:Array<Dynamic> = super.toArray("${superTypeName}");';
        }
        else
        {
            code += 'var result:Array<Dynamic> = [];';
            code += 'result.push("_");';
        }


        var typeName = TypeTools.toString(type);

        code += 'if (expectedTypeName != "$typeName")';
        code += '{';
        code += 'result[0] = "$typeName";';
        code += '}';

        endIndex = startIndex + vars.length;

        for (i in startIndex...endIndex)
        {
            var v = vars[i - startIndex];

            if (UtilMacro.typeIsSimple(v.type))
            {
                code += 'result[$i] = this.${v.name};';
            }
            else
            {
                var fieldTypeName = UtilMacro.getRealTypeName(v.type, pos);
                code += 'result[$i] = this.${v.name} == null ? null : this.${v.name}.toArray("$fieldTypeName");';
            }
        }

        code += 'return result;';

        code += '}'; // end of method body

        return {
            kind: FFun({
                args: [{
                    name: 'expectedTypeName',
                    type: TPath({pack: [], name: 'String'}),
                    value: { expr: EConst(CIdent('null')), pos: pos }
                }],
                ret: TPath({ name: 'Dynamic', pack: [] }),
                expr: Context.parse(code, pos)
            }),
            name: 'toArray',
            pos: pos,
            access: [APrivate, AOverride]
        };
    }

    private static function genSetRooted(publicVars:Array<PublicVarInfo>):Field
    {
        var pos = Context.currentPos();

        var code = '';

        code += '{';

        code += 'if (this.__isRooted == value) return;';
        code += 'this.__isRooted = value;';

        for (pv in publicVars)
        {
            if (!UtilMacro.typeIsSimple(pv.type))
            {
                code += 'if (this.${pv.name} != null) this.${pv.name}.setRooted(value);';
            }
        }

        code += '}';

        return {
            kind: FFun({
                args: [{
                    name: 'value',
                    type: TPath({ name: 'Bool', pack: [], params: [] }),
                    opt: false,
                    value: null
                }],
                expr: Context.parse(code, pos),
                ret: null
            }),
            name: 'setRooted',
            pos: pos,
            access: [APrivate, AOverride]
        };
    }
}
#end
