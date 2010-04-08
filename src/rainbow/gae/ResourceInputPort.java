package rainbow.gae;

import rainbow.ArcError;
import rainbow.types.Input;

import java.io.InputStream;

public class ResourceInputPort extends Input {
  private String name;

  public ResourceInputPort(String path) {
    super(getStream(path));
    this.name = path;
  }

  private static InputStream getStream(String name) {
    InputStream result = ResourceInputPort.class.getResourceAsStream(name);
    if (result == null) {
      throw new ArcError("No resource found at '" + name + "'");
    }
    return result;
  }

  public String getName() {
    return name;
  }
}
