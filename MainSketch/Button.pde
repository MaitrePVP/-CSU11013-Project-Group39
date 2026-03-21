class Button {
  float x, y, w, h;
  String label;
  int fontSize;

  Button(float x, float y, float w, float h, String label) {
    this(x, y, w, h, label, 18);
  }

  Button(float x, float y, float w, float h, String label, int fontSize) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.fontSize = fontSize;
  }

  void display() {
    display(false);
  }

  void display(boolean selected) {
    pushStyle();

    if (selected) {
      fill(35, 85, 150);
    } else if (isMouseOver()) {
      fill(70, 130, 200);
    } else {
      fill(50, 100, 170);
    }

    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 12);

    fill(255);
    textSize(fontSize);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);

    popStyle();
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }
}
