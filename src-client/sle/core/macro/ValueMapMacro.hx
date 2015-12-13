package sle.core.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.PositionTools;
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

class ValueMapMacro
{
    public static function build():Type
    {
        var localType = Context.getLocalType();

        // trace('');
        // trace('GenericBuild on ${localType}');

        return switch(localType)
        {
            case TInst(_.get() => classType, [elementType]):

                // trace('Element type is $elementType');

                if(!isValueMap(classType))
                    Context.fatalError('ValueMapMacro.build() can be called only on ValueMap<T>!', PositionTools.here());

                if(isSimpleType(elementType))
                {
                    // trace('Element type is simple, going with SimpleValueMap');

                    var targetType = Context.getType('sle.core.models.collections.SimpleValueMap');

                    // trace('Got type: $targetType');

                    // trace('Returning type: $targetType');
                    // trace('');

                    targetType;
                    
                }
                else
                {
                    // trace('Element type is complex, going with ComplexValueMap');

                    switch(elementType)
                    {
                        case TInst(_.get() => elementClassType, elementTypeParams):

                            // trace('Element class package: ${elementClassType.pack}');
                            // trace('Element class name: ${elementClassType.name}');
                            // trace('Element type params: $elementTypeParams');

                            var targetAbstractName = 'ComplexValueMap_${elementClassType.pack.join('_')}_${elementClassType.name}';
                            var targetAbstractPackage = ['sle', 'core', 'models', 'collections'];

                            // trace('Target abstract name: $targetAbstractName');
                            // trace('Target abstract package: $targetAbstractPackage');

                            var targetAbstractPath = '${targetAbstractPackage.join('.')}.$targetAbstractName';

                            // trace('Setting onTypeNotFound handler');

                            Context.onTypeNotFound(typeNotFoundHandler);

                            // trace('Requesting type by path "$targetAbstractPath"');

                            var targetAbstract = Context.getType(targetAbstractPath);

                            // trace('Got type: $targetAbstract');
                            // trace('');

                            targetAbstract;


                        default:
                            Context.fatalError('Generation of ValueMap<T> for complex element types is implemented for TInst only, got $elementType', PositionTools.here());
                    }
                }

            default:
                Context.fatalError('ValueMapMacro.build() expected sle.core.models.collections.ValueMap<T>, got $localType', PositionTools.here());
        }
    }

    private static function typeNotFoundHandler(requestedTypePath:String):TypeDefinition
    {
        var splitRequestedTypePath = requestedTypePath.split('.');

        var requestedTypePackage = splitRequestedTypePath.slice(0, -1);
        var requestedTypeName = splitRequestedTypePath[splitRequestedTypePath.length - 1];

        if(requestedTypePackage.join('.') != 'sle.core.models.collections')
            return null;

        var splitRequestedTypeName = requestedTypeName.split('_');

        if(splitRequestedTypeName[0] != 'ComplexValueMap')
            return null;

        var splitElementTypePath = splitRequestedTypeName.slice(1, splitRequestedTypeName.length);

        var elementTypePackage = splitElementTypePath.slice(0, -1);
        var elementTypeName = splitElementTypePath[splitElementTypePath.length - 1];

        var innerType = TPath({
            pack: ['sle', 'core', 'models', 'collections'],
            name: 'ComplexValueMapBase',
            params: [
                TPType(
                    TPath({
                        pack: elementTypePackage,
                        name: elementTypeName
                    })
                )                
            ]
        });

        var typeDefinition:TypeDefinition = {
            pos: PositionTools.here(),
            pack: requestedTypePackage,
            name: requestedTypeName,
            kind: TDAbstract(innerType, [innerType], [innerType]),
            isExtern: false,
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
                    pos: Context.currentPos(),
                    meta: [],
                    access: [APublic, AInline],
                    name: 'new',
                    kind: FFun({
                        args: [],
                        ret: null,
                        expr: Context.parse('this = new sle.core.models.collections.ComplexValueMapBase<${elementTypePackage.join('.')}.$elementTypeName>()', PositionTools.here())
                    })
                },
                {
                    pos: Context.currentPos(),
                    meta: [
                        {
                            pos: Context.currentPos(),
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
                        ret: TPath({
                            pack: elementTypePackage,
                            name: elementTypeName
                        }),
                        expr: macro return this.get(key)
                    })
                }
            ]
        };

        return typeDefinition;
    }

    private static function isSimpleType(type:Type):Bool
    {
        switch(haxe.macro.TypeTools.follow(type))
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: 'Int' | 'UInt' | 'Float' | 'Bool' }, []):
                return true;
            case TInst(_.get() => { pack: [], module: 'String', name: 'String' }, []):
                return true;
            default:
        }

        return false;
    }

    private static function isValueMap(t:ClassType):Bool
    {
        return t.pack.length == 4 && t.pack[0] == 'sle' && t.pack[1] == 'core' && t.pack[2] == 'models' && t.pack[3] == 'collections' && t.name == 'ValueMap';
    }
}

#end