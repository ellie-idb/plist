module plist.tests._real;
import plist;
import plist.types;

unittest {
    /* Can we even parse? */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");

        assert(parse.write() == xml, "Writing doesn't output the same what we put in");
    }
    /* Test whether or not we get a root dictionary */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
    }
    /* Test the value of foobar */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>1.1</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        assert(root["Foobar"].type() == PlistElementType.PLIST_ELEMENT_REAL, "Incorrect type found");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == 1.1, "Did not get value properly");
    }
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>1.337</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == 1.337, "Did not get value properly");
    }
    /* Even though this real does not have a decimal, it can still be one */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>41414141414141</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == 41414141414141.0, "Did not get value properly");
    }
    /* This should fail */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>0x1234</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        bool passed = false;
        try { 
            parse.read(xml);
        } catch(Exception e) {
            passed = true;
        }
        
        assert(passed, "This should not work");
    }
    /* Test negative numbers! */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>-41414141414141</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == -41414141414141.0, "Did not get value properly");
    }
    /* Test float precision */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>0.00041414</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == 0.00041414, "Did not get value properly");
    }
    /* Test negative float precision */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>-0.00041414</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == -0.00041414, "Did not get value properly");
    }
    /* Test setting the real */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>-0.00041414</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == -0.00041414, "Did not get value properly");
        elmt.value = 4141414;
        assert(elmt.value == 4141414, "Could not properly set value when in scope");
    }
    /* Test setting the real, then GETTING it via the dict */
    {
        string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <real>-0.00041414</real>
    </dict>
</plist>`;
        Plist parse = new Plist();
        parse.read(xml);

        assert(parse.length == 1, "Expected length of 1");
        PlistElementDict root = cast(PlistElementDict)parse[0];
        assert(root.keys.length == 1, "Expected 1 child");
        import std.algorithm.searching;
        assert(root.keys.canFind("Foobar"), "Expected key to be present in AA keys");
        PlistElementReal elmt = cast(PlistElementReal)root["Foobar"];
        assert(elmt.value == -0.00041414, "Did not get value properly");
        elmt.value = 4141414;
        assert(elmt.value == 4141414, "Could not properly set value when in scope");

        assert((cast(PlistElementReal)root["Foobar"]).value == 4141414, "Could not get value via dict root");
        (cast(PlistElementReal)root["Foobar"]).value = 1234;
        assert((cast(PlistElementReal)root["Foobar"]).value == 1234, "Could not get value via dict root");

        elmt.value = -0.00041414;
        assert(parse.write() == xml, "Generated output is not the same was what was put in");
    }
}
