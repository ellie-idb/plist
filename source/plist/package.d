module plist;
public import plist.types.element;
import dxml.dom;
import std.range;
import plist.types;
import plist.conv;

class Plist {
    bool read(string input) {
        import std.stdio;
        auto dom = parseDOM(input);

        auto root = dom.children[0];
        { 
            // sanity checking
            assert(root.name == "plist");
            assert(root.type == EntityType.elementStart);
            auto attrs = root.attributes();
            assert(attrs.length == 1);
            assert(attrs[0].name == "version");
            assert(attrs[0].value == "1.0");
        }

        foreach(child; root.children) {
            if (validateDataType(child)) {
                auto element = coerceRuntime(cast(PlistElementType)child.name, child);
                _elements ~= element;
            } else {
                writeln("Skipped child with name: ", child.name);
            }
        }

        return true;
    }

    override string toString() {
        string output = "";
        foreach(element; _elements) {
            output ~= element.toString() ~ "\n";
        }

        return output;
    }

    ref PlistElement opIndex(size_t index) {
        return _elements[index];
    }

    size_t length() {
        return _elements.length;
    }

    string write() {
        import std.array : Appender, appender;
        auto app = appender!string();
        app.writeXMLDecl!string();
        app.put("\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
        auto writer = xmlWriter(app);
        writer.openStartTag("plist");
        writer.writeAttr("version", "1.0");
        writer.closeStartTag();

        foreach(element; _elements) {
            element.write(writer);
        }
        writer.writeEndTag("plist");
        return writer.output.data;
    }

    private {
        PlistElement[] _elements;
    }
}


