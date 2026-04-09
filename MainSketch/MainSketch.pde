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

// File selector state
String[] availableFiles = { "flights2k.csv", "flights10k.csv", "flights100k.csv", "flights_full.csv" };
String[] fileLabels = { "2,000 flights", "10,000 flights", "100,000 flights", "Full dataset" };
int selectedFileIndex = 0;
String currentFileName = "flights2k.csv";

// Home screen animation
float planeX = -80;
float cloudOffset = 0;


BarChart flightDateChart;
ScatterPlot flightAirportScatter;
RangeSlider scatterDateSlider;
float[] scatterSliderValues = new float[0];
String[] scatterSliderDateKeys = new String[0];
int scatterSliderStartIndex = 0;
int scatterSliderEndIndex = 0;

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

  startButton = new Button(540, 500, 300, 55, "Start Exploring");
  infoButton = new Button(540, 570, 300, 55, "Group Info");
  quitButton = new Button(540, 640, 300, 55, "Exit");
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
  scatterDateSlider = new RangeSlider(120, 708, 760);

  initSnakeGame();
  loadFlightData("flights2k.csv");
  initialiseFilterState();
  buildFlightDateChart();
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
    } else {
      // file selector card clicks
      float panelX = 40;
      float panelY = 155;
      float panelW = 280;
      float cardStartY = panelY + 72;
      for (int i = 0; i < availableFiles.length; i++) {
        float cardY = cardStartY + i * 68;
        if (mouseX >= panelX + 16 && mouseX <= panelX + panelW - 16 &&
            mouseY >= cardY && mouseY <= cardY + 56) {
          if (i != selectedFileIndex) {
            reloadDataWithFile(i);
          }
          break;
        }
      }
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
    if (scatterDateSlider != null && scatterDateSlider.handlePressed(mouseX, mouseY)) {
      applyScatterDateSliderSelection();
    } else if (flightAirportScatter != null) {
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

void mouseDragged() {
  if (currentScreen == 5 && scatterDateSlider != null && scatterDateSlider.handleDragged(mouseX)) {
    applyScatterDateSliderSelection();
  }
}

void mouseReleased() {
  if (scatterDateSlider != null) {
    scatterDateSlider.handleReleased();
  }
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

  // --- animated background ---
  background(20, 32, 58);

  // subtle gradient overlay
  noStroke();
  for (int i = 0; i < height; i++) {
    float t = map(i, 0, height, 0, 1);
    fill(lerpColor(color(20, 32, 58), color(35, 60, 100), t), 255);
    rect(0, i, width, 1);
  }

  // animated radar circles (bottom-right)
  drawRadarPulse(width - 160, height - 140);

  // floating clouds
  cloudOffset += 0.15;
  drawCloud(100 + (cloudOffset * 0.5) % (width + 200) - 100, 130, 0.7);
  drawCloud(500 + (cloudOffset * 0.3) % (width + 200) - 100, 85, 0.5);
  drawCloud(850 + (cloudOffset * 0.4) % (width + 200) - 100, 180, 0.6);

  // animated airplane across the top
  planeX += 1.2;
  if (planeX > width + 100) planeX = -100;
  drawAirplaneIcon(planeX, 60, 1.0);

  // --- header banner ---
  noStroke();
  fill(15, 28, 52, 200);
  rect(0, 0, width, 120, 0, 0, 0, 0);

  // header glow line
  for (int i = 0; i < 4; i++) {
    fill(80, 170, 255, 60 - i * 15);
    rect(0, 120 - i, width, 1);
  }

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(34);
  text("Flight Data Visualisation", width / 2, 50);

  fill(160, 200, 255);
  textSize(15);
  text("CSU11013 — Group 39 Project", width / 2, 86);

  // === LEFT PANEL — file selector ===
  float panelX = 40;
  float panelY = 155;
  float panelW = 280;
  float panelH = 560;

  // panel shadow
  noStroke();
  fill(0, 30);
  rect(panelX + 4, panelY + 4, panelW, panelH, 16);

  // panel background
  fill(255, 245);
  stroke(180, 210, 240);
  strokeWeight(1.5);
  rect(panelX, panelY, panelW, panelH, 16);

  // panel header
  noStroke();
  fill(30, 55, 95);
  rect(panelX, panelY, panelW, 52, 16, 16, 0, 0);

  fill(255);
  textSize(17);
  textAlign(CENTER, CENTER);
  text("Select Dataset", panelX + panelW / 2, panelY + 26);

  // file icon
  drawFileIcon(panelX + 24, panelY + 15, 0.55);

  // file cards
  float cardStartY = panelY + 72;
  for (int i = 0; i < availableFiles.length; i++) {
    float cardY = cardStartY + i * 68;
    boolean isSelected = (i == selectedFileIndex);
    boolean isHovered = mouseX >= panelX + 16 && mouseX <= panelX + panelW - 16 &&
                        mouseY >= cardY && mouseY <= cardY + 56;

    // card shadow
    if (isSelected) {
      noStroke();
      fill(50, 100, 180, 25);
      rect(panelX + 18, cardY + 3, panelW - 34, 56, 12);
    }

    // card background
    if (isSelected) {
      fill(220, 235, 255);
      stroke(60, 120, 200);
      strokeWeight(2);
    } else if (isHovered) {
      fill(240, 246, 255);
      stroke(150, 180, 220);
      strokeWeight(1.5);
    } else {
      fill(248, 250, 255);
      stroke(210, 220, 235);
      strokeWeight(1);
    }
    rect(panelX + 16, cardY, panelW - 32, 56, 12);

    // radio circle
    float radioX = panelX + 38;
    float radioY = cardY + 28;
    noFill();
    stroke(isSelected ? color(50, 100, 180) : color(170));
    strokeWeight(2);
    ellipse(radioX, radioY, 16, 16);
    if (isSelected) {
      noStroke();
      fill(50, 100, 180);
      ellipse(radioX, radioY, 9, 9);
    }

    // file name
    textAlign(LEFT, CENTER);
    fill(isSelected ? color(30, 60, 110) : color(50));
    textSize(14);
    text(availableFiles[i], panelX + 54, cardY + 18);

    // file description
    fill(isSelected ? color(50, 90, 150) : color(120));
    textSize(11);
    text(fileLabels[i], panelX + 54, cardY + 38);
  }

  // current status
  float statusY = cardStartY + availableFiles.length * 68 + 12;
  noStroke();
  fill(235, 245, 255);
  rect(panelX + 16, statusY, panelW - 32, 52, 10);

  fill(50, 90, 140);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("Currently loaded:", panelX + panelW / 2, statusY + 16);
  fill(30, 65, 120);
  textSize(14);
  text(currentFileName, panelX + panelW / 2, statusY + 36);

  // flight stats mini display
  float statsY = statusY + 68;
  fill(80, 120, 170);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(flights.size() + " flights loaded", panelX + panelW / 2, statsY);

  if (dataLoaded) {
    fill(40, 160, 90);
    ellipse(panelX + panelW / 2 - 58, statsY, 8, 8);
  }

  // === RIGHT PANEL — welcome + buttons ===
  float rightX = 360;
  float rightY = 155;
  float rightW = 800;
  float rightH = 560;

  // panel shadow
  noStroke();
  fill(0, 25);
  rect(rightX + 4, rightY + 4, rightW, rightH, 16);

  // panel background
  fill(255, 240);
  stroke(180, 210, 240);
  strokeWeight(1.5);
  rect(rightX, rightY, rightW, rightH, 16);

  // decorative header stripe
  noStroke();
  fill(30, 55, 95, 15);
  rect(rightX, rightY, rightW, 80, 16, 16, 0, 0);

  // globe icon area
  drawGlobeIcon(rightX + rightW / 2, rightY + 115, 38);

  // welcome text
  fill(30, 50, 85);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Welcome", rightX + rightW / 2, rightY + 180);

  fill(80, 100, 130);
  textSize(15);
  text("Explore and visualise US domestic flight data.", rightX + rightW / 2, rightY + 220);
  text("Filter by airport, date range, and view interactive charts.", rightX + rightW / 2, rightY + 244);

  // decorative separator line
  stroke(180, 210, 240);
  strokeWeight(1);
  line(rightX + 120, rightY + 275, rightX + rightW - 120, rightY + 275);

  // draw small airplane on separator
  noStroke();
  fill(80, 170, 255);
  ellipse(rightX + rightW / 2, rightY + 275, 8, 8);

  // buttons (repositioned to right panel)
  float btnX = rightX + rightW / 2 - 150;
  startButton.x = btnX;
  startButton.y = rightY + 305;
  infoButton.x = btnX;
  infoButton.y = rightY + 385;
  quitButton.x = btnX;
  quitButton.y = rightY + 465;

  startButton.display();
  infoButton.display();
  quitButton.display();

  // bottom info
  fill(140, 165, 200);
  textSize(11);
  textAlign(CENTER, CENTER);
  text("Select a dataset on the left, then press Start Exploring", rightX + rightW / 2, rightY + rightH - 22);
}

// --- Home screen decorative drawing functions ---

void drawAirplaneIcon(float cx, float cy, float s) {
  pushMatrix();
  translate(cx, cy);
  scale(s);
  noStroke();

  // fuselage
  fill(200, 220, 255, 190);
  beginShape();
  vertex(34, 0);
  vertex(20, -3);
  vertex(-8, -4);
  vertex(-30, -3);
  vertex(-34, 0);
  vertex(-30, 3);
  vertex(-8, 4);
  vertex(20, 3);
  endShape(CLOSE);

  // main wings — wide swept-back shape
  fill(170, 200, 245, 175);
  beginShape();
  vertex(8, -4);
  vertex(2, -6);
  vertex(-12, -24);
  vertex(-6, -24);
  vertex(0, -18);
  vertex(4, -10);
  vertex(12, -3);
  endShape(CLOSE);
  beginShape();
  vertex(8, 4);
  vertex(2, 6);
  vertex(-12, 24);
  vertex(-6, 24);
  vertex(0, 18);
  vertex(4, 10);
  vertex(12, 3);
  endShape(CLOSE);

  // tail fins
  fill(145, 180, 230, 155);
  beginShape();
  vertex(-26, -2);
  vertex(-30, -12);
  vertex(-24, -12);
  vertex(-22, -3);
  endShape(CLOSE);
  beginShape();
  vertex(-26, 2);
  vertex(-30, 12);
  vertex(-24, 12);
  vertex(-22, 3);
  endShape(CLOSE);

  // cockpit highlight
  fill(230, 240, 255, 120);
  ellipse(26, 0, 8, 4);

  popMatrix();
}

void drawCloud(float cx, float cy, float s) {
  pushMatrix();
  translate(cx, cy);
  scale(s);
  noStroke();
  fill(255, 30);
  ellipse(0, 0, 80, 40);
  ellipse(-25, -8, 50, 30);
  ellipse(25, -5, 60, 35);
  ellipse(10, 5, 50, 25);
  popMatrix();
}

void drawRadarPulse(float cx, float cy) {
  noFill();
  for (int ring = 0; ring < 4; ring++) {
    float radius = 30 + ring * 35 + ((frameCount + ring * 20) % 80);
    float alpha = map((frameCount + ring * 20) % 80, 0, 80, 50, 0);
    stroke(80, 170, 255, alpha);
    strokeWeight(1.2);
    ellipse(cx, cy, radius * 2, radius * 2);
  }

  // center dot
  noStroke();
  fill(80, 170, 255, 100);
  ellipse(cx, cy, 8, 8);
}

void drawFlightRoutes() {
  // draw several curved dashed routes
  stroke(80, 140, 220, 30);
  strokeWeight(1.2);
  noFill();
  drawDashedArc(150, height - 60, width - 200, 200, 20);
  drawDashedArc(250, height - 40, width - 350, 250, 16);
}

void drawDashedArc(float x1, float y1, float x2, float y2, int segments) {
  float midX = (x1 + x2) / 2;
  float midY = min(y1, y2) - abs(x2 - x1) * 0.15;

  for (int i = 0; i < segments; i += 2) {
    float t0 = (float) i / segments;
    float t1 = (float) (i + 1) / segments;

    float ax = bezierPoint(x1, midX - 50, midX + 50, x2, t0);
    float ay = bezierPoint(y1, midY, midY, y2, t0);
    float bx = bezierPoint(x1, midX - 50, midX + 50, x2, t1);
    float by = bezierPoint(y1, midY, midY, y2, t1);

    line(ax, ay, bx, by);
  }
}

void drawGlobeIcon(float cx, float cy, float r) {
  pushStyle();
  noFill();
  stroke(80, 140, 220, 60);
  strokeWeight(1.5);
  ellipse(cx, cy, r * 2, r * 2);

  // longitude lines
  ellipse(cx, cy, r, r * 2);
  ellipse(cx, cy, r * 1.5, r * 2);

  // latitude lines
  line(cx - r, cy, cx + r, cy);
  line(cx - r * 0.85, cy - r * 0.5, cx + r * 0.85, cy - r * 0.5);
  line(cx - r * 0.85, cy + r * 0.5, cx + r * 0.85, cy + r * 0.5);
  popStyle();
}

void drawFileIcon(float x, float y, float s) {
  pushMatrix();
  translate(x, y);
  scale(s);
  noStroke();
  fill(255, 180);
  rect(0, 0, 28, 36, 3);
  fill(200, 220, 255);
  rect(4, 10, 20, 2);
  rect(4, 16, 16, 2);
  rect(4, 22, 18, 2);

  // fold corner
  fill(160, 190, 230);
  beginShape();
  vertex(18, 0);
  vertex(28, 10);
  vertex(18, 10);
  endShape(CLOSE);
  popMatrix();
}

void reloadDataWithFile(int fileIndex) {
  selectedFileIndex = fileIndex;
  currentFileName = availableFiles[fileIndex];
  loadFlightData(currentFileName);
  initialiseFilterState();
  buildFlightDateChart();
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
  String[] visibleCarriers = flightAirportScatter == null ? new String[0] : flightAirportScatter.getVisibleCarriers();
  ScatterPlotData data = getScatterPlotData(getScatterPlotFlights());
  flightAirportScatter = new ScatterPlot(110, 660, 820, 480, data.valuesX, data.valuesY, data.sizes, data.carriers);
  flightAirportScatter.setChartTitle("Flight Delay by Time");
  flightAirportScatter.setAxisTitles("Date + Flight Time", "Delay (min)");
  flightAirportScatter.setVisibleCarriers(visibleCarriers);
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

  if (scatterDateSlider != null) {
    scatterDateSlider.draw(
      "Scatter date/time range",
      getScatterSliderRangeLabel(),
      getScatterSliderEdgeLabel(scatterSliderStartIndex),
      getScatterSliderEdgeLabel(scatterSliderEndIndex),
      scatterSliderValues.length > 1
    );
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
  initialiseScatterFilterState();
  buildFlightScatterPlot();
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

void initialiseScatterFilterState() {
  scatterSliderDateKeys = getDateKeysFromFlights(flights);
  scatterSliderValues = getScatterSliderValues(flights);
  scatterSliderStartIndex = 0;
  scatterSliderEndIndex = max(0, scatterSliderValues.length - 1);
  syncScatterDateSlider();
}

void syncScatterDateSlider() {
  if (scatterDateSlider == null) return;

  int maxIndex = max(0, scatterSliderValues.length - 1);
  scatterDateSlider.setBounds(0, maxIndex);

  if (scatterSliderValues.length == 0) {
    scatterDateSlider.setValues(0, 0);
  } else {
    scatterDateSlider.setValues(scatterSliderStartIndex, scatterSliderEndIndex);
  }
}

void applyScatterDateSliderSelection() {
  if (scatterDateSlider == null || scatterSliderValues.length == 0) return;

  scatterSliderStartIndex = scatterDateSlider.getStartIndex();
  scatterSliderEndIndex = scatterDateSlider.getEndIndex();
  buildFlightScatterPlot();
}

String getScatterSliderEdgeLabel(int index) {
  if (scatterSliderValues.length == 0) return "";

  int safeIndex = constrain(index, 0, scatterSliderValues.length - 1);
  return formatScatterSliderValue(scatterSliderValues[safeIndex]);
}

String getScatterSliderRangeLabel() {
  if (scatterSliderValues.length == 0) {
    return "No points available";
  }

  String startLabel = getScatterSliderEdgeLabel(scatterSliderStartIndex);
  String endLabel = getScatterSliderEdgeLabel(scatterSliderEndIndex);
  if (startLabel.equals(endLabel)) return startLabel;
  return startLabel + " - " + endLabel;
}

String formatScatterSliderValue(float value) {
  if (scatterSliderDateKeys.length == 0) {
    return "N/A";
  }

  int day = floor(value);
  int dayIndex = constrain(day - 1, 0, scatterSliderDateKeys.length - 1);
  int mins = round((value - day) * 1440.0);

  if (mins >= 1440) {
    mins = 0;
    dayIndex = min(dayIndex + 1, scatterSliderDateKeys.length - 1);
  }

  return formatDateForUi(scatterSliderDateKeys[dayIndex]) + " " +
         nf(mins / 60, 2) + ":" + nf(mins % 60, 2);
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

ArrayList<Flight> getScatterPlotFlights() {
  if (scatterSliderValues.length == 0) {
    return new ArrayList<Flight>();
  }

  float startX = scatterSliderValues[constrain(scatterSliderStartIndex, 0, scatterSliderValues.length - 1)];
  float endX = scatterSliderValues[constrain(scatterSliderEndIndex, 0, scatterSliderValues.length - 1)];
  return getFlightsInScatterRange(flights, startX, endX);
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
