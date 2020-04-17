module plist.types.string;
import plist.types.element;

class PlistElementString : PlistElement {
    void instantiate(DOMEntity!string entity) {
        if(_entity.name == "key") {
            key = true;
        }
        _entity = entity;
        if (entity.type == EntityType.elementEmpty) return; 
        if(entity.children.length == 1) {
            if (entity.children[0].type != EntityType.text)
                throw new PlistParsingException("Expected a text element after string\n");
            _text = entity.children[0].text;
        } else {
            assert(entity.children.length == 0);
        }
    }

    override string toString() {
        import std.format : format;
        return format!"<PlistElementString text: %s>"(_text);
    }

    @property string value() {
        return _text;
    }

    @property string value(string newText) {
        _text = newText;
        return _text;
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_STRING;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        if (key) {
            writer.openStartTag("key");
        } else {
            writer.openStartTag("string");
        }

        writer.closeStartTag();
        writer.writeText(_text, Newline.no);

        if (key) {
            writer.writeEndTag("key", Newline.no);
        } else {
            writer.writeEndTag("string", Newline.no);
        }
    }

    private {
        bool key;
        string _text;
        DOMEntity!string _entity;
    }
}


