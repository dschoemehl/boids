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
     
   }
   
   void draw () {
     fill(col); //<>//
     pos.add(mov);
     pos.x = (pos.x + width) % width;
     pos.y = (pos.y + height) % height;
        
     ellipse(pos.x, pos.y, 15, 15);
   }
}