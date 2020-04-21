module plist.conv;
import plist.types;
import dxml.dom;
import std.traits : EnumMembers, isAssignable;

bool typeIsCoercible(T)(PlistElementType type) {
    // Can't avoid boilerplate here, as we need to hardcode the actual element types
    if (type == PlistElementType.PLIST_ELEMENT_DATA) {
        if (isAssignable!(T, ubyte[])) {
            return true;
        }
    } 

    if (type == PlistElementType.PLIST_ELEMENT_STRING || 
        type == PlistElementType.PLIST_ELEMENT_KEY) {
        if (isAssignable!(T, string)) {
            return true;
        }
    }

    if (type == PlistElementType.PLIST_ELEMENT_DATE) {
        import std.datetime : SysTime;
        if (isAssignable!(T, SysTime)) {
            return true;
        } 
    }

    if (type == PlistElementType.PLIST_ELEMENT_BOOLEAN_TRUE || 
        type == PlistElementType.PLIST_ELEMENT_BOOLEAN_FALSE) {
        if (isAssignable!(T, bool)) {
            return true;
        }
    }

    if (type == PlistElementType.PLIST_ELEMENT_INTEGER) {
        if (isAssignable!(T, long)) {
            return true;
        }
    }

    if (type == PlistElementType.PLIST_ELEMENT_REAL) {
        if (is(T == real)) {
            return true;
        }
    }

    return false;
}

bool validateDataType(DOMEntity!string _entity) {
    import std.algorithm.searching;

    auto members = cast(string[])[EnumMembers!PlistElementType]; // this makes a compile-time array of every value possible in the enum
    if (members.canFind(_entity.name)) { // verify that it's one of them
        return true;
    }
    return false;
}

PlistElement coerce(T)(DOMEntity!string _entity) {
    auto element = new T(); // object creation needed because type() cannot be static
    if (_entity.name != "true" && _entity.name != "false" && _entity.name != "key") { // booleans are the exception, <bool>false</bool> is just <false/>
        assert(_entity.name == element.type(), "Entity name " ~ _entity.name ~ " did not match " ~ element.type());
    }

    element.instantiate(_entity);

    return element;
}

PlistElement coerceRuntime(PlistElementType type, DOMEntity!string _entity) {
    assert(_entity.type == EntityType.elementStart || _entity.type == EntityType.elementEmpty, "Encountered invalid type"); // this should never happen
    assert(_entity.name == type);
    assert(validateDataType(_entity), "Invalid type " ~ _entity.name);

    PlistElement element;


    static foreach(etype; [EnumMembers!PlistElementType]) {
        if (type == etype) { // Check has to be done at runtime 
            mixin("element = coerce!(" ~ getElementClassFromType(etype) ~ ")(_entity);");
        }
    }

    return element;
}

auto getElementClassFromType(PlistElementType type) {
    static foreach(etype; [EnumMembers!PlistElementType]) {
        if (type == etype) {
            static if (etype == PlistElementType.PLIST_ELEMENT_BOOLEAN_TRUE || etype == PlistElementType.PLIST_ELEMENT_BOOLEAN_FALSE) {
                return "PlistElementBoolean";
            } else static if (etype == PlistElementType.PLIST_ELEMENT_KEY) {
                return "PlistElementString";
            } else {
                import std.string : capitalize;
                return "PlistElement" ~ capitalize(cast(string)etype);
            }
        }
    }
    
    assert(0, "Should never reach this point");
}
