module plist.types.date;
import plist.types.element;
import std.datetime;

class PlistElementDate : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;

        if (entity.type == EntityType.elementEmpty) return; 

        if (entity.children.length == 1) {
            if (entity.children[0].type != EntityType.text)
                throw new PlistParsingException("Expected a text element after date\n");
            _date = DateTime.fromISOExtString(entity.children[0].text);
        }
    }

    @property DateTime value() {
        return _date;
    }

    @property DateTime value(DateTime newDate) {
        newDate = _date;
        return _date;
    }

    override string toString() {
        import std.format : format;

        return format!"<PlistElementDate date: %s"(_date.toISOExtString());
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_DATE;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.openStartTag("date");
        writer.closeStartTag();
        writer.writeText(_date.toISOExtString(), Newline.no);
        writer.writeEndTag("date", Newline.no);
    }

    private {
        DOMEntity!string _entity;
        DateTime _date;
    }
}
