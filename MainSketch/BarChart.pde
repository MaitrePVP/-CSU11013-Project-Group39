class BarChart {

  int[] values;
  String[] labels;

  int x, y, width, height;
  int gap = 12;
  int maxValue;
  int topPadding = 30;

  String xAxisTitle = "X Axis";
  String yAxisTitle = "Y Axis";
  String chartTitle = "Bar Chart Title";

  PFont chartFont;

  BarChart(int x, int y, int width, int height, String[] csvData, String[] labels) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.labels = labels;

    chartFont = createFont("Arial", 16, true);

    if (csvData == null || csvData.length == 0) {
      values = new int[0];
      maxValue = 1;
      return;
    }

    String[] parts = split(csvData[0], ',');
    values = new int[parts.length];

    for (int i = 0; i < parts.length; i++) {
      parts[i] = parts[i].replace("\"", "").trim();

      try {
        values[i] = Integer.parseInt(parts[i]);
      } catch (NumberFormatException e) {
        values[i] = 0;
      }
    }

    maxValue = max(values);
    if (maxValue == 0) {
      maxValue = 1;
    }
  }

  void drawBarChart() {
    textFont(chartFont);

    if (values.length == 0) {
      fill(0);
      textSize(20);
      textAlign(CENTER, CENTER);
      text("No data available", x + width / 2, y - height / 2);
      return;
    }

    drawGridLines();
    drawAxes();
    drawTitle();

    int barWidth = (width - gap * (values.length - 1)) / values.length;
    float usableHeight = height - topPadding;

    int hoveredIndex = -1;

    for (int i = 0; i < values.length; i++) {
      int barX = x + i * (barWidth + gap);
      float barHeight = (float(values[i]) / maxValue) * usableHeight;
      float barTop = y - barHeight;

      boolean isHovered = mouseX >= barX && mouseX <= barX + barWidth &&
                          mouseY >= barTop && mouseY <= y;

      if (isHovered) {
        hoveredIndex = i;
        fill(220, 220, 60);   // brighter hover color
      } else {
        fill(195, 195, 25);   // normal bar color
      }

      // draw bar
      stroke(100);
      strokeWeight(1);
      rect(barX, barTop, barWidth, barHeight);

      // draw value label
      fill(0);
      textSize(14);
      textAlign(CENTER, BOTTOM);
      text(values[i], barX + barWidth / 2, barTop - 6);

      // draw x labels
      if (labels != null && i < labels.length) {
        textSize(12);
        textAlign(CENTER, TOP);
        text(labels[i], barX + barWidth / 2, y + 8);
      }
    }

    if (hoveredIndex != -1) {
      drawTooltip(hoveredIndex, barWidth, usableHeight);
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
    text(xAxisTitle, x + width / 2, y + 30);

    pushMatrix();
    translate(x - 60, y - height / 2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text(yAxisTitle, 0, 0);
    popMatrix();
  }

  void drawGridLines() {
    int steps = 5;
    float usableHeight = height - topPadding;

    for (int i = 0; i <= steps; i++) {
      float yPos = map(i, 0, steps, y, y - usableHeight);

      stroke(220);
      strokeWeight(1);
      line(x, yPos, x + width, yPos);

      int tickValue = int(map(i, 0, steps, 0, maxValue));
      fill(0);
      textSize(12);
      textAlign(RIGHT, CENTER);
      text(tickValue, x - 8, yPos);
    }
  }

  void drawTitle() {
    fill(0);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(chartTitle, x + width / 2, y - height - 20);
  }

  // Draws a small tooltip card with useful information about the hovered bar
  void drawTooltip(int index, int barWidth, float usableHeight) {
    int barX = x + index * (barWidth + gap);
    float barHeight = (float(values[index]) / maxValue) * usableHeight;
    float barTop = y - barHeight;

    float avg = getAverage();
    float percentOfMax = (float(values[index]) / maxValue) * 100.0;
    float diffFromAvg = values[index] - avg;

    String labelText = (labels != null && index < labels.length) ? labels[index] : "Bar " + (index + 1);
    String valueText = "Value: " + values[index];
    String percentText = "Of max: " + nf(percentOfMax, 0, 1) + "%";
    String avgText = "Vs avg: " + (diffFromAvg >= 0 ? "+" : "") + nf(diffFromAvg, 0, 1);

    float boxW = 150;
    float boxH = 82;
    float boxX = barX + barWidth / 2 - boxW / 2;
    float boxY = barTop - boxH - 14;

    // keep tooltip inside chart window horizontally
    boxX = constrain(boxX, 10, width - boxW + x);

    // if too close to the top, place below the top of the bar
    if (boxY < 10) {
      boxY = barTop + 10;
    }

    // subtle shadow
    noStroke();
    fill(0, 25);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);

    // tooltip card
    fill(255);
    stroke(210);
    strokeWeight(1);
    rect(boxX, boxY, boxW, boxH, 8);

    // text inside tooltip
    fill(20);
    textAlign(LEFT, TOP);

    textSize(13);
    text(labelText, boxX + 12, boxY + 10);

    textSize(12);
    fill(70);
    text(valueText,   boxX + 12, boxY + 30);
    text(percentText, boxX + 12, boxY + 46);
    text(avgText,     boxX + 12, boxY + 62);
  }

  float getAverage() {
    if (values.length == 0) return 0;

    int sum = 0;
    for (int i = 0; i < values.length; i++) {
      sum += values[i];
    }
    return (float) sum / values.length;
  }

  void setAxisTitles(String xTitle, String yTitle) {
    xAxisTitle = xTitle;
    yAxisTitle = yTitle;
  }

  void setChartTitle(String title) {
    chartTitle = title;
  }
}
