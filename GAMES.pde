interface GAME {
  void perform();
  void setGame();
  void judgeFinish();
}

int gameCnt = 4;
GAME games[] = new GAME[gameCnt];
MenuScreen menu;
GameOverScreen gos;
ClearScreen cs;
int screenNum;
int frameCnt;  //マウスクリックを適切に管理する用

void setup() {
  size(700, 900);
  smooth();
  frameRate(60);
  textAlign(CENTER, CENTER);
  frameCnt = 0;
  screenNum = -1;

  games[0] = new BreakBlocks(10, 10);
  games[1] = new ShootingGame(1);
  games[2] = new SlotGame();
  games[3] = new GetAndAvoid();

  menu = new MenuScreen(games);
  gos = new GameOverScreen();
  cs = new ClearScreen();
}

void draw() {
  background(255);
  if (mousePressed) {
    frameCnt++;
  } else {
    frameCnt = 0;
  }
  if (screenNum >= 0) {
    games[screenNum].perform();
  } else if (screenNum == -1) {
    menu.perform();
  } else if (screenNum == -2 ) {
    gos.perform();
  } else if (screenNum == -3) {
    cs.perform();
  }
}

class MenuScreen {
  GAME games[];
  Button gameBtn[];
  float btnX = width/5;
  float btnY = height/3;
  float btnW = width*3/5;
  float btnH = 70;
  MenuScreen(GAME g0[]) {
    games = g0;
    gameBtn = new Button[games.length];
    for (int i = 0; i < gameBtn.length; i++) {
      gameBtn[i] = new Button(btnX, btnY + i*btnH*1.2, btnW, btnH, #4C96A7, "game");
    }
  }
  //ゲームの個数分のセレクトボタンを表示
  void perform() {
    drawTitle();
    for (int i = 0; i < gameBtn.length; i++) {
      gameBtn[i].run();
      if (frameCnt == 1 && gameBtn[i].isPush()) {
        screenNum = i;
      }
    }
    //これはfor文には入れられない、しかたなし
    gameBtn[0].str = "BreakBlocks";
    gameBtn[1].str = "ShootingGame";
    gameBtn[2].str = "SlotGame";
    gameBtn[3].str = "GetAndAvoid";
  }
  void drawTitle() {
    textSize(60);
    textAlign(CENTER, CENTER);
    fill(0);
    noStroke();
    text("Welcome to MiniGames!!", width/2, height/4);
  }
}

class ClearScreen {
  ClearScreen() {
  }
  void perform() {
    textSize(60);
    textAlign(CENTER, CENTER);
    fill(0);
    noStroke();
    text("Congratulations!!!", width/2, height/4);
    text("Click to return menu.", width/2, height/2);
    if (frameCnt == 1) {
      screenNum = -1;
    }
  }
}

class GameOverScreen {
  GameOverScreen() {
  }
  void perform() {
    textSize(60);
    textAlign(CENTER, CENTER);
    fill(0);
    noStroke();
    text("GameOver!!!", width/2, height/4);
    text("Click to return menu.", width/2, height/2);
    if (frameCnt == 1) {
      screenNum = -1;
    }
  }
}

//ボタンクラス
class Button {
  float x, y;
  float sizeX, sizeY;
  int state;
  color baseCol;
  float nb;
  float sb;
  float pb;
  String str;
  Button(float x, float y, float sizeX, float sizeY, color baseCol, String str) {
    this.x = x;
    this.y = y;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.baseCol = baseCol;
    this.str = str;
    nb = 1; //普段の明度
    sb = 0.8; //マウスが重なったときの明度
    pb = 0.6; //クリックしたときの明度
  }
  void run() {
    rogic();
    display();
  }
  void display() {  //ボタンを表示する
    noStroke();
    changeColor();
    rect(x, y, sizeX, sizeY);
    fill(0, 0, 100);
    textSize(60);
    text(str, x+sizeX/2, y+sizeY/2);
  }
  void rogic() {
    state=checkState();
  }
  //===================================================================
  boolean isPush() {
    if (checkState() == 2) return true;
    return false;
  }
  int checkState() {
    if (!checkInMouse()) return 0;
    if (!mousePressed) return 1;
    return 2;
  }
  boolean checkInMouse() {
    if (x < mouseX && mouseX < x + sizeX) {
      if (y < mouseY && mouseY < y + sizeY) {
        return true;
      }
    }
    return false;
  }
  void changeColor() {
    switch(state) {
    case 0:
      fill(hue(baseCol), saturation(baseCol), brightness(baseCol)*nb);
      break;
    case 1:
      fill(hue(baseCol), saturation(baseCol), brightness(baseCol)*sb);
      break;
    case 2:
      fill(hue(baseCol), saturation(baseCol), brightness(baseCol)*pb);
      break;
    default:
      fill(0, 0, 0);
      break;
    }
  }
}
