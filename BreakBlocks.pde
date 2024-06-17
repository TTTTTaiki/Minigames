class BreakBlocks implements GAME {
  Ball ball;
  Bar bar;
  Block blocks[][];
  int wCnt, hCnt;
  float bw, bh;
  BreakBlocks(int wCnt0, int hCnt0) {
    wCnt = wCnt0;
    hCnt = hCnt0;
    bw = width / wCnt;
    bh = height/2 / hCnt;
    blocks = new Block[wCnt][hCnt];
    setGame();
  }
  public void perform() {
    for (int i = 1; i < wCnt-1; i++) {
      for (int j = 1; j < hCnt-1; j++) {
        blocks[i][j].display();
        blocks[i][j].reflect();
      }
    }
    bar.display();
    bar.move();
    bar.reflect();
    ball.display();
    ball.move();
    if (frameCnt == 1) {
      setGame();
    }
    judgeFinish();
  }
  public void setGame() {
    stroke(0);
    strokeWeight(2);
    ball = new Ball(width/2, height/2, 10);
    bar = new Bar(mouseX, height*9/10, 150, 20, ball);
    for (int i = 1; i < wCnt-1; i++) {
      for (int j = 1; j < hCnt-1; j++) {
        if (int(random(5)) == 0) {
          blocks[i][j] = new UnBreakableBlock(j*bw, i*bh, bw, bh, ball);
        } else {
          blocks[i][j] = new BreakableBlock(j*bw, i*bh, bw, bh, ball);
        }
      }
    }
  }
  public void judgeFinish() {
    boolean clear = true;
    for (int i = 1; i < blocks.length-1; i++) {
      for (int j = 1; j < blocks.length-1; j++) {
        if (blocks[i][j].isAlive) {
          clear = false;
        }
      }
    }
    if (clear) {
      screenNum = -3;
    }
    if (ball.y - ball.r/2 > height) {
      screenNum = -2;
      setGame();
    }
  }
}

class Ball {
  float x, y, r, dx, dy;
  Ball (float x0, float y0, float r0) {
    x = x0;
    y = y0;
    r = r0;
    dx = random(8, 10);
    dy = random(8, 10);
    if (int(random(0, 2)) % 2 == 0) {
      dx *= -1;
    }
    if (int(random(0, 2)) % 2 == 0) {
      dy *= -1;
    }
  }
  void display() {
    fill(#FFAA3B);
    ellipse(x, y, r*2, r*2);
  }
  void move() {
    if (x-r < 0 || width < x+r) {
      dx *= -1;
    }
    if (y-r < 0) {
      dy *= -1;
    }
    x += dx;
    y += dy;
  }
}

abstract class Block {
  float x, y, w, h;
  Ball ball;
  boolean isAlive = true;
  Block (float x0, float y0, float w0, float h0, Ball b0) {
    x = x0;
    y = y0;
    w = w0;
    h = h0;
    ball = b0;
  }
  abstract void display();
  void reflect() {
    if (y < ball.y && ball.y < y+h) {
      if (x < ball.x+ball.r && ball.x-ball.r < x+w) {
        ball.dx *= -1;
        isAlive = false;
      }
    }
    if (x < ball.x && ball.x < x+w) {
      if (y < ball.y+ball.r && ball.y-ball.r < y+h) {
        ball.dy *= -1;
        isAlive = false;
      }
    }
  }
}

class Bar extends Block {
  Bar (float x0, float y0, float w0, float h0, Ball b0) {
    super(x0, y0, w0, h0, b0);
    x = x0 - w0/2;
  }
  void display() {
    strokeWeight(2);
    stroke(0);
    fill(#2DB943);
    rect(x, y, w, h);
  }
  void move() {
    x = mouseX - w/2;
    //x = ball.x - w/2;
  }
}

class BreakableBlock extends Block {
  BreakableBlock (float x0, float y0, float w0, float h0, Ball b0) {
    super(x0, y0, w0, h0, b0);
  }
  void display() {
    if (isAlive) {
      strokeWeight(2);
      stroke(0);
      fill(#7E4E2E);
      rect(x, y, w, h);
    }
  }
  void reflect() {
    if (isAlive) {
      if (y < ball.y && ball.y < y+h) {
        if (x < ball.x+ball.r && ball.x-ball.r < x+w) {
          ball.dx *= -1;
          isAlive = false;
        }
      }
      if (x < ball.x && ball.x < x+w) {
        if (y < ball.y+ball.r && ball.y-ball.r < y+h) {
          ball.dy *= -1;
          isAlive = false;
        }
      }
    }
  }
}

class UnBreakableBlock extends Block {
  UnBreakableBlock (float x0, float y0, float w0, float h0, Ball b0) {
    super(x0, y0, w0, h0, b0);
  }
  void display() {
    if (isAlive) {
      fill(#7E4E2E);
    } else {
      fill(0);
    }
    strokeWeight(2);
    stroke(0);
    rect(x, y, w, h);
  }
}
