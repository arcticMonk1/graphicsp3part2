class Pair {
    int key;
    ArrayList<Integer> value;
    Pair(int key, ArrayList<Integer> value) {
        this.key = key;
        this.value = value;
    } 
}
class Caterpillar {
    int pathResolution;
    Ellipsoid[] elipsoids;
    int rootPtIndices[];
    int currPtIndex = 0;
    float currentRadius = 40.0f;
    float maxHeight = 80.0f;
    float currPillarRadius;
    pt[] currentPath;
    boolean shouldDisplaceVertically = true;
    boolean pathGen = false;
    ArrayList<pt> midpoints;
    color clr = blue;
    HashMap<Integer,ArrayList<Integer>> graph;
    Caterpillar(int length, int pathResolution) {
        elipsoids = new Ellipsoid[length];
        rootPtIndices = new int[length];
        this.pathResolution = pathResolution;
        midpoints = new ArrayList<pt>();
        graph = new HashMap<Integer,ArrayList<Integer>>();
    }
    void buildAdjList() {
        for (int c=0; c<M.nc; c++) {
            if(M.isInterior[M.V[c]]) {
              int curr = c;
              ArrayList<Integer> neighbors = new ArrayList<Integer>();
              do {
                neighbors.add(M.V[M.p(curr)]);
                curr = M.s(curr);
              } while(curr != c);
              graph.put(M.V[c],neighbors);
            }
        }
        for (HashMap.Entry<Integer, ArrayList<Integer>> item : graph.entrySet()) {
            println("vertex["+item.getKey()+"] neighbors="+item.getValue().size());
        }
    }

    void drawDfs() {
        int startV = 0;
        for (int v = 1; v < M.nv; v++) {
            ArrayList<Integer> path = dfs(startV, v);
            //String strPath = "[ ";
            for(int i = 0; i < path.size(); i++) {
                //strPath+= ""+path.get(i)+", ";
                if(i < path.size()-1) {
                    //show(M.G[path.get(i)],100);
                    show(M.G[path.get(i)],M.G[path.get(i+1)]);
                }
            }
            //strPath +=" ]";
            //println("v["+v +"]->v["+(v+1)+"] = "+strPath);
        }
    }
    ArrayList<Integer> dfs(int A, int B) {
        ArrayList<Pair> Stack = new ArrayList<Pair>();
        boolean[] visited = new boolean[M.nv];
        for (int v = 0; v < visited.length; v++) {
            if(M.isInterior[v]) {
                visited[v] = false;
            } else {
                //ignore exterior
                visited[v] = true;
            }
        }
        ArrayList<Integer> p = new ArrayList<Integer>();
        p.add(A);
        Stack.add(new Pair(A,p));
        while(!Stack.isEmpty()) {
            int lastIndex = Stack.size()-1;
            Pair top =  Stack.get(lastIndex);
            ArrayList<Integer> path = top.value;
            Stack.remove(lastIndex);
            if(visited[top.key] == false) {
                visited[top.key] = true;
                ArrayList<Integer> neighbors = graph.get(top.key); 
                for(int i = 0; i < neighbors.size(); i++) {
                    int w = neighbors.get(i);
                    if(M.isInterior[w]) {
                        path.add(w);
                        if(w == B) {
                            return path;
                        }
                        ArrayList<Integer> cpyPath = new ArrayList<Integer>(path);
                        Pair entry = new Pair(w, cpyPath);
                        Stack.add(entry);
                    }
                }
            }
        }
        return new ArrayList<Integer>();
    }

    void generatePathFromCorner() {
        generatePathFromCorner(0);
    }

    void checkVolume() {
        float expectedVolume = elipsoids.length*(4.0f/3.0f * PI * pow(currentRadius,3));
        float currentVolume = 0;
        for(int i = 0; i < elipsoids.length; i++) {
            currentVolume += elipsoids[i].getVolume();
        }
        if( abs(expectedVolume - currentVolume) > 10.0f) {
            //catShouldTranslateOnPath = false;
            if(printOnce) {
                println("expectedVolume: " + expectedVolume);
                println("currentVolume: " + currentVolume);
                for(int i = 0; i < elipsoids.length; i++) {
                    println("index["+ i +"].a: " + elipsoids[i].a);
                    println("index["+ i +"].b: " + elipsoids[i].b);
                    println("index["+ i +"].c: " + elipsoids[i].c);
                }
            }
        }
    }

    void generatePathFromCorner(int c) {
        if( M.pillarRadius[M.v(c)] != currPillarRadius) {
            M.pillarRadius[M.v(c)] = currPillarRadius;
        }
        if(pathGen) {
            return;
        }
        println("this is strange");
        int prev = M.u(c);
        int root = M.s(prev);
        int curr = c;
        boolean intitStart = true;
        do {
            int nx = M.s(curr);
            pt aCenter = util.circumcenter(M.g(prev),M.g(M.n(prev)),M.g(M.p(prev)));
            pt bCenter = util.circumcenter(M.g(curr),M.g(M.n(curr)),M.g(M.p(curr)));
            pt cCenter = util.circumcenter(M.g(nx),M.g(M.n(nx)),M.g(M.p(nx)));
            pt abm = util.midpoint(aCenter, bCenter);
            pt bcm = util.midpoint(bCenter, cCenter);
            prev = curr;
            curr = nx;
            midpoints.add(bcm);
            generatePath(abm, bCenter, bcm, intitStart);
            intitStart = false;
        } while(curr != root && curr != c);
        //println("num pts: " + currentPath.length);
        //for(int i = 0; i < currentPath.length; i++) {
        //    println("index["+i+"] = " + util.PointStringify(currentPath[i]));
        //}
        for(int i = 0; i < elipsoids.length; i++) {
            elipsoids[i].currentCorner = c;
        }
        pathGen = true;
        currPillarRadius = util.distance2d(M.g(c),util.midpoint(M.g(c),M.g(M.p(c)))) - (currentRadius+1);
        M.pillarRadius[M.v(c)] = currPillarRadius;
    }
    void generatePath(pt A, pt B, pt C, boolean intitStart) {
        ArrayList<pt> pts = new ArrayList<pt>(pathResolution);
        generatePathHelper(A, B, C, pathResolution, pts);
        if(intitStart) {
            currentPath = pts.toArray(new pt[0]);
            int j = 0;
            for(int i = elipsoids.length-1; i >= 0; i--, j++) {
                int jMap = (int) map(j, 0, elipsoids.length, 0, currentPath.length);
                /*if(j == 0) {
                    int jMap2 = (int) map(j+1, 0, elipsoids.length, 0, currentPath.length *(3/4.0));
                    currentRadius = 4.0f*(jMap - jMap2);
                    println("cat radius:" + currentRadius);
                }*/
                elipsoids[i] = new Ellipsoid(currentPath[jMap],currentRadius,clr,16);
                rootPtIndices[i] = jMap;
            }
            currPtIndex = rootPtIndices[0];
        } else {
            currentPath = (pt[]) concat((pt[]) currentPath,(pt[]) pts.toArray(new pt[0]));
        }
    }
    void draw() {
        for(int i = 0; i < elipsoids.length; i++) {
            elipsoids[i].draw();
        }
    }

    void resizeVertical(int i) {
        pt prevPt = M.g(M.p(elipsoids[i].currentCorner));
        pt currPt = M.g(elipsoids[i].currentCorner);
        float prevPillarRadius = M.pillarRadius[M.v(M.p(elipsoids[i].currentCorner))];
        float currentPillarRadius = M.pillarRadius[M.v(elipsoids[i].currentCorner)];

        if(elipsoids[i].intersect(prevPt,prevPillarRadius) && 
                elipsoids[i].intersect(currPt,currentPillarRadius)) {
            float distance = util.distance2d(currPt,prevPt);
            float shrinkTo = distance - (prevPillarRadius+ currentPillarRadius);
            elipsoids[i].shrinkTo(shrinkTo);
        } else {
            if(elipsoids[i].wasSphere()) {
                elipsoids[i].restoreSphere();
            }
        }
    }
    
    boolean getIntersectionPrev(int i) {
        return getIntersectionPrev(i,null);
    }

    boolean getIntersectionNext(int i) {
        return getIntersectionNext(i,null);
    }

    boolean getIntersectionPrev(int i, float[] outDistance) {
        pt prevPt = M.g(M.p(elipsoids[i].currentCorner));
        pt currPt = M.g(elipsoids[i].currentCorner);
        float prevPillarRadius = M.pillarRadius[M.v(M.p(elipsoids[i].currentCorner))];
        float currentPillarRadius = M.pillarRadius[M.v(elipsoids[i].currentCorner)];
        boolean intersect =  elipsoids[i].intersect(currPt,currentPillarRadius) && 
                elipsoids[i].intersect(prevPt,prevPillarRadius);
        if(outDistance !=null) {
            float distancePrev = util.distance2d(currPt, prevPt);
            outDistance[0] = distancePrev - (prevPillarRadius + currentPillarRadius);
            //println("elipsoids["+ i +"].distancePrev: " + distancePrev);
            //println("elipsoids["+ i +"].prevPillarRadius: " + prevPillarRadius);
            //println("elipsoids["+ i +"].currentPillarRadius: " + currentPillarRadius);
            //println("elipsoids["+ i +"].dPillarRadius: " + (prevPillarRadius + currentPillarRadius));

        }
        return intersect;
    }

    boolean getIntersectionNext(int i, float[] outDistance) {
        float nextPillarRadius = M.pillarRadius[M.v(M.n(elipsoids[i].currentCorner))];
        float currentPillarRadius = M.pillarRadius[M.v(elipsoids[i].currentCorner)];
        pt currPt = M.g(elipsoids[i].currentCorner);
        pt nextPt = M.g(M.n(elipsoids[i].currentCorner));
        boolean intersect = elipsoids[i].intersect(currPt,currentPillarRadius) && 
               elipsoids[i].intersect(nextPt,nextPillarRadius);
        if(outDistance !=null) {
            float distanceNext = util.distance2d(currPt, nextPt);
            outDistance[0] = distanceNext - (nextPillarRadius + currentPillarRadius);
            //println("elipsoids["+ i +"].distanceNext: " + distanceNext);
            //println("elipsoids["+ i +"].nextPillarRadius: " + nextPillarRadius);
            //println("elipsoids["+ i +"].currentPillarRadius: " + currentPillarRadius);
            //println("elipsoids["+ i +"].dPillarRadius: " + (nextPillarRadius + currentPillarRadius));
        }
        return intersect;
    }

    float getDeltaVolume(Ellipsoid el, float newRadius) {
        float oldVolume = el.getVolume();
        el.a = newRadius;
        el.b = newRadius;
        float newVolume = el.getVolume();
        float volumeDelta = max(oldVolume - newVolume,0);
        return volumeDelta;
    }
    
    float getC(float volume, float radius) {
        return (3.0f*volume)/(4.0f*PI*pow(radius,2));
    }

    void horizontalDisplacement(float maxDiameter, int i) {
        float newRadius = maxDiameter/2.0f;
        Ellipsoid el = elipsoids[i];
        if(newRadius > el.a) {
            return;
        }
        float volumeDelta = getDeltaVolume(el,newRadius);
        if(volumeDelta == 0) {
            return;
        }
        int nextIndex = (i + 1) % elipsoids.length;
        Ellipsoid elNext = elipsoids[nextIndex];
        float nextVolume = elNext.getVolume() + volumeDelta;
        float nextRadius = pow((3.0f*nextVolume)/(4.0f*PI),1.0f/3.0f);
        elNext.a = nextRadius;
        elNext.b = nextRadius;
        elNext.c = nextRadius;
    }

    void translateOnPath() {
        if(shouldDisplaceVertically) {
            translate();
            translateOnPathVeritcal();
        } else {
            translate();
            translateOnPathHorizontal();
        }
    }
    void addVolume(int i, float dVolume) {
        if(dVolume == 0) {
            return;
        }
        Ellipsoid elNext = elipsoids[i];
        float nextVolume = elNext.getVolume() + dVolume;
        float nextRadius = pow((3.0f*nextVolume)/(4.0f*PI),1.0f/3.0f);
        elNext.a = nextRadius;
        elNext.b = nextRadius;
        elNext.c = nextRadius;
    }
    void distVolumeOnHeight(int i) {
        if(i == -1) {
            return;
        }
         Ellipsoid elNext = elipsoids[i];
        float[] prevShrinkTo = new float[1];
        float[] nextShrinkTo = new float[1];
        boolean interNext = getIntersectionNext(i, nextShrinkTo);
        boolean interPrev = getIntersectionPrev(i, prevShrinkTo);
        float maxDiameter2 = min(prevShrinkTo[0], nextShrinkTo[0]);
        if(interNext || interPrev && maxDiameter2 < 2*elNext.a) {
            float maxRadius = maxDiameter2/2.0f;
            float oldVolume = elNext.getVolume();
            elNext.a = maxRadius;
            elNext.b = maxRadius;
            float c = getC(oldVolume, maxRadius);
            float cDistributed  = c / (float) elipsoids.length;
            elNext.c = cDistributed;
            for(int j = 1; j < elipsoids.length;j++) {
                int jj = (i+j) % elipsoids.length;
                elipsoids[jj].c += cDistributed;
            }
        }
    }
    int findLargestVolume() {
        float largestVolume = 0;
        int index = -1;
        for(int i = 0; i < elipsoids.length;i++) {
            float v = elipsoids[i].getVolume();
            if(v > largestVolume) {
                largestVolume = v;
                index = i;
            }
        }
        return index;
    }
    void translateOnPathHorizontal() {

        for(int i = 0; i < elipsoids.length; i++) {
            float[] prevShrinkTo = new float[1];
            float[] nextShrinkTo = new float[1];
            boolean interNext = getIntersectionNext(i,nextShrinkTo);
            boolean interPrev = getIntersectionPrev(i, prevShrinkTo);
            float maxDiameter = min(prevShrinkTo[0], nextShrinkTo[0]);
            if(interNext || interPrev ) {
                horizontalDisplacement(maxDiameter, i);
            }
        }
        //distVolumeOnHeight(findLargestVolume());

        boolean noIntersections = true;
        for(int i = 0; i < elipsoids.length; i++) {
            if(getIntersectionNext(i) || getIntersectionPrev(i)) {
                noIntersections = false;
                break;
            }
        }
        if(noIntersections){
            for(int i = 0; i < elipsoids.length; i++) {
                elipsoids[i].restoreSphere();
            }
        }
    }

    void translateOnPathVeritcal() {
        for(int i = 0; i < elipsoids.length; i++) {
            resizeVertical(i);
        }
    }
    void translate() {
        for(int i = 0; i < elipsoids.length; i++) {
            if(i == 0) {
                if(currPtIndex < currentPath.length-1) {
                    currPtIndex++;
                } else {
                    currPtIndex =  0;
                }
                elipsoids[i].center =  currentPath[currPtIndex];
            } else {
                 int deltaIndex = rootPtIndices[0] - rootPtIndices[i];
                 //println("deltaIndex: "+deltaIndex);
                 int indexLookup = currPtIndex-deltaIndex;
                 if(indexLookup < 0) {
                     indexLookup = (currentPath.length-1)+ indexLookup;
                 }
                 //println("indexLookup: "+indexLookup);
                 elipsoids[i].center = currentPath[indexLookup];
            }

            //println("midpoints: " + util.PointStringify(midpoints.get(cornerCount)));
            //println("currPt: " + util.PointStringify(elipsoids[0].center));
            if(elipsoids[i].center.x == midpoints.get(elipsoids[i].cornerCount).x && 
               elipsoids[i].center.y == midpoints.get(elipsoids[i].cornerCount).y) {
                //println("currentCorner["+ cornerCount +"] before: " + currentCorner);
                elipsoids[i].currentCorner = M.s(elipsoids[i].currentCorner);
                if(elipsoids[i].cornerCount < midpoints.size()-1){
                    elipsoids[i].cornerCount++;
                } else {
                    elipsoids[i].cornerCount = 0;
                }
                //println("currentCorner["+ cornerCount +"] after: " + currentCorner);
            }
        }
    }
    void generatePathHelper(pt A, pt B, pt C, int rec, ArrayList<pt> pts) {
        if (rec==0) { 
            pts.add(A);
            pts.add(B);
            pts.add(C);
        }  else { 
            float w = (d(A,B)+d(B,C))/2;
            float l = d(A,C)/2;
            float t = l/(w+l);
            pt L = L(A,t,B);
            pt R = L(C,t,B);
            pt M = P(L,R);
            generatePathHelper(A,L, M,rec-1,pts);
            generatePathHelper(M,R, C,rec-1,pts); 
     }
   }
}
