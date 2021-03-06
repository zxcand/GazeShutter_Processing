static int TARGET_ROW_NUM = 4;
static int TARGET_COL_NUM = 3;
static int TRAIL_PER_TARGET = 3;
static int TOTAL_TRAIL_NUM = TARGET_ROW_NUM * TARGET_COL_NUM * TRAIL_PER_TARGET;


final String outputPath = new String("data/");

//GUI const
final color COLOR_WHITE = color(255,255,255);
final color COLOR_BLACK = color(0,0,0);
final color COLOR_RED = color(255,0,0);
final color COLOR_GREEN = color(0,255,0);
final color COLOR_BLUE = color(0,0,255);
final color COLOR_LIGHTBLUE = color(30,177,237);
final color COLOR_HALOBTN_BEFORE = color(255,48,48);
final color COLOR_HALOBTN_AFTER  = color(173,255,47);


final int STROKE_WEIGHT = 2;
final int SCREEN_WIDTH = 1920;//deal with width/height init. problem
final int SCREEN_HEIGHT = 1080;
static final int WIREFRAME_WIDTH  = 660;
static final int WIREFRAME_HEIGHT = 896;
final int WIREFRAME_RADIUS = 18;
final int WIREFRAME_UL_X = (SCREEN_WIDTH - WIREFRAME_WIDTH)/2;
final int WIREFRAME_UL_Y = (SCREEN_HEIGHT - WIREFRAME_HEIGHT)/2;

final int HOMEPOSITION_WIDTH  = 60;
final int HOMEPOSITION_HEIGHT = 36;
final int HOMEPOSITION_MARGIN = 10;

final int INFO_MARGIN_X = 200;

static int targetWidth = WIREFRAME_WIDTH / TARGET_COL_NUM;
static int targetHeight = WIREFRAME_HEIGHT / TARGET_ROW_NUM;
final int CROSS_SIZE = 16;

static int HALO_BTN_RADIUS = targetHeight/2;//72;
static int HALO_BTN_DIAMETER = HALO_BTN_RADIUS*2;
final int HALO_BTN_DIST_THRESHOLD = 50;
final int HALO_BTN_DELAY_TIME = 500;//ms

static float DWELL_TIME = 1000;//ms

final int DWELL_PROGRESS_SIZE = 72;
final String USER_DESIGN = "USER_DESIGN";
final String USER_NAME   = "USER_NAME";

final String[] PHONE_SYMBOL = new String[]{"1","2","3","4","5","6","7","8","9","*","0","#"};

DropdownList mModeDropdown;
Textfield mUserIdText;

void drawWireframe(){
  noFill();
  pushMatrix();
  translate(WIREFRAME_UL_X, WIREFRAME_UL_Y);
  stroke(COLOR_BLACK);
  strokeWeight(STROKE_WEIGHT);
  
  rect(0, 0, WIREFRAME_WIDTH, WIREFRAME_HEIGHT, 
    WIREFRAME_RADIUS, WIREFRAME_RADIUS, WIREFRAME_RADIUS, WIREFRAME_RADIUS);
  drawTargets();
  popMatrix();
}

int getCurrentTarget(){
  int target;
  if(mContent == CONTENT.VISUALIZING)
    target = mVisualizer.currentTarget;
  else if((mContent == CONTENT.USER_TESTING || mContent == CONTENT.USER_TESTING2 || mContent == CONTENT.EVALUATION )
         && mUserTester.isGazing)
    target = mUserTester.getCurrentTarget();
  else
    target = -1;

  return target;
}


/*
 * drawing functions
*/

void drawTargets(){
  int target=getCurrentTarget();
  textAlign(CENTER, TOP);
  textSize(64);
  
  if(PilotStudy.mContent == CONTENT.EVALUATION){
    for(int r=0; r<TARGET_ROW_NUM; r++){
      for(int c=0; c<TARGET_COL_NUM; c++){
        int index = r*TARGET_COL_NUM + c;
        text(PHONE_SYMBOL[index], (c+0.5)*targetWidth, (r+0.5)*targetHeight);
      }
    }
  }else{
    for(int r=0; r<TARGET_ROW_NUM; r++){
      for(int c=0; c<TARGET_COL_NUM; c++){
        if(r*TARGET_COL_NUM + c == target){
          strokeWeight(STROKE_WEIGHT*2);
          if(PilotStudy.mUserTester instanceof Evaluation
            && PilotStudy.mUserTester.currentTrail != null 
            && PilotStudy.mUserTester.currentTrail.stage==STAGE.STAGE_5)
            stroke(COLOR_GREEN);
          else
            stroke(COLOR_RED);
          drawCross(int((c+0.5)*targetWidth), int((r+0.5)*targetHeight));  
        }
        else{
          strokeWeight(STROKE_WEIGHT);
          stroke(COLOR_BLACK);

          if(PilotStudy.mShowingTarget == SHOWING_TARGET.ALL){
            drawCross(int((c+0.5)*targetWidth), int((r+0.5)*targetHeight));  
          }
          else if(PilotStudy.mShowingTarget == SHOWING_TARGET.EVEN && (r+c)%2==1){
            drawCross(int((c+0.5)*targetWidth), int((r+0.5)*targetHeight));  
          }

        }
      }
    }
  }
}

void drawCross(int x, int y){
  line(x-CROSS_SIZE, y, x+CROSS_SIZE, y);
  line(x, y-CROSS_SIZE, x, y+CROSS_SIZE);
}

void drawUP(int r, int c, int margin){
  arc(int((c+0.5)*targetWidth), -margin, 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            PI/6, PI*5/6, CHORD);
}

void drawUP(float r, float c, int margin){
  arc(int((c+0.5)*targetWidth), -margin, 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            PI/6, PI*5/6, CHORD);
}

void drawRIGHT(int r, int c, int margin){
      arc(WIREFRAME_WIDTH+margin, int((r+0.5)*targetHeight), 
          HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
          PI*4/6, PI*8/6, CHORD);
}

void drawRIGHT(float r, float c, int margin){
      arc(WIREFRAME_WIDTH+margin, int((r+0.5)*targetHeight), 
          HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
          PI*4/6, PI*8/6, CHORD);
}

void drawDOWN(int r, int c, int margin){
        arc(int((c+0.5)*targetWidth), WIREFRAME_HEIGHT+margin, 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            -PI*5/6, -PI*1/6, CHORD);
}

void drawDOWN(float r, float c, int margin){
        arc(int((c+0.5)*targetWidth), WIREFRAME_HEIGHT+margin, 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            -PI*5/6, -PI*1/6, CHORD);
}

void drawLEFT(int r, int c, int margin){
        arc(-margin, int((r+0.5)*targetHeight), 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            -PI*2/6, PI*2/6, CHORD); 
}

void drawLEFT(float r, float c, int margin){
        arc(-margin, int((r+0.5)*targetHeight), 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            -PI*2/6, PI*2/6, CHORD); 
}
      
void drawHaloButton(Trail trail){  
  //[TODO] using mUserTester.lastTriggerTarget
  //int r = (mouseY - WIREFRAME_UL_Y)/targetHeight;
  //int c = (mouseX - WIREFRAME_UL_X)/targetWidth;
  if(trail==null)
    return;

  if(PilotStudy.mUserTester instanceof Evaluation
    && PilotStudy.mEvalMode != EVALUATION_MODE.GAZESHUTTER)
    return;

  if(STAGE.STAGE_0.ordinal() < trail.stage.ordinal()
    && trail.stage.ordinal() < STAGE.STAGE_5.ordinal()) {
    
    float r = (float)trail.getRow();
    float c = (float)trail.getCol();
    int margin = HALO_BTN_RADIUS/2;

    if(PilotStudy.mUserTester instanceof Study2){
      r = (float(mouseY - WIREFRAME_UL_Y - targetHeight/2))/targetHeight;
      c = (float(mouseX - WIREFRAME_UL_X - targetWidth/2))/targetWidth;
    }

    pushMatrix();
    translate(WIREFRAME_UL_X, WIREFRAME_UL_Y);
    
    if(trail.stage.ordinal() < STAGE.STAGE_3.ordinal())
      fill(COLOR_HALOBTN_BEFORE);
    else
      fill(COLOR_HALOBTN_AFTER);

    switch(mDesign){
      case DOWN:
        drawDOWN(r,c,margin);
        break;
        
      case RIGHT:
        drawRIGHT(r,c,margin);
        break;
        
      case LEFT:
        drawLEFT(r,c,margin);
        break;
      
      case UP:
        drawUP(r,c,margin);
        break;
      
      case DYNAMIC_4_POINT:
        drawUP(r,c,margin);
        drawRIGHT(r,c,margin);
        drawLEFT(r,c,margin);
        drawDOWN(r,c,margin);
        break;
      
      case DYNAMIC_1_POINT:
        //RIGHT
        arc(WIREFRAME_WIDTH+margin, int((r+0.5)*targetHeight), 
            HALO_BTN_DIAMETER, HALO_BTN_DIAMETER, 
            PI*4/6, PI*8/6, CHORD);
        break;
      
      
      case STATIC:
        ellipse(3*targetWidth, 0, HALO_BTN_RADIUS, HALO_BTN_RADIUS);
        break;
    }
        
    popMatrix();
  }
}

void drawHomePosition(){
  int UL_X = width/2 - HOMEPOSITION_WIDTH/2;
  int UL_Y = height - HOMEPOSITION_HEIGHT - HOMEPOSITION_MARGIN;
  
  
  if(mContent == CONTENT.VISUALIZING || mUserTester.isGazing){
    stroke(COLOR_BLACK);
    strokeWeight(STROKE_WEIGHT);
  }
  else{
    stroke(COLOR_RED);
    strokeWeight(STROKE_WEIGHT*2);
  }
  
  
  
  rect(UL_X, UL_Y, HOMEPOSITION_WIDTH, HOMEPOSITION_HEIGHT);
}

void drawTestingInfo(boolean ambientMode){
  if(DEBUG){
    println("frameRate:"+frameRate);
  }
  
  if(ambientMode){
    noCursor();
    mModeDropdown.hide();
    mUserIdText.hide();
    float process = float(mUserTester.trailNum)/TOTAL_TRAIL_NUM;


  }else{
    cursor(HAND);
    mModeDropdown.show();
    mUserIdText.show();
  }

  textSize(32);
  textAlign(LEFT, TOP);
  fill(COLOR_BLACK);
  pushMatrix();
  translate(WIREFRAME_UL_X+WIREFRAME_WIDTH+INFO_MARGIN_X, WIREFRAME_UL_Y);
  
  text("User:"+mUserTester.userID, 10, 50);
  text("Trails:"+mUserTester.trailNum+"/"+TOTAL_TRAIL_NUM, 10, 100);
  if(!ambientMode){
    text("Design:"+PilotStudy.mDesign.name(), 10, 150);
    text("Mode:"+PilotStudy.mMode.name(),10,200);
    text("EvalMode:"+PilotStudy.mEvalMode.name(),10,250);
  }
  popMatrix();
}



void drawVisInfo(){
  textSize(32);
  textAlign(LEFT, TOP);
  fill(COLOR_BLACK);
  pushMatrix();
  translate(WIREFRAME_UL_X+WIREFRAME_WIDTH+INFO_MARGIN_X, WIREFRAME_UL_Y);
  
  text("User:"+mVisualizer.userNames[mVisualizer.currentUserId], 10, 50);
  text("DESIGN:"+PilotStudy.mDesign, 10, 100);
  text("Task:("+mVisualizer.currentTarget/TARGET_COL_NUM+","+mVisualizer.currentTarget%TARGET_COL_NUM+")", 10, 150);
   
  popMatrix();
}

void drawContentInfo(){
  textSize(32);
  textAlign(LEFT, TOP);
  fill(COLOR_BLACK);
  pushMatrix();
  translate(WIREFRAME_UL_X+WIREFRAME_WIDTH+INFO_MARGIN_X, WIREFRAME_UL_Y);

  text("Content:"+PilotStudy.mContent, 10, 0);
  
  popMatrix();
}

//drawDwellProgress(int((c+0.5)*targetWidth), int((r+0.5)*targetHeight)); 
void drawDwellProgress(int trail, float progress){
    int r = trail/TARGET_COL_NUM;
    int c = trail%TARGET_COL_NUM;
    int y = int((r+0.5)*targetHeight);
    int x = int((c+0.5)*targetWidth);

    noFill();
    strokeWeight(5);
    stroke(COLOR_RED);
    
    pushMatrix();
    translate(WIREFRAME_UL_X, WIREFRAME_UL_Y);
    arc(x, y, DWELL_PROGRESS_SIZE, DWELL_PROGRESS_SIZE, -PI/2, -PI/2+2*PI*progress);
    strokeWeight(1);   
    popMatrix();
}

void setupPanel(){

  mModeDropdown = PilotStudy.mCP5.addDropdownList(USER_DESIGN)
                    .setPosition(100, 100)
                    .setSize(100,100);
  customize(mModeDropdown);   

  mUserIdText = PilotStudy.mCP5.addTextfield(USER_NAME)
                    .setPosition(100, 200)
                    .setSize(100, 20)
                    .setFocus(true);
}

void customize(DropdownList dl) {
  // a convenience function to customize a DropdownList
  dl.setBackgroundColor(color(190));
  dl.setItemHeight(30);
  dl.setBarHeight(30);
  for (DESIGN d:DESIGN.values()) {
    dl.addItem(d.name(), ""+d.ordinal());
  }
  //ddl.scroll(0);
  dl.setColorBackground(color(0,0,0));
  dl.setColorActive(color(255, 128));
}

boolean isWithinHomeBtn(int x, int y){
  int UL_X = width/2 - HOMEPOSITION_WIDTH/2;
  int UL_Y = height - HOMEPOSITION_HEIGHT - HOMEPOSITION_MARGIN;
  if(x<UL_X || UL_X+HOMEPOSITION_WIDTH<x)
    return false;
  if(y<UL_Y || UL_Y+HOMEPOSITION_HEIGHT<y)
    return false;
  return true;
}

/*
 *  return val targetID, or -1 if none
 */
int withinTarget(){
  int r = (mouseY - WIREFRAME_UL_Y)/targetHeight;
  int c = (mouseX - WIREFRAME_UL_X)/targetWidth;

  if(mouseX<WIREFRAME_UL_X || mouseX>WIREFRAME_UL_X+WIREFRAME_WIDTH || mouseY<WIREFRAME_UL_Y || mouseY>WIREFRAME_UL_Y+WIREFRAME_HEIGHT)
    return -1;
     
  int dx = mouseX - WIREFRAME_UL_X - int((c+0.5)*targetWidth);
  int dy = mouseY - WIREFRAME_UL_Y - int((r+0.5)*targetHeight);
  double distance = sqrt(dx*dx + dy*dy);

  if(distance < HALO_BTN_DIST_THRESHOLD)
    return r*TARGET_COL_NUM + c;
  else
    return -1;
}

int withinTarget(Trail trail){
  int r = trail.getRow();
  int c = trail.getCol();

  if(mouseX<WIREFRAME_UL_X || mouseX>WIREFRAME_UL_X+WIREFRAME_WIDTH || mouseY<WIREFRAME_UL_Y || mouseY>WIREFRAME_UL_Y+WIREFRAME_HEIGHT)
    return -1;
     
  int dx = mouseX - WIREFRAME_UL_X - int((c+0.5)*targetWidth);
  int dy = mouseY - WIREFRAME_UL_Y - int((r+0.5)*targetHeight);
  double distance = sqrt(dx*dx + dy*dy);

  if(distance < HALO_BTN_DIST_THRESHOLD)
    return r*TARGET_COL_NUM + c;
  else
    return -1;
}

boolean isWithinTarget(){
  if(withinTarget()==-1)
    return false;
  else
    return true;
}

boolean isWithinTarget(Trail trail){
  if(withinTarget(trail)==-1)
    return false;
  else
    return true;
}

boolean isWithinHaloButton(Trail trail){
  int r = trail.getRow();
  int c = trail.getCol();

  int dx, dy;
  int mx = mouseX - WIREFRAME_UL_X;
  int my = mouseY - WIREFRAME_UL_Y;
  int margin = HALO_BTN_RADIUS/2;
  double distance;
  switch(mDesign){
    case UP:
      //UP
      dx = mx - int((c+0.5)*targetWidth);
      dy = my - (-margin);
      distance = sqrt(dx*dx + dy*dy);
      if(distance<HALO_BTN_RADIUS){//&& my>0
        return true;
      }
      break;
    
    
    case RIGHT: 
      //RIGHT
      dx = mx - (WIREFRAME_WIDTH+margin);
      dy = my - int((r+0.5)*targetHeight);
      distance = sqrt(dx*dx + dy*dy);
      if(distance<HALO_BTN_RADIUS){// && mx<WIREFRAME_WIDTH
        return true;
      }
      break;
    
    case DOWN:       
      //DOWN
      dx = mx - int((c+0.5)*targetWidth);
      dy = my - (WIREFRAME_HEIGHT+margin);
      distance = sqrt(dx*dx + dy*dy);
      if(distance<HALO_BTN_RADIUS){// && my<WIREFRAME_HEIGHT
        return true;
      }
      break;
      
    case LEFT:
      //LEFT
      dx = mx - (-margin);
      dy = my - int((r+0.5)*targetHeight);
      distance = sqrt(dx*dx + dy*dy);
      if(distance<HALO_BTN_RADIUS){// && mx>0
        return true;
      }
 
      break;  
    
    case STATIC:
      dx = mx - 3*targetWidth;
      dy = my - 0;
      distance = sqrt(dx*dx + dy*dy);
      if(distance<1.5*HALO_BTN_RADIUS)
        return true;
      break; 
  }
  return false;
}




// DropdownList is of type ControlGroup.
void controlEvent(ControlEvent event) {
  if(event.isAssignableFrom(Textfield.class)){
    Textfield t = (Textfield)event.getController();
    mUserTester.userID = int(t.getText());//[TODO] check if not int
    mUserTester.init();
  }
  else if(event.isAssignableFrom(DropdownList.class)){
    mDesign = DESIGN.values()[int(event.getController().getValue())];
    println(event.getController()+":"+event.getController().getValue());
  }
  else if (event.isGroup()) {
    println(event.getGroup()+":"+event.getGroup().getValue());
  } 
}

void noDataPopout(){
  javax.swing.JOptionPane.showMessageDialog(null, "No data",
    "Info", javax.swing.JOptionPane.INFORMATION_MESSAGE); 
  noLoop();
}

void updateDisplayDimension(UserTester userTester){
  targetWidth = WIREFRAME_WIDTH / TARGET_COL_NUM;
  targetHeight = WIREFRAME_HEIGHT / TARGET_ROW_NUM;
  TOTAL_TRAIL_NUM = userTester.trailTarget.size();

  HALO_BTN_RADIUS = targetHeight/2;//72;
  HALO_BTN_DIAMETER = HALO_BTN_RADIUS*2;
}



