ArrayList<PVector> snake;
PVector food;

int cellSize = 20;
int cols;
int rows;

int dirX = 1;
int dirY = 0;

int snakeFrameCounter = 0;
int snakeSpeed = 8;

boolean snakeGameOver = false;
int snakeScore = 0;

// initSnakeGame()
// Initialises the Snake board dimensions and starts a fresh game.
// This is called once from setup().
void initSnakeGame() {
  cols = 30;
  rows = 30;
  resetSnakeGame();
}

// resetSnakeGame()
// Resets Snake to its starting state:
// - creates a new snake in the centre
// - resets direction
// - clears game over state
// - resets score
// - places new food
// Used both at startup and when restarting.
void resetSnakeGame() {
  snake = new ArrayList<PVector>();

  int startX = cols / 2;
  int startY = rows / 2;

  snake.add(new PVector(startX, startY));
  snake.add(new PVector(startX - 1, startY));
  snake.add(new PVector(startX - 2, startY));

  dirX = 1;
  dirY = 0;
  snakeGameOver = false;
  snakeScore = 0;
  snakeFrameCounter = 0;

  placeFood();
}

// placeFood()
// Randomly places food on the board.
// It keeps trying until it finds a position that is not already occupied
// by the snake body.
void placeFood() {
  boolean valid = false;

  while (!valid) {
    int fx = int(random(cols));
    int fy = int(random(rows));
    valid = true;

    for (int i = 0; i < snake.size(); i++) {
      if (snake.get(i).x == fx && snake.get(i).y == fy) {
        valid = false;
        break;
      }
    }

    if (valid) {
      food = new PVector(fx, fy);
    }
  }
}

// drawSnakeScreen()
// Draws the full Snake minigame screen:
// - dark background
// - title and instructions
// - score
// - back button
// - game board
// - game over message when needed
// It also updates the game every frame.
void drawSnakeScreen() {
  background(20);

  fill(255);
  textSize(30);
  text("Snake", width/2, 60);

  textSize(18);
  text("Use arrow keys to move", width/2, 95);
  text("Score: " + snakeScore, width/2, 125);

  drawNavBar();

  float boardSize = 600;
  float boardX = (width - boardSize) / 2;
  float boardY = 140;

  fill(35);
  stroke(80);
  strokeWeight(2);
  rect(boardX, boardY, boardSize, boardSize, 12);

  updateSnakeGame();

  drawSnakeBoard(boardX, boardY);

  if (snakeGameOver) {
    fill(255, 80, 80);
    textSize(28);
    text("Game Over", width/2, 770 - 80);

    fill(255);
    textSize(18);
    text("Press R to restart", width/2, 770 - 45);
  }
}

// updateSnakeGame()
// Handles the logic update of Snake.
// It:
// - waits according to snakeSpeed
// - computes the next head position
// - checks wall collision
// - checks self collision
// - moves the snake forward
// - grows the snake if food is eaten
// - updates the score
void updateSnakeGame() {
  if (snakeGameOver) {
    return;
  }

  snakeFrameCounter++;

  if (snakeFrameCounter < snakeSpeed) {
    return;
  }

  snakeFrameCounter = 0;

  PVector head = snake.get(0);
  int newX = int(head.x) + dirX;
  int newY = int(head.y) + dirY;

  if (newX < 0 || newX >= cols || newY < 0 || newY >= rows) {
    snakeGameOver = true;
    return;
  }

  for (int i = 0; i < snake.size(); i++) {
    if (int(snake.get(i).x) == newX && int(snake.get(i).y) == newY) {
      snakeGameOver = true;
      return;
    }
  }

  snake.add(0, new PVector(newX, newY));

  if (newX == int(food.x) && newY == int(food.y)) {
    snakeScore++;
    placeFood();
  } else {
    snake.remove(snake.size() - 1);
  }
}

// drawSnakeBoard(float boardX, float boardY)
// Draws the snake and food inside the board area.
// The head is drawn in a brighter green than the body.
// Food is drawn in red.
void drawSnakeBoard(float boardX, float boardY) {
  float actualCellSize = 600.0 / cols;

  noStroke();

  for (int i = 0; i < snake.size(); i++) {
    if (i == 0) {
      fill(0, 220, 120);
    } else {
      fill(0, 180, 100);
    }

    rect(
      boardX + snake.get(i).x * actualCellSize,
      boardY + snake.get(i).y * actualCellSize,
      actualCellSize,
      actualCellSize,
      4
    );
  }

  fill(220, 60, 60);
  rect(
    boardX + food.x * actualCellSize,
    boardY + food.y * actualCellSize,
    actualCellSize,
    actualCellSize,
    4
  );
}

// handleSnakeInput()
// Handles keyboard controls for Snake.
// Arrow keys change direction.
// R resets the game after losing or whenever the player wants.
void handleSnakeInput() {
  if (keyCode == UP && dirY != 1) {
    dirX = 0;
    dirY = -1;
  } else if (keyCode == DOWN && dirY != -1) {
    dirX = 0;
    dirY = 1;
  } else if (keyCode == LEFT && dirX != 1) {
    dirX = -1;
    dirY = 0;
  } else if (keyCode == RIGHT && dirX != -1) {
    dirX = 1;
    dirY = 0;
  } else if (key == 'r' || key == 'R') {
    resetSnakeGame();
  }
}
