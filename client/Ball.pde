class Ball
{
  int posx;  // position on the x axis
  int posy;  // position on the y axis
  
  int radius;  // value increases when ball "eats" an object
  int speed;   // dependends on parameter radius

  static final int min_radius = 30;  // min. value possible for the radius
  static final int max_radius = 200;

  Ball(int posx, int posy) {
    this.posx = posx;
    this.posy = posy;
    this.radius = min_radius;
    this.speed = 5;
  }
  
  // getters for ball
  int getX() { return this.posx; }
  int getY() { return this.posy; }
  int getRadius() { return this.radius; }
  
  // setters for ball
  void setX(int posx) { this.posx = posx; }
  void setY(int posy) { this.posy = posy; }
  void setRadius(int radius) { this.radius = radius; }
  
  
  // moves player on the x axis
  void moveX(int x) {
    this.posx = this.posx + x * this.speed;
    this.posx = constrain(this.posx, this.radius / 2, width - (this.radius / 2));
  }
  
  // moves player on the y axis
  void moveY(int y) {
    this.posy = this.posy + y * this.speed;
    this.posy = constrain(this.posy, this.radius / 2, height - (this.radius / 2));
  }
  
  // eats a poison consumable
  void eats_poison(Food poison) {
    if (this.radius - poison.getSize() < min_radius) { ; }
    else { this.radius -= poison.getSize(); } 
  }
  
  // eats an edible consumable
  void eats_food(Food consumable) {
    if (this.radius + consumable.getSize() > max_radius) { ; }
    else { this.radius += consumable.getSize(); }

    // to do: change speed // 
    //this.speed = 10;
  }
  
  // prints object to screen
  void display() {
    stroke(0, 0, 255);
    fill(0, 0, 0);
    ellipse(this.posx, this.posy, this.radius, this.radius);
  }
}