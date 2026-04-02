class BarChart {
  int[] values;
  String[] labels;
  boolean[] visible;

  int x, y, width, height, gap = 12, maxValue = 1, topPadding = 30;
  int legendWidth = 180, legendItemHeight = 24, legendBoxSize = 14, legendPadding = 16;
  int legendRowsPerColumn = 16, legendColumnGap = 18, legendColumnWidth = 88;

  String xAxisTitle = "X Axis", yAxisTitle = "Y Axis", chartTitle = "Bar Chart Title";
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
      visible = new boolean[0];
      return;
    }

    String[] parts = split(csvData[0], ',');
    values = new int[parts.length];
    visible = new boolean[parts.length];

    for (int i = 0; i < parts.length; i++) {
      try {
        values[i] = Integer.parseInt(parts[i].replace("\"", "").trim());
      } catch (Exception e) {
        values[i] = 0;
      }
      visible[i] = false;
    }
    updateMaxValue();
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

    int visibleCount = getVisibleCount();
    int chartWidth = width - getLegendAreaWidth() - 20;
    float usableHeight = height - topPadding;

    drawGridLines();
    drawAxes();
    drawTitle();
    drawLegend();

    if (visibleCount == 0) {
      fill(80);
      textSize(18);
      textAlign(CENTER, CENTER);
      text("No dates selected", x + chartWidth / 2, y - height / 2);
      return;
    }

    int barWidth = (chartWidth - gap * (visibleCount - 1)) / visibleCount;
    int hoveredIndex = -1, drawIndex = 0;

    for (int i = 0; i < values.length; i++) {
      if (!visible[i]) continue;

      int barX = x + drawIndex * (barWidth + gap);
      float barHeight = values[i] * usableHeight / maxValue;
      float barTop = y - barHeight;
      boolean hovered = mouseX >= barX && mouseX <= barX + barWidth && mouseY >= barTop && mouseY <= y;

      fill(hovered ? color(220, 220, 60) : color(195, 195, 25));
      stroke(100);
      strokeWeight(1);
      rect(barX, barTop, barWidth, barHeight);

      fill(0);
      textSize(14);
      textAlign(CENTER, BOTTOM);
      text(values[i], barX + barWidth / 2, barTop - 6);

      if (labels != null && i < labels.length) {
        textSize(12);
        textAlign(CENTER, TOP);
        text(labels[i], barX + barWidth / 2, y + 8);
      }

      if (hovered) hoveredIndex = i;
      drawIndex++;
    }

    drawAverageLine();

    if (hoveredIndex != -1) drawTooltip(hoveredIndex, barWidth, usableHeight);
  }

  void drawAxes() {
    int cw = width - getLegendAreaWidth() - 20;
    stroke(0);
    strokeWeight(2);
    line(x, y, x + cw, y);
    line(x, y, x, y - height);

    fill(0);
    textSize(18);
    textAlign(CENTER, TOP);
    text(xAxisTitle, x + cw / 2, y + 30);

    pushMatrix();
    translate(x - 60, y - height / 2);
    rotate(-HALF_PI);
    textAlign(CENTER, CENTER);
    text(yAxisTitle, 0, 0);
    popMatrix();
  }

  void drawGridLines() {
    int steps = 5, cw = width - getLegendAreaWidth() - 20;
    float usableHeight = height - topPadding;

    for (int i = 0; i <= steps; i++) {
      float yPos = map(i, 0, steps, y, y - usableHeight);
      stroke(220);
      strokeWeight(1);
      line(x, yPos, x + cw, yPos);

      fill(0);
      textSize(12);
      textAlign(RIGHT, CENTER);
      text(int(map(i, 0, steps, 0, maxValue)), x - 8, yPos);
    }
  }

  void drawTitle() {
    fill(0);
    textSize(22);
    textAlign(CENTER, CENTER);
    text(chartTitle, x + (width - getLegendAreaWidth()) / 2, y - height - 20);
  }

  void drawLegend() {
    int lx = x + width - getLegendAreaWidth() + legendPadding;
    int ly = y - height + 20;

    fill(0);
    textSize(15);
    textAlign(LEFT, TOP);
    text("Dates", lx, ly - 4);

    for (int i = 0; i < values.length; i++) {
      int col = i / legendRowsPerColumn;
      int row = i % legendRowsPerColumn;
      int itemX = lx + col * (legendColumnWidth + legendColumnGap);
      int iy = ly + 24 + row * legendItemHeight;
      boolean hovered = mouseX >= itemX && mouseX <= itemX + legendColumnWidth &&
                        mouseY >= iy && mouseY <= iy + legendBoxSize;

      if (hovered) {
        noStroke();
        fill(245);
        rect(itemX - 4, iy - 3, legendColumnWidth, legendBoxSize + 6, 4);
      }

      stroke(80);
      strokeWeight(1);
      fill(visible[i] ? color(195, 195, 25) : color(255));
      rect(itemX, iy, legendBoxSize, legendBoxSize);

      stroke(visible[i] ? 40 : 140);
      if (visible[i]) {
        line(itemX + 3, iy + 7, itemX + 6, iy + 10);
        line(itemX + 6, iy + 10, itemX + 11, iy + 3);
      } else {
        line(itemX + 3, iy + 3, itemX + 11, iy + 11);
        line(itemX + 11, iy + 3, itemX + 3, iy + 11);
      }

      fill(visible[i] ? 0 : 140);
      textSize(13);
      textAlign(LEFT, TOP);
      text((labels != null && i < labels.length) ? labels[i] : "Date " + (i + 1), itemX + legendBoxSize + 10, iy - 1);
    }
  }

  void drawAverageLine() {
    int count = getVisibleCount();
    if (count == 0) return;

    float avg = getAverageOfVisible();
    float avgY = y - (avg / maxValue) * (height - topPadding);
    int cw = width - getLegendAreaWidth() - 20;

    stroke(200, 60, 60);
    strokeWeight(2);
    for (int xp = x; xp < x + cw; xp += 12) line(xp, avgY, min(xp + 6, x + cw), avgY);

    fill(200, 60, 60);
    textSize(12);
    textAlign(LEFT, CENTER);
    text("Average: " + nf(avg, 0, 1), x - 95, avgY);
  }

  void handleClick(int mx, int my) {
    int lx = x + width - getLegendAreaWidth() + legendPadding;
    int ly = y - height + 44;

    for (int i = 0; i < values.length; i++) {
      int col = i / legendRowsPerColumn;
      int row = i % legendRowsPerColumn;
      int itemX = lx + col * (legendColumnWidth + legendColumnGap);
      int iy = ly + row * legendItemHeight;
      boolean hitSquare = mx >= itemX && mx <= itemX + legendBoxSize &&
                          my >= iy && my <= iy + legendBoxSize;

      if (hitSquare) {
        visible[i] = !visible[i];
        updateMaxValue();
        return;
      }
    }
  }

  void drawTooltip(int index, int barWidth, float usableHeight) {
    int drawIndex = getVisiblePosition(index);
    if (drawIndex == -1) return;

    int barX = x + drawIndex * (barWidth + gap);
    float barHeight = values[index] * usableHeight / maxValue;
    float barTop = y - barHeight;
    float avg = getAverageOfVisible();
    float percent = values[index] * 100.0 / maxValue;
    float diff = values[index] - avg;

    float boxW = 150, boxH = 82;
    float boxX = constrain(barX + barWidth / 2 - boxW / 2, x + 10, x + (width - getLegendAreaWidth() - 20) - boxW);
    float boxY = max(barTop - boxH - 14, 10);
    if (boxY == 10) boxY = barTop + 10;

    String label = (labels != null && index < labels.length) ? labels[index] : "Bar " + (index + 1);

    noStroke();
    fill(0, 25);
    rect(boxX + 3, boxY + 3, boxW, boxH, 8);

    fill(255);
    stroke(210);
    rect(boxX, boxY, boxW, boxH, 8);

    fill(20);
    textAlign(LEFT, TOP);
    textSize(13);
    text(label, boxX + 12, boxY + 10);

    fill(70);
    textSize(12);
    text("Value: " + values[index], boxX + 12, boxY + 30);
    text("Of max: " + nf(percent, 0, 1) + "%", boxX + 12, boxY + 46);
    text("Vs avg: " + (diff >= 0 ? "+" : "") + nf(diff, 0, 1), boxX + 12, boxY + 62);
  }


  int getLegendColumns() {
    return max(1, (values.length + legendRowsPerColumn - 1) / legendRowsPerColumn);
  }

  int getLegendAreaWidth() {
    return legendPadding * 2 + getLegendColumns() * legendColumnWidth + (getLegendColumns() - 1) * legendColumnGap;
  }

  int getVisibleCount() {
    int c = 0;
    for (boolean v : visible) if (v) c++;
    return c;
  }

  int getVisiblePosition(int index) {
    int pos = 0;
    for (int i = 0; i < visible.length; i++) {
      if (visible[i]) {
        if (i == index) return pos;
        pos++;
      }
    }
    return -1;
  }

  void updateMaxValue() {
    maxValue = 1;
    for (int i = 0; i < values.length; i++) if (visible[i]) maxValue = max(maxValue, values[i]);
  }

  float getAverage() {
    if (values.length == 0) return 0;
    int sum = 0;
    for (int v : values) sum += v;
    return (float) sum / values.length;
  }

  float getAverageOfVisible() {
    int sum = 0, count = 0;
    for (int i = 0; i < values.length; i++) if (visible[i]) {
      sum += values[i];
      count++;
    }
    return count == 0 ? 0 : (float) sum / count;
  }

  void setAxisTitles(String xTitle, String yTitle) {
    xAxisTitle = xTitle;
    yAxisTitle = yTitle;
  }

  void setChartTitle(String title) {
    chartTitle = title;
  }
}
