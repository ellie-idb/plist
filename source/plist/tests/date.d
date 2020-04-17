module plist.tests.date;
import plist;
import plist.types;

unittest {
    /* Can we even parse the date? */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date>1970-01-01T00:00:00Z</date>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATE, "Expected boolean at index 0");

          PlistElementDate date = cast(PlistElementDate)parse[0];

          assert(date.value.toUnixTime() == 0, "Timestamp was incorrect");
    }
    /* Test a random date */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date>2020-04-20T13:37:00Z</date>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATE, "Expected boolean at index 0");

          PlistElementDate date = cast(PlistElementDate)parse[0];

          assert(date.value.toUnixTime() == 1587389820, "Timestamp was incorrect");
    }
    /* Try setting the date */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date>1970-01-01T00:00:00Z</date>
</plist>`;
          string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date>2020-04-20T13:37:00Z</date>
</plist>`;

          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == xml, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATE, "Expected boolean at index 0");

          PlistElementDate date = cast(PlistElementDate)parse[0];

          assert(date.value.toUnixTime() == 0, "Timestamp was incorrect");
          import std.datetime;
          auto time = SysTime.fromUnixTime(1587389820, UTC());
          date.value = time;
          assert(parse.write() == expected, "Expected a different value");
    }
    /* Test something invalid */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date><string></string></date>
</plist>`;
          bool error = false;
          Plist parse = new Plist();
          try { 
              parse.read(xml);
          } catch(PlistParsingException e) {
              error = true;
          }

          assert(error, "Expected an exception to be thrown");
    }
    /* An empty date */
    {
          string xml = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date></date>
</plist>`;
          string expected = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <date>0001-01-01T00:00:00+00:00</date>
</plist>`;
          Plist parse = new Plist();
          parse.read(xml);
          assert(parse.length == 1, "Expected length of 1");

          assert(parse.write() == expected, "Writing doesn't output the same what we put in");
          assert(parse[0].type() == PlistElementType.PLIST_ELEMENT_DATE, "Expected boolean at index 0");

          PlistElementDate date = cast(PlistElementDate)parse[0];

    }

}
