package sle.core.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ComplexTypeTools;

using haxe.macro.Tools;
using haxe.macro.ComplexTypeTools;

class ValueMapMacro
{
    private static var ACTION_LOG = 'sle.core.actions.ActionLog';
    private static var CHANGE_OP = 'sle.core.actions.ActionType';
    private static var _pack = ['sle.core', 'models', 'collections'];
    private static var performing = false;

    public static function build():Type
    {
        var pos = Context.currentPos();
        var localType:Type = Context.getLocalType();

        switch(localType)
        {
            case TInst(_.get() => { pack: ['sle', 'core', 'models', 'collections'], name: 'ValueMap' }, [elementType]):
                return  genWrapper(elementType, pos);

            default:
                Context.fatalError('ValueMapMacro.build() can be called only on ValueMap<T>!', pos);
        }

        // this will never happen
        return localType;
    }

    private static function genWrapper(elementType:Type, pos:Position):Type
    {
        if (UtilMacro.typeIsSimple(elementType))
        {
            return genSimpleAbstract(elementType, pos);
        }

        return genComplexAbstract(elementType, pos);
    }

    private static function genSimpleAbstract(elementType:Type, pos:Position):Type
    {
        var elementTypeName = UtilMacro.getRealTypeName(elementType, pos);
        var typeName = '${elementTypeName}ValueMap';
        var abstractName = 'Abstract${typeName}';

        var concreteType = TPath({
            pack: ['sle', 'core', 'models', 'collections', 'impl'],
            name: typeName,
            params: []
        });

        var newCode = '{ this = new sle.core.models.collections.impl.${typeName}(); }';

        return genAbstract(concreteType, abstractName, newCode, elementType, pos);
    }

    private static function genComplexAbstract(elementType:Type, pos:Position):Type
    {
        var elementTypeName = TypeTools.toString(elementType);
        var concreteElementTypeName = UtilMacro.getRealTypeName(elementType, pos);

        var splitElementTypeName = concreteElementTypeName.split('.').join('_');
        var abstractName = 'Abstract${splitElementTypeName}ValueMap';

        var splitConcreteTypeName = 'sle.core.models.collections.impl.ComplexValueMap_${splitElementTypeName}';

        var concreteType = TPath({
            pack: ['sle', 'core', 'models', 'collections', 'impl'],
            name: 'ComplexValueMap',
            params: [TPType(TypeTools.toComplexType(elementType))]
        });

        var newCode = '';
        newCode += '{';
        newCode += 'this = new sle.core.models.collections.impl.ComplexValueMap<${elementTypeName}>();';
        newCode += 'this._typeName = "${splitConcreteTypeName}";';
        newCode += 'this._elementExpectedTypeName = "${concreteElementTypeName}";';
        newCode += '}';

        return genAbstract(concreteType, abstractName, newCode, elementType, pos);
    }

    private static function genAbstract(concreteType:ComplexType, abstractName:String, newCode:String, elementType:Type, pos:Position):Type
    {
        var fullAbstractName = 'sle.core.models.collections.${abstractName}';

        // try to get the type
        try
        {
            var result = Context.getType(fullAbstractName);
            if (result != null) return result;
        }
        catch(error:Dynamic)
        {
            // the type needs to be defined
        }

        var fields:Array<Field> = [
            {
                pos: pos,
                access: [APublic, AInline],
                meta: [
                    {
                        pos: pos,
                        name: ':access',
                        params: [
                            { pos: pos, expr: EConst(CString('sle.core.models.collections.impl.ComplexValueMap')) }
                        ]
                    }
                ],
                name: 'new',
                kind: FFun({
                    ret: null,
                    args: [],
                    expr: Context.parse(newCode, pos)
                })
            },
            {
                pos: pos,
                access: [APublic, AInline],
                meta: [{pos: pos, name: ':arrayAccess'}],
                name: 'get',
                kind: FFun({
                    ret: TypeTools.toComplexType(elementType),
                    args: [{
                        name: 'key',
                        type: TPath({ pack: [], name: 'String'})
                    }],
                    expr: Context.parse('{ return this.get(key); }', pos)
                })
            },
            {
                pos: pos,
                access: [APublic, AInline],
                meta: [{pos: pos, name: ':arrayAccess'}],
                name: 'set',
                kind: FFun({
                    ret: TypeTools.toComplexType(elementType),
                    args: [
                        {
                            name: 'key',
                            type: TPath({ pack: [], name: 'String'})
                        },
                        {
                            name: 'value',
                            type: TypeTools.toComplexType(elementType)
                        }
                    ],
                    expr: Context.parse('{ return this.set(key, value); }', pos)
                })
            }
        ];

        Context.defineType({
            pos: pos,
            pack: ['sle', 'core', 'models', 'collections'],
            name: abstractName,
            fields: fields,
            meta: [
                {
                    pos: pos,
                    name: ':dce'
                },
                {
                    pos: pos,
                    name: ':forward',
                    params: [
                        { pos: pos, expr: EConst(CString('__name')) },
                        { pos: pos, expr: EConst(CString('__parent')) },
                        { pos: pos, expr: EConst(CString('__hash')) },
                        { pos: pos, expr: EConst(CString('__isRooted')) },
                        { pos: pos, expr: EConst(CString('setRooted')) },
                        { pos: pos, expr: EConst(CString('getTypeName')) },
                        { pos: pos, expr: EConst(CString('fromObject')) },
                        { pos: pos, expr: EConst(CString('fromArray')) },
                        { pos: pos, expr: EConst(CString('toObject')) },
                        { pos: pos, expr: EConst(CString('toArray')) },
                        { pos: pos, expr: EConst(CString('exists')) },
                        { pos: pos, expr: EConst(CString('iterator')) },
                        { pos: pos, expr: EConst(CString('keys')) },
                        { pos: pos, expr: EConst(CString('remove')) }
                    ]
                }
            ],
            kind: TDAbstract(concreteType, [concreteType], [concreteType])
        });

        return Context.getType(fullAbstractName);
    }
}
#end
