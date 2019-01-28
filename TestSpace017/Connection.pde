// Maintain the connection information.
// Each node has 12 parameters.
// Each parameter can be null or come from 
// any other node's x, y or z.

public class Connection {
  //final int PARMS = 12;
  private int num_parms;
  private int num_outputs;
  private ArrayList<Connect []> connections;

  public Connection(int n) {
    num_parms = cf.PARMS;
    num_outputs = cf.OUTPUTS;
    connections = new ArrayList<Connect []>();
    for (int i=0; i<n; i++) {
      Connect [] c = new Connect[num_parms];
      for (int j=0; j<c.length; j++) {
        c[j] = null;
      }
      connections.add(c);
    }
  }

  public Connect [] getConnect(int i) {
    return connections.get(i);
  }

  public void connect(int n1, int p, int n2, int o) {
    if (n1 >= connections.size() || n2 >= connections.size()) 
      return;
    if (p < 0 || p >= num_parms) 
      return;
    connections.get(n1)[p] = new Connect(n2, o);
  }

  public Plug remove(int n, int p) {
    Plug plug = new Plug();
    if (n < 0 || n >= connections.size()) 
      return plug;
    if (p < 0 || p >= num_outputs) 
      return plug;
    for (int i=0; i<connections.size(); i++) {
      for (int j=0; j<num_parms; j++) {
        Connect conn = connections.get(i)[j];
        if (conn == null) {
          continue;
        }
        if (conn.getNode() == n && conn.getOutput() == p) {
          connections.get(i)[j] = null;
          plug.update(i, j);
          break;
        }
      }
    }
    return plug;
    //connections.get(n)[p] = null;
  }
}
