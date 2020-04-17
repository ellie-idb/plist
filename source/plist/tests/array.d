module plist.tests.array;
import plist;
import plist.types;

unittest {
    /* Can we even parse? */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <array>
        <string>Foobar</string>
    </array>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_ARRAY, "Expected array type");
    }
    /* Empty tags should also work */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <array/>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");
    }
    /* We internally convert an array with length == 0 to an empty tag */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <array>
    </array>
</plist>`;
        string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <array/>
</plist>`;

        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == expected, "Unexpected output");
    }
    /* Standard use case: embedded within a dict */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foo</key>
        <array>
            <string>bar</string>
        </array>
    </dict>
</plist>`;

        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        assert(parse.write() == xml, "Did not get out what we put in");
        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");
        PlistElementDict dict = cast(PlistElementDict)(parse[0]);
        assert(dict["Foo"].type() == PlistElementType.PLIST_ELEMENT_ARRAY, "Expected array with key 'Foo'");
        PlistElementArray array = cast(PlistElementArray)(dict["Foo"]);
        assert(array.length == 1, "Incorrect array length");
        assert(array[0].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 0");
        PlistElementString str = cast(PlistElementString)(array[0]);
        assert(str.value == "bar", "Wrong value for string");
    }
    /* Test appending objects TO the plist */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foo</key>
        <array>
            <string>bar</string>
        </array>
    </dict>
</plist>`;
        string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foo</key>
        <array>
            <string>bar</string>
            <string>beef</string>
        </array>
    </dict>
</plist>`;


        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        assert(parse.write() == xml, "Did not get out what we put in");
        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");
        PlistElementDict dict = cast(PlistElementDict)(parse[0]);
        assert(dict["Foo"].type() == PlistElementType.PLIST_ELEMENT_ARRAY, "Expected array with key 'Foo'");
        PlistElementArray array = cast(PlistElementArray)(dict["Foo"]);
        PlistElementString beef = new PlistElementString();
        beef.value = "beef";
        array ~= cast(PlistElement)beef;
        assert(parse.write() == expected, "Did not get expected output");
        assert(array[1].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 1");
        assert(array.length == 2, "Size did not grow");
        PlistElement[] arr2 = array.entries();
        arr2 ~= beef;
        assert(array.length == 2, "Size should've NOT grown");
    }
}
