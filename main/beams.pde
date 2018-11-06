// CLASS FOR KEEPING THE EDGES OF THE MESH
class EdgeSet // class for storing edges 
  { 
  int maxnbe = 1000;                 //  max number of edges
  int nb=0;                          // current number of edges
  int [] S = new int [maxnbe];       //  ID of ball or vertex where edge starts
  int [] E = new int [maxnbe];       //  ID of ball where edge ends
  EdgeSet() {}
  void reset() {nb=0;}
  void addEdge(int i, int j) {if(!isDuplicate(i,j)) {S[nb]=i; E[nb]=j; nb++;}}
  void showEdges(pts P, float rt) {for(int b=0; b<nb; b++) beam(P.G[S[b]],P.G[E[b]],rt);} // uses vertices of P to draw these edges
  boolean isDuplicate(int i, int j) // returns true if this edge already exists
    {
    for(int b=0; b<nb; b++) if((E[b]==i && S[b]==j) || (E[b]==j && S[b]==i)) return true;
    return false;
    }
  int count() {return nb;} // total edge count
  }
