class Reel {
  float x, y, w, h;
  int cnt0;
  boolean spinning=false;
  int reelFrameCnt;
  Reel(float x0, float y0, float w0, float h0) {
    x=x0;
    y=y0;
    w=w0;
    h=h0;
    cnt0 =int(random(1, 8));
    reelFrameCnt = 0;
  }
  void display() {
    stroke(0);
    fill(0);
    rect(x, y, w, h);
    if(cnt0==7){
    fill(255,0,0);
    }else{
      fill(255);
    }
    textSize(250);
    text(cnt0, x+73, y+70);
  }
  void spin() {
    if (reelFrameCnt == 10) {
      cnt0++;
      if (cnt0>7) {
        cnt0=1;
      }
      reelFrameCnt = 0;
    }
    reelFrameCnt++;
  }
  void reset() {
    cnt0 = int(random(1, 8)); // cnt0をランダムにリセット
  }
}

class ClearCnt {
  float x, y;
  Reel[] reel;
  ClearCnt(float x0, float y0, Reel[] reel0) {
    x=x0;
    y=y0;
    reel=reel0;
  }
  boolean isBingo() {
    return (reel[0].cnt0 == reel[1].cnt0 && reel[1].cnt0 == reel[2].cnt0);
  }

  void display() {
    if (isBingo()) {
      // スロットが揃った場合はスコアを増やすのは SlotGame クラスで行う
    }
    fill(#793E10);
    textSize(60);

    text("Let's align it twice  in a row!\nTheSlotAlignScore:"+BingoCnt, x, y);
  }
}

abstract class EllipseBtn extends Button {
  EllipseBtn(float x0, float y0, float sizeX0, float sizeY0, color baseCol0, String str0) {
    super(x0, y0, sizeX0, sizeY0, baseCol0, str0);
  }
    abstract void display() ;  //ボタンを表示する
    boolean checkInMouse() {
    if (dist(x, y, mouseX, mouseY)<sizeX/2) {
      return true;
    }
    return false;
  }
  
} 

class StartBtn extends EllipseBtn {
  StartBtn(float x0, float y0, float sizeX0, float sizeY0, color baseCol0, String str0) {
    super(x0, y0, sizeX0, sizeY0, baseCol0, str0);
  }

  void display() {  //ボタンを表示する
    noStroke();
    changeColor();
    ellipse(x, y, sizeX, sizeY);
    fill(255);
    textSize(40);
    text(str, x, y);
  }
}

class StopBtn extends EllipseBtn {
  boolean isClicked;
  StopBtn(float x1, float y1, float sizeX1, float sizeY1, color baseCol1, String str1) {
    super(x1, y1, sizeX1, sizeY1, baseCol1, str1);
  }
  void display() {  //ボタンを表示する
    noStroke();
    changeColor();
    ellipse(x, y, sizeX, sizeY);
    fill(255, 0, 0);
    textSize(40);
    text(str, x, y);
  }
}

class RestartBtn extends EllipseBtn {
  RestartBtn(float x2, float y2, float sizeX2, float sizeY2, color baseCol2, String str2) {
    super(x2, y2, sizeX2, sizeY2, baseCol2, str2);
  }
  void display() {  //ボタンを表示する
    noStroke();
    changeColor();
    ellipse(x, y, sizeX, sizeY);
    fill(200, 0, 200);
    textSize(35);
    text(str, x, y);
  }
}

int BingoCnt =0;
class SlotGame implements GAME {
  boolean checkedBingo = false;
  color c1=color(100,100,100), c2=color(255,0,0), c3=color(0,0,255);
  EllipseBtn startBtn;
  EllipseBtn [] stopBtn;
  EllipseBtn restartBtn;
  Reel[] reel;
  ClearCnt clearCnt;
  SlotGame() {
    setGame();
  }
  public void setGame() {
    checkedBingo = false;
    startBtn =new StartBtn(100, 300, 100, 100, c1, "start");
    stopBtn =new StopBtn[3];
    reel=new Reel[3];
    clearCnt=new ClearCnt(width/2, 100, reel);
    for (int i=0; i<stopBtn.length; i++) {
      reel[i]=new Reel(173+i*(width/4), 200, 150, 200);
      stopBtn[i] =new StopBtn (250+i*(width/4), 475, 100, 100, c2, "stop");
    }
    restartBtn =new RestartBtn(100, 400, 100, 100, c3, "restart");
  }

  public void perform() {
    background(200);
    startBtn.run();

    for (int i=0; i<stopBtn.length; i++) {
      stopBtn[i].run();
    }
    boolean allStopped = true;
    for (int i=0; i<3; i++) {
      if (frameCnt == 1 && startBtn.isPush()) {
        reel[i].spinning=true;
        checkedBingo = false;
      }
      if (frameCnt == 1 && stopBtn[i].isPush()) {
        reel[i].spinning=false;
      }
      if (reel[i].spinning) {
        reel[i].spin();
        allStopped = false;
      }

      reel[i].display();
    }
    if (allStopped &&!checkedBingo&&clearCnt.isBingo()) {
      BingoCnt++;
      checkedBingo = true;
    }
    clearCnt.display();
    restartBtn.run();
    if (restartBtn.isPush()) {
      setGame(); // ゲームのリセットを行うメソッド
      BingoCnt = 0;
    }
    judgeFinish();
  }

  public void judgeFinish() {
    if (BingoCnt==2) {
      screenNum=-3;
      setGame();
    }
  }
}
