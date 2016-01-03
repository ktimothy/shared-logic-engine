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
        // trace('AutoBuild on ${Context.getLocalClass()}');

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
                // trace('Field "${field.name}" is non-public, passing without changes');
                newFields.push(field);
                continue;
            }

            switch (field.kind)
            {
                case FVar(tPath, _):

                    // trace('Field "${field.name}" is a public variable, turning into a read-only property');

                    var prop = generateReadOnlyProperty(field);

                    bindableProps.push(prop);

                    newFields.push(prop);

                case FFun(f):

                    if(field.name == 'new')
                    {
                        //trace('Field "${field.name}" is a constructor, passing without changes');
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

        //trace('Done building class: ${Context.getLocalClass()}');

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
                        //Context.parse(genTypeDefaultValue(ComplexTypeTools.toType(tPath), field.pos), field.pos)
                        //macro ${genTypeDefaultValue(ComplexTypeTools.toType(tPath), field.pos)}
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
                macro action.path[0],
                cases,
                macro super.process(action)
            )
        }

        var code = macro {
            //trace($v{Context.getLocalClass().toString()} + ' processing action: ' + action);
            ${megaswitch};   
        }

        //trace(haxe.macro.ExprTools.toString(code));

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
                    macro if(action.path.length == 1)
                    {
                        $i{prop.name} = Reflect.hasField(action.newValue, '__type')
                            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                            : new $tPath();

                        for(fieldName in Reflect.fields(action.newValue))
                        {
                            if(fieldName == '__type')
                                continue;

                            $i{prop.name}.process({
                                opName:     'var',
                                path:       [fieldName],
                                newValue:   Reflect.field(action.newValue, fieldName)
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
                    Context.fatalError('Property ${prop.name} is not of any supported types', prop.pos);

            case TInst(instanceType, instanceTypeParams):
                if(isValueArray(instanceType.get()))
                {
                    Context.warning('ValueArray is not supported yet, property "${prop.name}" will not recieve changes', prop.pos);
                    macro trace(${haxe.macro.MacroStringTools.formatString('Ignoring changes for field "${prop.name}" (not implemented yet)', prop.pos)});
                }
                else if(isValue(instanceType.get()))
                {
                    macro if(action.path.length == 1)
                    {
                        $i{prop.name} = Reflect.hasField(action.newValue, '__type')
                            ? Type.createInstance(Type.resolveClass(action.newValue.__type), [])
                            : new $tPath();

                        for(fieldName in Reflect.fields(action.newValue))
                        {
                            if(fieldName == '__type')
                                continue;

                            $i{prop.name}.process({
                                opName:     'var',
                                path:       [fieldName],
                                newValue:   Reflect.field(action.newValue, fieldName)
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
        if(type.pack.join('.') == 'sle.core.models.collections' && type.name == 'SimpleValueMap')
            return true;

        if(type.pack.join('.') == 'sle.core.models.collections' && type.name == 'ComplexValueMap')
            return true;

        return false;
    }

    private static function isValueArray(type:haxe.macro.Type.ClassType):Bool
    {
        if(type.name == 'ValueArray' && type.pack.length == 4 && type.pack[0] == 'sle' && type.pack[1] == 'core' && type.pack[2] == 'models' && type.pack[3] == 'collections')
            return true;

        if(type.superClass == null)
            return false;

        return isValueArray(type.superClass.t.get());
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

    private static function genTypeDefaultValue(type:haxe.macro.Type, pos:haxe.macro.Expr.Position):String
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
}

#end