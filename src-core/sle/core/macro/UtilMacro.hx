package sle.core.macro;

#if macro

import haxe.macro.ComplexTypeTools;
import haxe.macro.TypeTools;
import haxe.macro.Expr.ComplexType;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ComplexTypeTools;

class UtilMacro
{
    private static var VALUE_BASE:String = 'sle.core.models.ValueBase';

    public static function typeIsSimple(type:Type):Bool
    {
        switch(TypeTools.follow(type))
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: 'Int' | 'UInt' | 'Float' | 'Bool' }, []):
                return true;
            case TInst(_.get() => { pack: [], module: 'String', name: 'String' }, []):
                return true;
            default:
        }

        return false;
    }

    public static function typeIsCollection(type:Type, pos:Position):Bool
    {
        if (!typeSubsValueBase(type, pos)) return false;

        var simpleCollectionTypeNames = [
            'BoolValueArray',
            'BoolValueMap',
            'FloatValueArray',
            'FloatValueMap',
            'IntValueArray',
            'IntValueMap',
            'StringValueArray',
            'StringValueMap',
            'UIntValueArray',
            'UIntValueMap'
        ];

        var complexCollectionTypeNames = [
            'ComplexValueArray',
            'ComplexValueMap'
        ];

        function isComplexCollectionTypeName(n:String):Bool
        {
            for (name in complexCollectionTypeNames)
            {
                if (n.indexOf(name) == 0) return true;
            }

            return false;
        }

        return switch(TypeTools.follow(type))
        {
            case TAbstract(_.get() => { type: realType }, []):
                typeIsCollection(realType, pos);

            case TInst(_.get() => { pack: ['sle', 'core', 'models', 'collections', 'impl'], name: n }, []):
                simpleCollectionTypeNames.indexOf(n) != -1 || isComplexCollectionTypeName(n);

            default:
                false;
        }
    }

    public static function typeSubsValueBase(type:Type, pos:Position):Bool
    {
        switch(TypeTools.follow(type))
        {
            case TInst(_.get() => cType, _):
                return classTypeSubsValueBase(cType);

            case TAbstract(_.get().type => type, []):
                return typeSubsValueBase(type, pos);

            default:
                Context.warning("Type " + type + " is not subclass of ValueBase.", pos);
                return false;
        }

        return false;
    }

    private static function classTypeSubsValueBase(cType:ClassType):Bool
    {
        return switch(cType)
        {
            case { pack: ['sle', 'core', 'models'], name: 'ValueBase' }:
                true;

            case { superClass: null }:
                false;

            case { superClass: {t: _.get() => ct, params: _ } }:
                classTypeSubsValueBase(ct);

            default:
                false;
        }
    }

    public static function typeIsLegal(type:Type, pos:Position):Bool
    {
        if (typeIsSimple(type)) return true;
        if (typeSubsValueBase(type, pos)) return true;

        return false;
    }

    public static function assertTypeIsLegal(type:Type, pos:Position):Void
    {
        if (typeIsLegal(type, pos)) return;

        trace(type);

        Context.fatalError('Type must be $VALUE_BASE or any simple type!', pos);
    }

    public static function genTypeDefaultValue(type:Type, pos:Position):String
    {
        return switch(TypeTools.follow(type))
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: 'Int' | 'UInt' | 'Float' }, []):
                '0';

            case TAbstract(_.get() => { pack: [], module: 'StdTypes', name: 'Bool' }, []):
                'false';

            case TAbstract(_.get() => { type: t }, []):
                genTypeDefaultValue(t, pos);

            case TInst(_, []):
                'null';

            default:
                Context.fatalError('Cannot generate default value for type $type', pos);
        }
    }

    public static function getRealTypeName(type:Type, pos:Position):String
    {
        if (typeIsSimple(type))
        {
            return TypeTools.toString(type);
        }

        return switch (type)
        {
            case TAbstract(_.get() => { type: t }, _):
                getRealTypeName(t, pos);

            case TInst(_, _):
                TypeTools.toString(type);

            default:
                Context.fatalError('Failed to getFullTypeName for $type, type= $type!', pos);
        }
    }

    public static function genUpdateHashCode(fieldType:Type, oldValue:String, newValue:String, pos:Position):String
    {
        if (!UtilMacro.typeIsSimple(fieldType))
        {
            return 'this.updateHash(this.hashOfValueBase($oldValue), this.hashOfValueBase($newValue));';
        }

        switch(fieldType)
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: n }, []):
                switch(n)
                {
                    case 'Bool':
                        return 'this.updateHash(this.hashOfBool($oldValue), this.hashOfBool($newValue));';
                    case 'Int' | 'UInt':
                        return 'this.updateHash(this.hashOfInt($oldValue), this.hashOfInt($newValue));';
                    case 'Float':
                        return 'this.updateHash(this.hashOfFloat($oldValue), this.hashOfFloat($newValue));';
                    default:
                        Context.fatalError('Unexpected simple type $n!', pos);
                }

            case TInst(_.get() => { pack: [], module: 'String', name: 'String' }, []):
                return 'this.updateHash(this.hashOfString($oldValue), this.hashOfString($newValue));';

            default:
                Context.fatalError('Expected TAbstract or TInst in genUpdateHashCode, got $fieldType', pos);
        }

        return '';
    }

    public static function genComparisonCode(left:String, right:String, type:Type, pos:Position):String
    {
        var result = switch(type)
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes', name: 'Float' }, []):
                '(${UtilMacro.genPlatformDependentIsNaNCode(left, right)}) || (${UtilMacro.genPlatfromDependedComparisonCode(left, right)})';

            default:
                UtilMacro.genPlatfromDependedComparisonCode(left, right);
        }

        return result;
    }

    private static function genPlatformDependentIsNaNCode(left:String, right:String):String
    {
        if(Context.defined('flash'))
        {
            return 'untyped __global__["isNaN"]($left) && untyped __global__["isNaN"]($right)';
        }
        else
        {
            return 'Math.isNaN($left) && Math.isNaN($right)';
        }
    }

    private static function genPlatfromDependedComparisonCode(left:String, right:String):String
    {
        if (Context.defined('cs'))
        {
            return 'cs.internal.Runtime.eq($left, $right)';
        }

        return '$left == $right';
    }
}
#end