//===== CIRCUMCENTER & RADIUS

float circumRadius (pt A, pt B, pt C) {float a=d(B,C), b=d(C,A), c=d(A,B), s=(a+b+c)/2, d=sqrt(s*(s-a)*(s-b)*(s-c)); return a*b*c/4/d;} 

pt CircumCenter(pt A, pt B, pt C) // CircumCenter(A,B,C): center of circumscribing circle, where medians meet)
  {
  vec N = U(N(A,B,C));
  vec AB = V(A,B), AC = V(A,C); 
  vec RAB=N(N,AB), RAC=N(N,AC); 
  return P(A,1./2/dot(AB,RAC),V(-n2(RAC),RAB,n2(AB),RAC)); 
  }; 
  
// From Rasmus Fonseca: https://rasmusfonseca.github.io/implementations/apollonius.html 
class CIRCLE 
   { 
   pt Center = P();
   float radius=1; 
   // creation    
   CIRCLE () {}; 
   CIRCLE (pt C, float r) {Center=P(C); radius=r;}
   void setTo(CIRCLE C) {Center=P(C.Center); radius=C.radius;}
   void showAsSphere() {show(Center,radius);} 
   void showAsSphere(float dr) {show(Center,radius+dr);} 
   void showAsColumn(float h) {pillar(Center,h,radius);} 
   }

CIRCLE Circ(pt C, float r) {return new CIRCLE(C,r);}

CIRCLE Apollonius(CIRCLE C1, CIRCLE C2, CIRCLE C3, int s1, int s2, int s3) // si are +/- 1 (s1=+1 means C1 is outside of Apollonius circle
  {
  float x1 = C1.Center.x;
  float y1 = C1.Center.y;
  float r1 = C1.radius;
  float x2 = C2.Center.x;
  float y2 = C2.Center.y;
  float r2 = C2.radius;
  float x3 = C3.Center.x;
  float y3 = C3.Center.y;
  float r3 = C3.radius;

 
  float v11 = 2*x2 - 2*x1;
  float v12 = 2*y2 - 2*y1;
  float v13 = x1*x1 - x2*x2 + y1*y1 - y2*y2 - r1*r1 + r2*r2;
  float v14 = 2*s2*r2 - 2*s1*r1;
  
  float v21 = 2*x3 - 2*x2;
  float v22 = 2*y3 - 2*y2;
  float v23 = x2*x2 - x3*x3 + y2*y2 - y3*y3 - r2*r2 + r3*r3;
  float v24 = 2*s3*r3 - 2*s2*r2;
  
  float w12 = v12/v11;
  float w13 = v13/v11;
  float w14 = v14/v11;
  
  float w22 = v22/v21-w12;
  float w23 = v23/v21-w13;
  float w24 = v24/v21-w14;
  
  float P = -w23/w22;
  float Q = w24/w22;
  float M = -w12*P-w13;
  float N = w14 - w12*Q;
  
  float a = N*N + Q*Q - 1;
  float b = 2*M*N - 2*N*x1 + 2*P*Q - 2*Q*y1 + 2*s1*r1;
  float c = x1*x1 + M*M - 2*M*x1 + P*P + y1*y1 - 2*P*y1 - r1*r1;
  
  // Find roots of a quadratic equation
  //double[] quadSols = Polynomial.solve(new double[]{a,b,c}); float rs = (float)quadSols[0];
  float rs = (-b-sqrt(sq(b)-4.*a*c))/(2*a);
  float xs = M+N*rs;
  float ys = P+Q*rs;
  return Circ(P(xs,ys),rs);
  }
  
// Apollonius graph in CGAL: https://doc.cgal.org/latest/Apollonius_graph_2/index.html   
