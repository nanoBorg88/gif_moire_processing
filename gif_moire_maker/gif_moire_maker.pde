/* This sketch was designed by Faraz Sayed initially on 31/05/13
 The goal of this project is to produce a way of displaying
 a black and white gif animation as a moire pattern.
 
 You can press space when the sketch loads to get an idea of how
the animation would look.

The gaps in the top layer are not white, the image may need to be
altered using an image editor.
 */
String folderNm = "stickMatrixReduced"; //folder where all the frames are kept
String filePrefix = "tmp-";//prefix for each file in the folder
int gifFrames = 9; // number of frames in folder/ that you would like to animate
int nGaps = 160;
PImage topLayer;
PImage[] gif = new PImage[gifFrames];
int kp =0;
boolean doOnce = false;
void setup() {
  size(1200, 1200);
  imageMode(CENTER);
  // smooth(4); //this doesnt seem to do much as I am using pixels
  //PImage topLayer = slitImg(12, 40);
  loadFrames(folderNm, filePrefix, gifFrames);
  noLoop();
}

void draw() {
  
  background(255);
  // constSlit(gifFrames, nGaps);
  PImage[] scaledGif= autoScaler(gif); //labour intensive if preformed every draw
  // image(scaledGif[kp], width/2, height/2);// to test out animation with keypresses
  PImage animIm = gifImage(gifFrames, nGaps, scaledGif); // labour intensive if preformed every draw
  image(animIm, width/2, height/2); //comment this out when saving slits(top layer)
  filter(INVERT);//turns black to white and vis versa
  topLayer = slitImg(gifFrames, nGaps);
//  doOnce = true;
  
  pushMatrix();
  translate(width/2, height/2);
  rotate(-(kp*(TWO_PI/(gifFrames*nGaps))));
  image(topLayer, 0, 0); //comment this out when saving animation frame
  popMatrix();
  // save("slits"+"_"+gifFrames+"_"+nGaps+".png"); //uncomment this when saving slits(top layer)
 //  save("anim"+"_"+gifFrames+"_"+nGaps+".png"); // uncomment this when saving animation frame
}

void constSlit(int nFrames, int spokes) {
  // this makes the filter layer to go on top of the layer frames are kept
  int slither = nFrames*spokes;
  float slitherRad = TWO_PI/(slither);
  pushMatrix();
  translate(width/2, height/2);
  for (int i=0; i<slither; i++) {
    rotate(slitherRad);
    if (i%nFrames>0) {
      fill(0);
      triangle(0, 0, 0, height, height*slitherRad, height);
    }
  }
  popMatrix();
}

//make a similar function to that above but one that returns an image

PImage slitImg(int nFrames, int nSlits) {
  int slither = nFrames*nSlits;
  float repRad = TWO_PI/nSlits;
  float slitRad = TWO_PI/(slither);
  int imSize = int(sqrt(sq(width)+sq(height)));
  int midIm = int(imSize/2);
  PImage img = createImage(imSize, imSize, ARGB);
  img.loadPixels();

  for (int i=0; i<img.pixels.length; i++) {
    int imX = i%imSize;
    int relX = imX-midIm;
    int imY = (i-imX)/imSize;
    int relY = imY - midIm;
    // println(relX+" "+relY);
    float pixRad = PI+atan(relX/(relY+0.0000001));// adding PI to this stops it from returning a negative value
    
    float distC = sqrt(sq(relX)+sq(relY));
    float toOne = 2*distC/width; //a number that should reach 1 at edge
    float sinOverlay = TWO_PI +2*slitRad*(toOne)*sin(0.5*(toOne-distC));
    float curvySlit = (pixRad+sinOverlay)%repRad;
    
    float oneSeg = pixRad%repRad;
    if (curvySlit<slitRad) { //originally oneSeg
      img.pixels[i] = color(0, 0, 0, 0);
    } 
    else {
      img.pixels[i] = color(0, 0, 0, 255);
    }
  }
  return img;
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
  if (kp<gifFrames-1 ) {
    kp++;
  }
  else {
    kp=0;
  }
}

PImage[] autoScaler(PImage[] sourceGif) {
  PImage firstFrame = sourceGif[0];
  //the float below kept on producing what i think is rounding errors
  float factor= width*1.222;// (width*height)/firstFrame.height ;
  // println(factor);
  PImage[] export = new PImage[gifFrames];
  for (int n=0; n<gifFrames; n++) {
    image(sourceGif[n], width/2, height/2, factor, height);
    export[n] = get();
  }
  background(200);
  return export;
}

//modify this one to draw with gif layers.
PImage gifImage(int nFrames, int nSlits, PImage[] toSplit) {
  int slither = nFrames*nSlits;
  float repRad = TWO_PI/nSlits;
  float slitRad = TWO_PI/(slither);
  PImage img = createImage(width, height, RGB);
  img.loadPixels();
  for (int a=0; a<gifFrames; a++) {// loadPixels() in toSplit
    toSplit[a].loadPixels();
  }
  for (int i=0; i<img.pixels.length; i++) {
    int imX = i%width;
    int relX = imX-width/2; 
    int imY = (i-imX)/height;
    int relY = imY - height/2;
    // println(relX+" "+relY);
    float pixRad = PI+atan(relX/(relY+0.0000001));// adding PI to this stops it from returning a negative value
    float distC = sqrt(sq(relX)+sq(relY));
    float toOne = 2*distC/width;
    float sinOverlay = TWO_PI +2*slitRad*(toOne)*sin(0.5*(toOne-distC));
    float curvySlit = (pixRad+sinOverlay)%repRad;
    float oneSeg = pixRad%repRad;
    for (int b=0;b<gifFrames;b++) {
      if (slitRad*b < curvySlit && curvySlit < slitRad*(b+1)) {
        img.pixels[i] = toSplit[b].pixels[i];
      }
    }
  }
  return img;
}

