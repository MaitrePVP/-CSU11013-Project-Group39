int currentScreen = 0; // 0 = home, 1 = results, 2 = info, 3 = snake, 4 = graph, 5= scatterplot

Button startButton;
Button infoButton;
Button quitButton;
Button backButton;
Button snakeButton;
Button graphButton;
Button scatterButton;

Button airportPrevButton;
Button airportNextButton;
Button airportPrevButtonGraph;
Button airportNextButtonGraph;
Button startPrevButton;
Button startNextButton;
Button endPrevButton;
Button endNextButton;

Button sortButton;
Button resetFiltersButton;

boolean clickedAlessandro = false;
boolean clickedMusa = false;
boolean clickedAlex = false;
boolean clickedElijas = false;
boolean snakeUnlocked = false;

PFont mainFont;

ArrayList<Flight> flights = new ArrayList<Flight>();
ArrayList<Flight> filteredFlights = new ArrayList<Flight>();

String[] airportOptions = { "ALL" };
String[] dateOptions = new String[0];

String defaultAirport = "ALL";
String selectedAirport = "ALL";
String startDate = "";
String endDate = "";

int selectedAirportIndex = 0;
int selectedStartDateIndex = 0;
int selectedEndDateIndex = 0;

boolean sortByLateness = false;
boolean dataLoaded = false;
int visibleFlightCount = 12;

String loadMessage = "Data not loaded yet.";

// Codex update, 21/03/2026: merged working filters into the latest UI.
BarChart flightDateChart;
ScatterPlot flightAirportScatter;

void setup() {
  size(1200, 800);
  smooth(8);

  mainFont = createFont("Arial", 20, true);
  textFont(mainFont);

  textAlign(CENTER, CENTER);
  rectMode(CORNER);

  startButton = new Button(width / 2 - 150, 320, 300, 60, "Start Exploring");
  infoButton = new Button(width / 2 - 150, 410, 300, 60, "Group Info");
  quitButton = new Button(width / 2 - 150, 500, 300, 60, "Exit");
  backButton = new Button(40, 40, 170, 50, "Back to Home");
  graphButton = new Button(990, 40, 170, 50, "See Graphs");
  scatterButton = new Button(990, 40, 170, 50, "See Scatter Plot");
  snakeButton = new Button(width / 2 - 120, 590, 240, 55, "Play Snake");

  airportPrevButton = new Button(95, 296, 42, 36, "<", 22);
  airportNextButton = new Button(303, 296, 42, 36, ">", 22);
  airportPrevButtonGraph = new Button(930, 130, 42, 36, "<", 22);
  airportNextButtonGraph = new Button(1130, 130, 42, 36, ">", 22);
  startPrevButton = new Button(95, 388, 42, 36, "<", 22);
  startNextButton = new Button(303, 388, 42, 36, ">", 22);
  endPrevButton = new Button(95, 454, 42, 36, "<", 22);
  endNextButton = new Button(303, 454, 42, 36, ">", 22);
  sortButton = new Button(110, 588, 220, 44, "Sort: File Order", 16);
  resetFiltersButton = new Button(110, 642, 220, 44, "Reset Filters", 16);

  initSnakeGame();
  loadFlightData("flights2k.csv");
  initialiseFilterState();
}

void draw() {
  background(235, 242, 250);

  if (currentScreen == 0) {
    drawHomeScreen();
  } else if (currentScreen == 1) {
    drawResultsScreen();
  } else if (currentScreen == 2) {
    drawInfoScreen();
  } else if (currentScreen == 3) {
    drawSnakeScreen();
  } else if (currentScreen == 4) {
    drawGraphScreen();
  } else if (currentScreen == 5) {
    drawScatterScreen();
  }
}

void drawResultsScreen() {
  backButton.label = "Back to Home";
  graphButton.label = "See Graphs";

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Results Screen", width / 2, 50);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(60, 140, 320, 560, 20);
  rect(410, 140, 730, 560, 20);

  fill(40);
  textSize(24);
  text("Controls", 220, 182);
  text("Flight Data", 775, 182);

  textAlign(LEFT, TOP);
  fill(70);
  textSize(15);
  text(loadMessage, 90, 214, 260, 40);

  fill(40);
  textSize(16);
  text("Airport", 90, 266);
  drawSelectionCard(145, 296, 150, 36, getAirportDisplayLabel());
  airportPrevButton.display();
  airportNextButton.display();

  text("Date Range", 90, 356);
  fill(80);
  textSize(13);
  text("Start", 90, 373);
  drawSelectionCard(145, 388, 150, 36, formatDateForUi(startDate));
  startPrevButton.display();
  startNextButton.display();

  text("End", 90, 440);
  drawSelectionCard(145, 454, 150, 36, formatDateForUi(endDate));
  endPrevButton.display();
  endNextButton.display();

  fill(40);
  textSize(14);
  text("Flights loaded: " + flights.size(), 90, 520);
  text("Flights shown: " + filteredFlights.size(), 90, 546);
  text("Date view: " + getDateRangeLabel(), 90, 572, 240, 40);

  sortButton.display(sortByLateness);
  resetFiltersButton.display();

  drawFlightResultsPanel();

  backButton.display();
  graphButton.display();
}

void drawInfoScreen() {
  backButton.label = "Back to Home";

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 120);

  fill(255);
  textSize(34);
  textAlign(CENTER, CENTER);
  text("Group Information", width / 2, 60);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(width / 2 - 350, 170, 700, 470, 20);

  fill(40);
  textSize(28);
  text("Group 39", width / 2, 230);

  textSize(22);
  text("Team Members", width / 2, 290);

  drawMemberName("Alessandro Caradonna", width / 2, 350, clickedAlessandro);
  drawMemberName("Musa Irfan", width / 2, 390, clickedMusa);
  drawMemberName("Alex Grigorita", width / 2, 430, clickedAlex);
  drawMemberName("Elijas Sohlstrom", width / 2, 470, clickedElijas);

  textSize(16);
  fill(80);
  text("There is a secret on this page, try to find it!", width / 2, 530);
  text("CSU11013 Group Project - Flight Data Visualisation", width / 2, 560);

  if (snakeUnlocked) {
    fill(20, 120, 60);
    textSize(18);
    text("Secret unlocked.", width / 2, 600);
    snakeButton.display();
  }

  backButton.display();
}

void drawMemberName(String name, float x, float y, boolean clicked) {
  if (clicked) {
    fill(20, 140, 60);
  } else {
    fill(40);
  }

  textSize(20);
  textAlign(CENTER, CENTER);
  text(name, x, y);
}

void mousePressed() {
  if (currentScreen == 0) {
    if (startButton.isMouseOver()) {
      currentScreen = 1;
    } else if (infoButton.isMouseOver()) {
      currentScreen = 2;
    } else if (quitButton.isMouseOver()) {
      exit();
    }
  } else if (currentScreen == 1) {
    if (backButton.isMouseOver()) {
      currentScreen = 0;
    } else if (graphButton.isMouseOver()) {
      currentScreen = 4;
    } else if (airportPrevButton.isMouseOver()) {
      shiftAirportSelection(-1);
    } else if (airportNextButton.isMouseOver()) {
      shiftAirportSelection(1);
    }else if (startPrevButton.isMouseOver()) {
      shiftStartDate(-1);
    } else if (startNextButton.isMouseOver()) {
      shiftStartDate(1);
    } else if (endPrevButton.isMouseOver()) {
      shiftEndDate(-1);
    } else if (endNextButton.isMouseOver()) {
      shiftEndDate(1);
    } else if (sortButton.isMouseOver()) {
      sortByLateness = !sortByLateness;
      applyActiveFilters();
    } else if (resetFiltersButton.isMouseOver()) {
      resetFilters();
    }
  } else if (currentScreen == 2) {
    if (backButton.isMouseOver()) {
      currentScreen = 0;
      return;
    }

    checkNameClicks();

    if (snakeUnlocked && snakeButton.isMouseOver()) {
      currentScreen = 3;
      resetSnakeGame();
    }
  } else if (currentScreen == 3) {
    if (backButton.isMouseOver()) {
      currentScreen = 0;
    }
  } else if (currentScreen == 4) {
    if (backButton.isMouseOver()) {
      currentScreen = 1;
    } else if (scatterButton.isMouseOver()){
      currentScreen = 5;
    } else if (airportPrevButtonGraph.isMouseOver()) {
      shiftAirportSelection(-1);
    } else if (airportNextButtonGraph.isMouseOver()) {
      shiftAirportSelection(1);
    }
  }else if (currentScreen == 5) {
    if (backButton.isMouseOver()) {
      currentScreen = 1;
    }
  }
  updateSnakeUnlock();
  
  flightDateChart.handleClick(mouseX, mouseY);
}

void keyPressed() {
  if (currentScreen == 3) {
    handleSnakeInput();
  }
}

void checkNameClicks() {
  if (isMouseOverText(width / 2, 350, 280, 30)) {
    clickedAlessandro = true;
  } else if (isMouseOverText(width / 2, 390, 180, 30)) {
    clickedMusa = true;
  } else if (isMouseOverText(width / 2, 430, 200, 30)) {
    clickedAlex = true;
  } else if (isMouseOverText(width / 2, 470, 220, 30)) {
    clickedElijas = true;
  }
}

void updateSnakeUnlock() {
  if (clickedAlessandro && clickedMusa && clickedAlex && clickedElijas) {
    snakeUnlocked = true;
  }
}

boolean isMouseOverText(float centerX, float centerY, float boxW, float boxH) {
  return mouseX >= centerX - boxW / 2 &&
         mouseX <= centerX + boxW / 2 &&
         mouseY >= centerY - boxH / 2 &&
         mouseY <= centerY + boxH / 2;
}

void drawHomeScreen() {
  backButton.label = "Back to Home";

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 120);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("Flight Data Visualisation", width / 2, 50);

  textSize(18);
  text("CSU11013 Group Project", width / 2, 90);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(width / 2 - 350, 180, 700, 450, 20);

  fill(40);
  textSize(28);
  text("Welcome", width / 2, 230);

  textSize(16);
  text("Use this application to explore and visualise flight data.", width / 2, 270);
  text("Choose an option below to begin.", width / 2, 300);

  startButton.display();
  infoButton.display();
  quitButton.display();
}

void buildFlightDateChart() {
  computeFlightsPerDate(filteredFlights);

  String[] shortLabels = new String[flightDates.length];
  for (int i = 0; i < flightDates.length; i++) {
    shortLabels[i] = formatDateForChartLabel(flightDates[i]);
  }

  String countsStr = "";
  for (int i = 0; i < flightCounts.length; i++) {
    countsStr += flightCounts[i];
    if (i < flightCounts.length - 1) countsStr += ",";
  }

  String[] csvData = flightCounts.length == 0 ? new String[0] : new String[] { countsStr };
  flightDateChart = new BarChart(120, 660, 960, 480, csvData, shortLabels);
  flightDateChart.setChartTitle(getChartTitle());
  flightDateChart.setAxisTitles("Date (MM/DD)", "Number of Flights");
}

void drawGraphScreen() {
  backButton.label = "Back to Results";

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);
  
  fill(40);
  textSize(16);
  text("Airport", 975, 115);
  drawSelectionCard(975, 130, 150, 36, getAirportDisplayLabel());
  airportPrevButtonGraph.display();
  airportNextButtonGraph.display();
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Flight Data - Bar Chart", width / 2, 45);

  textSize(14);
  text("Airport: " + getAirportDisplayLabel() + "   Dates: " + getDateRangeLabel() + "   Matching flights: " + filteredFlights.size(), width / 2, 78);

  if (flightDateChart != null) {
    flightDateChart.drawBarChart();
  } else {
    fill(80);
    textSize(18);
    text("Chart could not be built (no data loaded).", width / 2, height / 2);
  }

  backButton.display();
  scatterButton.display();
}


void drawScatterScreen() {
  backButton.label = "Back to Results";

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Flight Data - ScatterPlot", width / 2, 45);

  textSize(14);
  text("Airport: " + getAirportDisplayLabel() + "   Dates: " + getDateRangeLabel() + "   Matching flights: " + filteredFlights.size(), width / 2, 78);

  if (flightAirportScatter != null) {
    flightAirportScatter.drawScatterPlot();
  } else {
    fill(80);
    textSize(18);
    text("Scatter Plot could not be built (no data loaded).", width / 2, height / 2);
  }

  backButton.display();
}


void initialiseFilterState() {
  airportOptions = buildAirportOptions(0);
  dateOptions = getAvailableDateKeys();

  int defaultIndex = findStringIndex(airportOptions, defaultAirport);
  selectedAirportIndex = defaultIndex >= 0 ? defaultIndex : 0;

  if (dateOptions.length > 0) {
    selectedStartDateIndex = 0;
    selectedEndDateIndex = dateOptions.length - 1;
  }

  sortByLateness = false;
  applyActiveFilters();
}

void applyActiveFilters() {
  if (!dataLoaded) {
    filteredFlights.clear();
    buildFlightDateChart();
    return;
  }

  if (airportOptions.length == 0) {
    airportOptions = new String[] { "ALL" };
  }

  selectedAirportIndex = constrain(selectedAirportIndex, 0, airportOptions.length - 1);
  selectedAirport = airportOptions[selectedAirportIndex];

  if (dateOptions.length > 0) {
    selectedStartDateIndex = constrain(selectedStartDateIndex, 0, dateOptions.length - 1);
    selectedEndDateIndex = constrain(selectedEndDateIndex, 0, dateOptions.length - 1);

    if (selectedStartDateIndex > selectedEndDateIndex) {
      int temp = selectedStartDateIndex;
      selectedStartDateIndex = selectedEndDateIndex;
      selectedEndDateIndex = temp;
    }

    startDate = dateOptions[selectedStartDateIndex];
    endDate = dateOptions[selectedEndDateIndex];
  } else {
    startDate = "";
    endDate = "";
  }

  filterFlights(selectedAirport, startDate, endDate);

  if (sortByLateness) {
    sortFilteredFlightsByLateness();
  }

  sortButton.label = sortByLateness ? "Sort: Most Late" : "Sort: File Order";
  buildFlightDateChart();
}

void resetFilters() {
  selectedAirportIndex = 0;

  if (dateOptions.length > 0) {
    selectedStartDateIndex = 0;
    selectedEndDateIndex = dateOptions.length - 1;
  }

  sortByLateness = false;
  applyActiveFilters();
}

void shiftAirportSelection(int direction) {
  if (airportOptions.length == 0) return;

  selectedAirportIndex += direction;

  if (selectedAirportIndex < 0) {
    selectedAirportIndex = airportOptions.length - 1;
  } else if (selectedAirportIndex >= airportOptions.length) {
    selectedAirportIndex = 0;
  }

  applyActiveFilters();
}

void shiftStartDate(int direction) {
  if (dateOptions.length == 0) return;

  selectedStartDateIndex = constrain(selectedStartDateIndex + direction, 0, dateOptions.length - 1);
  if (selectedStartDateIndex > selectedEndDateIndex) {
    selectedEndDateIndex = selectedStartDateIndex;
  }

  applyActiveFilters();
}

void shiftEndDate(int direction) {
  if (dateOptions.length == 0) return;

  selectedEndDateIndex = constrain(selectedEndDateIndex + direction, 0, dateOptions.length - 1);
  if (selectedEndDateIndex < selectedStartDateIndex) {
    selectedStartDateIndex = selectedEndDateIndex;
  }

  applyActiveFilters();
}

void drawSelectionCard(float x, float y, float w, float h, String label) {
  pushStyle();
  fill(250);
  stroke(210);
  strokeWeight(1.5);
  rect(x, y, w, h, 10);

  fill(40);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
  popStyle();
}

void drawFlightResultsPanel() {
  pushStyle();
  textAlign(LEFT, TOP);

  fill(70);
  textSize(14);
  text("Airport: " + getAirportDisplayLabel() + "   Date range: " + getDateRangeLabel() + "   Sort: " + getSortDescription(), 440, 214, 650, 40);

  if (!dataLoaded) {
    fill(80);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(loadMessage, 775, 420);
    popStyle();
    return;
  }

  if (filteredFlights.size() == 0) {
    fill(80);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("No flights match the current filters.", 775, 420);
    popStyle();
    return;
  }

  fill(90);
  textSize(13);
  int shownFlights = min(visibleFlightCount, filteredFlights.size());
  text("Showing first " + shownFlights + " matching flights", 440, 250);

  float startY = 284;
  for (int i = 0; i < shownFlights; i++) {
    float rowY = startY + i * 32;
    Flight flight = filteredFlights.get(i);

    stroke(230);
    strokeWeight(1);
    line(440, rowY + 24, 1110, rowY + 24);

    noStroke();
    fill(35);
    text(formatFlightSummary(flight), 440, rowY);
  }

  if (filteredFlights.size() > shownFlights) {
    fill(100);
    text((filteredFlights.size() - shownFlights) + " more flights match the current filters.", 440, 666);
  }

  popStyle();
}

String formatFlightSummary(Flight flight) {
  return formatDateForChartLabel(flight.getDateKey()) + "   " +
         flight.getFlightCode() + "   " +
         flight.origin + " -> " + flight.dest + "   " +
         flight.getDelayLabel();
}

String getAirportDisplayLabel() {
  return selectedAirport.equals("ALL") ? "All airports" : selectedAirport;
}

String getDateRangeLabel() {
  if (startDate.equals("") || endDate.equals("")) {
    return "All dates";
  }

  String startLabel = formatDateForUi(startDate);
  String endLabel = formatDateForUi(endDate);

  if (startLabel.equals(endLabel)) {
    return startLabel;
  }

  return startLabel + " - " + endLabel;
}

String getSortDescription() {
  return sortByLateness ? "Most late first" : "Dataset order";
}

String getChartTitle() {
  if (selectedAirport.equals("ALL")) {
    return "Flights per Date";
  }

  return selectedAirport + " Flights per Date";
}

int findStringIndex(String[] values, String target) {
  for (int i = 0; i < values.length; i++) {
    if (values[i].equals(target)) {
      return i;
    }
  }

  return -1;
}
