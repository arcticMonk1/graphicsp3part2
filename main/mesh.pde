// TRIANGLE MESH
class MESH {
    // VERTICES
    int nv=0, maxnv = 1000;  
    pt[] G = new pt [maxnv];                        
    // TRIANGLES 
    int nt = 0, maxnt = maxnv*2;                           
    boolean[] isInterior = new boolean[maxnv];                                      
    // CORNERS 
    int c=0;    // current corner                                                              
    int nc = 0; 
    int[] V = new int [3*maxnt];   
    int[] O = new int [3*maxnt];  
    // current corner that can be edited with keys
  MESH() {for (int i=0; i<maxnv; i++) G[i]=new pt();};
  void reset() {
    nv=0; nt=0; nc=0; // removes all vertices and triangles
  }

  void loadVertices(pt[] P, int n) {nv=0; for (int i=0; i<n; i++) addVertex(P[i]);}
  void writeVerticesTo(pts P) {for (int i=0; i<nv; i++) P.G[i].setTo(G[i]);}
  void addVertex(pt P) { G[nv++].setTo(P); }                                             // adds a vertex to vertex table G
  void addTriangle(int i, int j, int k) {
    if(nc >= V.length) {
      /*println("nc is : " + nc +
              "V.length: " + V.length);*/
      return;
    }
    V[nc++]=i; V[nc++]=j; V[nc++]=k; nt=nc/3; 
    }     // adds triangle (i,j,k) to V table

  // CORNER OPERATORS
  int t (int c) {int r=int(c/3); return(r);}                   // triangle of corner c
  int n (int c) {int r=3*int(c/3)+(c+1)%3; return(r);}         // next corner
  int p (int c) {int r=3*int(c/3)+(c+2)%3; return(r);}         // previous corner
  pt g (int c) {return G[V[c]];}                             // shortcut to get the point where the vertex v(c) of corner c is located

  boolean nb(int c) {return(O[c]!=c);};  // not a border corner
  boolean bord(int c) {return(O[c]==c);};  // not a border corner
  boolean genPillars = true;
  float[] pillarRadius;
  pt cg(int c) {return P(0.6,g(c),0.2,g(p(c)),0.2,g(n(c)));}   // computes offset location of point at corner c

  // CORNER ACTIONS CURRENT CORNER c
  void next() {c=n(c);}
  void previous() {c=p(c);}
  void opposite() {c=o(c);}
  void left() {c=l(c);}
  void right() {c=r(c);}
  void swing() {c=s(c);} 
  void unswing() {c=u(c);} 
  void printCorner() {println("c = "+c);}
  
  

  // DISPLAY
  void showCurrentCorner(float r) { if(bord(c)) fill(red); else fill(dgreen); show(cg(c),r); };   // renders corner c as small ball
  void showEdge(int c) {beam( g(p(c)),g(n(c)),rt ); };  // draws edge of t(c) opposite to corner c
  void showVertices(float r) // shows all vertices green inside, red outside
    {
    for (int v=0; v<nv; v++) 
      {
      if(isInterior[v]) fill(green); else fill(red);
      show(G[v],r);
      }
    }                          
  void showInteriorVertices(float r) {for (int v=0; v<nv; v++) if(isInterior[v]) show(G[v],r); }                          // shows all vertices as dots
  void showTriangles() { for (int c=0; c<nc; c+=3) show(g(c), g(c+1), g(c+2)); }         // draws all triangles (edges, or filled)
  void showEdges() {for (int i=0; i<nc; i++) showEdge(i); };         // draws all edges of mesh twice

  void triangulate()      // performs Delaunay triangulation using a quartic algorithm
   {
     c=0;                   // to reset current corner
     pt cen = new pt(0,0);
     for (int i=0; i<nv; i++) {
       for (int j=i+1; j<nv; j++) {
         if(j == i) {
           continue;
         }
         for (int k=j+1; k<nv; k++) {
           if(k == j || k == i) {
             continue;
           }
           boolean good = true;
           cen = util.circumcenter(G[i],G[j],G[k]);
           //cen = CircumCenter(G[i],G[j],G[k]);
           for (int m=0; m<nv; m++) {
             if(m == i || m == j || m == k) {
               continue;
             }
             if(util.normVecAB(cen,G[m]) <= util.normVecAB(cen,G[i])) {
               good = false;
               break;
             }
           }
           if(good) {
             //println("{i: "+i +" j: "+j + " k: " + k + "} ");
             if(ccw(G[i],G[j],G[k])) {
               addTriangle(i,j,k);
             }else {
               addTriangle(k,j,i);
             }
           }
         }
       }
     }
   }

  void swap(int c,int b) {
    O[c]=b; 
    O[b]=c;
  }
  void computeO() // **02 implement it 
    {
      int ntTriBound = nt*3;
      for (int c=0; c<ntTriBound; c++) {
        O[c]=c;
      }
      for (int c=0; c<ntTriBound; c++) {
        for (int b=0; b<ntTriBound; b++) {
          if(c == b) {
            continue;
         }
         int nextOfC = n(c);
         int nextOfB = n(b);
         int prevOfC = p(c);
         int prevOfB = p(b);
         if(V[nextOfC] == V[prevOfB] && V[prevOfC] == V[nextOfB]) {
           swap(c,b);
         }
       }
      }
    }

  void showBorderEdges()  // draws all border edges of mesh
    {
      for (int i=0; i<nc; i++) {
        if(O[i] == i){
          showEdge(i);
        }
      }
    }

  void showNonBorderEdges() // draws all non-border edges of mesh
    {
      for (int i=0; i<nc; i++) {
        if(O[i] != i){
          showEdge(i);
        }
      }
    }
    
  void classifyVertices() {
      for(int v = 0; v < nv; v++) {
        isInterior[v] = true;
      }

      for(int c = 0; c < nc; c++) {
        if(O[c] == c){
          isInterior[V[n(c)]] = false;
          isInterior[V[p(c)]] = false;
        }
      }
}

pt weightedSmooth(int c) {
    pt avgSum = new pt(0,0);
    int root = s(u(c));
    int curr = root; 
    float distSum = 0;
    do {
      float distance = util.distance2d(g(n(curr)),g(p(curr)));
      pt avgPt = util.average(new pt[]{ g(n(curr)),g(p(curr)) });
      avgPt.mul(distance);
      avgSum.add(avgPt);
      distSum += distance;
      curr = s(curr);
    }
    while(curr != root);
    return avgSum.div(distSum);
}

  void smoothenInterior() { // even interior vertiex locations
    pt[] Gn = new pt[nv];
    if(SMOOTHTYPE == AVGWEIGHTED) {

    }
    for (int c=0; c<nc; c++) {
      int v = V[c];
      if(isInterior[v]) {
        switch(SMOOTHTYPE) {
          case CENTROID:
            Gn[v] = util.triCentroid(G[V[n(c)]],G[v], G[V[p(c)]]);
            break;
          case AVGNEIGH:
            Gn[v] = avgerageNeighbors(c);
            break;
          case AVGNEIGHCENTROIDS:
            Gn[v] = avgerageNeighborCentroids(c);
            break;
          case AVGWEIGHTED:
            Gn[v] = weightedSmooth(c);
            break;
          //case AVGWEIGHTEDTRIAREA:
            //Gn[v] = averageWeightByTriArea(c);
           // break;
        }
        G[v].translateTowards(.1,Gn[v]);
      }
    }
  }

  pt avgerageNeighbors(int c) {
    pt avgPt = new pt(0,0);
    int root = s(u(c));
    int curr = root; 
    int ngCount = 0;
    do {
      avgPt.add(G[V[n(curr)]]);
      ngCount++;
      curr = s(curr);
    }while(curr != root);
    if(ngCount == 0) {
      ngCount = 1;
    }
    return avgPt.div(ngCount);
  }
/*
  pt averageWeightByTriArea(int c) {
    pt avgPt = new pt(0,0);
    int root = s(u(c));
    int curr = root;
    float totalArea =  0;
    do {
      pt o = G[V[curr]];
      pt pi = G[V[n(curr)]];
      pt piplus1 = G[V[p(curr)]];
      pt piminus1 = G[V[n(u(curr))]];
      double currArea = area(o,pi,piplus1);
      double prevArea = area(o,pi,piminus1);
      float sumArea = (float)(currArea+prevArea)/2.0f;
      avgPt.add(pi.mul(sumArea));
      totalArea += sumArea;
      curr = s(curr);
    }while(curr != root);
    if(totalArea == 0) {
      totalArea = 1;
    }
    println("total Area: " + totalArea);
    return avgPt.div(totalArea);
  }*/

  pt avgerageNeighborCentroids(int c) {
    pt avgCentroids = new pt(0,0);
    int root = s(u(c));
    int curr = root; 
    int ngCount = 0;
    do {
      pt cent =util.triCentroid(G[V[n(curr)]],G[V[curr]], G[V[p(curr)]]);
      avgCentroids.add(cent);
      ngCount++;
      curr = s(curr);
    }while(curr != root);
    if(ngCount == 0) {
      ngCount = 1;
    }
    return avgCentroids.div(ngCount);
  }


   // **05 implement corner operators in Mesh
  int v (int c) {return V[c];}                                // vertex of c
  int o (int c) {return O[c];}                                // opposite corner
  int l (int c) {return o(n(c));}                             // left
  int s (int c) {return n(l(c));}                                   // left
  int u (int c) {return p(r(c));}                                   // left
  int r (int c) {return o(p(c));}                             // right

void showOpposites() {
   //HashSet<Edge> edges = new HashSet<Edges>();
   HashMap<Integer,Edge> edges = new HashMap<Integer,Edge>();
   for (int c=0; c<nc; c++) {
     int opp = O[c];
     if(opp != c) {
       pt a = g(c);
       pt oppPt = g(opp);
       Edge e = new Edge(a,oppPt);
       Edge re = new Edge(oppPt,a);
       if(edges.get(e.hashCode()) != null &&
          edges.get(re.hashCode()) != null) {
         continue;
       }
       edges.put(e.hashCode(),e);
       edges.put(re.hashCode(),re);
       //edges.add(e);
       //show(a, oppPt);
       pt cent = util.circumcenter(a, g(n(c)), oppPt);
       drawParabolaInHat(a, cent, oppPt, 6);
     }
   }
   //println(edges.size());

}

void showVoronoiEdges() // draws Voronoi edges on the boundary of Voroni cells of interior vertices
{
  for (int c=0; c<nc; c++) {
    if(O[c] != c && c < o(c)) {
      //note didn't know there was a CircumCenter function wrote my own.
      pt cornerCcenter = util.circumcenter(g(c),g(n(c)),g(p(c)));
      int b = o(c);
      pt cornerBcenter = util.circumcenter(g(b),g(n(b)),g(p(b)));
      show(cornerCcenter, cornerBcenter);
    }
  }
}

void showPillars() {
  if(genPillars) {
    pillarRadius = new float[nv];
    for( int v = 0; v < nv; v++) {
      pillarRadius[v] = 110+random(70);
    }
    genPillars = false;
  }
   for (int v=0; v<nv; v++) {
     if(isInterior[v]) {
        fill(magenta,150);
        pillar(G[v],90,pillarRadius[v]);
      }
  }
}

void showArcs() // draws arcs of quadratic B-spline of Voronoi boundary loops of interior vertices
    { 
      for (int c=0; c<nc; c++) {
        if(isInterior[V[c]]) {
        //if(O[c] != c && c < o(c)) {
          int prev = u(c);
          int root = s(prev);
          int curr = root;
          do {
            //println("curr is: " + curr);
            int nx = s(curr);
            pt aCenter = util.circumcenter(g(prev),g(n(prev)),g(p(prev)));
            pt bCenter = util.circumcenter(g(curr),g(n(curr)),g(p(curr)));
            pt cCenter = util.circumcenter(g(nx),g(n(nx)),g(p(nx)));
            pt abm = util.midpoint(aCenter, bCenter);
            pt bcm = util.midpoint(bCenter, cCenter);
            drawParabolaInHat(abm, bCenter, bcm, 6);
            prev = curr;
            curr = nx;
          } while(curr != root && curr != c);
        }
      }
    }

    void drawVoronoiFaceOfInteriorVertex() {
      float dc = 1./(nv-1);
      for(int c = 0; c < nc; c++) {
        int v = V[c];
        if(isInterior[v]) {
          fill(dc*255*v,dc*255*(nv-v),200);
          drawVoronoiFaceOfInteriorVertex(c);
        }
      }
    }

    void drawVoronoiFaceOfInteriorVertex(int c) {
      int prev = u(c);
      int root = s(prev);
      int curr = root;
      beginShape();
      do {
        //println("curr is: " + curr);
        int nx = s(curr);
        pt aCenter = util.circumcenter(g(prev),g(n(prev)),g(p(prev)));
        pt bCenter = util.circumcenter(g(curr),g(n(curr)),g(p(curr)));
        pt cCenter = util.circumcenter(g(nx),g(n(nx)),g(p(nx)));
        vertex(aCenter);
        vertex(bCenter);
        vertex(cCenter);
        prev = curr;
        curr = nx;
      } while(curr != root && curr != c);
      endShape(CLOSE);
    }

  pt triCenter(int c) {return P(g(c),g(n(c)),g(p(c))); }  // returns center of mass of triangle of corner c
  pt triCircumcenter(int c) {return CircumCenter(g(c),g(n(c)),g(p(c))); }  // returns circumcenter of triangle of corner c


  } // end of MESH
