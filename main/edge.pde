class Edge {
    pt start, end;
    public Edge(pt s, pt e) {
        this.start = s;
        this.end = e;
    }
}

class Shape {
    ArrayList<pt> pts;
    public Shape() {
        pts = new ArrayList<pt>();
    }
    public int size() {
        return pts.size();
    }
    public boolean addEdge(Edge e) {
        if(size() == 0) {
            pts.add(e.start);
            pts.add(e.end);
        } else if(pts.get(size()-1) == e.start) {
            pts.add(e.end);
        } else {
            return false;
        }
        return true;
    }

    public void addPt(pt p) {
        pts.add(p);
    }
    
    public void drawInhat() {
        for(int i = 0; i < pts.size(); i++) {
            pt prev, curr,next;
            if(i == 0){
                prev = pts.get(size()-1);
            } else {
                prev = pts.get(i-1);
            }
            curr = pts.get(i);
            next = pts.get((i+1)%size());
            drawParabolaInHat(prev,curr,next, 1);
        }
    }

    public void printPts() {
        print("[ ");
        for(int i = 0; i < pts.size(); i++) {
            print(util.PointStringify(pts.get(i)) + " , ");
        }
        print(" ]");
    }
}