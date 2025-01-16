class Enemy {

  // Enemy variables
  float position, speed;
  float enemyX = width;
  int initialDelay = 2000;
  int startTime;

  Enemy(float posTemp, float speedTemp) {
    position = posTemp;
    speed = speedTemp;
    startTime = millis();
  }
void move() {
    if (millis() - startTime > initialDelay) {
      enemyX = enemyX - speed;

      if (enemyX < 0) {
        enemyX = width;
        speed = random(4.5, 6.5);
        score--;
      }
   }
}
void display() {
    if (millis() - startTime > initialDelay) {
   
      image(alienImage, enemyX, position, 100, 100);
    }
  }
}
