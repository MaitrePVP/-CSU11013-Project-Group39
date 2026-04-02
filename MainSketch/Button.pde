class Button {
  float x, y, w, h;
  String label;
  int fontSize;
  // Button(float x, float y, float w, float h, String label)
  // Basic button constructor.
  // Creates a button with position, size, and text label.
  // Uses the default font size of 18.
  Button(float x, float y, float w, float h, String label) {
    this(x, y, w, h, label, 18);
  }
  // Button(float x, float y, float w, float h, String label, int fontSize)
  // Full button constructor.
  // Same as the basic one, but also lets you choose the font size.
  Button(float x, float y, float w, float h, String label, int fontSize) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.fontSize = fontSize;
  }
  // display()
  // Draws the button in its normal state.
  // Internally calls display(false), meaning "not selected".
  void display() {
    display(false);
  }
  
  // display(boolean selected)
  // Draws the button with UI styling.
  // Visual behaviour:
  // - darker highlighted colour if selected
  // - lighter hover colour if the mouse is over it
  // - normal blue colour otherwise
  // Also draws the text label centered inside the button.
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
  
  // displayNav(boolean selected)
  // Draws the button as a flat navigation tab.
  // No rounded corners, no stroke — integrated into the header bar.
  // Selected tab gets a bright accent line and lifted appearance.
  // Hover shows a visible lighter background.
  void displayNav(boolean selected) {
    pushStyle();
    noStroke();

    // background fill
    if (selected) {
      fill(38, 72, 120);
    } else if (isMouseOver()) {
      fill(30, 60, 105);
    } else {
      fill(18, 40, 72);
    }
    rect(x, y, w, h);

    // active tab: bright accent bar at the bottom
    if (selected) {
      fill(80, 170, 255);
      rect(x + 4, y + h - 3, w - 8, 3, 1);
    }

    // hover: subtle top highlight
    if (isMouseOver() && !selected) {
      fill(255, 12);
      rect(x, y, w, h);
    }

    // separator between inactive tabs
    if (!selected) {
      stroke(30, 55, 95, 120);
      strokeWeight(1);
      line(x + w, y + 12, x + w, y + h - 12);
    }

    noStroke();
    fill(selected ? 255 : 170);
    if (isMouseOver() && !selected) fill(220);
    textSize(fontSize);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2 - 2);

    popStyle();
  }
  // isMouseOver()
  // Returns true if the mouse is currently inside the button rectangle.
  // Used for click handling and hover effects.
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }
}
