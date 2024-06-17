class ShootingGame implements GAME {
  ShootingPlayer player;
  Universe universe;
  ArrayList<Bullet> bulletList = new ArrayList<Bullet>();
  ArrayList<Obstacle> obsList = new ArrayList<Obstacle>();
  int level;
  float worldSpeed;
  int fireRate, fireFrameCnt;
  int obsRate, obsFrameCnt;

  ShootingGame(int n) {
    level = n;
    setGame();
  }
  public void perform() {
    universe.run();
    handleBullet();
    handleObstacle();
    player.display();
    player.move();
    judgeFinish();
    fireFrameCnt++;
    obsFrameCnt++;
  }
  private void handleBullet() {
    for (int i = bulletList.size()-1; i >= 0; i--) {
      if (fireFrameCnt >= fireRate) {
        bulletList.add(new Bullet(player.x, player.y, 10, 5));
        fireFrameCnt = 0;
      }
      Bullet b = bulletList.get(i);
      if (b.isAlive && b.isInside(fireFrameCnt)) {
        b.move();
        b.display();
      } else if (bulletList.size() > 1) {
        bulletList.remove(i);
      }
    }
  }
  private void handleObstacle() {
    for (int i = obsList.size()-1; i >= 0; i--) {
      if (obsFrameCnt >= obsRate) {
        obsList.add(new Meteo(random(width), -30, random(40, 60), 3, bulletList, player));
        obsFrameCnt = 0;
      }
      Obstacle o = obsList.get(i);
      if (o.isAlive && o.isInside()) {
        o.move();
        o.damage();
        o.display();
      } else {
        obsList.remove(i);
      }
    }
  }
  public void setGame() {
    worldSpeed = 3;
    fireRate = 30;
    fireFrameCnt = 0;
    obsRate = 40;
    obsFrameCnt = 0;
    player = new ShootingPlayer(mouseX, mouseY, 30, worldSpeed);
    universe = new Universe(worldSpeed);
    bulletList = new ArrayList<Bullet>();
    bulletList.add(new Bullet(player.x, player.y, 10, 5));
    obsList = new ArrayList<Obstacle>();
    obsList.add(new Meteo(random(width), -30, 40, 3, bulletList, player));
  }
  public void judgeFinish() {
    if (!player.isAlive) {
      screenNum = -2;
      setGame();
    }
  }
}
abstract class MovableShape {
  float x, y, r, dy;
  boolean isAlive = true;
  MovableShape(float x0, float y0, float r0, float dy0) {
    x = x0;
    y = y0;
    r = r0;
    dy = dy0;
  }
  void drawFire(float x, float y, float r, color c, color strokeCol) {
    color fireCol = c;
    fill(fireCol);
    stroke(strokeCol);
    ellipse(x, y, r*1.2, r* 1.2);
    //fill(fireCol);
    //arc(x, y, r*1.2, r*1.2, PI, TWO_PI);
    fill(fireCol);
    beginShape();  // 形状の描画を開始します。
    curveVertex(x-r*0.6, y);
    curveVertex(x-r*0.6, y);
    for (float i = PI+1; i < TWO_PI-1; i += PI / 25) {
      float randLength = map(abs(1.5*PI - i), 0, PI/2, r * 5, -5*r);
      float fireX = x + (r)* cos(i);
      float fireY = y - 3*r * sin(i) + random(-2.2*r, randLength);  // 炎が上向きになるよう修正します。
      curveVertex(fireX, fireY);  // 形状の頂点を追加します。
    }
    curveVertex(x+r*0.6, y);
    curveVertex(x+r*0.6, y);
    endShape(CLOSE);  // 形状の描画を終了し、最初の頂点と最後の頂点を接続します。
  }
  abstract void display();
  abstract void move();
}

class ShootingPlayer extends MovableShape {
  float s = 3;
  ShootingPlayer(float x0, float y0, float r0, float dy0) {
    super(x0, y0, r0, dy0);
  }
  void perform() {
    display();
    move();
  }
  void display() {
    if (isAlive) {
      drawFire(x, y, r*2, color(0, 255, 255, 200), color(0, 100, 255));
      drawPlayer(r*2);
    } else {
      drawPlayer(r*2);
    }
  }
  void drawPlayer(float r) {
    stroke(0);
    strokeWeight(2);
    fill(255);
    ellipse(x, y, r, r);

    stroke(0);
    strokeWeight(1);
    fill(255);
    ellipse(x, y-r/8, r/1.3, r/1.2);

    fill(#FF0AC6);
    stroke(0);
    strokeWeight(3);
    ellipse(x, y-r/5, r/1.8, r/1.8);
    drawGloss(x*1.01, y * 0.995, r);
  }
  void drawGloss(float x, float y, float r) {
    float glossSize = r /6; // 光沢の範囲を決定
    for (int i = 0; i <= glossSize; i++) {
      // グラデーションを描画
      float alpha = map(i, 0, glossSize, 10, 255);
      stroke(255, alpha);
      noFill();
      ellipse(x, y-r/5, 2*((r/8)-i), 2*((r/8)-i));
    }
  }
  void move() {
    if (isAlive) {
      x = mouseX;
      y = mouseY;
    }
  }
}

class Bullet extends MovableShape {
  Bullet(float x0, float y0, float r0, float dy0) {
    super(x0, y0, r0, dy0);
  }
  void display() {
    drawFire(x, y, r, color(#FFFFFF99), color(#FFFFFF));
    strokeWeight(1);
    stroke(255);
    fill(#F5F789);
    ellipse(x, y, r*2, r*2);
  }
  void move() {
    y -= dy;
  }
  boolean isInside(int fireFrameCnt) {
    return (y + fireFrameCnt*dy) + r > 0 && y-r*2 < height;  //わざと画面外でもちょっと生きてる
  }
}

abstract class Obstacle extends MovableShape {
  ArrayList<Bullet> bulletList;
  ShootingPlayer player;
  int hitPoint;
  Obstacle(float x0, float y0, float r0, float dy0, ArrayList<Bullet> bL0, ShootingPlayer p0) {
    super(x0, y0, r0, dy0);
    bulletList = bL0;
    player = p0;
    hitPoint = 3;
  }
  abstract void display();
  void damage() {
    for (int i =  bulletList.size()-1; i >= 0; i--) {
      Bullet b = bulletList.get(i);
      if (b.isAlive && dist(x, y, b.x, b.y) <= r + b.r) {
        b.isAlive = false;
        hitPoint--;
      }
    }
    if (hitPoint <= 0) {
      isAlive = false;
    }
    if (dist(x, y, player.x, player.y) <= r + player.r) {
      player.isAlive = false;
    }
  }
  void move() {
    y += dy;
  }
  boolean isInside() {
    return y - r*5 < height;
  }
}

class Meteo extends Obstacle {
  Meteo(float x0, float y0, float r0, float dy0, ArrayList<Bullet> bL0, ShootingPlayer p0) {
    super(x0, y0, r0, dy0, bL0, p0);
  }
  void display() {
    push();
    translate(x, y);
    rotate(PI);
    drawFire(0, 0, r*2, color(#CB2E12, 200), color(#791B0A));
    pop();
    strokeWeight(1);
    stroke(0);
    fill(#832110);
    ellipse(x, y, r*2, r*2);
  }
}

class Universe {
  private Star stars[] = new Star[50];
  Universe(float speed) {
    int slen = stars.length;
    for (int i = 0; i < slen; i++) {
      if (i < slen/2) {
        stars[i] = new Star(random(0, width), random(0, height), 3, speed * 0.1);
      } else if (i < slen * 3/4) {
        stars[i] = new Star(random(0, width), random(0, height), 5, speed * 0.3);
      } else {
        stars[i] = new Star(random(0, width), random(0, height), 6, speed * 0.4);
      }
    }
  }
  void run() {
    background(#0C0748);
    int slen = stars.length;
    for (int i = 0; i < slen; i++) {
      stars[i].display();
      stars[i].move();
    }
  }
}

class Star extends MovableShape {
  public color col;
  Star(float x0, float y0, float r0, float dy0) {
    super(x0, y0, r0, dy0);
    col = color(random(0, 255), random(0, 255), random(0, 255));
  }
  void display() {
    noStroke();
    float p = 0.1;
    for (float i = 1.0; i > 0; i -= p) {
      fill(lerpColor(col, color(col, 0), i));
      ellipse(x, y, r*2*i, r*2*i);
    }
  }
  void move() {
    y += dy;
    if (y-r > height) {
      col = color(random(0, 255), random(0, 255), random(0, 255));
      y = -r;
    }
  }
}
