public class Plug {
  private int id;
  private int cable;

  public Plug() {
    id = -1;
    cable = -1;
  }

  public void update(int i, int c) {
    id = i;
    cable = c;
  }

  public int getId() {
    return id;
  }

  public int getCable() {
    return cable;
  }
}
