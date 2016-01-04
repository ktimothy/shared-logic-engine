package sle.core.macro;

#if macro

import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.PositionTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.Type;
import haxe.macro.Expr;
using StringTools;

import sle.core.models.collections.ValueMapImpl.ValueMapKind;

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

                ensureAbstractIsDefinedForElementType(elementType);

                return TPath(getAbstractPath(elementType));

                // isSimpleType(elementType)
                //     ? macro : sle.core.models.collections.SimpleValueMap<$ctElementType>
                //     : macro : sle.core.models.collections.ComplexValueMap<$ctElementType>;

            default:
                Context.fatalError('ValueMapMacro.build() expected sle.core.models.collections.ValueMap<T>, got $localType', PositionTools.here());
        }
    }

    private static function ensureAbstractIsDefinedForElementType(elementType:Type):Void
    {
        var path:TypePath = getAbstractPath(elementType);

        if(_typeCache.exists(path.name))
            return;

        defineAbstract(path, elementType);

        _typeCache.set(path.name, true);
    }

    private static function defineAbstract(path:TypePath, elementType:Type):Void
    {
        var ct = TypeTools.toComplexType(elementType);

        var kind:ValueMapKind = isSimpleType(elementType)
            ? Simple
            : Complex;

        Context.defineType({
            pos: PositionTools.here(),
            pack: path.pack,
            name: path.name,
            kind: AbstractBuilder.getKind(ct),
            meta: AbstractBuilder.getMeta(),
            fields: [
                AbstractBuilder.getNewField(ct, kind, AbstractBuilder.getFactory(ct)),
                AbstractBuilder.getArrayReadField(ct)
            ],
        });
    }

    private static function getAbstractPath(elementType:Type):TypePath
    {
        return {
            pack: ['sle', 'core', 'models', 'collections'],
            name: "ValueMap_" + ComplexTypeTools.toString(Context.toComplexType(elementType)).replace("<", "__").replace(">", "").replace(".", "_")
        };
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

class AbstractBuilder
{
    public static function getMeta():Metadata
    {
        return [
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
        ];
    }

    public static function getKind(elementType:ComplexType):TypeDefKind
    {
        return TDAbstract(macro : ValueMapImpl<$elementType>);
    }

    public static function getFactory(ct:ComplexType):Expr
    {
        var tpath = switch(ct)
        {
            case TPath(tp):
                tp;

            default:
                Context.fatalError('Expected TPath, got $ct', PositionTools.here());         
        }

        return macro function() return new $tpath();
    }

    public static function getNewField(elementType:ComplexType, kind:ValueMapKind, factory:Expr):Field
    {
        return {
            pos: PositionTools.here(),
            name: "new",
            access: [APublic, AInline],
            kind: FFun({
                args: [],
                ret: null,
                expr: kind == Complex
                    ? macro this = new ValueMapImpl<$elementType>($v{kind}, $factory)
                    : macro this = new ValueMapImpl<$elementType>($v{kind}, null)
            })
        };
    }

    public static function getArrayReadField(returnType:ComplexType):Field
    {
        return {
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
                ret: returnType,
                expr: macro return this.get(key)
            })
        };
    }
}

#end