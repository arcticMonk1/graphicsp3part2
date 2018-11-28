//  ******************* 2018 Project 3 basecde ***********************
Boolean 
  showFloor=true,
  showBalls=true, 
  showPillars=false,
  animating=false, 
  showEdges=true,
  showTriangles=true,
  showVoronoi=true,
  showArcs=true,
  showCorner=true,
  showOpposite=true,
  showVoronoiFaces=true,
  live=true,   // updates mesh at each frame

  step1=false,
  step2=false,
  step3=false,
  step4=false,
  step5=false,
  step6=false,
  step7=false,
  step8=false,
  step9=false,
  step10=false,
  
  PickedFocus=false, 
  center=true, 
 
  scribeText=false; // toggle for displaying of help text
  Util util = new Util();
  final int CENTROID = 0;
  final int AVGNEIGH = 1;
  final int AVGNEIGHCENTROIDS = 2;
  final int AVGWEIGHTED = 3;
  int SMOOTHTYPE = AVGWEIGHTED;
  String[] smoothNames = {"CENTROID","AVGNEIGH","AVGNEIGHCENTROIDS", "AVGWEIGHTED"};
  String smoothName = smoothNames[SMOOTHTYPE];

  float totalAnimationTime=9; // at 1 sec for 30 frames, this makes the total animation last 90 frames
  float time=0;
  boolean printOnce = false;

float 
  da = TWO_PI/32, // facet count for fans, cones, caplets
  t=0, 
  s=0,
  rb=50, // radius of the balls 
  rt=rb/2, // radius of tubes
  columnHeight = rb*0.7,
  h_floor=0, h_ceiling=600,  h=h_floor;
  
int
  f=0, 
  maxf=2*30, 
  level=4, 
  method=5,
  PTris=0,
  QTris=0,
  numberOfBorderEdges=0,
  tetCount=0;
 
 Caterpillar cat;
 boolean catShouldTranslateOnPath = true;

pts P = new pts(); // polyloop in 3D
pts Q = new pts(); // second polyloop in 3D
pts R, S, T; 
EdgeSet BP = new EdgeSet();  
MESH M = new MESH();

void setup() {
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);          
  size(900, 900, P3D); // P3D means that we will do 3D graphics
  //size(600, 600, P3D); // P3D means that we will do 3D graphics
  P.declare(); Q.declare(); // P is a polyloop in 3D: declared in pts
  //P.resetOnCircle(6,100); Q.copyFrom(P); // use this to get started if no model exists on file: move points, save to file, comment this line
  P.loadPts("data/pts");  
  Q.loadPts("data/pts2"); // loads saved models from file (comment out if they do not exist yet)
  noSmooth();
  //frameRate(30);
  sphereDetail(12);
  R=P; S=Q;
  cat = new Caterpillar(7,4);
  println(); println("_______ _______ _______ _______");
  //println("triangle area: " + util.triangleArea(new pt(0,0),new pt(1,1),new pt(0,2)));
  //println("triangle area: " + util.triangleArea(new pt(0,0),new pt(5,4),new pt(8,2)));
  }

void draw() {
  background(255);
  hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  if(showFloor) showFloor(h); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
  
  time+=1./(totalAnimationTime*frameRate);
      if (time > 1.0) {
        time = 0.0;
      }

  if(showBalls) 
      {
      fill(red); R.drawBalls(rb);
      fill(black,100); R.showPicked(rb+5); 
      }
  if(showPillars) 
      {
      fill(green); R.drawColumns(rb,columnHeight);
      fill(black,100); R.showPicked(rb+5); 
      }
    
  if(step1)
    {
      /*fill(green);
      pt c = util.circumcenter(R.G[0],R.G[1], R.G[2]);
      show(c,25);
      fill(magenta,150);
      Circ(c,util.distance2d(c,R.G[0])).showAsSphere();
      fill(blue);
      show( util.midpoint(R.G[0], R.G[1]), 25.0);
      show( util.midpoint(R.G[0], R.G[2]), 25.0);
      show( util.midpoint(R.G[1], R.G[2]), 25.0);*/
    pushMatrix(); 
    translate(0,0,4); 
    //Ellipsoid e = new Ellipsoid(R.G[0],25.0f,green,16);
    //e.draw();
    fill(cyan); stroke(yellow);

    if(live) 
      {
      M.reset(); 
      M.loadVertices(R.G,R.nv); 
      M.triangulate(); // **01 implement it in Mesh
      }
    if(showTriangles) M.showTriangles();
    noStroke();
    popMatrix();
    }
    
  if(step2)     
    {
    fill(yellow);
    if(live) {M.computeO();} // **02 implement it in Mesh
    if(showEdges) 
      {
      fill(yellow); 
      M.showNonBorderEdges(); // **02 implement it in Mesh
      fill(red); 
      M.showBorderEdges();} // **02 implement it in Mesh
    }
    
  if(step3)
    {
    M.classifyVertices();  // **03 implement it in Mesh
    showBalls=false;
    fill(green); noStroke(); 
    M.showVertices(rb+4); 
    }
    
  if(step4)
    {
    for(int i=0; i<1; i++) {
      M.smoothenInterior(); // **04 implement it in Mesh
    }
    M.writeVerticesTo(R);
    }
    
 // **05 implement corner operators in Mesh
  if(step5) 
    {
    live=false;
    fill(magenta); 
    if(showCorner) M.showCurrentCorner(20); 
    if(showOpposite) {
      pushMatrix();
      translate(0,0,10);
      stroke(blue); 
      M.showOpposites();
      popMatrix();
    }
    }
    
  if(step6)
    {
    pushMatrix(); 
    translate(0,0,6); noFill(); 
    if(showVoronoiFaces) {
      M.drawVoronoiFaceOfInteriorVertex();
    }
    stroke(blue); 
    if(showVoronoi) M.showVoronoiEdges(); // **06 implement it in Mesh
    stroke(red); 
    if(showArcs) M.showArcs(); // **06 implement it in Mesh
    noStroke();
    popMatrix();
    }

  if(step7)
    {
      showEdges = false;
      pushMatrix(); 
      translate(0,0,6); noFill(); 
      M.showPillars();
      cat.generatePathFromCorner();
      //cat.generateLongPath();
      cat.draw();
      //cat.checkVolume();
      if(catShouldTranslateOnPath) {
        cat.translateOnPath();
      }
      popMatrix();
    }
    
  if(step8)
    {
      //cat.buildAdjList();
      pushMatrix(); 
      translate(0,0,8); 
      noFill();
      M.showCats();
      //stroke(blue); 
      //cat.drawDfs();
      popMatrix();
    }
    
  if(step9)
    {
    }
    
  if(step10)
    {
    }

  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible

  int line=0;
  scribeHeader(" Project 3 for Rossignac's 2018 Graphics Course CS3451 / CS6491 by Farzon Lotfi",line++);
  scribeHeader(P.count()+" vertices, "+M.nt+" triangles ",line++);
  if(step4) {
    scribeHeader("Smoothing algorithm: "+smoothName,line++);
  }
  if(live) scribeHeader("LIVE",line++);
 
  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if(mousePressed) {stroke(cyan); strokeWeight(3); noFill(); ellipse(mouseX,mouseY,20,20); strokeWeight(1);}
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX+14,mouseY+20,26,26); fill(red); text(key,mouseX-5+14,mouseY+4+20); strokeWeight(1); }
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if(filming && (animating || change)) {print("."); saveFrame("../MOVIE FRAMES (PLEASE DO NOT SUBMIT)/F"+nf(frameCounter++,4)+".tif"); change=false;} // save next frame to make a movie
  if(filming && (animating || change)) {print("."); change=false;} // save next frame to make a movie
  //change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  //change=true;
  }
