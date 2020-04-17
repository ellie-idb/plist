module plist.types.data;
import plist.types.element;
import std.base64;

class PlistElementData : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;
        if (entity.type == EntityType.elementEmpty) 
            return;
        if (entity.children.length != 1)
            return;
        if (entity.children[0].type == EntityType.text) {
            auto encoded = entity.children[0].text;
            if (encoded.length != 0) 
                _data = Base64.decode(encoded); 
        }
    }

    @property ubyte[] value() {
        return _data;
    }

    @property ubyte[] value(ubyte[] newData) {
        _data = newData.dup;
        return newData;
    }

    override string toString() {
        import std.format : format;
        return format!"<PlistElementData data: %s>"(_data);
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_DATA;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.openStartTag("data");
        if (_data.length == 0) {
            writer.closeStartTag(EmptyTag.yes);
        } else {
            writer.closeStartTag();
            writer.writeText(Base64.encode(_data), Newline.no);
            writer.writeEndTag("data", Newline.no);
        }
    }

    private {
        DOMEntity!string _entity;
        ubyte[] _data;
    }
}
