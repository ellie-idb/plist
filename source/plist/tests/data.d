module plist.tests.data;
import plist;
import plist.types;

unittest {
    /* Can we even parse? */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data>QUFBQQ==</data>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATA, "Expected data type");
    }
    /* Test if value is correct */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data>QUFBQQ==</data>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATA, "Expected data type");

        PlistElementData dat = cast(PlistElementData)parse[0];

        assert(dat.value == [0x41, 0x41, 0x41, 0x41], "Did not get magic value from decoding");
    }
    /* Test modifying the value */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data>QUFBQQ==</data>
</plist>`;
        string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data>3q2+7w==</data>
</plist>`;

        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATA, "Expected data type");

        PlistElementData dat = cast(PlistElementData)parse[0];

        assert(dat.value == [0x41, 0x41, 0x41, 0x41], "Did not get magic value from decoding");
        ubyte[] val = dat.value;
        val[0] = 0xDE;
        val[1] = 0xAD;
        val[2] = 0xBE;
        val[3] = 0xEF;
        dat.value = val;
        assert(parse.write() == expected, "Did not get magic value from encoding");
    }
    /* Data is empty */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data/>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATA, "Expected data type");

        PlistElementData dat = cast(PlistElementData)parse[0];

        assert(dat.value == [], "Did not get magic value from decoding");
    }
    /* Ditto */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data></data>
</plist>`;
        string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <data/>
</plist>`;

        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == expected, "Writing doesn't output the same what we put in");

        assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATA, "Expected data type");

        PlistElementData dat = cast(PlistElementData)parse[0];

        assert(dat.value == [], "Did not get magic value from decoding");
    }
}
