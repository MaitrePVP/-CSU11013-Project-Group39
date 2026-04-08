class RangeSlider {
  float x;
  float y;
  float width;
  float height = 72;
  float trackInset = 48;
  float trackHeight = 6;
  float handleRadius = 11;

  int minIndex = 0;
  int maxIndex = 0;
  int startIndex = 0;
  int endIndex = 0;
  int activeHandle = -1;

  RangeSlider(float x, float y, float width) {
    this.x = x;
    this.y = y;
    this.width = width;
  }

  void setBounds(int minIndex, int maxIndex) {
    this.minIndex = minIndex;
    this.maxIndex = max(maxIndex, minIndex);
    setValues(startIndex, endIndex);
  }

  void setValues(int startIndex, int endIndex) {
    this.startIndex = constrain(startIndex, minIndex, maxIndex);
    this.endIndex = constrain(endIndex, minIndex, maxIndex);

    if (this.startIndex > this.endIndex) {
      int temp = this.startIndex;
      this.startIndex = this.endIndex;
      this.endIndex = temp;
    }
  }

  int getStartIndex() {
    return startIndex;
  }

  int getEndIndex() {
    return endIndex;
  }

  void draw(String title, String rangeLabel, String startLabel, String endLabel, boolean enabled) {
    pushStyle();
    fill(255);
    stroke(210);
    strokeWeight(1.5);
    rect(x, y, width, height, 18);

    fill(40);
    textAlign(LEFT, TOP);
    textSize(15);
    text(title, x + 16, y + 10);

    if (!enabled) {
      fill(120);
      textSize(13);
      text("No range available", x + 16, y + 40);
      popStyle();
      return;
    }

    fill(70);
    textAlign(RIGHT, TOP);
    textSize(13);
    text(rangeLabel, x + width - 16, y + 11);

    float trackStart = getTrackStart();
    float trackEnd = getTrackEnd();
    float trackY = getTrackY();
    float startHandleX = getHandleX(startIndex);
    float endHandleX = getHandleX(endIndex);

    noStroke();
    fill(226);
    rect(trackStart, trackY - trackHeight / 2.0, trackEnd - trackStart, trackHeight, 6);

    fill(50, 100, 170);
    rect(startHandleX, trackY - trackHeight / 2.0, max(2, endHandleX - startHandleX), trackHeight, 6);

    drawHandle(startHandleX, trackY, activeHandle == 0);
    drawHandle(endHandleX, trackY, activeHandle == 1);

    fill(90);
    textSize(12);
    textAlign(LEFT, TOP);
    text(startLabel, trackStart, y + height - 18);
    textAlign(RIGHT, TOP);
    text(endLabel, trackEnd, y + height - 18);
    popStyle();
  }

  boolean handlePressed(int mx, int my) {
    if (maxIndex <= minIndex) return false;

    int pressedHandle = getHandleAt(mx, my);
    if (pressedHandle != -1) {
      activeHandle = pressedHandle;
      return true;
    }

    if (isTrackHit(mx, my)) {
      activeHandle = getNearestHandle(mx);
      return updateFromMouse(mx);
    }

    return false;
  }

  boolean handleDragged(int mx) {
    if (activeHandle == -1 || maxIndex <= minIndex) return false;
    return updateFromMouse(mx);
  }

  void handleReleased() {
    activeHandle = -1;
  }

  float getTrackStart() {
    return x + trackInset;
  }

  float getTrackEnd() {
    return x + width - trackInset;
  }

  float getTrackY() {
    return y + 40;
  }

  float getHandleX(int index) {
    if (maxIndex <= minIndex) {
      return (getTrackStart() + getTrackEnd()) / 2.0;
    }
    return map(index, minIndex, maxIndex, getTrackStart(), getTrackEnd());
  }

  void drawHandle(float cx, float cy, boolean active) {
    stroke(active ? color(26, 62, 110) : color(255));
    strokeWeight(active ? 3 : 2);
    fill(active ? color(80, 170, 255) : color(50, 100, 170));
    ellipse(cx, cy, handleRadius * 2.0, handleRadius * 2.0);
  }

  int getHandleAt(int mx, int my) {
    float startX = getHandleX(startIndex);
    float endX = getHandleX(endIndex);
    float trackY = getTrackY();
    float hitRadius = handleRadius + 4;

    boolean onStart = dist(mx, my, startX, trackY) <= hitRadius;
    boolean onEnd = dist(mx, my, endX, trackY) <= hitRadius;

    if (onStart && onEnd) {
      return 1;
    }
    if (onEnd) {
      return 1;
    }
    if (onStart) {
      return 0;
    }
    return -1;
  }

  boolean isTrackHit(int mx, int my) {
    return mx >= getTrackStart() - 4 && mx <= getTrackEnd() + 4 &&
           my >= getTrackY() - 16 && my <= getTrackY() + 16;
  }

  int getNearestHandle(int mx) {
    return abs(mx - getHandleX(endIndex)) <= abs(mx - getHandleX(startIndex)) ? 1 : 0;
  }

  boolean updateFromMouse(int mx) {
    int oldStart = startIndex;
    int oldEnd = endIndex;
    int nextIndex = getIndexFromMouse(mx);

    if (activeHandle == 0) {
      startIndex = min(nextIndex, endIndex);
    } else if (activeHandle == 1) {
      endIndex = max(nextIndex, startIndex);
    }

    return oldStart != startIndex || oldEnd != endIndex;
  }

  int getIndexFromMouse(int mx) {
    if (maxIndex <= minIndex) return minIndex;

    float constrainedX = constrain(mx, getTrackStart(), getTrackEnd());
    return round(map(constrainedX, getTrackStart(), getTrackEnd(), minIndex, maxIndex));
  }
}
