class GetAndAvoid implements GAME {
  int treCnt, obsCnt, maxLife;
  int restLife, getsCnt;
  GAAPlayer player;
  Treasure Ts[];
  GAAObstacle Os[];
  GetAndAvoid() {
    treCnt = 5;
    obsCnt = 10;
    maxLife = 5;
    setGame();
  }
  public void perform() {
     player.go();
    for (int i = 0; i < treCnt; i++) {
      Ts[i].go();
    }
    for (int i = 0; i < obsCnt; i++) {
      Os[i].go();
    }
    setLife();
    setGets();
    judgeFinish();
  }
  public void setGame() {
    restLife = maxLife;
    getsCnt = treCnt;
    setBalls();
  }
  public void judgeFinish() {
    if (restLife <= 0) {
      setGame();
      screenNum = -2;
    }
    if (getsCnt == treCnt) {
      setGame();
      screenNum = -3;
    }
  }
  void setBalls() {
    float treR = 30, obsR = 30, pR = 35;
    player = new GAAPlayer(mouseX, mouseY, pR);
    Ts = new Treasure[treCnt];
    Os = new GAAObstacle[obsCnt];
    for (int i = 0; i < treCnt; i++) {
      Ts[i] = new Treasure(random(treR, width-treR), random(treR, height-treR), treR, player);
    }
    for (int i = 0; i < obsCnt; i++) {
      Os[i] = new GAAObstacle(random(obsR, width-obsR), random(obsR, height-obsR), obsR, player);
    }
  }
  void setLife() {
    restLife = maxLife;
    float x = 10, y = 10, w = (width-20)/maxLife, h = 20;
    for (int i = 0; i < obsCnt; i++) {
      if (Os[i].hit) restLife--;
    }
    for (int i = 0; i < maxLife; i++) {
      noFill();
      rect(x, y, w, h);
      x += w;
    }
    x = 10;
    for (int i = 0; i < restLife; i++) {
      fill(#00FF00, 150);
      rect(x, y, w, h);
      x += w;
    }
  }
  void setGets() {
    getsCnt = 0;
    float x = 10, y = 40, len = (width-10*(treCnt+1))/treCnt;
    if (len >= 40) len = 40;
    for (int i = 0; i < treCnt; i++) {
      fill(#1D35A7, 150);
      rect(x, y, len, len);
      x += len + 10;
      if (Ts[i].hit) getsCnt++;
    }
    x = 10;
    for (int i = 0; i < getsCnt; i++) {
      fill(#FAEE00, 200);
      int[] star5 = {1, 4, 2, 5, 3};
      drawStar(x + len/2, y + len/2, len/2, star5);
      x += len + 10;
    }
  }
  void drawStar(float x, float y, float r, int n[]) {
    //引数：基準となる円の座標, 半径, 一筆書きでたどる頂点の順番配列
    noStroke();
    beginShape();
    int N;
    for (int i = 0; i < n.length; i++) {
      N = n[i] - 1;
      float X = x + r * cos(2*PI * N / n.length + PI/2);
      float Y = y + r * sin(2*PI * N / n.length - PI/2);
      vertex(X, Y);
    }
    endShape();
    stroke(1);
  }
}

abstract class GAABall {
  float x, y, r;
  GAABall(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
  }
  abstract void move();
  abstract void display();
}

class GAAPlayer extends GAABall {
  GAAPlayer(float x, float y, float r) {
    super(x, y, r);
  }
  void go() {
    move();
    display();
  }
  void move() {
    x = mouseX;
    y = mouseY;
  }
  void display() {
    strokeWeight(2);
    fill(#DCF3F7);
    ellipse(x, y, r*2, r*2);
    fill(0);
  }
}

abstract class Target extends GAABall {
  float dx, dy;
  boolean hit = false;
  GAAPlayer player;
  Target(float x, float y, float r, GAAPlayer p0) {
    super(x, y, r);
    dx = makeR(1, 3);
    dy = makeR(1, 3);
    player = p0;
  }
  void go() {
    if (!hit) {
      hitJudge();
      move();
      display();
    }
  }
  void hitJudge() {
    if (dist(x, y, player.x, player.y) <= r + player.r) {
      hit = true;
    }
  }
  void move() {
    if (x + r > width || x - r < 0) {
      dx *= -1;
    }
    if (y + r > height || y - r < 0) {
      dy *= -1;
    }
    x += dx;
    y += dy;
  }
  float makeR(float min, float max) {
    float val = random(min, max);
    if (int(random(2)) == 0) {
      val *= -1;
    }
    return val;
  }
  void drawHeart(float x, float y, int R) { //R : ハートの大きさ調整用
    strokeWeight(2);
    stroke(200, 0, 0);
    strokeJoin(ROUND); //線のつなぎ目について設定
    pushMatrix();
    translate(x, y);
    fill(#FF0D11);
    beginShape();
    for (int theta = 0; theta < 360; theta++) {
      x = R * (16 * sin(radians(theta)) * sin(radians(theta)) * sin(radians(theta)));
      y = (-1) * R * (13 * cos(radians(theta)) - 5 * cos(radians(2 * theta)) 
        - 2 * cos(radians(3 * theta)) - cos(radians(4 * theta)));
      vertex(x, y);
    }
    endShape(CLOSE);
    popMatrix();
  }
  void drawStar(float x, float y, float r, int n[]) {
    //引数：基準となる円の座標, 半径, 一筆書きでたどる頂点の順番配列
    noStroke();
    beginShape();
    int N;
    for (int i = 0; i < n.length; i++) {
      N = n[i] - 1;
      float X = x + r * cos(2*PI * N / n.length + PI/2);
      float Y = y + r * sin(2*PI * N / n.length - PI/2);
      vertex(X, Y);
    }
    endShape();
    stroke(1);
  }
}

class Treasure extends Target {
  Treasure(float x, float y, float r, GAAPlayer p0) {
    super(x, y, r, p0);
  }
  void display() {
    //あたり判定は円だが表示は星にする
    fill(#FAEE00);
    int[] star5 = {1, 4, 2, 5, 3};
    drawStar(x, y, r, star5);
  }
}

class GAAObstacle extends Target {
  GAAObstacle(float x, float y, float r, GAAPlayer p0) {
    super(x, y, r, p0);
  }
  void display() {
    //あたり判定は円だが表示は星にする
    fill(#BF2CFF);
    int[] star7 = {1, 3, 5, 7, 2, 4, 6};
    drawStar(x, y, r, star7);
  }
}
