/* $Id: myURL.java,v 1.1 2001/11/30 23:25:42 bill Exp $
From "Learning Oracle PL/SQL page 297

Java program (static class with a single method) to retrieve a given web
page via URL.  Approach derive from code I found at
http://csnet.sc.maricopa.edu/csc260/976/handouts/FetchURL.java

*/

import java.net.*;
import java.io.*;
import java.util.*;

public class myURL
{ public static void getBytes (String theURL, int maxLength, byte[][] bytesOut, int[] byteCount)
  throws MalformedURLException, IOException
  {   
      URL url  = new URL(theURL);
         
      URLConnection urlC = url.openConnection();
      InputStream is = urlC.getInputStream();

      byte[] theBytes = new byte[maxLength];
      byteCount[0] = is.read(theBytes);
      bytesOut[0] = theBytes;
      is.close();
   }
}
