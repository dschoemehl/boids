ArrayList<Boid> boids;
ArrayList<Avoid> avoids;
ArrayList<Avoid> attracts;
ArrayList<PImage> fishImages;

float globalScale = .91;
float eraseRadius = 20;
String tool = "boids";

// boid control
float maxSpeed;
float friendRadius;
float preyRadius;
float crowdRadius;
float avoidRadius;
float coheseRadius;
float attractRadius;
float partnerRadius;

boolean option_friend = true;
boolean option_crowd = true;
boolean option_avoid = true;
boolean option_noise = true;
boolean option_cohese = true;
boolean show_gender = false;
boolean show_lines = false;
boolean movement_wrap = false;
boolean show_radius = false;
boolean predator_prey = false;



ArrayList <FishInfo> fishLibrary;


int timeToEat = 1000;

color avoid_color = color(0,255,200);
color attract_color = color(255,0,0);

PImage fishImage;

// gui crap
int messageTimer = 0;
String messageText = "";

void setup () {
  size(1024, 576);
  textSize(16);
  recalculateConstants();
  boids = new ArrayList<Boid>();
  avoids = new ArrayList<Avoid>();
  attracts = new ArrayList<Avoid>();
  fishLibrary = new ArrayList<FishInfo>();
  for (int x = 100; x < width - 100; x+= 100) {
    for (int y = 100; y < height - 100; y+= 100) {
 //   boids.add(new Boid(x + random(3), y + random(3)));
  //    boids.add(new Boid(x + random(3), y + random(3)));
    }
  
  fishImages = new ArrayList<PImage>();
  
  String path = sketchPath() + "/data";
  //println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  printArray(filenames);
  int fishCount = 0;
  /*
  for( String imageFile : filenames ) {
    println(imageFile);
    if(imageFile.endsWith(".png")){
      //fishImages.add(loadImage(imageFile));
      //FishInfo Fish = new FishInfo(loadImage(imageFile), fishCount, fishCount+1, fishCount+2);
      fishLibrary.add(new FishInfo(loadImage(imageFile), fishCount, fishCount+1, fishCount+2));
      fishCount++;
    }
    
   
   
  }*/
  
  //Load 3 fish
   fishLibrary.add(new FishInfo(loadImage("Cardinal_Tetra_Pixel.png"), 0, 1, 2));
   fishLibrary.add(new FishInfo(loadImage(filenames[1]), 1, 2, 0));
   fishLibrary.add(new FishInfo(loadImage(filenames[2]), 2, 0, 1));
  }
  
  //setupWalls();
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// haha
void recalculateConstants () {
  maxSpeed = 2.1 * globalScale;
  friendRadius = 60 * globalScale;
  preyRadius = 240 * globalScale;
  crowdRadius = (friendRadius / 1.3);
  avoidRadius = 90 * globalScale;
  coheseRadius = friendRadius;
  attractRadius = 300 * globalScale;
  partnerRadius = 400 * globalScale;
}


void setupWalls() {
  avoids = new ArrayList<Avoid>();
   for (int x = 0; x < width; x+= 20) {
    avoids.add(new Avoid(x, 10,avoid_color));
    avoids.add(new Avoid(x, height - 10,avoid_color));
  } 
}

void setupCircle() {
  avoids = new ArrayList<Avoid>();
   for (int x = 0; x < 50; x+= 1) {
     float dir = (x / 50.0) * TWO_PI;
    avoids.add(new Avoid(width * 0.5 + cos(dir) * height*.4, height * 0.5 + sin(dir)*height*.4,avoid_color));
  } 
}


void draw () {
  noStroke();
  //colorMode(HSB);
  fill(16,21,231);
  rect(0, 0, width, height);


  if (tool == "erase") {
    noFill();
    stroke(0, 100, 260);
    rect(mouseX - eraseRadius, mouseY - eraseRadius, eraseRadius * 2, eraseRadius *2);
    if (mousePressed) {
      erase();
    }
  } else if (tool == "avoids") {
    noStroke();
    fill(avoid_color);
    ellipse(mouseX, mouseY, 15, 15);
  } else if (tool == "attracts") {
    noStroke();
    fill(attract_color);
    ellipse(mouseX, mouseY, 15, 15);
  }
    
  for (int i = 0; i <boids.size(); i++) {
    Boid current = boids.get(i);
    if(!current.dead) {
      current.go();
      current.draw();
    } else {
      boids.remove(i);
    }
  }

  for (int i = 0; i <avoids.size(); i++) {
    Avoid current = avoids.get(i);
    current.go();
    current.draw();
  }
  
 for (int i = 0; i <attracts.size(); i++) {
    Avoid current = attracts.get(i);
    current.go();
    current.draw();
  }

  if (messageTimer > 0) {
    messageTimer -= 1; 
  }
  drawGUI();
}

void keyPressed () {
  if (key == 'q') {
    tool = "boids";
    message("Add boids");
  } else if (key == 'w') {
    tool = "avoids";
    message("Place obstacles");
  } else if (key == 's') {
    tool = "attracts";
    message("Place attractor");
  } else if (key == 'e') {
    tool = "erase";
    message("Eraser");
  } else if (key == '-') {
    message("Decreased scale");
    globalScale *= 0.8;
  } else if (key == '=') {
      message("Increased Scale");
    ;
  } else if (key == '1') {
     option_friend = option_friend ? false : true;
     message("Turned friend allignment " + on(option_friend));
  } else if (key == '2') {
     option_crowd = option_crowd ? false : true;
     message("Turned crowding avoidance " + on(option_crowd));
  } else if (key == '3') {
     option_avoid = option_avoid ? false : true;
     message("Turned obstacle avoidance " + on(option_avoid));
  }else if (key == '4') {
     option_cohese = option_cohese ? false : true;
     message("Turned cohesion " + on(option_cohese));
  }else if (key == '5') {
     option_noise = option_noise ? false : true;
     message("Turned noise " + on(option_noise));
  } else if (key == ',') {
     setupWalls(); 
  } else if (key == '.') {
     setupCircle(); 
  } else if(key == 'g') {
    show_gender = !show_gender;
    message("show_gender = " + show_gender);
  } else if(key == 'l') {
    show_lines = !show_lines;
    message("show_lines = " + show_lines);
  } else if(key == 'f') {
    movement_wrap = !movement_wrap;
    message("movement_wrap = " + movement_wrap);
  } else if(key == 'r') {
    show_radius = !show_radius;
    message("show_radius = " + show_radius);
  } else if(key == 'p') {
    predator_prey = !predator_prey;
    message("predator_prey = " + predator_prey);
  }
  
  recalculateConstants();

}

void drawGUI() {
   if(messageTimer > 0) {
     fill((min(30, messageTimer) / 30.0) * 255.0);

    text(messageText, 10, height - 20); 
   }
}

String s(int count) {
  return (count != 1) ? "s" : "";
}

String on(boolean in) {
  return in ? "on" : "off"; 
}

void mousePressed () {
  switch (tool) {
  case "boids":
    //boids.add(new Boid(mouseX, mouseY,fishImages.get(int(random(0,fishImages.size())))));
    FishInfo newFish = fishLibrary.get(int(random(0,fishLibrary.size())));
    boids.add(new Boid(mouseX, mouseY,newFish.file, newFish.ID, newFish.predator, newFish.prey));
    println(newFish.ID, newFish.predator, newFish.prey);
    message(boids.size() + " Total Boid" + s(boids.size()));
    break;
  case "avoids":
    avoids.add(new Avoid(mouseX, mouseY,avoid_color));
    break;
  case "attracts":
    attracts.add(new Avoid(mouseX, mouseY,attract_color));
    break;
  }
}

void erase () {
  for (int i = boids.size()-1; i > -1; i--) {
    Boid b = boids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius) {
      boids.remove(i);
    }
  }

  for (int i = avoids.size()-1; i > -1; i--) {
    Avoid b = avoids.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius) {
      avoids.remove(i);
    }
  }
  
  for (int i = attracts.size()-1; i > -1; i--) {
    Avoid b = attracts.get(i);
    if (abs(b.pos.x - mouseX) < eraseRadius && abs(b.pos.y - mouseY) < eraseRadius) {
      attracts.remove(i);
    }
  }
}

void drawText (String s, float x, float y) {
  fill(0);
  text(s, x, y);
  fill(200);
  text(s, x-1, y-1);
}


void message (String in) {
   messageText = in;
   messageTimer = (int) frameRate * 3;
}