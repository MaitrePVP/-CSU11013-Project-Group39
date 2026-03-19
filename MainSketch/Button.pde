class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() {
    if (isMouseOver()) {
      fill(70, 130, 200);
    } else {
      fill(50, 100, 170);
    }

    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 12);

    fill(255);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }
}
