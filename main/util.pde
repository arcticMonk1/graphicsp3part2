class Util {
 
  String PointStringify(pt point) {
        return "{x: "+point.x + " y: "+point.y + " z: " + point.z + "} ";
  }

  pt circumcenter(pt A, pt B, pt C) {
        vec AB = new vec(A, B).normalize();
        vec AC = new vec(A, C).normalize();
        vec N = cross(AB, AC).normalize();
        vec perp = cross(N, AB).normalize();

        pt mAB = midpoint(A, B);
        pt mAC = midpoint(A, C);
        vec AMB = V(A, mAB);
        vec AMC = V(A, mAC);

        float scale = (dot(AMC,AMC) - dot(AMB, AMC))/(dot(perp, AMC));
        return mAB.addAlloc(scale, perp);
  }

  pt triCentroid(pt A, pt B, pt C) {
        return new pt((A.x+B.x+C.x)/3.,(A.y+B.y+C.y)/3.,0);
  }
 
  pt midpoint(pt A, pt B) {
        vec AB = new vec(A, B);
        float normAB = AB.norm()/2;
        vec ABNormalized = AB.normalize();
        return A.addAlloc(normAB, ABNormalized);
    }

  float normVecAB(pt A, pt B) {
        vec AB = new vec(A, B);
        return AB.norm();
  }
  float distance2d(pt p1, pt p2) {
      float dxsq = sq(p2.x-p1.x);
      float dysq = sq(p2.y-p1.y);
      return sqrt(dxsq + dysq);
  }

  void drawCurve(pt a, pt b, pt c, int resolution) {
      pt bzOld = null;
      for(float i = 0.0; i< resolution; i++) {
            pt bz = Bezier(a, b, c, i/resolution);
            if(bzOld != null) {
                  show(bzOld,bz);
            }
            bzOld = bz;
      }
  }
}