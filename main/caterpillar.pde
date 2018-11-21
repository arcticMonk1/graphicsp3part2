class Caterpillar {
    int pathResolution;
    Ellipsoid[] elipsoids;
    //boolean[] intersections;
    int displaceOver = 0;
    int rootPtIndices[];
    int currPtIndex = 0;
    int cornerCount = 0;
    pt[] currentPath;
    boolean shouldDisplaceVertically = false;
    boolean resize = true;
    boolean pathGen = false;
    ArrayList<pt> midpoints;
    Caterpillar(int length, int pathResolution) {
        elipsoids = new Ellipsoid[length];
        //intersections = new boolean[length];
        rootPtIndices = new int[length];
        this.pathResolution = pathResolution;
        pathResolution = length;
        midpoints = new ArrayList<pt>();
    }

    void generatePathFromCorner() {
        generatePathFromCorner(0);
    }
    void generatePathFromCorner(int c) {
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
            elipsoids[i].currentCorner =c;
        }
        pathGen = true;
    }
    void generatePath(pt A, pt B, pt C, boolean intitStart) {
        ArrayList<pt> pts = new ArrayList<pt>(pathResolution);
        generatePathHelper(A, B, C, pathResolution, pts);
        if(intitStart) {
            currentPath = pts.toArray(new pt[0]);
            int j = 0;
            for(int i = elipsoids.length-1; i >= 0; i--, j++) {
                int jMap = (int) map(j, 0, elipsoids.length, 0, currentPath.length *(3/4.0));
                elipsoids[i] = new Ellipsoid(currentPath[jMap],40.0f,blue,16);
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

    /*void saveAllIntersection() {
        displaceOver = 0;
        for(int i = 0; i < elipsoids.length; i++) {
            pt prevPt = M.g(M.p(elipsoids[i].currentCorner));
            pt currPt = M.g(elipsoids[i].currentCorner);
            float prevPillarRadius = M.pillarRadius[M.v(M.p(elipsoids[i].currentCorner))];
            float currentPillarRadius = M.pillarRadius[M.v(elipsoids[i].currentCorner)];
            intersections[i] = elipsoids[i].intersect(prevPt,prevPillarRadius) && 
                elipsoids[i].intersect(currPt,currentPillarRadius);
            if(!intersections[i]) {
                displaceOver++;
            }
        }
    }*/

    void horizontalDisplacement(float shrinkTo, int elipsoidsIndex) {
        float newRadius = shrinkTo/2.0f;
        int nextIndex = elipsoidsIndex+1;
        if(nextIndex == elipsoids.length) {
            nextIndex = 0;
            for(int i = 0; i < elipsoids.length; i++) {
                elipsoids[i].restoreSphere();
            }
        }
        Ellipsoid el = elipsoids[elipsoidsIndex];
        float oldVolume = elipsoids[elipsoidsIndex].getVolume();
        el.a = newRadius;
        el.b = newRadius;
        float newVolume = elipsoids[elipsoidsIndex].getVolume();
        float volumeDelta = oldVolume - newVolume;

        Ellipsoid elNext = elipsoids[nextIndex];
        float nextVolume = elipsoids[nextIndex].getVolume() + volumeDelta;
        float nextRadius = pow((3*nextVolume)/(4*PI),1.0/3.0);
        elNext.a = nextRadius;
        elNext.b = nextRadius;
        elNext.c = nextRadius;
    }

    void translateOnPath() {
        if(shouldDisplaceVertically) {
            translate();
            translateOnPathVeritcal();
        } else {
            if(resize) {
                translateOnPathHorizontal();
            } else {
                translate();
            }
            resize=!resize;
        }
    }

    void translateOnPathHorizontal() {
        for(int i = 0; i < elipsoids.length; i++) {
            pt prevPt = M.g(M.p(elipsoids[i].currentCorner));
            pt currPt = M.g(elipsoids[i].currentCorner);
            float prevPillarRadius = M.pillarRadius[M.v(M.p(elipsoids[i].currentCorner))];
            float currentPillarRadius = M.pillarRadius[M.v(elipsoids[i].currentCorner)];

            if(elipsoids[i].intersect(prevPt,prevPillarRadius) && 
               elipsoids[i].intersect(currPt,currentPillarRadius)) {
                float distance = util.distance2d(currPt,prevPt);
                float shrinkTo = distance - (prevPillarRadius+ currentPillarRadius);
                horizontalDisplacement(shrinkTo,i);
            }
        }

        /*boolean noIntersections = true;
        for(int i = 0; i < elipsoids.length; i++) {
            if(intersections[i]) {
                noIntersections = false;
                break;
            }
        }
        if(noIntersections){
            for(int i = 0; i < elipsoids.length; i++) {
                elipsoids[i].restoreSphere();
            }
        }*/
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
