module plist.tests.integer;
import plist;
import plist.types;

unittest {
    /* Can we even parse the date? */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <integer>1337</integer>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_INTEGER, "Expected integer at index 0");

          PlistElementInteger integer = cast(PlistElementInteger)parse[0];

          assert(integer.value == 1337, "Integer value is not the magic number");
    }
    /* Set the data */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <integer>1337</integer>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_INTEGER, "Expected integer at index 0");

          PlistElementInteger integer = cast(PlistElementInteger)parse[0];

          assert(integer.value == 1337, "Integer value is not the magic number");
          integer.value = 0xBADB00B135;
          assert(integer.value == 0xBADB00B135, "Integer value is not the magic number"); 
    }
    /* Set the data, verify that XML matches */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <integer>1337</integer>
</plist>`;
          string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <integer>802538172725</integer>
</plist>`;

          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_INTEGER, "Expected integer at index 0");

          PlistElementInteger integer = cast(PlistElementInteger)parse[0];

          assert(integer.value == 1337, "Integer value is not the magic number");
          integer.value = 0xBADB00B135;
          assert(integer.value == 0xBADB00B135, "Integer value is not the magic number"); 
          assert(parse.write() == expected, "Expected different XML");
    }
    /* Do something obviously invalid */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <integer><string></string></integer>
</plist>`;
          Plist parse = new Plist();
          bool fail = false;
          try { 
              parse.read(xml);
          } catch(PlistParsingException e) {
              fail = true;
          }

          assert(fail, "Expected operation to fail");

    }
}
