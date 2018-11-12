
class Edge /*implements Comparator<Edge>*/ {
    pt start, end;
    String strRep;
    public Edge(pt s, pt e) {
        this.start = s;
        this.end = e;
        this.strRep = creatStrRep(this.start, this.end);
    }
    private String creatStrRep(pt s, pt e) {
        return util.PointStringify(s) + " -> " +
                      util.PointStringify(e);
    }
    public String toString() {
        return strRep;
    }
    public boolean equals(Edge e){
        if(this == e) {
            return true;
        }
        else if(start == e.start && end == e.end) {
            return true;
        }
        else if(start.x == e.start.x && start.y == e.start.y &&
                end.x == e.end.x && end.y == e.end.y) {
            return true;
        }
        else if(start == e.end && end == e.start) {
            return true;
        }
        else if(start.x == e.end.x && start.y == e.end.y &&
                end.x == e.start.x && end.y == e.start.y) {
            return true;
        }
        return false;
    }
    public int hashCode() {
        return strRep.hashCode();
    }

    /*public int compareTo(Edge e) {
        if(this.equals(e)) {
            return 0;
        } else {
            return strRep.compareTo(e.toString());
        }
    }*/
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