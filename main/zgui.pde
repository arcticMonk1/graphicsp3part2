void keyPressed() 
    { 
    if(key=='~') filming=!filming;
    if(key=='!') snapPicture();
    if(key=='@') ; // make a .TIF picture of the canvas, better quality, but large file
    if(key=='#') exit();
    if(key=='$') ;
    if(key=='%') P.makeRandom(30,1500,10);
    if(key=='^') showCorner=!showCorner;
    if(key=='&') ; 
    if(key=='*') ;    
    if(key=='(') ;
    if(key==')') ;  
    if(key=='_') showFloor=!showFloor;
    if(key=='+') ;

    if(key=='`') ;  // hold to zoom with mouse
    if(key=='1') {step1=!step1; if(step1) {M.reset(); M.loadVertices(R.G,R.nv); M.triangulate();}}
    if(key=='2') {step2=!step2; if(step2) M.computeO();}
    if(key=='3') step3=!step3;
    if(key=='4') step4=!step4;
    if(key=='5') step5=!step5;
    if(key=='6') step6=!step6;
    if(key=='7') step7=!step7; 
    if(key=='8') step8=!step8;
    if(key=='9') step9=!step9;
    if(key=='0') step10=!step10;
    if(key=='-') ;
    if(key=='=') S.copyFrom(R);

    if(key=='a') {animating=!animating;}
    if(key=='b') {for(int i=0; i<10; i++) M.smoothenInterior(); M.writeVerticesTo(R);}
    if(key=='c') ; 
    if(key=='d') {R.set_pv_to_pp(); R.deletePicked();}  
    if(key=='e') ;
    if(key=='f') ; // hold to move focus with mouse pressed
    if(key=='g') P.loadPts("data/pts"); 
    if(key=='h') ; // hold do change column height with mouse
    if(key=='i') ; // insert additional vertex
    if(key=='j') ;
    if(key=='k') ; 
    if(key=='l') M.left();
    if(key=='m') {M.reset(); M.loadVertices(R.G,R.nv); M.triangulate(); M.computeO();}
    if(key=='n') M.next();
    if(key=='o') M.opposite();  
    if(key=='p') M.previous();
    if(key=='q') ; 
    if(key=='r') M.right(); 
    if(key=='s') M.swing();
    if(key=='t') ; 
    if(key=='u') M.unswing();
    if(key=='v') ; 
    if(key=='w') P.savePts("data/pts");   // save vertices to pts 
    if(key=='x') ; // hold to move selected vertex with mouse
    if(key=='y') ;
    if(key=='z') ; 

    if(key=='A') showArcs=!showArcs;
    if(key=='B') showBalls=!showBalls ;  
    if(key=='C') {FileName=getClipboard(); println("PicturesFileName="+FileName); pictureCounter=0;} // uses clipboard content to set file name for images 
    if(key=='D') ;  
    if(key=='E') showEdges=!showEdges;
    if(key=='F') ; // press to adjust height of focus with mouse pressed
    if(key=='G') {P.loadPts("data/"+FileName+".pts"); R=P; S=Q;} // jarek
    if(key=='H') ; 
    if(key=='I') showVoronoiFaces=!showVoronoiFaces; 
    if(key=='J') ;
    if(key=='K') ; 
    if(key=='L') live = !live;
    if(key=='M') ; 
    if(key=='N') ;
    if(key=='O') showOpposite=!showOpposite;
    if(key=='P') showPillars=!showPillars;
    if(key=='Q') ;
    if(key=='R') {R=P; S=Q;}; 
    if(key=='S') {S=P; R=Q;};
    if(key=='T') showTriangles=!showTriangles; 
    if(key=='U') ;
    if(key=='V') showVoronoi=!showVoronoi; 
    if(key=='W') P.savePts("data/"+FileName+".pts"); 
    if(key=='X') ;  // hold to move all vertices with mouse
    if(key=='Y') ;
    if(key=='Z') ;  

    if(key=='{') ;
    if(key=='}') ;
    if(key=='|') ; 
    if(key=='[') ;
    if(key==']') ; 
    if(key=='\\') ;
    if(key==':') R.perturb(100); 
    if(key=='"') ;    
    if(key==';') R.perturb(1); 
    if(key=='\'') ;    
    if(key=='<') M.left();
    if(key=='>') M.right();
    if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture 
    if(key==',') ; 
    if(key=='.') ; // change radius of columns
    if(key=='/') M.printCorner(); 
  
    if(key==' ') // SPACE : hold to rotate view with mouse
    
    if (key == CODED) 
       {
       String pressed = "Pressed coded key ";
       if (keyCode == UP) {pressed="UP";   }
       if (keyCode == DOWN) {pressed="DOWN";   };
       if (keyCode == LEFT) {pressed="LEFT";   };
       if (keyCode == RIGHT) {pressed="RIGHT";   };
       if (keyCode == ALT) {pressed="ALT";   };
       if (keyCode == CONTROL) {pressed="CONTROL";   };
       if (keyCode == SHIFT) {pressed="SHIFT";   };
       println("Pressed coded key = "+pressed); 
       } 
    println("key pressed = "+key);
    
  change=true;   // to save a frame for the movie when user pressed a key 
  }

void mouseWheel(MouseEvent event) 
  {
  dz -= event.getAmount(); 
  change=true;
  }

void mousePressed() 
  {
  //if (!keyPressed) picking=true;
  if(!keyPressed) {R.set_pv_to_pp(); println("picked vertex "+R.pp);}
  if(keyPressed && key=='i') {R.addPt(Of);}
  change=true;
  }
  
void mouseMoved() 
  {
  //if (!keyPressed) 
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='`') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  if (keyPressed) change=true;
  }
  
void mouseDragged() 
  {
  if (!keyPressed) R.setPickedTo(Of); 
//  if (!keyPressed) {Of.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {Of.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') R.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') R.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') R.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') R.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='.') {rb+=20.*(mouseX-pmouseX)/width; }
  if (keyPressed && key=='h') {columnHeight-=100.*(mouseY-pmouseY)/width; }
  if (keyPressed && key=='f')  // move focus point on plane
    {
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F')  // move focus point vertically
    {
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  change=true;
  }  

// **** Header, footer, help text on canvas
void displayHeader()  // Displays title and authors face on screen
    {
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter()  // Displays help text at the bottom
    {
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="Lattice Maker", name ="TEAM NAMES",
       menu="?:help, t/T:move view, space:rotate view, `/wheel:zoom, !:picture, ~:(start/stop) filming,  #:quit",
       guide="click&drag:pick&slide, _:flip ceiling/floor, x/X:move picked/all, m/M:perturb, X:slide All, |:snap heights, l/L:load, w/W:write"; // user's guide
