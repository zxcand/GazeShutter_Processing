 public enum STAGE{
  STAGE_0, STAGE_1, STAGE_2, STAGE_3, STAGE_4, STAGE_5, STAGE_6;

  private static STAGE[] stages = values();
  public STAGE next(){  
    if(this.ordinal()+1 != stages.length)
      return stages[(this.ordinal()+1) % stages.length];
    else
      return this;
  }
}


public class Trail{
  static final String USER_KEY = "userID";
  static final String TRAIL_KEY = "trailID";
  static final String TARGET_KEY = "target";
  static final String PATH_KEY = "path";
  static final String DESIGN_KEY = "design";
  static final String DURATION_KEY = "duration";
  static final String MODE_KEY = "mode";

  int trailID;
  int userID;
  int target;
  int startTime;
  int duration;
  MODE mode;
  DESIGN design;
  STAGE stage;
  STAGE prevStage;
  ArrayList<Point> path;
  
  Trail(int user, int trail, int target){
    this.startTime = millis();
    this.userID = user;
    this.trailID = trail;
    this.target = target; 
    this.mode = MODE.STATIC;
    this.stage = STAGE.STAGE_0;
    this.prevStage = STAGE.STAGE_0;
    this.design = PilotStudy.mDesign;

    this.path = new ArrayList<Point>();
  }

  Trail(JSONObject trailJSON){
    this.userID = trailJSON.getInt(Trail.USER_KEY,-1);
    this.trailID = trailJSON.getInt(Trail.TRAIL_KEY,-1);;
    this.target = trailJSON.getInt(Trail.TARGET_KEY,-1);
    this.duration = trailJSON.getInt(Trail.DURATION_KEY,-1);
    this.design = DESIGN.valueOf(trailJSON.getString(Trail.DESIGN_KEY,""));
    this.mode = MODE.valueOf(trailJSON.getString(Trail.MODE_KEY,"STATIC"));
    this.path = loadPathFromJson(trailJSON);
  }


  public void update(){
    int x = (mouseX - WIREFRAME_UL_X);
    int y = (mouseY - WIREFRAME_UL_Y);
    int elapsedTime = millis() - startTime;
    updateStage();
    updateDuration(elapsedTime);
    path.add(new Point(x, y, elapsedTime, this.stage.ordinal()));
  }
  
  public void output(){
    JSONObject json = new JSONObject();
    json.setInt(USER_KEY,  userID);
    json.setInt(TRAIL_KEY, trailID);
    json.setInt(TARGET_KEY, target);
    json.setInt(DURATION_KEY, duration);
    json.setString(DESIGN_KEY, design.name());
    json.setString(MODE_KEY, mode.name());
  
    JSONArray pathJSON = new JSONArray();
    for (int i = 0; i < path.size(); i++){
      JSONObject point = new JSONObject();
      point.setInt(Point.POINT_X_KEY, path.get(i).x);
      point.setInt(Point.POINT_Y_KEY, path.get(i).y);
      point.setInt(Point.POINT_T_KEY, path.get(i).t);
      point.setInt(Point.POINT_STAGE_KEY, path.get(i).stage);
      pathJSON.setJSONObject(i, point);
    }
    json.setJSONArray(PATH_KEY, pathJSON);
    
    if(PilotStudy.mUserTester  instanceof Study1){
      String fileName = new String(userID+"/study1_"+mDesign+"_"+trailID+"_"+target+".json");
      saveJSONObject(json, outputPath+fileName);
    }else if(PilotStudy.mUserTester  instanceof Study2){
      String fileName = new String(userID+"/study2_"+mMode+"_"+trailID+"_"+target+".json");
      saveJSONObject(json, outputPath+fileName);
    }else{
      String fileName = new String(userID+"/eval_"+mEvalMode+"_"+trailID+"_"+target+".json");
      saveJSONObject(json, outputPath+fileName);
    }

  }

  void updateStage(STAGE stage){
    this.stage = stage;
  }

  void updateStage(){
    if(PilotStudy.mEvalMode == EVALUATION_MODE.DWELL_SHORT && PilotStudy.mEvalMode == EVALUATION_MODE.DWELL_LONG)
      return;

    if(stage==STAGE.STAGE_0 && isWithinTarget(this))
      stage = STAGE.STAGE_1;
    else if(stage==STAGE.STAGE_1 && !isWithinTarget(this))
      stage = STAGE.STAGE_2;
    else if(stage==STAGE.STAGE_2 && isWithinHaloButton(this))
      stage = STAGE.STAGE_3;
    else if(stage==STAGE.STAGE_3 && !isWithinHaloButton(this))
      stage=STAGE.STAGE_4;
    else if(stage==STAGE.STAGE_4 && isWithinTarget(this))
      stage=STAGE.STAGE_5;
    else if(stage==STAGE.STAGE_5 && !isWithinTarget(this))
      stage=STAGE.STAGE_6;
  }

  int getRow(){
    return target/TARGET_COL_NUM;
  }

  int getCol(){
    return target%TARGET_COL_NUM;
  }

  void updateDuration(int elapsedTime){
    if(elapsedTime > this.duration)
      duration = elapsedTime;
    return;
  }

  int getLastTimestamp(){
    return path.get(path.size()-1).t;
  }

  int getDuration(){
    return duration;
  }

  ArrayList<Point> loadPathFromJson(JSONObject trailJSON){
    ArrayList<Point> path = new ArrayList<Point>();

    JSONArray pathJSON = trailJSON.getJSONArray(Trail.PATH_KEY);
    for (int j=0; j<pathJSON.size(); j++) {
      JSONObject point = pathJSON.getJSONObject(j);
      int x = point.getInt(Point.POINT_X_KEY);
      int y = point.getInt(Point.POINT_Y_KEY);
      int t = point.getInt(Point.POINT_T_KEY);
      int s = point.getInt(Point.POINT_STAGE_KEY);
      path.add(new Point(x, y, t, s));
    }

    return path;
  }

  int calcStage2Time(){
    int startTime = -1;
    int endTime = -1;
    Point prevPoint = null;
    for(Point p:path){
      //1->2
      if(p.stage==STAGE.STAGE_2.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_1.ordinal()){
        startTime = p.t;
      }
      //2->3
      if(p.stage==STAGE.STAGE_3.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_2.ordinal()){
        endTime = p.t;
      }

      prevPoint = p;
    }

    if(startTime!=-1 && endTime!=-1)
      return (endTime-startTime);
    else
      return 0;
  }

  int calcStage4Time(){
    int startTime = -1;
    int endTime = -1;
    Point prevPoint = null;
    for(Point p:path){
      //3->4
      if(p.stage==STAGE.STAGE_4.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_3.ordinal()){
        startTime = p.t;
      }
      //4->5
      if(p.stage==STAGE.STAGE_5.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_4.ordinal()){
        endTime = p.t;
      }

      prevPoint = p;
    }

    if(startTime!=-1 && endTime!=-1)
      return (endTime-startTime);
    else
      return 0;
  }

  int calcShutterTime(){
    int startTime = -1;
    int endTime = -1;
    Point prevPoint = null;
    for(Point p:path){
      //1->2
      if(p.stage==STAGE.STAGE_2.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_1.ordinal()){
        startTime = p.t;
      }

      //4->5
      if(p.stage==STAGE.STAGE_5.ordinal() && prevPoint!=null && prevPoint.stage==STAGE.STAGE_4.ordinal()){
        endTime = prevPoint.t;
      }

      //update
      prevPoint = p;
    }

    if(startTime!=-1 && endTime!=-1)
      return (endTime-startTime);
    else
      return 0;
  }

  DISTANCE calcDistance(){
    switch (design) {
      case LEFT: 
        if(target%TARGET_COL_NUM==0)
          return PilotStudy.DISTANCE.S;
        else if(target%TARGET_COL_NUM==1)
          return PilotStudy.DISTANCE.M;
        else if(target%TARGET_COL_NUM==2)
          return PilotStudy.DISTANCE.L;
        break;

      case UP:
        if(target/TARGET_COL_NUM==0)
          return DISTANCE.S;
        else if(target/TARGET_COL_NUM==1)
          return DISTANCE.M;
        else if(target/TARGET_COL_NUM==2)
          return DISTANCE.L;
        else 
          return DISTANCE.XL;

      case RIGHT:
        if(target%TARGET_COL_NUM==0)
          return DISTANCE.L;
        else if(target%TARGET_COL_NUM==1)
          return DISTANCE.M;
        else if(target%TARGET_COL_NUM==2)
          return DISTANCE.S;
        break;

      case DOWN:
        if(target/TARGET_COL_NUM==3)
          return DISTANCE.S;
        else if(target/TARGET_COL_NUM==2)
          return DISTANCE.M;
        else if(target/TARGET_COL_NUM==1)
          return DISTANCE.L;
        else 
          return DISTANCE.XL;

      default:
       return PilotStudy.DISTANCE.ERR; 
    }
    return PilotStudy.DISTANCE.ERR;
  }
}

public class Point{
  static final String POINT_X_KEY = "x";
  static final String POINT_Y_KEY = "y";
  static final String POINT_T_KEY = "t";
  static final String POINT_STAGE_KEY = "s";

  //t for elapsed time in milles
  int t;  
  int x, y;
  int stage;
  
  Point(int x, int y, int t, int s){
    this.x = x;
    this.y = y;
    this.t = t;  
    this.stage = s;
  }
}