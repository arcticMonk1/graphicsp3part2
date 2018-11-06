float triArea(pt A, pt B, pt C) {return 0.5*det3(V(A,B),V(A,C)); }
float triThickness(pt A, pt B, pt C) {float a = abs(disToLine(A,B,C)), b = abs(disToLine(B,C,A)), c = abs(disToLine(C,A,B)); return min (a,b,c); } 
boolean ccw(pt A, pt B, pt C) {return dot(V(A,B),cross(V(A,C),V(0,0,1)))>0 ;} // CLOCKWISE
