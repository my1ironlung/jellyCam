/*
CONROLS:
1 2 3 4 5 6 7 8 9 0 : different color modes
m, n: toggle mirror 
mouse click: in mirror mode, toggle between vert and horiz. mirroring
i : toggle invert
arrow up, down: change stream direction
B: fill black
c, f : toggle rectangle/circle
s,d: shifter works in modes 7 8 9 and 0
e,r: adjust resolution up or down


*/ 
import processing.video.*;
//import fullscreen.*; 

//FullScreen fs; 

Capture video;

int numPixels; //the total number of pixels in the video feed
int Rows;// not used
int res;    //the number of pixels wide each stripe will be.
int startRes; //the number in the resArray[] that the res starts at. in this case we are set to default res of 20, which is Array[11],
// so the startRes will get defined as 11
int timer; //used in the keypressed method
int timer2;// will be used for color shifts
int shifter; //will be used for color shift
int shaper; //used to determine the way the stripes are loaded
int startFrame; 
int endFrame;  
int opacity;
int reflector;
 int factorCount;

boolean mirrorLine;
boolean blackFill; //used to clear the screen when switching to circle mode
boolean flow; //will be used to determine whether the frames flow up or down
boolean mirror; //will switch mirroring on and off
boolean inverter; //inverts colors 


float numStripesFloat;
int numStripes;  // the number of stripes in the video, the video height/res
int pixelGroup; //the number of pixels per stripe.

//SHAPER2:
int rad;  //the radius 
float theta; //the angle
float xPos; //x position
float yPos;
float radStepFloat;
int radStep; //the amount to increase radius for each stripe
int radEnd;//the ending radius of each stripe
int pixelPos; //used to convert the x and y coordinates to a single positional number

int[][] circleArray; //this will hold pixel positions for circle groups

 int[][] videoR;  //currently being used with colorIndexes 7-0 
 int[][] videoG; 
 int[][] videoB;
 
 int colorIndex; //will be used to mess with the RGB values
 
 int [][] allVideo;   //the array that will hold the color information for all the pixels
 int resArray [];
 
void setup() {
 size(640, 480);
  //fs = new FullScreen(this); 
  
 // enter fullscreen mode
 //fs.enter();
 smooth();
  video = new Capture(this, 640, 480,30);
  frameRate(30);   
    video.start();
  numPixels=video.width*video.height; 
  colorIndex=1;
  
  opacity=255;
  mirror=false; //turn off mirroring to start
  mirrorLine=true;
  reflector=0;
  flow=true; //set flow going down to start
  inverter=false;
  timer2=0;
  shifter=5;
  //set up array to store pixels from previous video frames, making up to as many previoius frames as the video height.

 loadPixels();
 
 /////////////
 resArray=new int[50];
 startRes=11; //set the start resolution here. 11 means 20 because it is number 12 in the factor list, so (0 -11) is the 12th.  
 //1,2,3,4,5,6,8,10,12, 15,16,20,24,30,32,40,48,60,80,96,120,160,240,480
 factorCount=0;
 //find all factors for given video height
 for (int i=1; i<=video.height;i++)
   { 
      if ((video.height)%i==0)
       {
        resArray[factorCount]=i;
        print(" "+i);
        factorCount++;
       }
      else {
      ;
      }
  }//close forloop
  println(" ");
 //println("factor count: " +factorCount+" = " +resArray.length);
 
 //this next section is repeated in initialize()
  res=resArray[startRes];
 
 numStripes=video.height/res;
 pixelGroup=video.width*res;
 println("resolution:  "+res);
 println("numStripes:  "+numStripes);
  println("pixelGroup:  "+pixelGroup);
  println("numPixels:   "+numPixels);


//set up the allVideo array. it can hold as many frames as numStripes
  allVideo = new int[numStripes][numPixels];    
  
   //these arrays are  being used to fuck with the color
  videoR = new int[numStripes][numPixels];
  videoG = new int[numStripes][numPixels];
  videoB = new int[numStripes][numPixels];
  
  numStripesFloat= float(numStripes);
  circleArray= new int[numStripes][numPixels]; //the second and third  will be the pixel coordinates
  radStepFloat= (video.height/2)/numStripesFloat;
  radStep=int(radStepFloat);
  rad=1;
  theta=0;
  shaper=1;//for now, set to 2 because we are testing circle
  blackFill=false;
  
    println("radstep:  "+radStep);
    //end of repeated section
}
//////////////HERE WE GO

void draw() {
  timer=0;
  timer2++;
  keyPressed(); //calls the keypressed function to check opacity and perhaps other things
  keyReleased(); //check for boolean flow value, to determine the flow of stripes
 

   timer=(frameCount%30);  //currently used for the opacity function.

  // println(currentRow);
  if (video.available() == true) {
    video.read();
    video.loadPixels();
   // startPixel=(video.width*currentRow);
    //println("startPixel:  "+startPixel);
  
 //load pixels
 
 if (shaper==1){
 for(int i=0; i<numStripes; i++){
   
   startFrame=i*pixelGroup;
   endFrame=startFrame+pixelGroup;
   //println("startFrame:   "+startFrame+"                     endFrame:     "+endFrame);
   
   for (int m=startFrame; m<endFrame; m++){
  
     if (flow==true){
         pixels[m]= color(allVideo[i][m]); // This line will have the frames load from top down. pixels[] is the final array that will be displayed.
       
     
   }//close if flow
      else{
        pixels[m]= color(allVideo[numStripes-1-i][m]);  //This line will instead load the frames from bottom up
      } //close else
     } //close forloop m 
   }//close for loop i
   
       storePixels(); 
       mirrorFrames();  //this method will mirror the frames 
      updatePixels(); //THIS LINE ACTUALLY DISPLAYS THE CURRENTLY LOADED PIXELS
      
  }//close if shaper=1
  
  
  if (shaper==2){
    
    if(blackFill==true){
     for (int k=0;k<numStripes;k++){
   for (int i=0; i<numPixels; i++){
   pixels[i]=color(0);
   //allVideo[k][i]=pixels[i];
   }
     }
   //updatePixels();
    blackFill=false;
    }
    
    else{
    rad=1;
      for(int i=0; i<numStripes; i++){
        radEnd=rad+radStep;//define end radius
        for (int r=rad; r<radEnd;r++){
          //for (int j=0;j<numPixels; j++){
            for (int t=0; t<720;t++){
              float tee= t;
              theta=radians(tee/2);//convert to radians
                xPos= int (r*(cos(theta)))+(video.width/2);
                yPos= int (r*(sin(theta)))+(video.height/2);
                pixelPos=int((video.width*(yPos))+xPos);
               ///* 
               
                //if(timer2%200==0){
                  
                  if (pixelPos>numPixels){
                 //println("stripe:  "+i+"   x: "+xPos+"    y: "+yPos+"     degree:  "+t+"   radius: "+r+  "    radStep:  "+radStep+ "     radEnd:  "+radEnd+"      pixelPos:  "+pixelPos+"     OUT OF BOUNDS");
                  }
                  else{
                    
                    if (flow==true){
                //println("stripe:  "+i+"   x: "+xPos+"    y: "+yPos+"     degree:  "+t+"    radius: "+r+  "    radStep:  "+radStep+ "     radEnd:  "+radEnd+"      pixelPos:  "+pixelPos);                 
                pixels[pixelPos]=color(allVideo[i][pixelPos]);
                    }//close flow true
                     else{
                     pixels[pixelPos]= color(allVideo[numStripes-1-i][pixelPos]);  //This line will instead load the frames from bottom up
                    }
             
            }//close else
               // }
                
                
               
                // pixels[pixelPos]=circleArray[i][pixelPos];
                
             }//close for t loop
          // }//close for j loop
          }//close r loop
        rad=radEnd;
      }//end for i loop  
    storePixels();
    mirrorFrames();  //this method will mirror the frames
   updatePixels(); //THIS LINE ACTUALLY DISPLAYS THE CURRENTLY LOADED PIXELS
    }//end else
   } //end if shaper = 2
   
  }//close if video available
  if (key == 'q'){
  saveFrame("render/jellycam_########");
  }
}  //close draw ///////////////////////////////////////////////////////////////////////////////////////////////////


void initialize(){
println("init:");
res=resArray[startRes];
 numStripes=video.height/res;
 pixelGroup=video.width*res;
 println("resolution:  "+res);
 println("numStripes:  "+numStripes);
  println("pixelGroup:  "+pixelGroup);
  println("numPixels:   "+numPixels);


//set up the allVideo array. it can hold as many frames as numStripes
  allVideo = new int[numStripes][numPixels];    
  
   //these arrays are  being used to fuck with the color
  videoR = new int[numStripes][numPixels];
  videoG = new int[numStripes][numPixels];
  videoB = new int[numStripes][numPixels];
  
  numStripesFloat= float(numStripes);
  circleArray= new int[numStripes][numPixels]; //the second and third  will be the pixel coordinates
  radStepFloat= (video.height/2)/numStripesFloat;
  radStep=int(radStepFloat);
  rad=1;
  theta=0;
  shaper=1;//for now, set to 2 because we are testing circle
  blackFill=false;
  
    println("radstep:  "+radStep);
}

void storePixels(){

     //store all pixels in video color arrays
     for (int k=numStripes-1; k>=0; k--){
    for (int j = 0; j < numPixels; j++){
      
      if (k!=0){
     allVideo[k][j]=allVideo[k-1][j]; //pass frames from last frame to second to last frame, from 2nd to last to 3rd to last...etc
      }//close if k!=0
      
    if (k==0){
      color currColor=video.pixels[j];
      /* // test line samples one pixel and reads color every frame
      if(j==1){
      println(currColor);}
      */
    
      int currR = (currColor >> 16) & 0xFF;  //seperate the currColor into r g b.
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      int currTemp;
      
      //to invert:
      if (inverter==true){
      currR=255-currR;
      currG=255-currG;
      currB=255-currB;
      }
       
/////////////////////////////// a long if statement to change color indexes
     if (colorIndex==1){
     ;
     }
     
     if (colorIndex==2){
     currTemp=currR;
     currR=currG;
     currG=currB;
     currB=currTemp;
    //red becomes green, green becomes blue, blue becomes red
     }
     
     if (colorIndex==3){
     currTemp=currB;
     currB=currG;
     currG=currR;
     currR=currTemp;
       if(currR>200){
          currR-=currB;
          }  
          
          if (currB>200){
          currB-=currR;
          }
          
          if (currG>140){
          currG-=currTemp;
          }
     //weird
     }
     
     
     if (colorIndex==4){
       currTemp=currR;
       currR=(currG+currB)/2;
       currG=(currTemp+currB)/2;
       currB=(currTemp+currG)/2;
       //becomes almost black and white
     }
     
       if (colorIndex==5){
       currTemp=currR;
       currR=(currG*currB/10)%255;
       currG=(currTemp*currB/10)%255;
       currB=(currTemp*currG/10)%255;
       //noisy
     }
     
      if (colorIndex==6){
       currTemp=currG;
       currG=abs(currR-currB);
       currB=abs(currR-currTemp);
       currR=abs(currTemp-currB);
       //whites turn Red
     }
     
     
     if (colorIndex==7){  
currR= videoR[k][j]+shifter;  
          if (videoR[k][j]>=255){
            shifter=-1*(shifter);
           }
           if (videoR[k][j]<=0){
           shifter=abs(shifter);
           }  
            
       
      }
      if (colorIndex==8){
      currG= videoG[k][j]+shifter;  
          if (videoG[k][j]>=255){
            shifter=-1*abs(shifter);
           }
           if (videoG[k][j]<=0){
           shifter=abs(shifter);
           }  
      }
      
       if (colorIndex==9){
      currB= videoB[k][j]+shifter;  
          if (videoB[k][j]>=255){
            shifter=-1*abs(shifter);
           }
           if (videoB[k][j]<=0){
           shifter=abs(shifter);
           }  
      }
      
       if (colorIndex==0){
     
      
          if (videoG[k][j]>=255){
            shifter=-1*abs(shifter);
           }
           if (videoG[k][j]<=0){
           shifter=abs(shifter);
           }  
            currG= videoG[k][j]+shifter;
            
          if (videoB[k][j]>=255){
            shifter=-1*abs(shifter);
           }
           if (videoB[k][j]<=0){
           shifter=abs(shifter);
           }  
           currB= videoB[k][j]+shifter; 
          
           
      }
     
     //
      videoR[k][j]=currR;
      videoG[k][j]=currG;
      videoB[k][j]=currB;
      
     
      //allVideo[k][j]= currColor;
      allVideo[k][j]= color(currR,currG,currB, opacity);
       }//close if k==0

      }//close forloop j
     
    }//close loop k  
  
}//close storePixels



void keyPressed(){
  if (keyPressed==true){
 
 if (timer<1){
  
   if (key=='i'){
   if (inverter==true){
     inverter=false;
     println("normal");
     timer++;
     }
     else if(inverter==false) {
     inverter=true;
     println("inverted");
     timer++;
     }
   }
     
      if (key=='p'){
  println("color:  "+allVideo[0][0]); 
  }  
     
      if (key=='f'){
  shaper=1;
  blackFill=false; 
  }
  if (key== 'c'){
  shaper=2;
  blackFill=true;
  }
  
     if(key=='B'){
      fillBlack();
     //rect(0,0,screen);
     }
  
  
  if (key=='='){
     if (opacity<255){
        opacity+=10;
         println("opacity:   "+opacity);
         timer++;
      }
     else{
       opacity=255;
       println("opacity:   "+opacity);
     }
    }//close if +
   
  if (key=='-'){
    if (opacity>10){
      opacity-=10;
      timer++;
       println("opacity:   "+opacity);
      }
    else{opacity=10;
    println("opacity:   "+opacity);
     }
     
   }//close if -
   
     if(key=='s'){
       if (shifter<0){
     shifter+=1;
       }
       if (shifter>=0){
       shifter-=1;
       }
     println(shifter);
     }
     
     if(key=='d'){
     if (shifter<=0){
     shifter-=1;
       }
       if (shifter>0){
       shifter+=1;
       }
     println(shifter);
     }
     
     if(key=='r')
     {
         if (startRes<(factorCount-1))
          {
           startRes ++;
          }
         else 
          {
           startRes=2; //skipping 0 and 1 there is not enough memory
          }
       timer++;
       initialize();
       
       println("new res:  " + res);
     }  
     
      if(key=='e')
     {
         if (startRes>2) //skipping 0 and 1 there is not enough memory
          {
           startRes --;
          }
         else 
          {
           startRes=factorCount-1; 
          }
       timer++;
       initialize();
       
       println("new res:  " + res);
     }  
     
 }//close if timer
  }//close if keypressed
 
}//close keyPressed


void keyReleased() {
  if (key == CODED) {
    if (keyCode == DOWN) {
      flow=true;
    } 
    if (keyCode == UP) {
      flow=false;
    }
    
     //RES keys
  }
 
 //mirror keys 
  if (key == 'm'){
     mirror=true;
   }
   if (key== 'n'){
    mirror=false;
   }
   
   ///COLOR KEYES
   if (key=='1'){
   colorIndex=1;
   }
   
   if (key=='2'){
   colorIndex=2;
   } 
      
   if (key=='3'){
   colorIndex=3;
   }  
   
   if (key=='4'){
   colorIndex=4;
   }  
   
   if (key=='5'){
   colorIndex=5;
   } 
  
  if (key=='6'){
   colorIndex=6;
   } 
 
  if (key=='7'){
   colorIndex=7;
   }   
   
   if (key=='8'){
   colorIndex=8;
   } 
   
   if (key=='9'){
   colorIndex=9;
   } 
   
   if (key=='0'){
   colorIndex=0;
   } 
}//close keyrealeased method


//mirror pixels
void mirrorFrames(){
  keyReleased();
  if (mirror==true){
    if (mirrorLine==true){
    for(int y=0;y<video.height;y++){
     for (int x=0;x<video.width;x++){
       pixels[(((video.width-1)-x)+((video.width)*y))]= pixels[(x+((video.width)*y))];
    }
   } //close mirror forloops 
  }//close if mirrorLine true
  else {
    
  for(int y=0;y<video.height;y++){
     for (int x=0;x<video.width;x++){
       pixels[((video.width)*y)+x] = pixels[((video.width)*(video.height-y))-(video.width)+x];  
    }
   } //close mirror forloops 
  
  
  }//close else
  
 }//close if mirror true
 
 
}//close mirror method

void fillBlack(){
  println("FillBlack");
  for (int k=0;k<numStripes;k++){
  for (int i=0;i<numPixels; i++){
   pixels[i]=color(0);
  allVideo[k][i]=pixels[i];
  }
  }
}

void mouseClicked() {
    if (mirrorLine==true)
      {
          mirrorLine=false;
          println("vertical");
      }
      else 
    {
    mirrorLine=true;
    println("horizontal");
    }
}

