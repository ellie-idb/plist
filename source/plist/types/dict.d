module plist.types.dict;
import plist.types.element;
import std.array;
import std.algorithm.sorting;
import std.string;
import std.algorithm.searching;

class PlistElementDict : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;
        if (entity.type == EntityType.elementEmpty) return;
        auto children = entity.children;
        import std.conv : to;
        if((children.length % 2) != 0)
            throw new PlistParsingException("Length should be a multiple of 2, got " ~ to!string(children.length));

        for (int i = 0; i < children.length; i += 2) {
            import plist.conv;
            auto _key = children[i];
            auto _val = children[i + 1];
            if (_key.type != EntityType.elementStart)
                throw new PlistParsingException("Expected elementStart while parsing dict\n");
            if (_key.name != PlistElementType.PLIST_ELEMENT_KEY)
                throw new PlistParsingException("Expected a <key> element before a value\n");
            if (_key.children.length != 1)
                throw new PlistParsingException("Expected a valid string after key element\n");
            if (_key.children[0].type != EntityType.text)
                throw new PlistParsingException("Did not get a text element after key\n");
            string key = _key.children[0].text;
            if (_entries.keys.canFind(key))
                throw new PlistParsingException("Cannot override an existing key within dict\n");
            if (!validateDataType(_val)) 
                throw new PlistParsingException("Expected a valid data type for value in dict\n");
            auto val = coerceRuntime(cast(PlistElementType)_val.name, _val);
            _entries[key] = val;
        }
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_DICT;
    }

    ref PlistElement opIndex(string index) {
        if (_entries.keys.canFind(index)) {
            return _entries[index];
        }
        assert(0);
    }
        

    /* 
       Only return true if we were able to fill all members of the field
    */

    // Complexity is infinity
    bool coerceToNative(T)(ref T obj) {
        import std.traits;
        enum field_names = FieldNameTuple!T;
        import plist.conv;
        import plist.types;
        // This static foreach lets us go over all fields defined in the struct
        bool fail = false;
        static foreach(i, field; Fields!T) {
            // We have to wrap this entire thing within a lambda
            // and potentially make execution flow go ALL over the
            // damn place, since alias is global, but within a lambda
            // it isn't...
            fail = () {
                // IF and only if the programmer has defined the corresponding key within the plist, proceed
                mixin("alias F = T." ~ field_names[i] ~ ";");
                static if (hasUDA!(F, PlistKey)) {
                    // There should ONLY be one mapping to a Plist value
                    static assert(getUDAs!(F, PlistKey).length == 1, "Cannot have more then one key to deserialize");
                    static string key = getUDAs!(F, PlistKey)[0].key;
                    // Do this check at runtime, since we populate the dict at runtime (and have no prior knowledge
                    auto results = _entries.keys.find(key);
                    if (!results.empty) {
                        PlistElement element = _entries[key];
                        // And ensure that the type that they want us to convert to (within the struct) is actually compatible
                        // for example, PlistElementType.PLIST_ELEMENT_DATE to std.datetime.SysTime,
                        // PlistElementType.PLIST_ELEMENT_STRING to "string", etc
                        // SINCE the type field is defined at runtime,
                        // we have to do this weird hack in order to get it to be compile-time
                        // where we generate a MASSIVE branch comparing types

                        // As well, we have to check if it's a boolean,
                        // since for some GOD awful reason, true/false is
                        // defined as it's own type -_-
                        if (element.type == "bool") {
                            // Hack to ensure compilers don't try to cast every field to a boolean
                            static if (typeIsCoercible!field(PlistElementType.PLIST_ELEMENT_BOOLEAN_TRUE)) {
                                enum type = "PlistElementBoolean";
                                mixin (type ~ " val = cast(" ~ type ~ ")element;"); 
                                mixin ("obj." ~ field_names[i] ~ " = val.value;");
                                return true;
                            }
                            else {
                                throw new PlistSerdeException("Field " ~ field_names[i] ~ " was not coercible to a " ~ element.type);
                            }
                        } else if (element.type == "dict") {
                            import std.datetime : SysTime;
                            // God have mercy on my soul for this
                            // SysTime is also a dict, but we need to ignore it
                            static if (is(typeof(F) == struct) && !is(typeof(F) == SysTime)) { 
                                // Now recurse!
                                PlistElementDict wrappedDict = cast(PlistElementDict)element;
                                return wrappedDict.coerceToNative!(typeof(F))(mixin("obj." ~ field_names[i])); 
                            } else {
                                throw new PlistSerdeException("Field " ~ field_names[i] ~ " was not coercible to a " ~ element.type);
                            }
                        } else if (element.type == "array") {
                            static if (is(typeof(F) == PlistElementArray)) {
                                mixin ("obj." ~ field_names[i] ~ " = cast(PlistElementArray)element;");
                                return true; // strange that I have to bail out here
                            }
                            else {
                                throw new PlistSerdeException("Field " ~ field_names[i] ~ " was not coercible to a " ~ element.type);
                            }
                        }

                        static foreach(etype; [EnumMembers!PlistElementType]) {
                            if (element.type == etype) { // Implicit that element.type will never be bool here
                                static if (typeIsCoercible!field(etype)) {
                                    enum type = getElementClassFromType(etype);
                                    mixin (type ~ " val = cast(" ~ type ~ ")element;"); 
                                    mixin ("obj." ~ field_names[i] ~ " = val.value;");
                                    return true; // Jump out of the massive branch quicker
                                } else {
                                    throw new PlistSerdeException("Field " ~ field_names[i] ~ " was not coercible to a " ~ element.type);
                                }
                            }
                        }
                    }
                    else {
                        static if (hasUDA!(F, PlistOptional)) {
                            return true;
                        }
                        throw new PlistParsingException("Missing field " ~ key);
                    }
                } else {
                    return true;
                }

                return false;
            }();

            if (!fail) // Jump out quick, in case one field wasn't able to deserialize, followed by one that WAS
                return fail;
        }
        return fail;
    }


    @property string[] keys() {
        auto keys = _entries.keys.sort!("a.toLower() < b.toLower()")();
        return keys.array;
    }

    override string toString() {
        import std.format : format;
        string ret = format!"<PlistElementDict keys: %s, n_keys: %s>"(_entries.keys, _entries.keys.length);
        return ret;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.writeStartTag("dict");
        // order doesn't matter, so sort it alphabetically
        foreach (key; keys()) {
            PlistElement e = _entries[key];
            writer.openStartTag("key");
            writer.closeStartTag();
            writer.writeText(key, Newline.no);
            writer.writeEndTag("key", Newline.no);
            e.write(writer);
        }
        writer.writeEndTag("dict");

    }

    private {
        DOMEntity!string _entity;
        PlistElement[string] _entries;
    }
}

