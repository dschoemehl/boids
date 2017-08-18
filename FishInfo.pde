class FishInfo {
  
  public PImage file;
  public int ID;
  public int predator;
  public int prey;
  
  FishInfo(PImage fileName, int inID, int inPredator, int inPrey){
    file = fileName;
    ID = inID;
    predator = inPredator;
    prey = inPrey;
  }
}