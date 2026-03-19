int currentScreen = 0; // 0 = home, 1 = results, 2 = info, 3 = snake, 4 = graph

Button startButton;
Button infoButton;
Button quitButton;
Button backButton;
Button snakeButton;
Button graphButton;

boolean clickedAlessandro = false;
boolean clickedMusa = false;
boolean clickedAlex = false;
boolean clickedElijas = false;
boolean snakeUnlocked = false;

PFont mainFont;

ArrayList<Flight> flights = new ArrayList<Flight>();
ArrayList<Flight> filteredFlights = new ArrayList<Flight>();

String selectedAirport = "JFK";   // sample default for Week 8 demo
String startDate = "20220101";    // sample date range
String endDate   = "20220131";

boolean dataLoaded = false;
String loadMessage = "Data not loaded yet.";

void setup() {
  size(1200, 800);
  smooth(8);

  mainFont = createFont("Arial", 20, true);
  textFont(mainFont);

  textAlign(CENTER, CENTER);
  rectMode(CORNER);
  
  startButton = new Button(width/2 - 150, 320, 300, 60, "Start Exploring");
  infoButton  = new Button(width/2 - 150, 410, 300, 60, "Group Info");
  quitButton  = new Button(width/2 - 150, 500, 300, 60, "Exit");
  backButton  = new Button(40, 40, 160, 50, "Back to Home");
  graphButton = new Button(1000, 40, 160, 50, "See Graphs");
  snakeButton = new Button(width/2 - 120, 590, 240, 55, "Play Snake");

  initSnakeGame();
  loadFlightData("flights2k.csv");
  filterFlightsByAirport(selectedAirport);
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
  }else if (currentScreen == 4) {
    //drawGraphScreen();
  }
}

void drawResultsScreen() {
  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 100);

  fill(255);
  textSize(32);
  text("Results Screen", width/2, 50);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(80, 150, 250, 500, 20);
  rect(370, 150, 750, 500, 20);

  fill(40);
  textSize(22);
  text("Controls", 205, 190);

  textSize(15);
  text("Loaded: " + dataLoaded, 205, 235);
  text("Airport filter: " + selectedAirport, 205, 270);
  text("Flights loaded: " + flights.size(), 205, 305);
  text("Flights shown: " + filteredFlights.size(), 205, 340);

  textSize(13);
  text("Week 8 demo:", 205, 390);
  text("• CSV file read into Flight objects", 205, 420);
  text("• Airport/date/lateness query outline", 205, 445);
  text("• Results rendered on screen", 205, 470);

  fill(40);
  textSize(22);
  text("Flight Data", 745, 190);

  textSize(14);
  if (!dataLoaded) {
    text(loadMessage, 745, 240);
  } else if (filteredFlights.size() == 0) {
    text("No flights match current filter.", 745, 240);
  } else {
    text("Showing first 10 matching flights", 745, 230);

    float startY = 270;
    for (int i = 0; i < min(10, filteredFlights.size()); i++) {
      Flight f = filteredFlights.get(i);

      String line = f.flightDate + " | " +
                    f.getFlightCode() + " | " +
                    f.origin + " -> " + f.dest +
                    " | Delay: " + f.getDepartureDelay();

      text(line, 745, startY + i * 28);
    }
  }

  backButton.display();
  graphButton.display();
}

void drawInfoScreen() {
  background(245);

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 120);

  fill(255);
  textSize(34);
  text("Group Information", width/2, 60);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(width/2 - 350, 170, 700, 470, 20);

  fill(40);
  textSize(28);
  text("Group 39", width/2, 230);

  textSize(22);
  text("Team Members", width/2, 290);

  drawMemberName("Alessandro Caradonna", width/2, 350, clickedAlessandro);
  drawMemberName("Musa Irfan", width/2, 390, clickedMusa);
  drawMemberName("Alex Grigorita", width/2, 430, clickedAlex);
  drawMemberName("Elijas Sohlstrom", width/2, 470, clickedElijas);

  textSize(16);
  fill(80);
  text("There is a secret on this page, try to find it!", width/2, 530);
  text("CSU11013 Group Project - Flight Data Visualisation", width/2, 560);

  if (snakeUnlocked) {
    fill(20, 120, 60);
    textSize(18);
    text("Secret unlocked.", width/2, 600);
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
    }else if (graphButton.isMouseOver()){
      currentScreen = 4;
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
  }

  updateSnakeUnlock();
}

void keyPressed() {
  if (currentScreen == 3) {
    handleSnakeInput();
  }
}

void checkNameClicks() {
  if (isMouseOverText(width/2, 350, 280, 30)) {
    clickedAlessandro = true;
  } else if (isMouseOverText(width/2, 390, 180, 30)) {
    clickedMusa = true;
  } else if (isMouseOverText(width/2, 430, 200, 30)) {
    clickedAlex = true;
  } else if (isMouseOverText(width/2, 470, 220, 30)) {
    clickedElijas = true;
  }
}

void updateSnakeUnlock() {
  if (clickedAlessandro && clickedMusa && clickedAlex && clickedElijas) {
    snakeUnlocked = true;
  }
}

boolean isMouseOverText(float centerX, float centerY, float boxW, float boxH) {
  return mouseX >= centerX - boxW/2 &&
         mouseX <= centerX + boxW/2 &&
         mouseY >= centerY - boxH/2 &&
         mouseY <= centerY + boxH/2;
}

void drawHomeScreen() {

  fill(30, 60, 100);
  noStroke();
  rect(0, 0, width, 120);

  fill(255);
  textSize(36);
  text("Flight Data Visualisation", width/2, 50);

  textSize(18);
  text("CSU11013 Group Project", width/2, 90);

  fill(255);
  stroke(180);
  strokeWeight(2);
  rect(width/2 - 350, 180, 700, 450, 20);

  fill(40);
  textSize(28);
  text("Welcome", width/2, 230);

  textSize(16);
  text("Use this application to explore and visualise flight data.", width/2, 270);
  text("Choose an option below to begin.", width/2, 300);

  startButton.display();
  infoButton.display();
  quitButton.display();
}
