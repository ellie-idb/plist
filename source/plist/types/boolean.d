module plist.types.boolean;
import plist.types.element;

class PlistElementBoolean : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;
        if (entity.name == PlistElementType.PLIST_ELEMENT_BOOLEAN_TRUE) 
            _value = true;
    }

    @property bool value() {
        return _value;
    }

    @property bool value(bool newValue) {
        _value = newValue;
        return newValue;
    }

    override string toString() {
        import std.format : format;
        return format!"<PlistElementBoolean value: %s>"(_value);
    }

    string type() {
        return "bool";
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        if(_value) {
            writer.openStartTag("true");
        } else {
            writer.openStartTag("false");
        }
        writer.closeStartTag(EmptyTag.yes);
    }

    private {
        DOMEntity!string _entity;
        bool _value;
    }
}


