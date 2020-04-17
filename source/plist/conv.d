module plist.conv;
import plist.types;
import dxml.dom;
import std.traits : EnumMembers;

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
    if (_entity.name != "true" && _entity.name != "false") { // booleans are the exception, <bool>false</bool> is just <false/>
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
        if (type == etype) {
            static if (etype == PlistElementType.PLIST_ELEMENT_BOOLEAN_TRUE || etype == PlistElementType.PLIST_ELEMENT_BOOLEAN_FALSE) {
                element = coerce!(PlistElementBoolean)(_entity); // again, bypass logic for booleans
            } else static if (etype == PlistElementType.PLIST_ELEMENT_KEY) {
                element = coerce!(PlistElementString)(_entity); // a key is just a string
            } else {
                import std.string : capitalize;
                // this is generated at compile time to avoid boilerplate 
                mixin("element = coerce!(PlistElement" ~ capitalize(cast(string)etype) ~ ")(_entity);"); 
            }
        }
    }

    return element;
}
