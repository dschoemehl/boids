class Avoid {
   PVector pos;
   PVector mov;
   color col;
   
   Avoid (float xx, float yy, color clr) {
     pos = new PVector(xx,yy);
     mov = new PVector(random(-1,1),random(-1,1));
     col = clr;
   }
   
   void go () {
     pos.add(mov);
     wrap();
   }
   
   void draw () {
     fill(col); //<>//
     ellipse(pos.x, pos.y, 15, 15);
   }
   
  void wrap () {
    pos.x = (pos.x + width) % width;
    pos.y = (pos.y + height) % height;
  }
}