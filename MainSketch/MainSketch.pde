import processing.event.*;

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

Button navHomeButton;
Button navResultsButton;
Button navInfoButton;
Button navGraphButton;
Button navScatterButton;
Button navSnakeButton;


boolean graphAirportDropdownOpen = false;
int graphAirportDropdownScroll = 0;
int graphAirportDropdownX = 975;
int graphAirportDropdownY = 130;
int graphAirportDropdownW = 150;
int graphAirportDropdownH = 36;
int graphAirportDropdownItemH = 34;
int graphAirportDropdownVisibleItems = 10;
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

int graphAirportIndex = 0;
String graphSelectedAirport = "ALL";

boolean sortByLateness = false;
boolean dataLoaded = false;
int visibleFlightCount = 12;

String loadMessage = "Data not loaded yet.";


BarChart flightDateChart;
ScatterPlot flightAirportScatter;

// setup()
// Initialises the whole sketch:
// - sets window size and text settings
// - creates all UI buttons
// - initialises the Snake minigame
// - loads the flight CSV data
// - prepares the filter state for the results/graph screens
// This function runs once at the start.
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
  
  navHomeButton = new Button(0, 0, 200, 45, "Home", 15);
  navResultsButton = new Button(200, 0, 200, 45, "Results", 15);
  navInfoButton = new Button(400, 0, 200, 45, "Info", 15);
  navGraphButton = new Button(600, 0, 200, 45, "Bar Chart", 15);
  navScatterButton = new Button(800, 0, 200, 45, "ScatterPlot", 15);
  navSnakeButton = new Button(1000, 0, 200, 45, "Snake", 15);

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
  buildFlightDateChart();
  buildFlightScatterPlot();
}

// draw()
// Main Processing loop.
// Decides which screen to draw depending on currentScreen:
// 0 = home
// 1 = results
// 2 = info
// 3 = snake
// 4 = bar chart
// 5 = scatter plot

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

// drawResultsScreen()
// Draws the results page:
// - top header
// - filter controls on the left
// - loaded flight results on the right
// - sorting/reset buttons
// - navigation buttons
// This is the main data exploration screen.
void drawResultsScreen() {


  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Results Screen", width / 2, 75);

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

  drawNavBar();
}

// drawInfoScreen()
// Draws the group information page.
// Displays team member names, the hidden message, and unlocks the Snake button
// once all names have been clicked.
// Also shows the back button.
void drawInfoScreen() {


  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textSize(34);
  textAlign(CENTER, CENTER);
  text("Group Information", width / 2, 75);

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

  drawNavBar();
}

// drawMemberName(String name, float x, float y, boolean clicked)
// Draws one team member name at a given position.
// If the name has already been clicked, it is shown in green.
// Otherwise it is shown in the default dark colour.
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
void drawNavBar() {
  pushStyle();
  noStroke();

  // full-width background strip
  fill(18, 40, 72);
  rect(0, 0, width, 48);

  // subtle bottom edge glow
  for (int i = 0; i < 3; i++) {
    fill(60, 120, 200, 30 - i * 10);
    rect(0, 48 - i, width, 1);
  }

  popStyle();

  // tabs stretch edge-to-edge across the full window
  boolean showSnake = snakeUnlocked || currentScreen == 3;
  int tabCount = showSnake ? 6 : 5;
  float tabW = (float) width / tabCount;

  Button[] navButtons = { navHomeButton, navResultsButton, navInfoButton, navGraphButton, navScatterButton };
  int[] screenIds = { 0, 1, 2, 4, 5 };

  for (int i = 0; i < navButtons.length; i++) {
    navButtons[i].x = round(i * tabW);
    navButtons[i].w = round((i + 1) * tabW) - round(i * tabW);
    navButtons[i].h = 48;
    navButtons[i].displayNav(currentScreen == screenIds[i]);
  }

  if (showSnake) {
    navSnakeButton.x = round(5 * tabW);
    navSnakeButton.w = width - round(5 * tabW);
    navSnakeButton.h = 48;
    navSnakeButton.displayNav(currentScreen == 3);
  }
}

boolean handleNavBarClick() {
  if (navHomeButton.isMouseOver()) {
    currentScreen = 0;
    graphAirportDropdownOpen = false;
    return true;
  } else if (navResultsButton.isMouseOver()) {
    currentScreen = 1;
    graphAirportDropdownOpen = false;
    return true;
  } else if (navInfoButton.isMouseOver()) {
    currentScreen = 2;
    graphAirportDropdownOpen = false;
    return true;
  } else if (navGraphButton.isMouseOver()) {
    currentScreen = 4;
    graphAirportDropdownOpen = false;
    return true;
  } else if (navScatterButton.isMouseOver()) {
    currentScreen = 5;
    graphAirportDropdownOpen = false;
    return true;
  } else if ((snakeUnlocked || currentScreen == 3) && navSnakeButton.isMouseOver()) {
    currentScreen = 3;
    graphAirportDropdownOpen = false;
    resetSnakeGame();
    return true;
  }

  return false;
}

// mousePressed()
// Handles all mouse click interactions in the sketch.
// What it does depends on the current screen:
// - home: open results/info or quit
// - results: change filters, sort, reset, open graph screen
// - info: click member names, unlock/open Snake
// - snake: return to home
// - graph: interact with airport dropdown or go to scatter
// - scatter: return to results
// At the end, it also checks whether Snake should now be unlocked.
void mousePressed() {
  if (handleNavBarClick()) {
    return;
  }
  if (currentScreen == 0) {
    if (startButton.isMouseOver()) {
      currentScreen = 1;
    } else if (infoButton.isMouseOver()) {
      currentScreen = 2;
    } else if (quitButton.isMouseOver()) {
      exit();
    }
  } else if (currentScreen == 1) {
      if (airportPrevButton.isMouseOver()) {
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
    checkNameClicks();

    if (snakeUnlocked && snakeButton.isMouseOver()) {
      currentScreen = 3;
      resetSnakeGame();
  }

    checkNameClicks();

    if (snakeUnlocked && snakeButton.isMouseOver()) {
      currentScreen = 3;
      resetSnakeGame();
    }
  } else if (currentScreen == 3) {
  } else if (currentScreen == 4) {
    if (handleGraphAirportDropdownClick(mouseX, mouseY)) {
      return;
    }
  } else if (currentScreen == 5) {
    if (flightAirportScatter != null) {
      flightAirportScatter.handleClick(mouseX, mouseY);
    }
  }
  updateSnakeUnlock();
  
  if (currentScreen == 4 && flightDateChart != null && !graphAirportDropdownOpen) {
    flightDateChart.handleClick(mouseX, mouseY);
  }
}

// mouseWheel(MouseEvent event)
// Handles scrolling only for the graph airport dropdown.
// If the dropdown is open on the graph screen, this changes which airport
// options are currently visible.
void mouseWheel(MouseEvent event) {
  if (!graphAirportDropdownOpen || currentScreen != 4) return;

  int visibleCount = getGraphAirportDropdownVisibleCount();
  int maxScroll = max(0, airportOptions.length - visibleCount);
  graphAirportDropdownScroll += int(event.getCount());
  graphAirportDropdownScroll = constrain(graphAirportDropdownScroll, 0, maxScroll);
}

// keyPressed()
// Handles keyboard input.
// At the moment, this only forwards keyboard input to the Snake game
// when the Snake screen is active.
void keyPressed() {
  if (currentScreen == 3) {
    handleSnakeInput();
  }
}

// checkNameClicks()
// Checks whether the user clicked on one of the group member names
// on the info screen.
// Each successful click marks the corresponding boolean as true.
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

// updateSnakeUnlock()
// Unlocks the Snake minigame once all four names have been clicked.
// This is the small easter egg system for the project.
void updateSnakeUnlock() {
  if (clickedAlessandro && clickedMusa && clickedAlex && clickedElijas) {
    snakeUnlocked = true;
  }
}

// isMouseOverText(float centerX, float centerY, float boxW, float boxH)
// Utility function used for clickable text.
// Instead of checking the exact letters, it checks whether the mouse is inside
// a rectangular area around the text.
boolean isMouseOverText(float centerX, float centerY, float boxW, float boxH) {
  return mouseX >= centerX - boxW / 2 &&
         mouseX <= centerX + boxW / 2 &&
         mouseY >= centerY - boxH / 2 &&
         mouseY <= centerY + boxH / 2;
}

// drawHomeScreen()
// Draws the main welcome screen.
// Shows the project title, short description, and the three main buttons:
// Start Exploring, Group Info, Exit.
void drawHomeScreen() {
  

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 120);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("Flight Data Visualisation", width / 2, 64);

  textSize(18);
  text("CSU11013 Group Project", width / 2, 96);

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

// buildFlightDateChart()
// Rebuilds the bar chart based on the currently filtered flights.
// It computes flights per date, shortens the date labels,
// builds the chart data, and updates the chart title/axis labels.
void buildFlightDateChart() {
  ArrayList<Flight> chartFlights = getGraphBarChartFlights();
  BarChartData data = getBarChartData(chartFlights);
  flightDateChart = new BarChart(120, 660, 960, 480, data.csvData, data.labels);
  flightDateChart.setChartTitle(getGraphChartTitle());
  flightDateChart.setAxisTitles("Date (MM/DD)", "Number of Flights");
}

void buildFlightScatterPlot() {
  ScatterPlotData data = getScatterPlotData(flights);
  flightAirportScatter = new ScatterPlot(110, 660, 820, 480, data.valuesX, data.valuesY, data.sizes, data.carriers);
  flightAirportScatter.setChartTitle("Flight Delay by Time");
  flightAirportScatter.setAxisTitles("Date + Flight Time", "Delay (min)");
}

// drawGraphScreen()
// Draws the bar chart screen.
// Shows:
// - page title
// - selected airport/date range information
// - airport dropdown
// - bar chart if available
// - fallback message if chart cannot be built
void drawGraphScreen() {

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);
  
  fill(40);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("Airport", 975, 115);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Flight Data - Bar Chart", width / 2, 75);

  if (flightDateChart != null) {
    flightDateChart.drawBarChart();
  } else {
    fill(80);
    textSize(18);
    text("Chart could not be built (no data loaded).", width / 2, height / 2);
  }

  drawAirportDropdown();
  drawNavBar();
}

// drawScatterScreen()
// Draws the scatter plot screen.
// Similar to the graph screen, but displays the scatter plot instead
// of the bar chart.
void drawScatterScreen() {

  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Flight Data - ScatterPlot", width / 2, 75);


  if (flightAirportScatter != null) {
    flightAirportScatter.drawScatterPlot();
  } else {
    fill(80);
    textSize(18);
    text("Scatter Plot could not be built (no data loaded).", width / 2, height / 2);
  }

  drawNavBar();
}

// initialiseFilterState()
// Sets up the filtering system after the data is loaded.
// It:
// - builds airport options
// - loads available dates
// - selects default filter values
// - disables sorting initially
// - applies the filters once to populate the results
void initialiseFilterState() {
  airportOptions = buildAirportOptions(0);
  dateOptions = getAvailableDateKeys();

  int defaultIndex = findStringIndex(airportOptions, defaultAirport);
  selectedAirportIndex = defaultIndex >= 0 ? defaultIndex : 0;
  graphAirportIndex = selectedAirportIndex;
  graphSelectedAirport = airportOptions[graphAirportIndex];

  if (dateOptions.length > 0) {
    selectedStartDateIndex = 0;
    selectedEndDateIndex = dateOptions.length - 1;
  }

  sortByLateness = false;
  applyActiveFilters();
}

// applyActiveFilters()
// Core filtering function of the project.
// It validates current filter indices, updates selected airport/date values,
// filters the flights list, optionally sorts by lateness,
// updates button labels, and rebuilds the chart.
void applyActiveFilters() {
  if (!dataLoaded) {
    filteredFlights.clear();
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
}

// resetFilters()
// Resets the filters back to their default state:
// - airport = ALL
// - date range = full available range
// - sorting = file order
// Then reapplies the filters.
void resetFilters() {
  selectedAirportIndex = 0;

  if (dateOptions.length > 0) {
    selectedStartDateIndex = 0;
    selectedEndDateIndex = dateOptions.length - 1;
  }

  sortByLateness = false;
  applyActiveFilters();
}

// shiftAirportSelection(int direction)
// Moves the airport selection left or right through the airport list.
// Wraps around when reaching the beginning or end of the list.
// Then reapplies the filters.
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

// shiftStartDate(int direction)
// Moves the selected start date backward or forward.
// Ensures that the start date never goes past the end date.
// Then reapplies the filters.
void shiftStartDate(int direction) {
  if (dateOptions.length == 0) return;

  selectedStartDateIndex = constrain(selectedStartDateIndex + direction, 0, dateOptions.length - 1);
  if (selectedStartDateIndex > selectedEndDateIndex) {
    selectedEndDateIndex = selectedStartDateIndex;
  }

  applyActiveFilters();
}

// shiftEndDate(int direction)
// Moves the selected end date backward or forward.
// Ensures that the end date never goes before the start date.
// Then reapplies the filters.
void shiftEndDate(int direction) {
  if (dateOptions.length == 0) return;

  selectedEndDateIndex = constrain(selectedEndDateIndex + direction, 0, dateOptions.length - 1);
  if (selectedEndDateIndex < selectedStartDateIndex) {
    selectedStartDateIndex = selectedEndDateIndex;
  }

  applyActiveFilters();
}

// drawSelectionCard(float x, float y, float w, float h, String label)
// Draws a small rounded rectangular UI card used to display
// the currently selected airport or date value.
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

// drawFlightResultsPanel()
// Draws the right-hand results area on the results screen.
// It shows:
// - current filter summary
// - loading/fallback messages if needed
// - the first visible matching flights
// - a note if there are more matching flights than shown
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

// formatFlightSummary(Flight flight)
// Converts a Flight object into a readable one-line summary
// for display in the results panel.
String formatFlightSummary(Flight flight) {
  return formatDateForChartLabel(flight.getDateKey()) + "   " +
         flight.getFlightCode() + "   " +
         flight.origin + " -> " + flight.dest + "   " +
         flight.getDelayLabel();
}

// getAirportDisplayLabel()
// Returns the airport label for the UI.
// If the selected airport is "ALL", it returns "All airports" instead.
String getAirportDisplayLabel() {
  return selectedAirport.equals("ALL") ? "All airports" : selectedAirport;
}

String getGraphAirportDisplayLabel() {
  return graphSelectedAirport.equals("ALL") ? "All airports" : graphSelectedAirport;
}

// getDateRangeLabel()
// Returns a readable label for the currently selected date range.
// If both dates are empty, it returns "All dates".
// If both dates are the same, it returns just one date.
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

// getSortDescription()
// Returns a short description of the current sort mode.
String getSortDescription() {
  return sortByLateness ? "Most late first" : "Dataset order";
}

// getChartTitle()
// Returns the title to use for the bar chart.
// If all airports are selected, it uses a generic title.
// Otherwise it includes the airport name.
String getChartTitle() {
  if (selectedAirport.equals("ALL")) {
    return "Flights per Date";
  }

  return selectedAirport + " Flights per Date";
}

String getGraphChartTitle() {
  if (graphSelectedAirport.equals("ALL")) {
    return "Flights per Date";
  }
  return graphSelectedAirport + " Flights per Date";
}

ArrayList<Flight> getGraphBarChartFlights() {
  if (graphSelectedAirport.equals("ALL")) {
    return flights;
  }

  ArrayList<Flight> graphFlights = new ArrayList<Flight>();
  for (Flight flight : flights) {
    if (flight.origin.equals(graphSelectedAirport) || flight.dest.equals(graphSelectedAirport)) {
      graphFlights.add(flight);
    }
  }
  return graphFlights;
}

// drawAirportDropdown()
// Draws the custom airport dropdown used on the graph screen.
// It draws:
// - the collapsed selection box
// - the arrow indicator
// - the open dropdown list if expanded
// - hover/selected styling
// - a small "Scroll for more" hint if needed
void drawAirportDropdown() {
  pushStyle();

  float cardX = graphAirportDropdownX;
  float cardY = graphAirportDropdownY;
  float cardW = graphAirportDropdownW;
  float cardH = graphAirportDropdownH;

  fill(250);
  stroke(graphAirportDropdownOpen ? color(70, 130, 200) : color(210));
  strokeWeight(graphAirportDropdownOpen ? 2 : 1.5);
  rect(cardX, cardY, cardW, cardH, 10);

  fill(40);
  textAlign(LEFT, CENTER);
  textSize(14);
  text(getGraphAirportDisplayLabel(), cardX + 12, cardY + cardH / 2);

  textAlign(CENTER, CENTER);
  textSize(12);
  text(graphAirportDropdownOpen ? "▲" : "▼", cardX + cardW - 16, cardY + cardH / 2 + 1);

  if (graphAirportDropdownOpen) {
    int visibleCount = getGraphAirportDropdownVisibleCount();
    int listH = visibleCount * graphAirportDropdownItemH;
    float listY = cardY + cardH + 6;

    noStroke();
    fill(0, 18);
    rect(cardX + 3, listY + 3, cardW, listH, 10);

    stroke(210);
    strokeWeight(1.5);
    fill(255);
    rect(cardX, listY, cardW, listH, 10);

    for (int i = 0; i < visibleCount; i++) {
      int optionIndex = graphAirportDropdownScroll + i;
      float itemY = listY + i * graphAirportDropdownItemH;
      boolean isHovered = mouseX >= cardX && mouseX <= cardX + cardW &&
                          mouseY >= itemY && mouseY <= itemY + graphAirportDropdownItemH;
      boolean isSelected = optionIndex == graphAirportIndex;

      if (isHovered || isSelected) {
        noStroke();
        fill(isSelected ? color(220, 232, 247) : color(240, 245, 250));
        rect(cardX + 2, itemY + 2, cardW - 4, graphAirportDropdownItemH - 4, 8);
      }

      fill(35);
      textAlign(LEFT, CENTER);
      textSize(13);
      text(getAirportOptionLabel(optionIndex), cardX + 12, itemY + graphAirportDropdownItemH / 2);
    }

    if (airportOptions.length > visibleCount) {
      fill(90);
      textAlign(CENTER, CENTER);
      textSize(11);
      text("Scroll for more", cardX + cardW / 2, listY + listH - 10);
    }
  }

  popStyle();
}

// handleGraphAirportDropdownClick(int mx, int my)
// Handles mouse clicks for the graph airport dropdown.
// It can:
// - open/close the dropdown
// - select an airport from the list
// - close the dropdown if the user clicks outside it
// Returns true if the click was handled by the dropdown.
boolean handleGraphAirportDropdownClick(int mx, int my) {
  float cardX = graphAirportDropdownX;
  float cardY = graphAirportDropdownY;
  float cardW = graphAirportDropdownW;
  float cardH = graphAirportDropdownH;

  boolean clickedCard = mx >= cardX && mx <= cardX + cardW &&
                        my >= cardY && my <= cardY + cardH;

  if (clickedCard) {
    graphAirportDropdownOpen = !graphAirportDropdownOpen;
    graphAirportDropdownScroll = constrain(graphAirportDropdownScroll, 0, max(0, airportOptions.length - getGraphAirportDropdownVisibleCount()));
    return true;
  }

  if (!graphAirportDropdownOpen) {
    return false;
  }

  int visibleCount = getGraphAirportDropdownVisibleCount();
  float listY = cardY + cardH + 6;
  float listH = visibleCount * graphAirportDropdownItemH;
  boolean clickedList = mx >= cardX && mx <= cardX + cardW &&
                        my >= listY && my <= listY + listH;

  if (clickedList) {
    int itemIndex = int((my - listY) / graphAirportDropdownItemH);
    int optionIndex = graphAirportDropdownScroll + itemIndex;

    if (optionIndex >= 0 && optionIndex < airportOptions.length) {
      graphAirportIndex = optionIndex;
      graphSelectedAirport = airportOptions[graphAirportIndex];
      graphAirportDropdownOpen = false;
      buildFlightDateChart();
    }
    return true;
  }

  graphAirportDropdownOpen = false;
  return false;
}

// getGraphAirportDropdownVisibleCount()
// Calculates how many dropdown items can be shown on screen at once,
// based on available space and the configured dropdown limit.
int getGraphAirportDropdownVisibleCount() {
  if (airportOptions.length == 0) return 0;

  int spaceBelow = height - (graphAirportDropdownY + graphAirportDropdownH + 16);
  int maxFromSpace = max(1, spaceBelow / graphAirportDropdownItemH);
  return min(airportOptions.length, min(graphAirportDropdownVisibleItems, maxFromSpace));
}

// getAirportOptionLabel(int index)
// Returns the airport label at a given index.
// Converts "ALL" into "All airports" for nicer UI text.
String getAirportOptionLabel(int index) {
  if (index < 0 || index >= airportOptions.length) return "";

  return airportOptions[index].equals("ALL") ? "All airports" : airportOptions[index];
}

// findStringIndex(String[] values, String target)
// Searches an array of strings and returns the index of the target string.
// Returns -1 if the target is not found.
int findStringIndex(String[] values, String target) {
  for (int i = 0; i < values.length; i++) {
    if (values[i].equals(target)) {
      return i;
    }
  }

  return -1;
}
