class Boid {
  // main fields
  PVector pos;
  PVector move;
  float shade;
  ArrayList<Boid> friends;
  float fishSize;
  float maxFishSize;
  int gender;

  // timers
  int thinkTimer = 0;
  int hungerTimer = 0;
  
  boolean seek_food = false;
  boolean dead = false;
  boolean find_partner;


  Boid (float xx, float yy) {
    move = new PVector(0, 0);
    pos = new PVector(0, 0);
    pos.x = xx;
    pos.y = yy;
    thinkTimer = int(random(10));
    hungerTimer = int(random(500));
    shade = random(255);
    friends = new ArrayList<Boid>();
    fishSize = .5;
    maxFishSize = 2;
    gender = int(random(2));
    find_partner = false;
    
  }

  void go () {
    increment();
    wrap();

    if (thinkTimer ==0 ) {
      // update our friend array (lots of square roots)
      getFriends();
    }
    flock();
    pos.add(move);
  }

  void flock () {
    PVector allign = getAverageDir();
    PVector avoidDir = getAvoidDir(); 
    PVector avoidObjects = getAvoidAvoids();
    PVector noise = new PVector(random(-1,1), random(-1,1));
    PVector cohese = getCohesion();
    PVector attractObjects = getAttracts();
    PVector partner = new PVector(0,0);
    if(find_partner == true){
      message("find partner");
      partner = getPartner();
    }
    

    allign.mult(1);
    if (!option_friend || seek_food ) allign.mult(0);
    
    avoidDir.mult(1);
    if (!option_crowd) avoidDir.mult(0);
    
    avoidObjects.mult(3);
    if (!option_avoid) avoidObjects.mult(0);
    
    attractObjects.mult(3);
      
    partner.mult(5);
    
    noise.mult(0.1);
    if (!option_noise) noise.mult(0);

    cohese.mult(1);
    if (!option_cohese || seek_food ) cohese.mult(0);
    
    stroke(0, 255, 160);

    move.add(allign);
    move.add(avoidDir);
    move.add(avoidObjects);
    move.add(attractObjects);
    move.add(noise);
    move.add(cohese);
    move.add(partner);

    move.limit(maxSpeed);
    
    shade += getAverageColor() * 0.03;
    shade += (random(2) - 1) ;
    shade = (shade + 255) % 255; //max(0, min(255, shade));
    
    if(seek_food){
      shade = 100;
    }
  }

  void getFriends () {
    ArrayList<Boid> nearby = new ArrayList<Boid>();
    for (int i =0; i < boids.size(); i++) {
      Boid test = boids.get(i);
      if (test == this) continue;
      if (abs(test.pos.x - this.pos.x) < friendRadius &&
        abs(test.pos.y - this.pos.y) < friendRadius) {
        nearby.add(test);
      }
    }
    friends = nearby;
  }

  PVector getPartner() {
    PVector steer = new PVector(0, 0);
    int count = 0;
    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < partnerRadius)) {
        if( (gender != other.gender) && other.find_partner ){  
          message("I found a partner!");
          PVector diff = PVector.sub(pos, other.pos);
          diff.normalize();
          diff.div(d);        // Weight by distance
          steer.sub(diff);
          count++;            // Keep track of how many
          if(d < 5) {
            //have babies
            message("Have Babies!");
            int numberofbabies = int(random(3,9));
            for (int i = 0; i < numberofbabies; i++){
              boids.add(new Boid(pos.x,pos.y));
              dead = true;
            }  
           }
        }
      }
    }
    return steer;
  }
    

  float getAverageColor () {
    float total = 0;
    float count = 0;
    for (Boid other : friends) {
      if (other.shade - shade < -128) {
        total += other.shade + 255 - shade;
      } else if (other.shade - shade > 128) {
        total += other.shade - 255 - shade;
      } else {
        total += other.shade - shade; 
      }
      count++;
    }
    if (count == 0) return 0;
    return total / (float) count;
  }

  PVector getAverageDir () {
    PVector sum = new PVector(0, 0);
    int count = 0;

    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < friendRadius)) {
        PVector copy = other.move.copy();
        copy.normalize();
        copy.div(d); 
        sum.add(copy);
        count++;
      }
      if (count > 0) {
        //sum.div((float)count);
      }
    }
    return sum;
  }

  PVector getAvoidDir() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < crowdRadius)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    if (count > 0) {
      //steer.div((float) count);
    }
    return steer;
  }

  PVector getAvoidAvoids() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Avoid other : avoids) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < avoidRadius)) {
        // Calculate vector pointing away from avoid
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
        if( d < 20 ){
          dead = true;
        }
      }
    }
    return steer;
  }
  
  PVector getAttracts() {
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (int i = 0; i < attracts.size(); i++) {
      Avoid other = attracts.get(i);
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < attractRadius)) {
        // Calculate vector pointing towards attractor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.sub(diff);
        count++;            // Keep track of how many
        if(d < 5) {
          attracts.remove(other);
          if(fishSize < maxFishSize){
            fishSize /= 0.8;
          }
          else
          {
            find_partner = true;
          }
        }
      }
    }
    return steer;
  }
  
  PVector getCohesion () {
   float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : friends) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < coheseRadius)) {
        sum.add(other.pos); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      
      PVector desired = PVector.sub(sum, pos);  
      return desired.setMag(0.05);
    } 
    else {
      return new PVector(0, 0);
    }
  }

  void draw () {
    for ( int i = 0; i < friends.size(); i++) {
      Boid f = friends.get(i);
      stroke(90);
      //line(this.pos.x, this.pos.y, f.pos.x, f.pos.y);
    }
    noStroke();
    if (gender == 1){
      shade = 200;
      tint(132,216,251);
    }
    else {
      shade = 140;
      tint(231,151,233);
    }
    //tint(shade, 100, 200);  
    fill(shade, 100, 200);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(move.heading());
    //beginShape();
    //vertex(15 * globalScale, 0);
    //vertex(-7* globalScale, 7* globalScale);
    //vertex(-7* globalScale, -7* globalScale);
    //vertex(15 * fishSize, 0);
    //vertex(-7* fishSize, 7* fishSize);
    //vertex(-7* fishSize, -7* fishSize);
    //endShape(CLOSE);
    imageMode(CENTER);
    //tint(255, 153, 204);
    //message("Heading " + move.heading());
    if(move.x < 0)
    {
      scale(1,-1);
    }
    image(fishImage,0,0,50*fishSize, 50*fishSize);
    popMatrix();
  }

  // update all those timers!
  void increment () {
    thinkTimer = (thinkTimer + 1) % 5;
    hungerTimer = (hungerTimer + 1);
    
    if(hungerTimer >= timeToEat){
      //seek_food = !seek_food;
      shade = random(255);
      hungerTimer = int(random(500));
    }
    
  }

  void wrap () {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
  }
}