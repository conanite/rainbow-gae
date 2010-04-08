package rainbow.gae;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.ServletOutputStream;
import java.util.List;
import java.util.Locale;
import java.io.IOException;
import java.io.PrintWriter;

public class TestHttpServletResponse implements HttpServletResponse {
  private final List headers;
  private final ServletOutputStream wrapper;

  public TestHttpServletResponse(List headers, ServletOutputStream wrapper) {
    this.headers = headers;
    this.wrapper = wrapper;
  }

  public void addCookie(Cookie cookie) {
  }

  public boolean containsHeader(String s) {
    return false;
  }

  public String encodeURL(String s) {
    return null;
  }

  public String encodeRedirectURL(String s) {
    return null;
  }

  public String encodeUrl(String s) {
    return null;
  }

  public String encodeRedirectUrl(String s) {
    return null;
  }

  public void sendError(int i, String s) throws IOException {
  }

  public void sendError(int i) throws IOException {
  }

  public void sendRedirect(String s) throws IOException {
  }

  public void setDateHeader(String s, long l) {
  }

  public void addDateHeader(String s, long l) {
  }

  public void setHeader(String name, String value) {
    headers.add(name + ": " + value);
  }

  public void addHeader(String s, String s1) {
  }

  public void setIntHeader(String s, int i) {
  }

  public void addIntHeader(String s, int i) {
  }

  public void setStatus(int i) {
    headers.add("status is " + i);
  }

  public void setStatus(int i, String s) {
  }

  public String getCharacterEncoding() {
    return null;
  }

  public String getContentType() {
    return null;
  }

  public ServletOutputStream getOutputStream() throws IOException {
    return wrapper;
  }

  public PrintWriter getWriter() throws IOException {
    return null;
  }

  public void setCharacterEncoding(String s) {
  }

  public void setContentLength(int i) {
  }

  public void setContentType(String s) {
  }

  public void setBufferSize(int i) {
  }

  public int getBufferSize() {
    return 0;
  }

  public void flushBuffer() throws IOException {
  }

  public void resetBuffer() {
  }

  public boolean isCommitted() {
    return false;
  }

  public void reset() {
  }

  public void setLocale(Locale locale) {
  }

  public Locale getLocale() {
    return null;
  }
}
