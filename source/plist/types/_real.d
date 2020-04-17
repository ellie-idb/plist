module plist.types._real;
import plist.types.element;

class PlistElementReal : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;
        if (entity.type == EntityType.elementEmpty) return; 
        if (entity.children.length == 1) {
            assert(entity.children[0].type == EntityType.text);
            import std.conv : to;
            _value = to!real(entity.children[0].text);
        } 

    }

    @property real value() { // getter
        return _value;
    }

    @property real value(real newValue) { // setter
        _value = newValue;
        return _value;
    }

    override string toString() {
        import std.format : format;
        return format!"<PlistElementReal value: %f>"(_value);
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_REAL;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.openStartTag(type());
        writer.closeStartTag();
        import std.conv : to;
        writer.writeText(to!string(_value), Newline.no);
        writer.writeEndTag(type(), Newline.no);
    }

    private {
        DOMEntity!string _entity;
        real _value;
    }
}
