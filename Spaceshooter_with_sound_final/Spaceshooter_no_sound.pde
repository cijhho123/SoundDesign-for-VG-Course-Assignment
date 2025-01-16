import ddf.minim.*;
Minim minim;
AudioPlayer btn_startButtonSound;
AudioPlayer btn_retryButtonSound;
AudioPlayer bgm_pauseSound;

AudioPlayer sfx_shootingSound;
AudioPlayer sfx_killingSound;
AudioPlayer sfx_gotHitSound1;
AudioPlayer sfx_gotHitSound2;

AudioPlayer bgm_menuSound;
AudioPlayer bgm_gameOverScreenSound;
AudioPlayer bgm_levelSound;

// Start menu
boolean gameStarted = false;
boolean cursorVisible = true;
boolean useFirstHitSound = true;

// Sprites
PImage shipImage, laserImage, alienImage, spaceImage, menuImage;
float bgX = 0;

// Player variables
float starshipY = 0;
float starshipX = 50;

// Shot variables
float shotX, shotY, shotVisible, shotStart;
boolean shooting = false;

// Enemies
Enemy[] enemies = new Enemy[5];
int enemiesDefeated = 0;

// Score
int score = 0;
int lives = 5;

// Collision
int collisionTime = -3000;

// Pause and game over
boolean isPaused = false;
boolean gameOverClicked = false;
int bestScore = 0;
int previousScore = 0;

void startScreen() {
  image(menuImage, 0, 0, width, height);
  fill(255);
  textSize(80);
  textAlign(CENTER, CENTER);
  text("Generic Space Shooter", width / 2, height / 4);

  rectMode(CENTER);
  fill(200, 170, 0);
  rect(width / 2, height / 2 + 50, 120, 50, 10);
  fill(255);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Play", width / 2, height / 2 + 50);

  // CONTROL
  textSize(18);
  textAlign(CENTER, BOTTOM);
  fill(255);
  text("CONTROLS", width / 2, height - 100);

  textSize(25);
  textAlign(CENTER, TOP);
  fill(255);
  text("Move - Mouse    /    Shoot - Space    /    Pause - P", width / 2, height - 75);
  

}


void audioSetup(){
  minim = new Minim(this);
  //buttons
  btn_startButtonSound = minim.loadFile("data/audio/start.wav"); 
  btn_retryButtonSound = minim.loadFile("data/audio/retry.wav");
  
  //sfx
  sfx_shootingSound =  minim.loadFile("data/audio/shooting.wav");
  sfx_killingSound = minim.loadFile("data/audio/killing.wav");
  sfx_gotHitSound1 = minim.loadFile("data/audio/gothit1.wav");  // First hit sound
  sfx_gotHitSound2 = minim.loadFile("data/audio/gothit2.wav");  // Second hit sound
  
  //bgm
  bgm_menuSound = minim.loadFile("data/audio/menu.wav");
  bgm_gameOverScreenSound = minim.loadFile("data/audio/gameOver.wav");
  bgm_levelSound = minim.loadFile("data/audio/level.wav");
  bgm_pauseSound = minim.loadFile("data/audio/pausesound.wav");
  bgm_menuSound.loop();
  
}
void setup() {
  size(960, 540);
  frameRate(60);
  noSmooth();
  rectMode(CENTER);
  
  audioSetup();
  // Load images
  shipImage = loadImage(dataPath("sprites/Ship.png"));
  laserImage = loadImage(dataPath("sprites/Laser.png"));
  alienImage = loadImage(dataPath("sprites/Alien.png"));
  spaceImage = loadImage(dataPath("sprites/GameBG.jpeg"));
  menuImage = loadImage(dataPath("sprites/MenuBG.png"));

  // Create enemies
  for (int i = 0; i < enemies.length; i++) {
    enemies[i] = new Enemy(random(60, 300), random(4.5, 6.5));
  }

}

void starship() {
  if (millis() - collisionTime < 1500) {
    if ((millis() / 100) % 2 == 0) {
      image(shipImage, starshipX, starshipY, 120, 60);
    }
  } else {
    image(shipImage, starshipX, starshipY, 120, 60);
  }

  starshipY = mouseY;
}


void shot() {
  fill(222, 0, 0, shotVisible);
  noStroke();

  if (!shooting) {
    shotStart = starshipY + 20;
    shotX = starshipX;
  }
  if (shooting) {
    shotY = shotStart;
    shotX = shotX + 60;
    image(laserImage, shotX, shotY, 70, 30);
  }
  
  if (keyPressed && key == ' ' && !sfx_shootingSound.isPlaying()){
      shooting = true;  
      sfx_shootingSound.rewind();
      sfx_shootingSound.play();
  }

  if (shotX > width) {
    shooting = false;
  }
}

void hit() {
    for (int i = 0; i < enemies.length; i++) {
    if (enemies[i].enemyX <= starshipX && enemies[i].enemyX >= starshipX - 80 && enemies[i].position >= starshipY - 40 && enemies[i].position <= starshipY + 40) {
      if (millis() - collisionTime > 1500) {
        lives--;
        // Play alternating hit sounds
        if (useFirstHitSound) {
          sfx_gotHitSound1.rewind();
          sfx_gotHitSound1.play();
        } else {
          sfx_gotHitSound2.rewind();
          sfx_gotHitSound2.play();
        }
        useFirstHitSound = !useFirstHitSound;  // Switch to the other sound for next hit
        collisionTime = millis();
        enemies[i].enemyX = -80;
      }
    }
  }

  if (lives == 0) {
    noLoop();
    if (!bgm_gameOverScreenSound.isPlaying()) {
      bgm_levelSound.close();      // Stop level background music
      bgm_gameOverScreenSound.loop();  // Play game-over background music
    }
    stroke(255, 255, 255);
    strokeWeight(5);
    fill(100, 0, 0, 75);
    rect(width / 2, height / 2 + 8, 600, 300);
    fill(255, 0, 0);
    textSize(120);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2);
     
    stroke(0,0,0);
    strokeWeight(3);
    fill(200, 170, 0);
    rect(width / 2, height / 2 + 200, 120, 50, 10);
    fill(0);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("RETRY?", width / 2, height / 2 + 200);
    
    cursorVisible = true;
    
    bgm_gameOverScreenSound.loop();
    cursor();


  }
}

void kill() {
  for (int i = 0; i < enemies.length; i++) {
    // Only check for kills if we're actually shooting and the enemy is on screen
    if (shooting && enemies[i].enemyX > -80 && enemies[i].enemyX < width + 80) {
      if (shotX >= enemies[i].enemyX && shotX <= enemies[i].enemyX + 80 && 
          shotY >= enemies[i].position - 50 && shotY <= enemies[i].position + 50) {
        enemies[i].enemyX = width + 80;  // Reset enemy position
        enemies[i].position = random(60, 300);
        enemies[i].speed = random(4.5, 6.5);
        enemies[i].startTime = millis();
        shooting = false;
        score++;
        enemiesDefeated++;
        // Play the killing sound
        sfx_killingSound.rewind();
        sfx_killingSound.play();     
      }
    }
  }
}

void keyPressed() {
  
  if (key == 'p') {
    isPaused = !isPaused;
    if (isPaused) {
      // Stop the level music
      bgm_levelSound.pause();
      
      // Start the pause sound
      bgm_pauseSound.rewind();
      bgm_pauseSound.loop();
      fill(255);
      textSize(80);
      textAlign(CENTER, CENTER);
      text("Pause", width / 2, height / 2);
      noLoop();
    } 
    else {
       // Stop the pause sound
      bgm_pauseSound.pause();
      
      // Resume the level music
      bgm_levelSound.loop();
      loop();
    }
  }
}



void resetGame() {
  // Play retry button sound
  btn_retryButtonSound.rewind();
  btn_retryButtonSound.play();
  
  // Store previous score
  previousScore = enemiesDefeated;
  
  // Reset game state
  lives = 5;
  score = 0;
  bgX = 0;
  collisionTime = -3000;
  gameStarted = false;
  cursorVisible = true;
  
  // Reset audio states
  bgm_gameOverScreenSound.close();
  bgm_levelSound.close();
  
  // Reload all music files to ensure they're fresh
  bgm_menuSound = minim.loadFile("data/audio/menu.wav");
  bgm_levelSound = minim.loadFile("data/audio/level.wav");
  bgm_gameOverScreenSound = minim.loadFile("data/audio/gameOver.wav");
  
  // Start playing menu music
  bgm_menuSound.loop();
  
  // Reset enemies
  for (int i = 0; i < enemies.length; i++) {
    enemies[i] = new Enemy(random(60, 300), random(4.5, 6.5));
  }
  
  enemiesDefeated = 0;
  gameOverClicked = false;
  
  // Update best score if necessary
  if (previousScore > bestScore) {
    bestScore = previousScore;
  }
  
  loop();
}


void resetEnemies() {
  for (int i = 0; i < enemies.length; i++) {
    enemies[i].enemyX = width;
    enemies[i].position = random(60, 300);
    enemies[i].speed = random(4.5, 6.5);
    enemies[i].startTime = millis();
  }
}

void scoreCount(){
  if (lives > 0) {
      
      fill(255, 255, 255);
      textSize(30);
      textAlign(LEFT, TOP);
      text("Life: " + lives, 20, 20);

      fill(255);
      textSize(30);
      textAlign(RIGHT, TOP);
      text("Score: " + score, width - 20, 20);
    } 
    else {
      fill(255);
      textSize(25);
      textAlign(CENTER, TOP);
      text("Your Score: " + score, width / 2, 345);
      
      if (score > bestScore) {
        textSize(25);
        text("NEW RECORD: " + score, width / 2, 385);
      } else {
        textSize(25);
        text("Best Score: " + bestScore, width / 2, 385);
      }
    }
  
}


void mousePressed() {
  if (!gameStarted && mouseX > width / 2 - 120 && mouseX < width / 2 + 120 && mouseY > height / 2 && mouseY < height / 2 + 180) {
    btn_startButtonSound.rewind();  
    btn_startButtonSound.play();   
    gameStarted = true;
    cursorVisible = false;
    noCursor();
    resetEnemies();  
    bgm_menuSound.close();          
    bgm_levelSound.loop(); 
  }
  
  else if (lives <= 0 && mouseX > width / 2 - 60 && mouseX < width / 2 + 60 && mouseY > height / 2 + 150 && mouseY < height / 2 + 200) {
    resetGame();
    gameOverClicked = true;
  } else {
    gameOverClicked = false;
  }
}


void draw() {
  
  image(spaceImage, bgX, 0, width, height);
  
  if (!gameStarted) {
    startScreen();
  } else {
    bgX -= 4;

    if (bgX <= -width) {
      bgX = 0;
    }

   image(spaceImage, bgX + width, 0, width, height);

    starship();
    shot();
    kill();

    for (int i = 0; i < enemies.length; i++) {
      enemies[i].move();
      enemies[i].display();
    }

    hit();
    scoreCount();
    
  }
}
