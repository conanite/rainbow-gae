package rainbow.gae;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.LinkedList;
import java.util.List;

public class ServletOutput extends OutputStream {
  private HttpServletResponse response;
  private OutputStream o;
  private StringBuilder buffer = new StringBuilder();
  private boolean finishedHeaders = false;
  private boolean finishedStatus = false;

  public ServletOutput(HttpServletResponse response) throws IOException {
    this.response = response;
    o = response.getOutputStream();
  }

  public void write(int i) throws IOException {
    if (finishedHeaders) {
      o.write(i);
    } else if (finishedStatus) {
      appendToHeader(i);
    } else {
      appendToStatus(i);
    }
  }

  private void appendToStatus(int i) {
    buffer.append((char)i);
    String s = buffer.toString();
    int nl = s.indexOf("\n");
    if (nl == -1) {
      return;
    }

    s = s.substring("HTTP/1.1 ".length());
    s = s.replaceAll("[^\\d]", "");
    response.setStatus(Integer.parseInt(s));
    buffer.setLength(0);
    finishedStatus = true;
  }

  private void appendToHeader(int i) {
    buffer.append((char)i);
    String s = buffer.toString();
    int nlnl = s.indexOf("\n\n");
    if (nlnl == -1) {
      return;
    }

    finishedHeaders = true;

    String[] headers = s.substring(0, nlnl).split("\n");
    for (String header : headers) {
      String[] nv = header.split(":");
      String name = nv[0].trim();
      String value = nv[1].trim();
      response.setHeader(name, value);
    }

    String body = s.substring(nlnl + 2);
    PrintStream ps = new PrintStream(o);
    ps.print(body);
    ps.flush();
  }

  public static void main(String[] args) throws IOException {
    final OutputStream out = new ByteArrayOutputStream();
    final ServletOutputStream wrapper = new ServletOutputStream() {
      public void write(int i) throws IOException {
        out.write(i);
      }
    };

    final List headers = new LinkedList();
    HttpServletResponse r = new TestHttpServletResponse(headers, wrapper);

    ServletOutput test = new ServletOutput(r);
    PrintStream printer = new PrintStream(test);

    printer.print("HTTP/1.1 200 OK\n");
    printer.print("Conte");
    printer.print("nt-Typ");
    printer.print("e: text/html\n");
    printer.print("Content-encoding: utf8\n");
    printer.print("\n");
    printer.print("<html>\n<body");
    printer.print(">Hello, wor");
    printer.print("ld\n\n</body>");
    printer.print("\n</html>\n\n");

    System.out.println(headers.toString());
    System.out.println(out.toString());
  }

}
