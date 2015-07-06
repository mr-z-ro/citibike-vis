class LinearAnimation {
  Coord initialPos;
  Coord currentPos;
  Coord finalPos;
  int numSteps;
  color shapeColor;
  String associatedText;
  
  private boolean isComplete;
  private float slope;
  private float xStepSize;
  
  LinearAnimation(Coord initialPos, Coord finalPos, int numSteps, color shapeColor) {
    this.initialPos = initialPos;
    this.currentPos = new Coord(initialPos.x, initialPos.y);
    this.finalPos = finalPos;
    this.numSteps = numSteps;
    this.slope = ((float)(finalPos.y - initialPos.y))/((float)(finalPos.x - initialPos.x));
    this.xStepSize = (finalPos.x - initialPos.x)/numSteps;
    this.shapeColor = shapeColor;
    this.isComplete = false;
    println(this.initialPos + " to " + this.finalPos);
    println("slope: " + this.slope);
  }
  
  void step()
  {
    if (this.currentPos.x < this.finalPos.x - this.xStepSize) {
      this.currentPos.x += this.xStepSize;
      //this.currentPos.y += (int)((float)this.xStepSize * this.slope);
      this.currentPos.y = (int)(this.slope * (this.currentPos.x - this.initialPos.x)) + this.initialPos.y;
      // println(currentPos); 
    } else {
      this.currentPos.x = this.finalPos.x;
      this.currentPos.y = this.finalPos.y;
      this.isComplete = true;
    }
  }
}
