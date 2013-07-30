/* This sketch is the second version of gif_moire_maker produced
 by Faraz Sayed in late May 2013. This will use some of the code
 from the original but instead of a circular rotation at the centre
 this will cycle through the animation at a distance from the point
 of rotation.
 Developed on 05/06/13
 
 The animation layer can be printed on paper or card
 The top layer (slits) should be printed on a transparant film
 Using a drawing pin, or something similar, attach the two layers
 while overlapping the two small circles peircing through the centre
 of the circles.
 
 */
//press space on keyboard to rotate top layer

String folderNm = "colourFrames";
String filePrefix = "tmp-";
int gifFrames = 8;
int nGaps = 80;
float factor= 1.2;// scales image (1 doesnt seem to work)
int rGifCent = 2*height/3; // radius of the center of rotation from centre of gif
boolean curvyOn = true;

//variable to initialise
PImage topLayer;
PImage[] gif = new PImage[gifFrames]; 
int kp =0; // use to increment key presses
int shiftDown = 0; // if adjusting use one in setup
boolean doSave = false; // variable needed for saving

float sinOverlay = 0; // put here to initialise variable
void setup() {
  width= 600;
  size(width, 3*width/2);//P2D is needed for blur filter
  shiftDown = height/12;
  imageMode(CENTER);
  // smooth(4); //this doesnt seem to do much as I am using pixels
  //PImage topLayer = slitImg(12, 40);
  loadFrames(folderNm, filePrefix, gifFrames);
  noLoop();
}

void draw() {
  pushMatrix();
  fill(255);
  stroke(0);
  rect(0, -shiftDown, width, height);
  PImage[] scaledGif= autoScaler(gif); //labour intensive if preformed every draw
  PImage[] layers = layerMaker(gifFrames, nGaps, scaledGif); // labour intensive if preformed every draw
  translate(width/2, shiftDown);
  image(layers[0], 0, height/2);
  ellipse(0, 0, 5, 5);
  if (doSave == true) {
    saveFrame(folderNm+"anim"+"_"+gifFrames+"_"+nGaps+".png");
  }
  rotate(-(0.2*kp*(TWO_PI/(gifFrames*nGaps))));
  image(layers[1], 0, height/2);
  ellipse(0, 0, 5, 5);
  if (doSave == true) {
    saveFrame(folderNm+"slits"+"_"+gifFrames+"_"+nGaps+".png");
  }

  popMatrix();
  //  save("slits"+"_"+gifFrames+"_"+nGaps+".png");
  //save("anim"+"_"+gifFrames+"_"+nGaps+".png");
  doSave= false;
}

void loadFrames(String folder, String filePre, int nFrames) {
  //PImage[] gif = new PImage[nFrames];// this has been taken out to the top so it remains a universal variable
  for (int i=0; i<nFrames; i++) {
    String fileLoc = "../"+folder+"/"+filePre+i+".gif";
    // println(fileLoc);
    gif[i] = loadImage(fileLoc);
    //image(gif[i], width/2, height/2);
  }
}

void keyPressed() {
  redraw();
  if (keyCode == 32) {// 32 is space bar
    if (kp<5*gifFrames-1 ) {
      kp++;
    }
    else {
      kp=0;
    }
  }
  if (keyCode == 83) {// 83 is letter s
    doSave = true;
  }
}

//This is not autoscaling as the factor needs to be calculated by user
PImage[] autoScaler(PImage[] sourceGif) {
  PImage firstFrame = sourceGif[0];
  //the float below kept on producing what i think is rounding errors
  // println(factor);
  PImage[] export = new PImage[gifFrames];
  for (int n=0; n<gifFrames; n++) {
    image(sourceGif[n], width/2, height/2, factor*firstFrame.width, factor*firstFrame.height);
    export[n] = get();
  }
  // background(200);
  return export;
}

PImage[] layerMaker(int nFrames, int nSlits, PImage[] toSplit) {
  int slither = nFrames*nSlits;
  float repRad = TWO_PI/nSlits;
  float slitRad = TWO_PI/(slither);
  PImage img = createImage(width, height, RGB);
  PImage top = createImage(width, height, ARGB);
  img.loadPixels();
  for (int a=0; a<gifFrames; a++) {// loadPixels() in toSplit
    toSplit[a].loadPixels();
  }
  for (int i=0; i<img.pixels.length; i++) {
    int imX = i%width; //x value in gif image
    int relX = imX-width/2; //relative x value to new axis
    int imY = (i-imX)/width; // gets rid of x value then divides by width
    int relY = imY;// rotates at top edge of the new image being made
    // println(relX+" "+relY);
    float pixRad = PI+atan(relX/(relY+0.1));// adding PI to this stops it from returning a negative value
    float distC = sqrt(sq(relX)+sq(relY));
    float toOne = 2*distC/width;
    if (curvyOn == true) {
      sinOverlay = TWO_PI +2*slitRad*sin(0.5*(toOne-distC));
    }
    float allSlit = (pixRad+sinOverlay)%repRad;
    for (int b=0;b<gifFrames;b++) {//finds the frame to use for pixel
      if (slitRad*b < allSlit && allSlit < slitRad*(b+1)) {
        img.pixels[i] = toSplit[b].pixels[i];//draws gif animation layer
        boolean gifPixelExist = false;

        if (alpha(img.pixels[i]) != 0) {// choses to draw topLayer only if over gif
          gifPixelExist = true;
        } 
        else {
          gifPixelExist = false;
        }

        if (b!=0 && gifPixelExist == false) { //draws top layer
          top.pixels[i] = color(0, 0, 0, 255); //black regions
        }
        else {
          if (doSave == true) {
            //whiten, clear regions when saving
            top.pixels[i] = color(255, 255, 255, 255);
          }
          else {
            top.pixels[i] = color(0, 0, 0, 0); //clear regions
          }
        }
      }
    }
  }
  PImage[] both = new PImage[2];
  both[0] = img;
  both[1] = top;
  return both;
}

