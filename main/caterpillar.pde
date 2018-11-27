class Pair {
    pt key;
    ArrayList<pt> value;
    Pair(pt key, ArrayList<pt> value) {
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
    HashMap<Integer,ArrayList<Integer>> pointMap;
    ArrayList<pt> genPoints;
    

    Caterpillar(int length, int pathResolution) {
        elipsoids = new Ellipsoid[length];
        rootPtIndices = new int[length];
        this.pathResolution = pathResolution;
        midpoints = new ArrayList<pt>();
        pointMap = new HashMap<Integer, ArrayList<Integer>>();
        genPoints = new ArrayList<pt>();
    }
    void addPoints(pt a) {
        if(a.index == -1) {
            genPoints.add(a);
            a.index = genPoints.size()-1;
        }
    }
    void addNeighbors(pt a, pt b) {
        ArrayList<Integer> neighbors = pointMap.get(a.index);
        if(neighbors == null) {
            neighbors = new ArrayList<Integer>();
            addPoints(a);
            addPoints(b);
            neighbors.add(b.index);
            pointMap.put(a.index, neighbors);
        } else {
            addPoints(b);
            neighbors.add(b.index);
        }
    }

    pt genVoronoiGraph() {
      pt start = null;
      for (int c=0; c<M.nc; c++) {
        if(M.isInterior[M.V[c]]) {
          int root = M.s(M.u(c));
          int curr = root;
          do {
            pt am = util.midpoint(M.g(curr), M.g(M.p(curr)));
            pt bm = util.midpoint(M.g(curr), M.g(M.n(curr)));
            if(pointMap.size() == 0) {
                start = am;
            }
            addNeighbors(am,bm);
            curr = M.s(curr);
          } while(curr != root && curr != c);
        }
      }
      return start;
    }

    void topologicalSort(pt v, boolean visited[], 
                                ArrayList<pt> Stack) { 
        // Mark the current node as visited 
        visited[v.index] = true; 
        ArrayList<Integer> neighbors = pointMap.get(v.index);
        for (int i = 0; i < neighbors.size(); i++) { 
            pt node = genPoints.get(neighbors.get(i)); 
            if (!visited[node.index]) 
                topologicalSort(node, visited, Stack); 
        } 
        Stack.add(v); 
    }

    ArrayList<pt> dfs(pt A, pt B) {
        ArrayList<Pair> Stack = new ArrayList<Pair>();
        boolean[] visited = new boolean[pointMap.size()];
        for (int i = 0; i < visited.length; i++) {
            visited[i] = false;
        }
        ArrayList<pt> p = new ArrayList<pt>();
        p.add(A);
        Stack.add(new Pair(A,p));
        
        while(!Stack.isEmpty())
        {
            int lastIndex = Stack.size()-1;
            Pair top =  Stack.get(lastIndex);
            ArrayList<pt> path = top.value;
            Stack.remove(lastIndex);
            if(visited[top.key.index] == false)
            {
                visited[top.key.index] = true;
                ArrayList<Integer> neighbors = pointMap.get(top.key); 
                for(int i = 0; i < neighbors.size(); i++) {
                    pt w = genPoints.get(neighbors.get(i));
                    path.add(w);
                    if(w == B)
                    {
                        return path;
                    }
                    ArrayList<pt> cpyPath = new ArrayList<pt>(path);
                    cpyPath.add(w);
                    Pair entry = new Pair(w,cpyPath);
                    Stack.add(entry);
                }
            }
        }
        return new ArrayList<pt>();
    }

    pt longestPath(pt start) {
        boolean[] visited = new boolean[pointMap.size()];
        ArrayList<pt> Stack = new ArrayList<pt>(); 
        int dist[] = new int[visited.length]; 
        for (int i = 0; i < visited.length; i++) {
            visited[i] = false;
        }
        for (HashMap.Entry<Integer, ArrayList<Integer>> item : pointMap.entrySet()) {
            pt key = genPoints.get(item.getKey());
            if (visited[key.index] == false) {
                topologicalSort(key, visited, Stack);
            }
        }
        for (int i = 0; i < visited.length; i++) {
            dist[i] = Integer.MAX_VALUE;
        }
        dist[start.index] = 0; 

        while(!Stack.isEmpty()) {
            int lastIndex = Stack.size()-1;
            pt u =  Stack.get(lastIndex);
            Stack.remove(lastIndex);
            if (dist[u.index] != Integer.MAX_VALUE) {
                ArrayList<Integer> neighbors = pointMap.get(u); 
                for (int i = 0; i < neighbors.size(); i++) {
                    pt neighborPt = genPoints.get(neighbors.get(i));
                    if (dist[neighborPt.index] < dist[u.index]) { 
                        dist[neighborPt.index] = dist[u.index]; 
                    }
                }
            }
        }
        int max = -1;
        int maxIndex = 0;
        for(int i = 0; i < dist.length; i++) {
            if(dist[i] != Integer.MAX_VALUE && dist[i] > max) {
                max = dist[i];
                maxIndex = i;
            }
        }
        return genPoints.get(maxIndex);
    }
    void genVoronoiGraphDiagnostics() {
        for (HashMap.Entry<Integer, ArrayList<Integer>> item : pointMap.entrySet()) {
            println(util.PointStringify(genPoints.get(item.getKey())) + 
                    " : " + item.getValue().size());
        }
    }
    void generateLongPath() {
        if(pathGen) {
            return;
        }
        pt start = genVoronoiGraph();
        genVoronoiGraphDiagnostics();
        pt end = longestPath(start);
        ArrayList<pt> startPath = dfs(start,end);
        ArrayList<pt> endPath = dfs(end, start);
        for(int i = 0; i < startPath.size()-3; i++) {
            boolean intitStart = (i == 0);
            generatePath(startPath.get(i),startPath.get(i+1),
                startPath.get(i+2), intitStart);
        }
         for(int i = 0; i < endPath.size()-3; i++) {
             generatePath(startPath.get(i),startPath.get(i+1),
                startPath.get(i+2),false);
         }
         pathGen = true;
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
                elipsoids[i] = new Ellipsoid(currentPath[jMap],currentRadius,blue,16);
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
        /*float newC = getC(oldVolume, newRadius);
        if(newC < maxHeight) {
            el.c = newC;
        } else {
            el.c = maxHeight;
        }*/
        float newVolume = el.getVolume();
        float volumeDelta = max(oldVolume - newVolume,0);
        return volumeDelta;
    }
    float getC(float volume, float radius) {
        return (3.0f*volume)/(4.0f*PI*pow(radius,2));
    }
    void horizontalDisplacement(float maxDiameter, int i) {
        float newRadius = maxDiameter/2.0f;
        
        //DEBUG block delete
        if(maxDiameter == 0) {
            println("elipsoids["+ i +"].maxDiameter: " + maxDiameter);
            println("elipsoids["+ i +"].newRadius: " + newRadius);
            catShouldTranslateOnPath = false;
            return;
        }
        //DEBUG block delete

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
