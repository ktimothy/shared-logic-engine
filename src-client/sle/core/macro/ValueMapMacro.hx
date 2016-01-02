package sle.core.macro;

#if macro

import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.PositionTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.Type;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.TypeDefinition;
import haxe.macro.Expr.TypeDefKind;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.TypeParam;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Constant;
using StringTools;

class ValueMapMacro
{
    private static var _typeCache = new StringMap<Bool>();

    public static function build():ComplexType
    {
        var localType = Context.getLocalType();

        return switch(localType)
        {
            case TInst(_.get() => classType, [elementType]):

                if(!isValueMap(classType))
                    Context.fatalError('ValueMapMacro.build() can be called only on ValueMap<T>!', PositionTools.here());

                var name = getAbstractNameForElementType(elementType);

                if(!_typeCache.exists(name))
                    defineAbstractForType(elementType);

                return TPath({pack: ['sle', 'core', 'models', 'collections'], name: name});

                // isSimpleType(elementType)
                //     ? macro : sle.core.models.collections.SimpleValueMap<$ctElementType>
                //     : macro : sle.core.models.collections.ComplexValueMap<$ctElementType>;

            default:
                Context.fatalError('ValueMapMacro.build() expected sle.core.models.collections.ValueMap<T>, got $localType', PositionTools.here());
        }
    }

    private static function defineAbstractForType(elementType:Type):Void
    {
        var name = getAbstractNameForElementType(elementType);

        var ct = TypeTools.toComplexType(elementType);

        var tpath = switch(ct)
        {
            case TPath(tp):
                tp;

            default:
                Context.fatalError('Expected TPath, got $ct', PositionTools.here());         
        }

        var kind:sle.core.models.collections.ValueMapImpl.ValueMapKind = isSimpleType(elementType)
            ? Simple
            : Complex;

        var factory = macro function() return new $tpath();

        Context.defineType({
            pos: PositionTools.here(),
            pack: ['sle', 'core', 'models', 'collections'],
            name: name,
            kind: TDAbstract(macro : ValueMapImpl<$ct>),
            meta: [
                {
                    pos: Context.currentPos(),
                    name: ':forward',
                    params: [
                        {
                            pos: PositionTools.here(),
                            expr: EConst(CString('process'))
                        },
                        {
                            pos: PositionTools.here(),
                            expr: EConst(CString('exists'))
                        },
                        {
                            pos: PositionTools.here(),
                            expr: EConst(CString('get'))
                        },
                        {
                            pos: PositionTools.here(),
                            expr: EConst(CString('iterator'))
                        },
                        {
                            pos: PositionTools.here(),
                            expr: EConst(CString('keys'))
                        }
                    ]
                }
            ],
            fields: [
                {
                    pos: PositionTools.here(),
                    name: "new",
                    access: [APublic, AInline],
                    kind: FFun({
                        args: [],
                        ret: null,
                        expr: kind == Complex
                            ? macro this = new ValueMapImpl<$ct>($v{kind}, $factory)
                            : macro this = new ValueMapImpl<$ct>($v{kind}, null)
                    })
                },
                {
                    pos: PositionTools.here(),
                    meta: [
                        {
                            pos: PositionTools.here(),
                            name: ':arrayAccess'
                        }
                    ],
                    access: [APublic, AInline],
                    name: 'arrayRead',
                    kind: FFun({
                        args: [
                            {
                                name: 'key',
                                type: TPath({ pack: [], name: 'String'})
                            }
                        ],
                        ret: ct,
                        expr: macro return this.get(key)
                    })
                }
            ],
        });

        _typeCache.set(name, true);
    }

    private static function getAbstractNameForElementType(elementType:Type):String
    {
        return "ValueMap_" + ComplexTypeTools.toString(Context.toComplexType(elementType)).replace("<", "__").replace(">", "").replace(".", "_");           
    }

    private static function isSimpleType(type:Type):Bool
    {
        return switch(haxe.macro.TypeTools.follow(type))
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: 'Int' | 'UInt' | 'Float' | 'Bool' }, []):
                true;

            case TInst(_.get() => { pack: [], module: 'String', name: 'String' }, []):
                true;

            default:
                false;
        }
    }

    private static function isValueMap(t:ClassType):Bool
    {
        return t.pack.join('.') == 'sle.core.models.collections' && t.name == 'ValueMap';
    }
}

#end