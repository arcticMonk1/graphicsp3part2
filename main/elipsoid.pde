class Ellipsoid {
    pt center;
    //if circle a=b=c
    float a, b, c; 
    //c is length of normal vector
    // a and b are perpendicular vector lengths
    float r;
    int resolution;
    color cl;
    int currentCorner;
    int cornerCount =0;
    Ellipsoid(pt center, float r, color cl, int resolution) {
        this(center,r,r,r,cl, resolution);
        this.r = r;
    }
    Ellipsoid(pt center, vec a, vec b, vec c, color cl, int resolution) {
        this(center,a.norm(),b.norm(),c.norm(),cl, resolution);
    }
    Ellipsoid(pt center, float a, float b, float c, color cl, int resolution) {
        this.center = center;
        this.a = a;
        this.b = b;
        this.c = c;
        this.cl = cl;
        this.resolution = resolution;
    }
    void shrinkTo(float shrinkXY) {
        float newRadius = shrinkXY/2.0f;
        a = newRadius;
        b = newRadius;
        c = pow(r,3)/(a*b);
    }

    boolean isSphere() {
        return a == b && b == c;
    }

    float getVolume() {
        return 4.0f/3.0f * PI * (a * b * c);
    }

    boolean wasSphere() {
        return r != 0 && (r != a  || r != b || r != c);
    }
    
    void restoreSphere() {
        a = r;
        b = r;
        c = r;
    }

    boolean intersect(pt other,float otherRadius) {
        float distance = sqrt((this.center.x - other.x) * (this.center.x - other.x) +
                           (this.center.y - other.y) * (this.center.y - other.y) +
                           (this.center.z - other.z) * (this.center.z - other.z));

        return distance < (this.r + otherRadius);
    }

    pt[][] updateMesh() {
        pt[][] v = new pt[resolution+1][resolution+1];
        for (int i = 0; i <= resolution; i++) {
            float rowAng = map(i, 0, resolution, 0, PI);
            // Re-maps a number from one range to another.
            // map(value, start1, stop1, start2, stop2)
            for (int j = 0; j <= resolution; j++) {
                float colAng = map(j, 0, resolution, 0, TWO_PI);
                float x = a * sin(rowAng) * cos(colAng);
                float y = b * sin(rowAng) * sin(colAng);
                float z = c * cos(rowAng);
                v[i][j] = new pt(x,y,z);
            }
        }
        return v;
    }

    void draw() {
        pushMatrix();
        translate(center.x, center.y, center.z);
        pt[][] meshVertices = updateMesh();
        for (int i = 0; i < resolution; i++) {
            fill(cl);
            beginShape(TRIANGLE_STRIP);
            for (int j = 0; j <= resolution; j++) {
                pt v1 = meshVertices[j][i];
                pt v2 = meshVertices[j][i+1];
                vertex(v1.x, v1.y, v1.z);
                vertex(v2.x, v2.y, v2.z);
            }
            endShape();
        }
        popMatrix();
    }
}
