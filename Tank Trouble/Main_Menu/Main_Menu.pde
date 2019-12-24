/*
*TankTrouble
*ICS3U-01 - Mrs. Manoil
*Shaurya Ganguly
*June/13/ 2019

INSTRUCTIONS:
Tank Trouble is a two player game with the objective to navigate your way through the maze to try and outsmart your opponent.
Once you have gained a valuable position, you can try and shoot down your opponent, but be careful, they'll be doing the same!
It is a game that requires skill, precision, and quick reaction times....are you up to the task?

Use the D-Pad to move, the joystick to aim and the shoulder buttons to shoot.
The Z butoons are to switch between on-screen options, and press the home button to confirm your entry.
You can always pause the game by pressing + or - 
*/

//import sound files to play music and sound properties
import processing.sound.*;
SoundFile main; //main theme
SoundFile over; //game over theme
SoundFile pop; //bullet collision with wall
SoundFile explosion; //bullet collision with player
SoundFile sword; //start button sound effect
PImage volumeOn, volumeOff; //mute buttons
boolean sound = true;

//score properties
PImage p1Score, p2Score; //player 1 and 2 profile picture
int score1 = 0, score2 = 0; //actual score of players
PFont font; //score font

//game button properties
import static javax.swing.JOptionPane.*; //pop-up window library
boolean flag = true; //flag to prevent repeated pop-ups
boolean spawn = false;
//button dimensions
int buttonX = width + 80;
int buttonY = 440;
PImage title, play, button; //title image and how to play

//player properties
Player player; //declare player 1 object
Player2 player2; //declare player 2 object

//cursor properties
Cursor cursor; //declare cursor object
PVector globalMouse, globalMouse2;

//bullet properties
ArrayList <Bullet> bullets = new ArrayList <Bullet> (); //create bullet ArrayList object
float maxSpeed = 3; //speed of bullets
boolean shoot = false; //checks weather the player is shooting or not

//wall properties
Wall wall; //declare wall object

//game over properties
boolean gameOver = false; //checks if game is over or not
EndGame endGame; //create endGame object
PImage death; //gmae over screen

//pause screen properties
boolean paused; //checks if game is paused
PImage pause; //pause screen image
int pausePressed = 1; //pause screen options

//main menu
void setup() {
  size(800, 600); //grid size of application
  
  //creates smooth, fluid experience
  smooth();
  frameRate(60);
  noStroke();
  
  //draws the background
  endGame = new EndGame(); //create newEngGame object
  title = loadImage("title.jpg"); //load in title screen image
  play = loadImage("play.png"); //load in instructions
  button = loadImage("button.png"); //load in start game button
  
  //creates player 1 from the Player class with its corresponding properties
  player = new Player((int)random(20, 700), (int)random(100, 500));
  p1Score = loadImage("player1Score.png");//player 1 score
  
  //creates player 2 from the Player2 class with its corresponding properties
  player2 = new Player2 ((int)random(20, 700), (int)random(100, 500));
  p2Score = loadImage("player2Score.png"); //player 2 score
  
  //create a new font
  font = createFont("scoreFont.ttf", 32);
  textFont(font);
  
  //load in game over scree image
  death = loadImage("gameover.png");
  
  //creates a wall from the Wall class with its corresponding properties
  wall = new Wall();
  
  //load in pause screen image
  pause = loadImage("pause.jpg");    
  
  //creates a new cursor for player 2 from the Cursor class
  cursor = new Cursor (300, 300);
  
  //plays background sound indefinitely
  main = new SoundFile(this, "music.wav");
  main.loop();
  main.amp(0.5);
  
  //plays game over sound
  over = new SoundFile(this, "gameover.wav");
  over.amp(0.5);
  
  //plays bullet collision sound
  pop = new SoundFile(this, "pop.wav"); //wall collision
  pop.amp(0.5);
  explosion = new SoundFile(this, "explosion.wav"); //player collision
  explosion.amp(0.5);
  
  //start game sound effect
  sword = new SoundFile(this, "sword.wav");
  sword.amp(0.5);
  
  //load in buttons for muting sound
  volumeOn = loadImage("volon.png");
  volumeOff = loadImage("voloff.png");
}

void draw() {
  
  //draws the button to start the game
  drawButton();
   
  //spawns the instructions if player needs them in a dialog box
  instructions();
     
  //code that's run after the start game button is pressed
  if (spawn == true && gameOver == false) {
    flag = false; //prevents the instructions from popping up during a game
    background(#FFFFFF); //sets the background to white each loop so cloning of the player doesn't happen
    player.drawPlayer(); //spawns the player
    player.movePlayer(); //calls the movement method if the player wants to move
    player2.drawPlayer2(); //spawns the second player
    player2.movePlayer2(); //calls the movement method if the player 2 wants to move
    noCursor(); //hides the cursor allowing players to aim with greater precision
    strokeWeight(2);
    stroke(0);
    
    //keep track of the score at the top of the window
    score();

    //creates an aiming tool for player 1
    PVector mouse = new PVector(mouseX, mouseY); //places the mouse coordinates into a PVector to be used later to calculate bullet firing
    //cursor properties
    fill(#FC7F00);
    ellipse(mouse.x, mouse.y, 8, 8);
    globalMouse = mouse;
    
    cursor.drawCursor(); //creates an aiming tool for player 2
    cursor.moveCursor(); //call this method if the player 2 wants their cursor to move
     
    //spawns the bullets each time the mouse is pressed
    shootBullets1();
    
    //spawns the bullets each time the 'm' is pressed
    shootBullets2();
    
    //updates the bullets location and displays them
    for (Bullet b : bullets) {
      b.update();
      b.display();
    } 
    
    //spawns the borders of the map
    wall.makeWall(20, 60, width - 20, 60);
    wall.makeWall(20, 60, 20, height - 20);
    wall.makeWall(width - 20, 60, width - 20, height - 20);
    wall.makeWall(20, height - 20, width - 20, height - 20);
    
    //makes the maze
    wall.makeWall(20, height/2, 250, height/2);
    wall.makeWall(250, height/2 - 100, 250, height/2);
    wall.makeWall(20, height/2 - 130, 100, height/2 - 130);
    wall.makeWall(150, height/2, 150, height/2 + 100);
    
    wall.makeWall(300, height - 150, 300, height - 20);
    wall.makeWall(350, 60, 350, 200);
    
    wall.makeWall(525, height/2, 525, height - 20);
    wall.makeWall(400, height/2 + 100, 525, height/2 + 100);
    
    wall.makeWall(width - 140, 150, width - 20, 150);
    wall.makeWall(width - 150, height/2 + 150, width - 20, height/2 + 150);
    
    //if the game is paused, it will open up the pause menu
    if (paused == true)
      pauseGame();
    
  }
  else if (gameOver == true) { //if the game is over the player will be prompted to quit or try again
    background(0);
    cursor();
    imageMode(CENTER);
    image(death, width/2, height/2);
    endGame.drawPlayAgain();
  }
  
}//end draw()


// WALL CLASS
class Wall {
  void makeWall(int startX, int startY, int endX, int endY) { //draws each wall which innately checks for collision detection with the player
    //draws a black wall according to the parameters
    fill(0);
    line(startX, startY, endX, endY);
    
    //collision detection algorithim calculates if a player has touched a wall and places them 1 pixel away from the line to prevent them from sticking to the wall
    
    //a for loop that runs the length of the player to calculate every possible collision point
    for (int i = 0; i < player.size; i++) {
      //detects weather a player has touched a horizontal line and prevents them from crossing it
      if (startY == endY) {
        //this first half of the if statement checks if the player is touching the actual wall
                          // the startY value is subtracted by 3 to add depth to the wall and prevents the player from glitching through
        if (player.yPos + i <= startY && player.yPos + i >= startY - 3 && player.xPos + i >= startX - 3 && player.xPos + i <= endX + 3) {
          if (player.yPos + 5 > startY)                                             //this second half of the if statement checks if a player is touching the corners of two walls
          
            //this if else statement checks which side of the player is touching the wall and adjusts the position accordingly
            player.yPos = startY + 1;
          else
            player.yPos = startY - 1 - player.size;
          }
          //collision detection for player 2
          if (player2.yPos + i <= startY && player2.yPos + i >= startY - 3 && player2.xPos + i >= startX - 3 && player2.xPos + i <= endX + 3) {
            if (player2.yPos + 5 > startY)
              player2.yPos = startY + 1;
          else
            player2.yPos = startY - 1 - player.size;
          }
        }
      //detects weather a player has touched a vertical line and prevents them from crossing it
      //for further explanation read the comment for the if statements above ^^^
      else if (startX == endX) {
        if (player.xPos + i <= startX && player.xPos + i >= startX - 3 && player.yPos + i >= startY - 3 && player.yPos + i <= endY + 3) {
          if (player.xPos + 5 > startX)
            player.xPos = startX + 1;
          else
            player.xPos = startX - 1 - player.size;
        }
        if (player2.xPos + i <= startX && player2.xPos + i >= startX - 3 && player2.yPos + i >= startY - 3 && player2.yPos + i <= endY + 3) {
          if (player2.xPos + 5 > startX)
            player2.xPos = startX + 1;
          else
            player2.xPos = startX - 1 - player.size;
        }
      }
    }//end player collision algorithim
    
    //bullet collision loop that checks if a bullet touches a line, then removes it
    //Since we have to remove an object from an ArrayList WHILE it is iterating, we have to start fromt the end and remove the most recent object created and then work towards the start
    for (int j = bullets.size()-1; j >= 0; j--) {
            if (bullets.get(j).collideline(startX, startY, endX, endY)) { //checks if the bullet touches a wall
                pop.play(); //plays the pop sound effect
                bullets.remove(j); //despawns the bullet
            }
            
            //checks if a bullet hit a player, if its true, then the game is over
            else if (bullets.get(j).collideline(player.xPos, player.yPos, player.xPos + player.size, player.yPos + player.size)) {
                bullets.remove(j); //despawns the bullet
                main.stop(); //stops the main theme
                explosion.play(); //plays the player death sound
                over.loop(); //loops the game over theme
                score2++;
                gameOver = true; //prompts the gameOver menu to start
            }
            //checking if player 2 is hit as well
            else if (bullets.get(j).collideline(player2.xPos, player2.yPos, player2.xPos + player2.size, player2.yPos + player2.size)) {
                bullets.remove(j); //despawns the bullet
                main.stop(); //stops the main theme
                explosion.play(); //plays the player death sound
                over.loop(); //loops the game over theme
                score1++;
                gameOver = true; //prompts the gameOver menu to start
            }
    }
    
    //cursor collision detection
    //makes sure the player's aiming tool stays within the map
    if (cursor.mouse2X > width)
      cursor.mouse2X = width - 1 - cursor.size;
    else if (cursor.mouse2X < 0)
      cursor.mouse2X = 1 + cursor.size;
    else if (cursor.mouse2Y > height)
      cursor.mouse2Y = height - 1 - cursor.size;
    else if (cursor.mouse2Y < 0)
      cursor.mouse2Y = 1 + cursor.size;
      
  }//end makeWall method
}//end Wall class


// calculates and displays the score
void score() {
    imageMode(CORNER);
    //player avatars
    p1Score.resize(160, 100);
    p2Score.resize(100, 100);
    image(p1Score, 20, -25);
    image(p2Score, width - 150, -25);
    
    //printing the score
    textSize(60);
    fill(0);
    text(score1, 160, 57); //player 1's score
    text(score2, width - 210, 57); //player 2's score
    
    //display creators name (me! :)  )
    textSize(40);
    textMode(CENTER);
    text("Shaurya Ganguly", width/2 - 170, 60);
}

//pauses the game
void pauseGame() {
  
  //create the pause screen as the background
  pause.resize(width, height);
  image(pause, 0, 0);

  //selector properties
  stroke(#00FF63);
  strokeWeight(3);
  strokeCap(ROUND);
  int x = width/2 - 105, y = height/2 - 59, sizeX = 210, sizeY = 49;
  
  //Switch between these 4 options by pressing TAB
  
  //resume game
  if (pausePressed == 1) {
    if (key == ENTER)
      paused = false;
  }
  //restart game
  else if (pausePressed == 2) {
    y += 93;
    if (key == ENTER) {
      endGame.restart();
    }
  }
  //quit game
  else if (pausePressed == 3) {
    y += 188;
    if (key == ENTER)
      exit();
  }
  //sound control
  else if (pausePressed == 4) {
    y += 1000;
    noFill();
    ellipse(85, 500, 80, 80);
    if (key == ENTER) {
      if (sound == true) { //turns music off
        main.amp(0);
        over.amp(0);
        pop.amp(0);
        explosion.amp(0);
        stroke(#FF0303);
      line(52, 477, 118, 528); //momentarily flashes red line to show music is off
      }
      else { //turns music on
        main.amp(0.5);
        over.amp(0.5);
        pop.amp(0.5);
        explosion.amp(0.5);
      }
    }
  }
  
  //draws the actual selector
  line(x, y, x + sizeX, y);
  line(x, y, x, y + sizeY);
  line(x, y + sizeY, x + sizeX, y + sizeY);
  line(x + sizeX, y, x + sizeX, y + sizeY);
}


// ENDGAME CLASS

class EndGame {
   //option to move selector between choices
   boolean option;
   
void drawPlayAgain(){ //asks the user if they want to play again or quit
  
   //triangle properites
  int x = width/2 - 150, y = height/2 + 22;
  fill(#00FF63);
  
  //switches the selector's position each time TAB is pressed
  if (option == false) {
    triangle(x, y, x, y + 10 , x + 10, y + 5);
    
    //restarts the game
    if (key == ENTER) {
      restart();
    }
  }
  else { //moves selector to second option
    x += 180;
    triangle(x, y, x, y + 10 , x + 10, y + 5);
    
      if (key == ENTER) //quits the game
        exit();
    }
  }
  
  void restart() { //resets all variables and the environment
    gameOver = false; //game is not over because new game has started
    paused = false;
      main.loop(); //plays the main theme
      over.stop(); //stops the death theme
      player = new Player((int)random(20, 700), (int)random(20, 500)); //spawn new player
      player2 = new Player2 ((int)random(20, 700), (int)random(20, 500)); //spawn new player 2
      for (int j = bullets.size()-1; j >= 0; j--) { //reruns the bullet removal loop to remove any remaining bullets remaining on the map when a player died
        bullets.remove(j);
      }
  }
}


// BULLET CLASS: This portion of the code is not mine
//It was used as a reference from https://forum.processing.org/one/topic/shoot-multiple-bullets.html
class Bullet extends PVector {
  PVector vel;
 
  Bullet(PVector loc, PVector vel) {
    super(loc.x, loc.y);
    this.vel = vel.get();
  }
 
  void update() {
    add(vel);
  }
 
  void display() {
    fill(0);
    ellipse(x, y, 5, 5);
  }
  
  float bulletX() {
    return x;
  }
  
  //calculates if the bullet collides with the line
  boolean collideline(float x1, float y1, float x2, float y2) { //accepts parameters from the makeWall method
        PVector O = new PVector(x1, y1);
        PVector L2 = new PVector(x2, y2);
        float len = O.dist(L2);
        PVector D = L2.sub(O).normalize();
        PVector P = this;
        PVector X = add(O, mult(D, sub(P, O).dot(D)));

        // distance to the line has to be less than velocity
        float distX = X.dist(P);
        if (distX > this.vel.mag())
            return false;

        // if bullet doesn't "miss" the line
        PVector VX = X.sub(O); 
        float distO = VX.dot(D);
        return distO > -5 && distO < len+5;   
    }
}

//adds a delay to each shot of the bullets so players can't spam the button
void shootBullets1() {
    if (frameCount % 15 == 0 && mousePressed) {
        PVector dir = PVector.sub(globalMouse, player.position()); //creates new PVector using the mouse and player direction and magnitude
        dir.normalize();
        dir.mult(maxSpeed*3);
        Bullet b = new Bullet(player.position(), dir); //spawns the bullet
        bullets.add(b);
  } 
}
//shooting bullet algorithim for player 2
void shootBullets2() {
  if (frameCount % 15 == 0 && shoot == true) {
      PVector dir = PVector.sub(globalMouse2, player2.position());
      dir.normalize();
      dir.mult(maxSpeed*3);
      Bullet b = new Bullet(player2.position(), dir);
      bullets.add(b);
  }
}


// CURSOR CLASS
//The cursor class is a user made class that attempts to emulate a second mouse
class Cursor {
  int mouse2X, mouse2Y, size = 8, cursorSpeed = 2;
  boolean moveLeft, moveRight, moveUp, moveDown;
  
  Cursor(int x, int y) { //moves the cursor to its new location
    mouse2X = x;
    mouse2Y = y;
  }
  
  //draws the cursor
  void drawCursor() {
      fill(#00FC49);
      ellipse(cursor.mouse2X, cursor.mouse2Y, size, size);
      globalMouse2 = new PVector (cursor.mouse2X, cursor.mouse2Y);
    }
  
  //moves the cursor
  void moveCursor() {    
    if(moveLeft == true) 
      mouse2X -= cursorSpeed * 2;
    if(moveRight == true) 
      mouse2X += cursorSpeed * 2;
    if(moveUp == true) 
      mouse2Y -= cursorSpeed * 2;
    if(moveDown == true) 
      mouse2Y += cursorSpeed * 2;
  }
}//end Cursor class


//PLAYER CLASS
 //Draws player and handles all of its events
class Player {
  int xPos; // x-position of the player
  int yPos; // y-position of the player
  int speed = 2; //speed of the player
  int size = 50; //size of the player
  boolean moveLeft, moveRight, moveUp, moveDown; //movement direction
 
  //moves the player to its new location
  Player(int x, int y) {
    xPos = x;
    yPos = y; 
  }
  
  //puts the positions of the player into a method so it can be called later
  PVector position() {
    PVector position = new PVector(barrelPos[0], barrelPos[1]); //adding half the length of the player so the bullets spawn from the middle
    return position;
  }

   //code that spawns the player
   void drawPlayer() {
     stroke(0);
     strokeWeight(1);
     fill(#FF0000);
     rect(xPos, yPos, size, size); //height and width values are the same becasue the player is a square
     drawTurret(); //spawns the turret that follows the mouse
     ellipse(xPos + 25, yPos + 25, 30, 30); //tank cap
   }
     
    // I am placing the values newX and newY into an array so multiple values can be passed from the method drawTurret(). These values will then be used in the method position() above ^^^
    // All of these calculations result int the bullets appearing to be shot from the actual barrel of the tank instead of just the tank body. Previously, if the mouse moved too fast,
    //you could see the bullet not actually inside the barrel, this fixes that problem
    float[] barrelPos = new float[2];
    
   // makes the barrel follow the mouse so its always aiming at the right position 
   float[] drawTurret() {
     int dx, dy, barrelLength = 50;
     float angle, newX, newY;
     
      //determines the distance, then the corresponding angle from the player to the mouse
       dx = mouseX - xPos + 25; //distance from mouse to player (x plane)
       dy = mouseY - yPos + 25; //distance from mouse to player (y plane)
       angle = atan2(dy, dx); //calculates the angle between the two lines

      //calculate the end point of the barrel
       newX = (xPos + 25) + cos(angle) * barrelLength;
       newY = (yPos + 25) + sin(angle) * barrelLength;

     //draws the barrel
     strokeWeight(10);
     stroke(#830303);
     strokeCap(PROJECT);
     line(xPos + 25, yPos +25, newX, newY);
     
     barrelPos[0] = newX;
     barrelPos[1] = newY;
          
     return barrelPos; //return array with the x and y values of the turret
   }
 
  //method that moves the player according to its current speed
  void movePlayer() {
    if(moveLeft == true) 
      xPos -= speed * 2;
    if(moveRight == true) 
      xPos += speed * 2;
    if(moveUp == true) 
      yPos -= speed * 2;
    if(moveDown == true) 
      yPos += speed * 2;
  }
}//end Player class



//PLAYER 2 CLASS
//refer to Player class for comments
class Player2 {
  int xPos; 
  int yPos; 
  int speed = 2; 
  int size = 50; 
  boolean moveLeft, moveRight, moveUp, moveDown;
 
  Player2(int x, int y) {
    xPos = x;
    yPos = y; 
  }
  
  PVector position() {
    PVector position = new PVector(barrelPos[0], barrelPos[1]); //adding half the length of the player so the bullets spawn from the middle
    return position;
  }
  
   void drawPlayer2() {
     stroke(0);
     strokeWeight(1);
     fill(#0700FC);
     rect(xPos, yPos, size, size);
     drawTurret();
     ellipse(xPos + 25, yPos + 25, 30, 30);
   }
   
    float[] barrelPos = new float[2];
     
   float[] drawTurret() {
     int dx, dy, barrelLength = 50;
     float angle, newX, newY;
     
       dx = cursor.mouse2X - xPos + 25;
       dy = cursor.mouse2Y - yPos + 25;
       angle = atan2(dy, dx);

       newX = (xPos + 25) + cos(angle) * barrelLength;
       newY = (yPos + 25) + sin(angle) * barrelLength;

     strokeWeight(10);
     stroke(#201CAD);
     strokeCap(PROJECT);
     line(xPos + 25, yPos +25, newX, newY);
     
     barrelPos[0] = newX;
     barrelPos[1] = newY;
          
     return barrelPos;
   }
 
  void movePlayer2() {
    if(moveLeft == true) 
      xPos -= speed * 2;
    if(moveRight == true) 
      xPos += speed * 2;
    if(moveUp == true) 
      yPos -= speed * 2;
    if(moveDown == true) 
      yPos += speed * 2;
  }
}//end Player2 class



// KEYBOARD INTERACTIONS (used keyPressed() and keyReleased instead of just the former to creater a smoother and faster movement experience. 
//Using both functions in tandem allows the objects to travel diagonally as well)
  
void keyPressed() {
  if (paused != true) {
  //when called moves the player 1 in the desired direction
  if (key == CODED) {
     if (keyCode == LEFT)
       player.moveLeft = true;
     else if(keyCode == RIGHT)
       player.moveRight = true;
     else if(keyCode == UP)
       player.moveUp = true;
     else if (keyCode == DOWN)
       player.moveDown = true;
  }
  //moves player 2 in the desired direction
  else if(key == 'a' || key == 'A')
    player2.moveLeft = true;
  else if(key == 'd' || key == 'D')
    player2.moveRight = true;
  else if(key == 'w' || key == 'W')
    player2.moveUp = true;
  else if(key == 's' || key == 'S')
    player2.moveDown = true;
  if (key == 'm' || key == 'M') //this is not else if to let player move and shoot at the same time
    shoot = true;
    
  //moves the player 2 cursor  
  if(key == 'i' || key == 'I')
    cursor.moveUp = true;
  else if(key == 'j' || key == 'J')
    cursor.moveLeft = true;
  else if(key == 'k' || key == 'K')
    cursor.moveDown = true;
  else if(key == 'l' || key == 'L')
    cursor.moveRight = true;
    
    /*
    if (key == ENTER) 
    gameOver = true; */
  }
  
  //selector moves between the options each time TAB is pressed
  if (key == TAB && paused != true) //selector for game over screeen
    endGame.option ^= true;
  else if (key == TAB && paused == true) { //selector for pause screen
    pausePressed++;
    if (pausePressed >= 5) //resets this value to let player cycle through options
      pausePressed = 1;
  }
  
  //pauses the game
  if(key == 'p' || key == 'P')
    paused ^= true;
    
    if(key == ENTER) //toggles music on/off
      sound ^= true;
}

void keyReleased() { //when called stops all movement
  if (key == CODED) {
     if (keyCode == LEFT)
       player.moveLeft = false;
     else if(keyCode == RIGHT)
       player.moveRight = false;
     else if(keyCode == UP)
       player.moveUp = false;
     else if (keyCode == DOWN)
       player.moveDown = false;
  }
  else if(key == 'a' || key == 'A')
    player2.moveLeft = false;
  else if(key == 'd' || key == 'D')
    player2.moveRight = false;
  else if(key == 'w' || key == 'W')
    player2.moveUp = false;
  else if(key == 's' || key == 'S')
    player2.moveDown = false;
  else if (key == 'm' || key == 'M')
    shoot = false;
    
    if(key == 'i' || key == 'I')
    cursor.moveUp = false;
  else if(key == 'j' || key == 'J')
    cursor.moveLeft = false;
  else if(key == 'k' || key == 'K')
    cursor.moveDown = false;
  else if(key == 'l' || key == 'L')
    cursor.moveRight = false;
    
     //sets all the flag related keys to ESC (acting as a null values in this situation) when keyReleased() so they only run once
  if (key == TAB || key == ENTER || key == 'p' || key == 'P')
    key = ESC;
}
  
  
// DRAW FUNCTIONS - SPAWNS: button, volume control, instructions

void drawButton() { //draws the button to start the game

    //spawns title image
     title.resize(width, height);
     image(title, 0, 0);
     
     //spawns game button
     image(button, buttonX, buttonY);

     if (mousePressed && mouseX < buttonX+button.width && mouseY < buttonY+button.height && mouseX > buttonX && mouseY > buttonY ) { //checks if the button is pressed
        //plays sword sound effect
        sword.play();
        
        //clears the main menu and starts the game
        spawn = true; //sets the player spawn to true so it can be drawn
     }
     
     //spawns the volume buttons
     mute();
     
     stroke(255); //prevents ghosting of the cursor on the menu screen
}

//mute function that toggles the volume on and off
void mute() {
  int x = 20, y = 20, size = 20;
  
  //volume button size and positions
  volumeOn.resize(20, 20);
  volumeOff.resize(20, 20);
  image(volumeOn, x+50, y);
  image(volumeOff, x, y);
       
     if(sound == true) { //mutes music
         if (mousePressed && mouseX < x + size && mouseY < y + size && mouseX > x && mouseY > y && spawn == false) {
            main.amp(0);
            over.amp(0);
            pop.amp(0);
            explosion.amp(0);
            sound = false;
        }
     }
     else { //un-mutes it
        if (mousePressed && mouseX < x + 50 + size && mouseY < y + size && mouseX > x + 50 && mouseY > y && spawn == false) {
            main.amp(0.5);
            over.amp(0.5);
            pop.amp(0.5);
            explosion.amp(0.5);
            sound = true;
        }
     }
}

//creates a pop-up box for the instructions
void instructions() {
  int x = width - 400, y = 20, sizeX = 400, sizeY = 65;
  fill(0);
  play.resize(400, 65);
  image(play, x, y); //image that opens a pop-up of the instructions when clicked
  
  //spawns the popup box with the message
    if (mousePressed && mouseX < x + sizeX && mouseY < y + sizeY && mouseX > x && mouseY > y && flag == true) {
      showMessageDialog(null, "Tank Trouble is a two player game with the objective to navigate your way through the maze to try and outsmart your opponent. \nOnce you have gained a valuable position, you can try and shoot down your opponent, but be careful, they'll be doing the same! \nIt is a game that requires skill, precision, and quick reaction times....are you up to the task? \n\n Use the D-Pad to move, the joystick to aim and the shoulder buttons to shoot. \nThe Z butoons are to switch between on-screen options, and press the home button to confirm your entry. \nYou can always pause the game by pressing + or - ", 
      "Instructions", INFORMATION_MESSAGE);
      flag = false;
  }
}
