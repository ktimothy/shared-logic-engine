package sle.core.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.TypeTools;
import haxe.macro.ComplexTypeTools;
import haxe.macro.PositionTools;
import haxe.macro.Type;

@:dce
class ValueMacro
{
    public static function build():Array<Field>
    {
        var newFields       :Array<Field> = [];
        var bindableProps   :Array<Field> = [];
        var fields          :Array<Field> = Context.getBuildFields();

        for(field in fields)
        {
            if (field.access.indexOf(AStatic) != -1)
            {
                Context.warning('Static fields are not allowed, field "${field.name}" will be removed', field.pos);
                continue;
            }

            if (field.access.indexOf(APublic) == -1)
            {
                newFields.push(field);
                continue;
            }

            switch (field.kind)
            {
                case FVar(tPath, _):

                    var prop = generateReadOnlyProperty(field);

                    bindableProps.push(prop);

                    newFields.push(prop);

                case FFun(f):

                    if(field.name == 'new')
                    {
                        newFields.push(field);
                        continue;
                    }

                    Context.warning('Methods are not allowed for client models, method "${field.name}" will be removed', field.pos);

                case FProp(_):
                    Context.warning('Properties are not allowed for client models, property "${field.name}" will be removed', field.pos);
                    continue;

                default:
                    Context.fatalError('Unsupported field kind: ' + field.kind, field.pos);
            }
        }

        newFields.push(generateProcessMethod(bindableProps));

        return newFields;
    }

    private static function generateReadOnlyProperty(field:Field):Field
    {
        return switch (field.kind)
        {
            case FVar(tPath, _):
                {
                    kind: FProp(
                        'default',
                        'null',
                        tPath
                    ),
                    meta: [],
                    name: field.name,
                    doc: null,
                    pos: field.pos,
                    access: [APublic]
                }

            default:
                Context.fatalError('Expected FVar, got: ' + field.kind, PositionTools.here());
        }
    }

    private static function generateProcessMethod(props:Array<Field>):Field
    {
        var cases = props.map(function(field):haxe.macro.Expr.Case
        {
            return {
                values: [macro $v{field.name}],
                expr: generateCaseForProperty(field)
            };
        });

        var megaswitch:haxe.macro.Expr = {
            pos: PositionTools.here(),
            expr: ESwitch(
                macro action.key,
                cases,
                macro super.process(action)
            )
        }

        var code = macro {
            if (action.path.length == 0)
            {
                ${megaswitch};
            }
            else
            {
                throw new sle.shim.Error("woo");
            }
        }

        return {
            kind: FFun(
                {
                    args: [{name: 'action', type: macro: sle.shim.ActionDump, opt: false, value: null}],
                    params: [],
                    ret: macro: Void,
                    expr: code
                }
            ),
            meta: [],
            name: 'process',
            doc: null,
            pos: PositionTools.here(),
            access: [APublic, AOverride]
        }
    }

    private static function generateCaseForProperty(prop:Field):haxe.macro.Expr
    {
        var propertyType = switch (prop.kind)
        {
            case FProp(get, set, t, e):
                t;

            default:
                Context.fatalError('Expected FProp, got: ${prop.kind}', prop.pos);
        }

        var tPath = switch(propertyType)
        {
            case TPath(p):
                p;

            default:
                Context.fatalError('Expected TPath, got $propertyType', PositionTools.here());
        };

        var type = TypeTools.follow(ComplexTypeTools.toType(propertyType));

        return switch(type)
        {
            case TAbstract(_.get() => { pack: [], module: 'StdTypes' | 'UInt', name: 'Int' | 'UInt' | 'Float' | 'Bool' }, []):
                macro $i{prop.name} = action.newValue;

            case TInst(_.get() => {pack: [], module: 'String', name: 'String'}, []):
                macro $i{prop.name} = action.newValue;

            case TAbstract(instanceType, instanceTypeParams):             

                if(isValueMap(instanceType.get()))
                {
                    macro if(action.path.length == 0)
                    {
                        $i{prop.name} = Reflect.hasField(action.newValue, '__type')
                            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                            : new $tPath();

                        for(fieldName in Reflect.fields(action.newValue))
                        {
                            if(fieldName == '__type')
                                continue;

                            $i{prop.name}.process({
                                path:       [],
                                key:        fieldName,
                                newValue:   Reflect.field(action.newValue, fieldName),
                                type:       sle.shim.ActionType.MAP_INSERT
                            });
                        }
                    }
                    else
                    {
                        action.path.shift();
                        $i{prop.name}.process(action);
                    }
                }
                else if(isValueArray(instanceType.get()))
                {
                    macro if(action.path.length == 0)
                    {
                        $i{prop.name} = Reflect.hasField(action.newValue, '__type')
                            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                            : new $tPath();

                        for(element in cast(action.newValue, Array<Dynamic>))
                        {
                            $i{prop.name}.process({
                                path:       [],
                                key:        0,
                                newValue:   element,
                                type:       sle.shim.ActionType.ARRAY_PUSH,
                            });
                        }
                    }
                    else
                    {
                        action.path.shift();
                        $i{prop.name}.process(action);
                    }
                }
                else
                    Context.fatalError('Property ${prop.name} is not of any supported types, got $type', prop.pos);

            case TInst(instanceType, instanceTypeParams):

                if(isValue(instanceType.get()))
                {
                    macro if(action.path.length == 0)
                    {
                        $i{prop.name} = Reflect.hasField(action.newValue, '__type')
                            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                            : new $tPath();

                        for(fieldName in Reflect.fields(action.newValue))
                        {
                            if(fieldName == '__type')
                                continue;

                            $i{prop.name}.process({
                                path:       [],
                                key:        fieldName,
                                newValue:   Reflect.field(action.newValue, fieldName),
                                type:       sle.shim.ActionType.PROP_CHANGE
                            });
                        }
                    }
                    else
                    {
                        action.path.shift();
                        $i{prop.name}.process(action);
                    };
                }
                else
                    Context.fatalError('Property ${prop.name} is not of any supported types', prop.pos);

            default:
                Context.fatalError('Cannot generate case body for type $propertyType', PositionTools.here());
        }
    }

    private static function isValueMap(type:haxe.macro.Type.AbstractType):Bool
    {
        if(type.pack.join('.') == 'sle.core.models.collections' && ~/ValueMap_/.match(type.name))
            return true;

        return false;
    }

    private static function isValueArray(type:haxe.macro.Type.AbstractType):Bool
    {
        if(type.pack.join('.') == 'sle.core.models.collections' && ~/ValueArray_/.match(type.name))
            return true;

        return false;
    }

    private static function isValue(type:haxe.macro.Type.ClassType):Bool
    {
        if(type.superClass == null)
            return false;

        var superType = type.superClass.t.get();

        if(superType.name == 'Value' && superType.pack.length == 3 && superType.pack[0] == 'sle' && superType.pack[1] == 'core' && superType.pack[2] == 'models')
            return true;

        return isValue(superType);
    }
}

#end