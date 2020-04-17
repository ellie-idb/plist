module plist.types.array;
import plist.types.element;
import plist.conv;

class PlistElementArray : PlistElement {
    void instantiate(DOMEntity!string entity) {
        _entity = entity;
        if(entity.type == EntityType.elementEmpty) return;
        auto children = entity.children;
        foreach (child; children) {
            if (!validateDataType(child))
                throw new PlistParsingException("Invalid data type within array\n");
            auto val = coerceRuntime(cast(PlistElementType)child.name, child);
            _entries ~= val;
        }
    }

    @property PlistElement[] entries() {
        return _entries;
    }

    @property size_t length() {
        return _entries.length;
    }

    ref PlistElement opIndex(size_t index) {
        return _entries[index];
    }
    
    void opOpAssign(string op : "~", U)(U val) 
    if(__traits(compiles, _entries ~= val)) {
        _entries ~= val;
    }

    override string toString() {
        import std.format : format;
        return format!"<PlistElementArray n_entries: %d>"(_entries.length);
    }

    string type() {
        return PlistElementType.PLIST_ELEMENT_ARRAY;
    }

    void write(ref XMLWriter!(Appender!string) writer) {
        writer.openStartTag(type());
        if (_entries.length == 0) { 
            writer.closeStartTag(EmptyTag.yes);
        } else {
            writer.closeStartTag();
            foreach (entry; _entries) {
                entry.write(writer);
            }
            writer.writeEndTag(type());
        }
    }

    private {
        DOMEntity!string _entity;
        PlistElement[] _entries;
    }
}
