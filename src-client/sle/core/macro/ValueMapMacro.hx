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
    public static function build():ComplexType
    {
        var localType = Context.getLocalType();

        return switch(localType)
        {
            case TInst(_.get() => classType, [elementType]):

                if(!isValueMap(classType))
                    Context.fatalError('ValueMapMacro.build() can be called only on ValueMap<T>!', PositionTools.here());

                generateValueMapType(classType, elementType);

            default:
                Context.fatalError('ValueMapMacro.build() expected sle.core.models.collections.ValueMap<T>, got $localType', PositionTools.here());
        }
    }

    private static function generateValueMapType(classType:ClassType, elementType:Type):ComplexType
    {
        var elementCT = Context.toComplexType(elementType);
        return if(isSimpleType(elementType))
            macro : sle.core.models.collections.SimpleValueMap<$elementCT>;
        else
            macro : sle.core.models.collections.ComplexValueMap<$elementCT>;
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
        return '${t.pack.join('.')}.${t.name}' == 'sle.core.models.collections.ValueMap';
    }
}

#end