module plist.tests.boolean;
import plist;
import plist.types;

unittest {
    /* Can we even parse? */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <true/>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");

        import std.stdio;
        assert(parse[0].type() == "bool", "Expected boolean at index 0");

        PlistElementBoolean b = cast(PlistElementBoolean)parse[0];

        assert(b.value, "Expected boolean to be true");
    }
    /* Since this is an empty tag, we will convert it to it's proper form */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <true>
    </true>
</plist>`;
        string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <true/>
</plist>`;

        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == expected, "Writing doesn't output the same as what we expected");

        import std.stdio;
        assert(parse[0].type() == "bool", "Expected boolean at index 0");

        PlistElementBoolean b = cast(PlistElementBoolean)parse[0];

        assert(b.value, "Expected boolean to be true");
    }

}
