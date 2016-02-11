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

            default:
                Context.fatalError('Expected TInst with one param, got $localType', PositionTools.here());
        }
    }

    private static function ensureAbstractIsDefinedForElementType(elementType:Type):Void
    {
        var path:TypePath = getAbstractPath(elementType);

        if(_typeCache.exists(path.name))
            return;

        isSimpleType(elementType)
            ? Context.defineType((new SimpleAbstractDefinitionFactory()).generate(path, elementType))
            : Context.defineType((new ComplexAbstractDefinitionFactory()).generate(path, elementType));

        _typeCache.set(path.name, true);
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

class SimpleAbstractDefinitionFactory extends AbstractDefinitionFactoryBase
{
    public function new(){}

    override private function getKind(elementType:ComplexType):TypeDefKind
    {
        var t:ComplexType = macro : SimpleValueMapBase<$elementType>;

        return TDAbstract(t, [], [t]);
    }

    override private function getNewField(elementType:ComplexType):Field
    {
        return {
            pos: PositionTools.here(),
            name: "new",
            access: [APublic, AInline],
            kind: FFun({
                args: [],
                ret: null,
                expr: macro this = new SimpleValueMapBase<$elementType>()
            })
        };
    }
}

class ComplexAbstractDefinitionFactory extends AbstractDefinitionFactoryBase
{
    public function new(){}

    override private function getKind(elementType:ComplexType):TypeDefKind
    {
        var t:ComplexType = macro : ComplexValueMapBase<$elementType>;

        return TDAbstract(t, [], [t]);
    }

    override private function getNewField(elementType:ComplexType):Field
    {
        var factory = getFactory(elementType);

        return {
            pos: PositionTools.here(),
            name: "new",
            access: [APublic, AInline],
            kind: FFun({
                args: [],
                ret: null,
                expr: macro this = new ComplexValueMapBase<$elementType>($factory)
            })
        };
    }

    private function getFactory(ct:ComplexType):Expr
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
}

class AbstractDefinitionFactoryBase
{
    public function generate(path:TypePath, elementType:Type):TypeDefinition
    {
        var ct = TypeTools.toComplexType(elementType);

        return {
            pos: PositionTools.here(),
            pack: path.pack,
            name: path.name,
            kind: getKind(ct),
            meta: getMeta(),
            fields: [
                getNewField(ct),
                getArrayReadField(ct)
            ],
        };
    }

    private function getMeta():Metadata
    {
        return [
            {
                pos: PositionTools.here(),
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

    private function getArrayReadField(returnType:ComplexType):Field
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

    private function getNewField(elementType:ComplexType):Field throw 'Abstract method';

    private function getKind(elementType:ComplexType):TypeDefKind throw 'Abstract method';
}

#end