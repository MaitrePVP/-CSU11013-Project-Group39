class ScatterPlot {

  float[] valuesX;
  float[] valuesY;
  float[] sizes;
  String[] origins;

  int x, y, width, height;

  String xAxisTitle = "X Axis";
  String yAxisTitle = "Y Axis";
  String chartTitle = "Scatter Plot";

  PFont chartFont;

  // Visual size range for points
  float minPointSize = 8;
  float maxPointSize = 48;

  ScatterPlot(int x, int y, int width, int height,
              float[] valuesX, float[] valuesY, float[] sizes, String[] origins) {

    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.valuesX = valuesX;
    this.valuesY = valuesY;
    this.sizes = sizes;
    this.origins = origins;

    chartFont = createFont("Arial", 16, true);
  }

  void drawScatterPlot() {
    textFont(chartFont);

    if (valuesX == null || valuesX.length == 0) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(20);
      text("No data available", x + width / 2, y - height / 2);
      return;
    }

    float minX = 0;
    float minY = 0;
    float maxX = max(valuesX);
    float maxY = max(valuesY);
    float minSize = min(sizes);
    float maxSize = max(sizes);

    drawGridLines(minX, maxX, minY, maxY);
    drawAxes();
    drawTitle();

    int hoveredIndex = drawPoints(minX, maxX, minY, maxY, minSize, maxSize);

    drawLegend();

    if (hoveredIndex != -1) {
      drawTooltip(hoveredIndex, minX, maxX, minY, maxY, minSize, maxSize);
    }
  }

  void drawAxes() {
    stroke(0);
    strokeWeight(2);

    line(x, y, x + width, y);
    line(x, y, x, y - height);

    fill(0);
    textSize(18);

    textAlign(CENTER, TOP);
    text(xAxisTitle, x + width / 2, y + 20);

    pushMatrix();
    translate(x - 50, y - height / 2);
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
      float xVal = map(i, 0, steps, minX, maxX);

      line(xPos, y, xPos, y - height);
      textAlign(CENTER, TOP);
      text(nf(xVal, 0, 0), xPos, y + 6);
    }

    for (int i = 0; i <= steps; i++) {
      float yPos = map(i, 0, steps, y, y - height);
      float yVal = map(i, 0, steps, minY, maxY);

      line(x, yPos, x + width, yPos);
      textAlign(RIGHT, CENTER);
      text(nf(yVal, 0, 0), x - 8, yPos);
    }
  }

  int drawPoints(float minX, float maxX, float minY, float maxY,
                 float minSize, float maxSize) {

    int hoveredIndex = -1;

    noStroke();

    for (int i = 0; i < valuesX.length; i++) {
      float px = map(valuesX[i], minX, maxX, x, x + width);
      float py = map(valuesY[i], minY, maxY, y, y - height);
      float pointSize = mapSize(sizes[i], minSize, maxSize);

      boolean isHovered = dist(mouseX, mouseY, px, py) <= pointSize / 2;

      if (isHovered) {
        hoveredIndex = i;
        fill(getHoverColor(origins[i]));
        stroke(50, 80);
        strokeWeight(1.5);
      } else {
        fill(getColor(origins[i]));
        noStroke();
      }

      ellipse(px, py, pointSize, pointSize);
    }

    return hoveredIndex;
  }

  // Continuous size mapping:
  // every distinct numeric input value gets its own plotted size
  float mapSize(float value, float minSizeValue, float maxSizeValue) {
    if (minSizeValue == maxSizeValue) {
      return (minPointSize + maxPointSize) / 2.0;
    }
    return map(value, minSizeValue, maxSizeValue, minPointSize, maxPointSize);
  }

  color getColor(String category) {
    String[] unique = getUnique(origins);
    int idx = indexOf(unique, category);

    color[] palette = {
      color(100, 140, 220, 160),
      color(235, 170, 130, 160),
      color(120, 200, 120, 160),
      color(180, 130, 220, 160),
      color(240, 210, 90, 160),
      color(110, 200, 200, 160),
      color(220, 120, 160, 160),
      color(160, 160, 160, 160)
    };

    return palette[idx % palette.length];
  }

  color getHoverColor(String category) {
    String[] unique = getUnique(origins);
    int idx = indexOf(unique, category);

    color[] palette = {
      color(70, 110, 210, 220),
      color(225, 145, 100, 220),
      color(90, 180, 100, 220),
      color(160, 110, 210, 220),
      color(220, 190, 60, 220),
      color(80, 180, 180, 220),
      color(210, 90, 140, 220),
      color(130, 130, 130, 220)
    };

    return palette[idx % palette.length];
  }

  void drawLegend() {
    float lx = x + width + 40;
    float ly = y - height + 40;

    String[] unique = getUnique(origins);

    fill(0);
    textSize(14);
    textAlign(LEFT, CENTER);
    text("Origin", lx, ly);

    for (int i = 0; i < unique.length; i++) {
      fill(getColor(unique[i]));
      noStroke();
      ellipse(lx + 8, ly + 25 + i * 24, 10, 10);

      fill(0);
      text(unique[i], lx + 24, ly + 25 + i * 24);
    }
  }

  void drawTooltip(int index, float minX, float maxX, float minY, float maxY,
                   float minSize, float maxSize) {

    float px = map(valuesX[index], minX, maxX, x, x + width);
    float py = map(valuesY[index], minY, maxY, y, y - height);

    float avgX = getAverage(valuesX);
    float avgY = getAverage(valuesY);
    
    // percentage differences
    float vsAvgX = avgX != 0 ? ((valuesX[index] - avgX) / avgX) * 100.0 : 0;
    float vsAvgY = avgY != 0 ? ((valuesY[index] - avgY) / avgY) * 100.0 : 0;
    
    String originText = "Origin: " + origins[index];
    String xText = xAxisTitle + ": " + nf(valuesX[index], 0, 1);
    String yText = yAxisTitle + ": " + nf(valuesY[index], 0, 1);
    String sizeText = "Size metric: " + nf(sizes[index], 0, 1);

    String vsAvgXText = "Vs avg X: " + formatPercent(vsAvgX);
    String vsAvgYText = "Vs avg Y: " + formatPercent(vsAvgY);

    float boxW = 180;
    float boxH = 120;
    float boxX = px + 14;
    float boxY = py - boxH - 10;

    if (boxX + boxW > x + width) {
      boxX = px - boxW - 14;
    }
    if (boxY < y - height) {
      boxY = py + 14;
    }

    noStroke();
    fill(0, 25);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);

    fill(255);
    stroke(210);
    strokeWeight(1);
    rect(boxX, boxY, boxW, boxH, 8);

    fill(20);
    textAlign(LEFT, TOP);

    textSize(13);
    text(originText, boxX + 12, boxY + 10);

    textSize(12);
    text(xText,      boxX + 12, boxY + 30);
    text(yText,      boxX + 12, boxY + 46);
    text(sizeText,   boxX + 12, boxY + 62);
    text(vsAvgXText, boxX + 12, boxY + 78);
    text(vsAvgYText, boxX + 12, boxY + 94);
  }

  void drawTitle() {
    fill(0);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(chartTitle, x + width / 2, y - height - 20);
  }

  float getAverage(float[] arr) {
    if (arr == null || arr.length == 0) return 0;

    float sum = 0;
    for (int i = 0; i < arr.length; i++) {
      sum += arr[i];
    }
    return sum / arr.length;
  }

  String formatSigned(float value) {
    if (value >= 0) {
      return "+" + nf(value, 0, 1);
    }
    return nf(value, 0, 1);
  }

  String[] getUnique(String[] arr) {
    ArrayList<String> unique = new ArrayList<String>();

    for (String value : arr) {
      if (!unique.contains(value)) {
        unique.add(value);
      }
    }

    return unique.toArray(new String[0]);
  }

  int indexOf(String[] arr, String value) {
    for (int i = 0; i < arr.length; i++) {
      if (arr[i].equals(value)) {
        return i;
      }
    }
    return 0;
  }

  void setAxisTitles(String xTitle, String yTitle) {
    xAxisTitle = xTitle;
    yAxisTitle = yTitle;
  }

  void setChartTitle(String title) {
    chartTitle = title;
  }
  
  String formatPercent(float value) {
    String sign = value > 0 ? "+" : "";
    return sign + nf(value, 0, 1) + "%";
  }
}
