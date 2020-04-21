module plist.types.element;
public import plist.exceptions;
public import dxml.dom;
public import dxml.writer;
public import std.range : Appender;

struct PlistKey {
    string key;
}

enum PlistOptional;

enum PlistElementType {
  PLIST_ELEMENT_DATA = "data",
  PLIST_ELEMENT_STRING = "string",
  PLIST_ELEMENT_BOOLEAN_TRUE = "true",
  PLIST_ELEMENT_BOOLEAN_FALSE = "false",
  PLIST_ELEMENT_DATE = "date",
  PLIST_ELEMENT_INTEGER = "integer",
  PLIST_ELEMENT_REAL = "real",
  PLIST_ELEMENT_ARRAY = "array",
  PLIST_ELEMENT_DICT = "dict",
  PLIST_ELEMENT_KEY = "key"
}

interface PlistElement {
    // everything is subclassed from this
    void instantiate(DOMEntity!(string) entity);
    string toString(); //expected override
    void write(ref XMLWriter!(Appender!string) writer);
    string type();
}
