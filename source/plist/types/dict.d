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

