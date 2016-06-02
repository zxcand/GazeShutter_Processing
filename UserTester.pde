import java.util.Collections;
import java.util.Random;

DESIGN[][] LatinSquare = {
  {DESIGN.LEFT, DESIGN.UP, DESIGN.DOWN, DESIGN.RIGHT},   //ABDC
  {DESIGN.UP, DESIGN.RIGHT, DESIGN.LEFT, DESIGN.DOWN},   //BCAD  
  {DESIGN.RIGHT, DESIGN.DOWN, DESIGN.UP, DESIGN.LEFT},   //CDBA
  {DESIGN.DOWN, DESIGN.LEFT, DESIGN.RIGHT, DESIGN.UP}};  //DACB
  

public class UserTester{
  int userID=-1;
  String userName = "";
  int trailNum;
  int lastTriggerTimestamp = -1;
  int lastTriggerTarget = -1;
  int lastTriggerTargetTTL = -1;
  boolean mAmbientMode = false;
  Trail currentTrail = null;
  int startTime = millis();
  int mSession = 0;

  ArrayList<Integer> trailTarget = new ArrayList<Integer>();
  
  boolean isGazing = false;
  
  public UserTester(){
    init();
  }

  void init(){
    trailNum = 0;
    lastTriggerTimestamp = -1;
    lastTriggerTarget = -1;
    lastTriggerTargetTTL = -1;
    trailTarget = new ArrayList<Integer>();
    PilotStudy.mDesign = getCounterBalancedDesign();
  
    isGazing = false;
  
    for(int r=0; r<TARGET_ROW_NUM; r++){
      for(int c=0; c<TARGET_COL_NUM; c++){
        for(int t=0; t<TRAIL_PER_TARGET; t++){ 
          trailTarget.add(r*TARGET_COL_NUM+c);
        }
      }
    }
    Collections.shuffle(trailTarget);
  }

  void switchAmbientMode(){
    mAmbientMode = !mAmbientMode;
  }
  
  void switchGazeState(){
     isGazing = !isGazing;
     
     if(isGazing){
      //starting of new trail
      currentTrail = new Trail(userID, trailNum, trailTarget.get(trailNum));
     }
     else{
      //just in case
      if(currentTrail!=null){
        currentTrail.output();
        currentTrail = null;
      }
       
       trailNum++;
       if(trailNum == TOTAL_TRAIL_NUM){
         finish();
       }
     }
  }

  void redoTrail(){
    if(isGazing){
      //starting of new trail
      currentTrail = new Trail(userID, trailNum, trailTarget.get(trailNum));
     }
     isGazing = false;
  }
  
  void finish(){
    javax.swing.JOptionPane.showMessageDialog(null, "Finished",
      "Info", javax.swing.JOptionPane.INFORMATION_MESSAGE); 
    mSession++;
    init();
  }

  DESIGN getCounterBalancedDesign(){
    if(userID==-1)
      return DESIGN.LEFT;
    else{
      println(LatinSquare[userID%4][mSession%4]);
      return LatinSquare[userID%4][mSession%4];
    }
  }
  
  //update
  void trackGazeGesture(){
    if(!isGazing){
      return;
    }

    currentTrail.update();  
    int tmpTriggerTarget = withinTarget(currentTrail);
    if(tmpTriggerTarget == -1){
      lastTriggerTargetTTL -= (millis()-lastTriggerTimestamp);
      if(lastTriggerTargetTTL<0){
        lastTriggerTarget = -1;
      }
    }
    else{
      lastTriggerTarget = tmpTriggerTarget;
      lastTriggerTargetTTL = HALO_BTN_DELAY_TIME;
    }

//    println("lastTriggerTargetTTL:"+lastTriggerTargetTTL);
    lastTriggerTimestamp = millis();
  }
  

  /*
   *  The main functions of processing 
   */
  void keyPressed(){
    if(key==' '){
      switchGazeState();
    }
    else if(key=='`'){
      switchAmbientMode();
    }
    else if(key=='r'){
      redoTrail();
    }
  }
  
  void draw(){
    background(COLOR_WHITE);
    drawWireframe();
    drawHomePosition();
    drawHaloButton();
    drawTestingInfo(mAmbientMode);
    
    //saving trail data
    trackGazeGesture();
  }
}