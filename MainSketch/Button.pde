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
  // isMouseOver()
  // Returns true if the mouse is currently inside the button rectangle.
  // Used for click handling and hover effects.
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }
}
