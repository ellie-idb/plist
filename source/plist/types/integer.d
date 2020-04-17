module plist.types.integer;
import plist.types.element;

class PlistElementInteger : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;

        if (entity.type == EntityType.elementEmpty) return; 

        if (entity.children.length == 1) {
            if (entity.children[0].type != EntityType.text)
                throw new PlistParsingException("Expected a text element after integer\n");
            import std.conv : to;
            _value = to!long(entity.children[0].text);
        } 
    }

    @property long value() {
        return _value;
    }

    @property long value(long val) {
        _value = val;
        return _value;
    }

    override string toString() {
        import std.format : format;

        return format!"<PlistElementInteger value: %d>"(_value);
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_INTEGER;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.openStartTag("integer");
        writer.closeStartTag();
        import std.conv : to;
        writer.writeText(to!string(_value), Newline.no);
        writer.writeEndTag("integer", Newline.no);
    }

    private {
        DOMEntity!string _entity;
        long _value;
    }
}
