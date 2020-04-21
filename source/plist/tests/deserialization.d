module plist.tests.deserialization;
import plist;
import plist.types;

unittest {
    /* Test deserialization of strings */
    {
        struct DeserdeTest {
            @PlistKey("Hello") string hi;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <string>World</string>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest obj;

          dict.coerceToNative!DeserdeTest(obj);

          import std.stdio;
          assert(obj.hi == "World", "Expected different result from deserialization");
    }
    /* Deserialize reals */
    {
        struct DeserdeTest_2 {
            @PlistKey("Hello") real hi;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <real>1.0001</real>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_2 obj;

          dict.coerceToNative!DeserdeTest_2(obj);

          assert(obj.hi == 1.0001, "Expected different result from deserialization");
    }
    /* Deserialize integers */
    {
        struct DeserdeTest_3 {
            @PlistKey("Hello") long hi;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <integer>1337</integer>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_3 obj;

          dict.coerceToNative!DeserdeTest_3(obj);

          assert(obj.hi == 1337, "Expected different result from deserialization");
    }
    /* Deserialize integers (with precision) */
    {
        struct DeserdeTest_4 {
            @PlistKey("Hello") int hi;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <integer>1337</integer>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_4 obj;

          bool failed = false;
          try {
              dict.coerceToNative!DeserdeTest_4(obj);
          } catch (PlistSerdeException e) {
              failed = true;
          }

          assert(failed, "Should NOT deserialize");

          assert(obj.hi == 0, "Expected different result from deserialization");
    }

    /* Deserialize dates */
    {
        import std.datetime : SysTime;
        struct DeserdeTest_5 {
            @PlistKey("Hello") SysTime hi;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <date>1970-01-01T00:00:00Z</date>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_5 obj;

          dict.coerceToNative!DeserdeTest_5(obj);

          assert(obj.hi.toUnixTime() == 0, "Expected different result from deserialization");
    }
    /* Deserialize booleans */
    {
        struct DeserdeTest_6 {
            @PlistKey("Hello") bool hi;
            @PlistKey("World") bool bye;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <true/>
        <key>World</key>
        <false/>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_6 obj;

          dict.coerceToNative!DeserdeTest_6(obj);

          assert(obj.hi, "Expected different result from deserialization");
          assert(!obj.bye, "Expected different result from deserialization");
    }
    /* Deserialize a dict within a dict */
    {
        struct DeserdeTest_8 {
            @PlistKey("Hello") bool hi;
            @PlistKey("World") bool bye;
        }

        struct DeserdeTest_9 {
            @PlistKey("Leet") string msg;
        }

        struct DeserdeTest_7 {
            @PlistKey("Foo") DeserdeTest_8 bar;
            @PlistKey("Bar") DeserdeTest_9 meat;
        }

              string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Bar</key>
        <dict>
            <key>Leet</key>
            <string>Code</string>
        </dict>
        <key>Foo</key>
        <dict>
            <key>Hello</key>
            <true/>
            <key>World</key>
            <false/>
        </dict>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_7 obj;

          dict.coerceToNative!DeserdeTest_7(obj);

          assert(obj.bar.hi, "Expected different value");

          assert(!obj.bar.bye, "Expected different value");

          assert(obj.meat.msg == "Code", "Expected different value");
    }
    /* Ensure that exceptions and such are passed down through the insane amount of redirection we do */
    {
        struct DeserdeTest_10 {
            @PlistKey("Hello") bool hi;
            @PlistKey("World") bool bye;
        }

        struct DeserdeTest_11 {
            @PlistKey("Foobar") DeserdeTest_10 foobar;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Foobar</key>
        <dict>
            <key>Hello</key>
            <string>Hmm</string>
            <key>World</key>
            <false/>
        </dict>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_11 obj;

          bool failed = false;
          try {
            dict.coerceToNative!DeserdeTest_11(obj);
          } catch(PlistSerdeException e) {
              failed = true;
          }


          assert(failed, "Should've failed");
    }
    /* Deserialize arrays */
    {
        struct DeserdeTest_12 {
            @PlistKey("Hello") PlistElementArray array;
        }
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Hello</key>
        <array>
            <string>Pied Piper's revolutionary compression</string>
            <true/>
        </array>
    </dict>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DICT, "Expected dict at index 0");

          PlistElementDict dict = cast(PlistElementDict)parse[0];

          DeserdeTest_12 obj;

          dict.coerceToNative!DeserdeTest_12(obj);

          assert(obj.array.length == 2);
    }
}
