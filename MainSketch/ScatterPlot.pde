class ScatterPlot {
  float[] valuesX, valuesY, sizes;
  String[] carriers, uniqueCarriers;
  boolean[] carrierVisible;

  int x, y, width, height;
  String xAxisTitle = "X Axis";
  String yAxisTitle = "Y Axis";
  String chartTitle = "Scatter Plot";
  PFont chartFont;

  float minPointSize = 8;
  float maxPointSize = 30;
  float plotMargin = 4;

  ScatterPlot(int x, int y, int width, int height,
              float[] valuesX, float[] valuesY, float[] sizes, String[] carriers) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.valuesX = valuesX;
    this.valuesY = valuesY;
    this.sizes = sizes;
    this.carriers = carriers;
    chartFont = createFont("Arial", 16, true);

    uniqueCarriers = getUnique(carriers);
    carrierVisible = new boolean[uniqueCarriers.length];
    for (int i = 0; i < carrierVisible.length; i++) carrierVisible[i] = false;
  }

  void drawScatterPlot() {
    textFont(chartFont);
    drawTitle();

    if (valuesX == null || valuesX.length == 0) {
      drawEmptyMessage("No data available");
      return;
    }

    float[] r = getRanges();
    float minX = r[0], maxX = r[1], minY = r[2], maxY = r[3], minSize = r[4], maxSize = r[5];

    drawGridLines(minX, maxX, minY, maxY);
    drawAxes(minY, maxY);
    drawLegend();

    if (!hasVisibleCarrier()) {
      drawEmptyMessage("No carrier selected");
      return;
    }

    int hovered = drawPoints(minX, maxX, minY, maxY, minSize, maxSize);
    drawAverageLine(minY, maxY);
    if (hovered != -1) drawTooltip(hovered, minX, maxX, minY, maxY, minSize, maxSize);
  }

  float[] getRanges() {
    float minX = min(valuesX), maxX = max(valuesX);
    float minY = min(valuesY), maxY = max(valuesY);
    float minSize = max(1, min(sizes)), maxSize = max(sizes);

    if (minX == maxX) maxX = minX + 1;
    if (minY > 0) minY = 0;
    if (maxY < 0) maxY = 0;
    if (minY == maxY) {
      minY--;
      maxY++;
    }
    return new float[] {minX, maxX, minY, maxY, minSize, maxSize};
  }

  void drawEmptyMessage(String msg) {
    fill(120);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(msg, x + width / 2.0, y - height / 2.0);
  }

  void drawAxes(float minY, float maxY) {
    stroke(0);
    strokeWeight(2);
    line(x, y, x + width, y);
    line(x, y, x, y - height);

    float zeroY = getPlotY(0, minY, maxY, 0);
    stroke(130);
    strokeWeight(1);
    line(x, zeroY, x + width, zeroY);

    fill(0);
    textSize(12);
    textAlign(RIGHT, CENTER);
    text("0", x - 8, zeroY);

    textSize(18);
    textAlign(CENTER, TOP);
    text(xAxisTitle, x + width / 2.0, y + 22);

    pushMatrix();
    translate(x - 55, y - height / 2.0);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text(yAxisTitle, 0, 0);
    popMatrix();
  }

  void drawGridLines(float minX, float maxX, float minY, float maxY) {
    int steps = 5;
    stroke(225);
    strokeWeight(1);
    fill(0);
    textSize(12);

    for (int i = 0; i <= steps; i++) {
      float xPos = map(i, 0, steps, x, x + width);
      float yPos = map(i, 0, steps, y, y - height);

      line(xPos, y, xPos, y - height);
      line(x, yPos, x + width, yPos);

      textAlign(CENTER, TOP);
      text(formatXLabel(map(i, 0, steps, minX, maxX)), xPos, y + 6);
      textAlign(RIGHT, CENTER);
      text(nf(map(i, 0, steps, minY, maxY), 0, 1), x - 8, yPos);
    }
  }

  int drawPoints(float minX, float maxX, float minY, float maxY, float minSize, float maxSize) {
    int hovered = -1;

    for (int i = 0; i < valuesX.length; i++) {
      int c = indexOf(uniqueCarriers, carriers[i]);
      if (c < 0 || !carrierVisible[c]) continue;

      float d = mapSize(sizes[i], minSize, maxSize);
      float px = getPlotX(valuesX[i], minX, maxX, d);
      float py = getPlotY(valuesY[i], minY, maxY, d);
      boolean over = dist(mouseX, mouseY, px, py) <= d / 2.0;

      stroke(over ? color(40, 120) : color(255, 50));
      strokeWeight(over ? 2 : 1);
      fill(getCarrierColor(c), 170);
      ellipse(px, py, d, d);

      if (over) hovered = i;
    }
    return hovered;
  }

  void drawAverageLine(float minY, float maxY) {
    float avg = getVisibleAverageDelay();
    if (Float.isNaN(avg)) return;

    float avgY = getPlotY(avg, minY, maxY, 0);
    String label = "Average: " + nf(avg, 0, 1);
    float labelX = x - 95;
    float labelW = textWidth(label);
    float labelH = 18;
    boolean hover = mouseX >= labelX - 6 && mouseX <= labelX + labelW + 6 &&
      mouseY >= avgY - labelH / 2.0 - 4 && mouseY <= avgY + labelH / 2.0 + 4;

    stroke(220, 50, 50);
    strokeWeight(2);
    for (int xp = x; xp < x + width; xp += 12) line(xp, avgY, min(xp + 6, x + width), avgY);

    if (hover) {
      noStroke();
      fill(255);
      rect(labelX - 4, avgY - labelH / 2.0 - 2, labelW + 8, labelH, 4);
    }

    fill(220, 50, 50);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(label, labelX, avgY);
  }

  void drawLegend() {
    float lx = x + width + 34;
    float ly = y - height + 34;
    float box = 14;
    float row = 24;

    fill(0);
    textSize(15);
    textAlign(LEFT, TOP);
    text("Carrier", lx, ly - 4);

    for (int i = 0; i < uniqueCarriers.length; i++) {
      float iy = ly + 24 + i * row;
      stroke(90);
      strokeWeight(1);
      fill(carrierVisible[i] ? getCarrierColor(i) : color(190));
      rect(lx, iy, box, box, 3);

      fill(carrierVisible[i] ? 0 : 140);
      textSize(13);
      textAlign(LEFT, CENTER);
      text(uniqueCarriers[i], lx + box + 12, iy + box / 2.0);
    }
  }

  void drawTooltip(int i, float minX, float maxX, float minY, float maxY, float minSize, float maxSize) {
    float d = mapSize(sizes[i], minSize, maxSize);
    float px = getPlotX(valuesX[i], minX, maxX, d);
    float py = getPlotY(valuesY[i], minY, maxY, d);

    float boxW = 168, boxH = 86;
    float boxX = (px + 14 + boxW > x + width) ? px - boxW - 14 : px + 14;
    float boxY = (py - boxH - 10 < y - height) ? py + 14 : py - boxH - 10;

    noStroke();
    fill(0, 25);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);

    fill(255);
    stroke(210);
    strokeWeight(1);
    rect(boxX, boxY, boxW, boxH, 8);

    fill(20);
    textSize(12);
    textAlign(LEFT, TOP);
    text("Carrier: " + carriers[i], boxX + 12, boxY + 10);
    text("Flight time: " + formatXLabel(valuesX[i]), boxX + 12, boxY + 28);
    text("Delay: " + formatSigned(valuesY[i]) + " min", boxX + 12, boxY + 46);
    text("Distance: " + nf(sizes[i], 0, 0), boxX + 12, boxY + 64);
  }

  boolean hasVisibleCarrier() {
    for (boolean v : carrierVisible) if (v) return true;
    return false;
  }

  float getVisibleAverageDelay() {
    float total = 0;
    int count = 0;
    for (int i = 0; i < valuesY.length; i++) {
      int c = indexOf(uniqueCarriers, carriers[i]);
      if (c >= 0 && carrierVisible[c]) {
        total += valuesY[i];
        count++;
      }
    }
    return count == 0 ? Float.NaN : total / count;
  }

  float mapSize(float v, float minV, float maxV) {
    return minV == maxV ? (minPointSize + maxPointSize) / 2.0 : map(v, minV, maxV, minPointSize, maxPointSize);
  }

  int getCarrierColor(int i) {
    colorMode(HSB, 255);
    int c = color((i * 57) % 255, 170, 210);
    colorMode(RGB, 255);
    return c;
  }

  float getPlotX(float v, float minX, float maxX, float size) {
    float m = size / 2.0 + plotMargin;
    return map(v, minX, maxX, x + m, x + width - m);
  }

  float getPlotY(float v, float minY, float maxY, float size) {
    float m = size / 2.0 + plotMargin;
    return map(v, minY, maxY, y - m, y - height + m);
  }

  String formatXLabel(float value) {
    int day = floor(value);
    int mins = round((value - day) * 1440.0);
    if (mins >= 1440) {
      mins = 0;
      day++;
    }
    return day + " " + nf(mins / 60, 2) + ":" + nf(mins % 60, 2);
  }

  String formatSigned(float v) {
    return v > 0 ? "+" + nf(v, 0, 0) : nf(v, 0, 0);
  }

  String[] getUnique(String[] arr) {
    ArrayList<String> out = new ArrayList<String>();
    for (String s : arr) if (s != null && !s.equals("") && !out.contains(s)) out.add(s);
    return out.toArray(new String[0]);
  }

  int indexOf(String[] arr, String value) {
    for (int i = 0; i < arr.length; i++) if (arr[i].equals(value)) return i;
    return -1;
  }

  void handleClick(int mx, int my) {
    float lx = x + width + 34;
    float ly = y - height + 58;
    float box = 14;
    float row = 24;

    for (int i = 0; i < uniqueCarriers.length; i++) {
      float iy = ly + i * row;
      if (mx >= lx && mx <= lx + box && my >= iy && my <= iy + box) {
        carrierVisible[i] = !carrierVisible[i];
        return;
      }
    }
  }

  void setAxisTitles(String xTitle, String yTitle) {
    xAxisTitle = xTitle;
    yAxisTitle = yTitle;
  }

  void setChartTitle(String title) {
    chartTitle = title;
  }

  void drawTitle() {
    fill(0);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(chartTitle, x + width / 2.0, y - height - 20);
  }
}
