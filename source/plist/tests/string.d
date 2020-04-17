module plist.tests.string;
import plist;
import plist.types;

unittest {
    /* Can we even parse the data? */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string>battery correct horse staple</string>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 0");
          PlistElementString str = cast(PlistElementString)parse[0];
          assert(str.value == "battery correct horse staple", "String value is not the magic number");
    }
    /* Blank string */ 
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string></string>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 0");
          PlistElementString str = cast(PlistElementString)parse[0];
          assert(str.value == "", "Expected blank string");
          assert(str.value.length == 0, "Expected length of 0");
    }
    /* Change the data, check */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string>battery correct horse staple</string>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 0");
          PlistElementString str = cast(PlistElementString)parse[0];
          assert(str.value == "battery correct horse staple", "String value is not the magic number");
          str.value = "3 is the magic number";
          assert(str.value == "3 is the magic number", "String value is not the magic number");
    }
    /* Change the data, and check the XML */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string>battery correct horse staple</string>
</plist>`;
          string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string>3 is the magic number</string>
</plist>`;

          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_STRING, "Expected string at index 0");
          PlistElementString str = cast(PlistElementString)parse[0];
          assert(str.value == "battery correct horse staple", "String value is not the magic number");
          str.value = "3 is the magic number";
          assert(str.value == "3 is the magic number", "String value is not the magic number");

          assert(parse.write() == expected, "Expected different write");
    }
    /* Try something that should obviously fail */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string><true/></string>
</plist>`;
          bool fail = false;
          Plist parse = new Plist();
          try { 
              parse.read(xml);
          } catch(PlistParsingException e) {
              fail = true;
          }
          assert(fail, "Operation should not have succeeded");
    }
    /* Try another thing that should obviously fail */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <string><true/><true/></string>
</plist>`;
          bool fail = false;
          Plist parse = new Plist();
          try { 
              parse.read(xml);
          } catch(PlistParsingException e) {
              fail = true;
          }
          assert(fail, "Operation should not have succeeded");
    }
    /* Test key reading */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <key>battery correct horse staple</key>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");
          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == "string", "Expected string at index 0");
          PlistElementString str = cast(PlistElementString)parse[0];
          assert(str.value == "battery correct horse staple", "String value is not the magic number");
    }
}


