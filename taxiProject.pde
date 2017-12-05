//*****************************************************
//*****************************************************
//   Boston College    CSCI 3383-02        Fall 2017
//       *** Final Project: Taxi King/Queen ***
//
//                             Developed by Lewis Tseng
//                                  Date: Nov. 19, 2017
//*****************************************************
//*****************************************************

// display parameters
final int xLen = 1000;
final int yLen = 500;
int lineWidth = 10;

// GUI objects
import interfascia.*;
GUIController c;
IFButton bStop;

// GUI for debugging
int clickDetection = 20;
IFLabel lCarInfo;
boolean ifClicked = false;
int clickedCarIndex = -1;

// taxi parameters
final int carLeng = 25;
final int numCars = 6;
color oppoColor = color(255,0,0);
color ourColor = color(0,255,0);
final float carSpeed = 0.5; 
Car[] cars;
float ourScore = 0;
float oppoScore = 0;

// passenger parameters
final int numPassengers = 100;
color passColor = color(0,0,255);
Passenger[] passengers;
float fareRatio = 0.1;
float pickupDistance = 20;
float dropDistance = 20;

// simulation parameters
int localFrameRate = 100; // 100 frames per sec
boolean ifStop = false;
int curFrame = 1;
int finalFrame = 10000;
// choose the seed for your random numbers
int rSeed = 100;



void setup() {
  randomSeed(rSeed);
  // y = yLen + 200 for showing info
  // x = xLen + 10 for showing the boundary
  size(1010,700);
  frameRate(localFrameRate);
  
  // initialize cars:
  //   first set of cars is our cars
  //   second set of cars is opponent's cars
  cars = new Car[numCars];
  for (int i=0; i < numCars; i++){
    if(i < numCars/2){
      cars[i] = new Car(i, true);
    }else{
      cars[i] = new Car(i, false);
    }
  }
  
  // initialize passengers
  passengers = new Passenger[numPassengers];
  for (int i=0; i < numPassengers; i++){
    passengers[i] = new Passenger(i);
  }
  
  // GUIs
  c = new GUIController(this);
  bStop = new IFButton ("Stop/Go", xLen-100, yLen+10);
  c.add(bStop);
  bStop.addActionListener(this);
  
  lCarInfo = new IFLabel("Debugging Info:\n", 15, yLen+20);
  c.add(lCarInfo);
}

// Trigger the action: start/stop button clicked
void actionPerformed(GUIEvent e) {
  if(e.getSource() == bStop){
    ifStop = !ifStop;
  }  
}

// For debugging: you can click a car and see its internal parameters
// only one car will be displayed
void mousePressed(){
  // Clean the state
  ifClicked = false;
  clickedCarIndex = -1;
  for(int i=0; i < numCars; i++){
    cars[i].ifClicked = false;
  }
  
  // Check the clicked cars
  for(int i=0; i < numCars; i++){
    if(dist(mouseX,mouseY,cars[i].xpos,cars[i].ypos) < clickDetection){
      cars[i].ifClicked = true;
      clickedCarIndex = i;
      ifClicked = true;
      break;
    }
  }
}

// main simulation loop
// YOU SHOULD NOT MODIFY THIS PART
void draw() {
    background(255);
    textAlign(CENTER);
    
    if(!ifStop){
      for(int i=0; i < numCars/2; i++){
        cars[i].move();
        ourMove(i);
      }
      
      // Dumb Taxi Strategy
      // This is opponent's strategy
      for(int i=numCars/2; i < numCars; i++){
        cars[i].move();
        dumbMove(i);
      }
    }
    
    for (int i=0; i < numCars; i++){
      cars[i].display();
    }
    
    for (int i=0; i < numPassengers; i++){
      passengers[i].display();
    }
    
    // stop the game
    if(curFrame >= finalFrame){
      ifStop = true;
      textSize(50);
      stroke(0);
      text("Time's Up", xLen-450, yLen+100);
    }else{
      if(!ifStop){
        curFrame = curFrame + 1;
      }
    }
    
    showDebugInfo();
    drawTopology();
    pickupPassenger();
    dropPassenger();
    
    // show game info
    textSize(20);
    text("Seed: " + str(rSeed), xLen-100, yLen+70);
    text("Our Score: " + str(ourScore), xLen-100, yLen+100);
    text("Oppo. Score: " + str(oppoScore), xLen-100, yLen+130);
    text("Time: " + str(curFrame) + " /10000", xLen-100, yLen+180);
    
}
// ****************************
// IMPLEMENT YOUR STRATEGY HERE
// ****************************
void ourMove(int i){
  
  
  // randomly move in one direction
  if(cars[i].numPassenger == 0){
    if(curFrame % 150 == 0){
      cars[i].changeDirection(int(random(0,4)));
    }
  }else{
    // move to the destination of the first passenger
    int j = cars[i].passengerList[0];
    
    if(abs(passengers[j].destX-cars[i].xpos) > 10){
      if(passengers[j].destX >= cars[i].xpos){
        cars[i].changeDirection(0);
      }else{
        cars[i].changeDirection(1);
      }
    }
    
    if(abs(passengers[j].destY-cars[i].ypos) > 10){
      if(passengers[j].destY >= cars[i].ypos){
        cars[i].changeDirection(2);
      }else{
        cars[i].changeDirection(3);
      }
    }
  }
}
      
      
//****************
// HELP FUNCTIONS
//****************
// Simple (dumb) Greedy moving strategy
void dumbMove(int i){
  // randomly move in one direction
  if(cars[i].numPassenger == 0){
    if(curFrame % 150 == 0){
      cars[i].changeDirection(int(random(0,4)));
    }
  }else{
    // move to the destination of the first passenger
    int j = cars[i].passengerList[0];
    
    if(abs(passengers[j].destX-cars[i].xpos) > 10){
      if(passengers[j].destX >= cars[i].xpos){
        cars[i].changeDirection(0);
      }else{
        cars[i].changeDirection(1);
      }
    }
    
    if(abs(passengers[j].destY-cars[i].ypos) > 10){
      if(passengers[j].destY >= cars[i].ypos){
        cars[i].changeDirection(2);
      }else{
        cars[i].changeDirection(3);
      }
    }
  }
}

// If a car is close to a passenger, 
//  pick up the passenger automatically
void pickupPassenger(){
  for(int i=0; i < numPassengers; i++){
    if(passengers[i].ifIdle){
      for (int j=0; j < numCars; j++){
        if(cars[j].capacity > cars[j].numPassenger){
          // Car j can pick up passenger i
          if(dist(cars[j].xpos, cars[j].ypos, passengers[i].startX, passengers[i].startY) < pickupDistance){
            // Car j and passenger i are close
            passengers[i].ifIdle = false;
            cars[j].passengerList[cars[j].numPassenger] = i;
            cars[j].numPassenger++;
          }
        }
      }
    }
  }
}

// If a car is close to a passenger's destination,
//  drop the passenger and update passengers automatically
void dropPassenger(){
  for (int j=0; j < numCars; j++){
    if(cars[j].numPassenger > 0){
      for (int i=0; i < cars[j].numPassenger; i++){
        int pIndex = cars[j].passengerList[i];
        if(dist(cars[j].xpos, cars[j].ypos, passengers[pIndex].destX, 
                        passengers[pIndex].destY) < dropDistance){
          // Update score
          if(cars[j].ifOurCar){
            ourScore += passengers[i].fare;
          }else{
            oppoScore += passengers[i].fare;
          }
            
          // Generate a new passenger
          passengers[pIndex] = new Passenger(pIndex);
          
          // Renew Car j's passenger list
          for (int k=i; k<cars[j].numPassenger-1; k++){
            cars[j].passengerList[k] = cars[j].passengerList[k+1]; 
          }
          cars[j].numPassenger--;
        }
      }
    }
  }
}

//*************************************
// Add the info here to help you debug
//*************************************
void showDebugInfo(){
  if(ifClicked){
    int i = clickedCarIndex;
    String addStr = new String("Car Info:" + str(cars[i].index)+"\n");
    addStr = addStr.concat(str(cars[i].xpos)+"; "+ 
          str(cars[i].ypos)+ "; " + str(cars[i].xspeed) + "; " + str(cars[i].yspeed) + "\n");
    lCarInfo.setLabel("Debugging Info:\n"+addStr);
  }else{
    lCarInfo.setLabel("Debugging Info:\n");
  }
}

void drawTopology(){
  stroke(0);
  strokeWeight(lineWidth);
  fill(200);
  
  line(0,yLen+lineWidth/2,xLen,yLen+lineWidth/2);
  line(0,lineWidth/2,xLen,lineWidth/2);
  line(xLen+lineWidth/2,0,xLen+lineWidth/2,yLen);
  line(lineWidth/2,0,lineWidth/2,yLen);
}

// YOU SHOULD NOT MODIFY THIS PART
class Passenger {
  float startX;
  float startY;
  float destX;
  float destY;
  float fare;
  float index;
  boolean ifIdle = true;
  
  // Random positions and random fare
  Passenger(int tmpIndex){
    startX = random(0, xLen);
    startY = random(0, yLen);
    destX = random(0, xLen);
    destY = random(0, yLen);
    fare = fareRatio*dist(destX, destY, startX, startY) + random(1,5);
    index = tmpIndex;
  }
  
  void display(){
    strokeWeight(0);
    stroke(0);
    if(ifIdle){
      fill(color(#FFCC00, 100));
      ellipse(startX, startY, 5, 5);
    }
  }
}

// YOU SHOULD NOT MODIFY THIS PART
class Car { 
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
  int index;
  boolean ifOurCar;
  boolean ifClicked;
  int capacity = 5;
  int numPassenger = 0;
  int[] passengerList;
  
  // Randome initial position and speed
  Car(int tempIndex, boolean tempIfOurCar) { 
    xpos = random(0, xLen);
    ypos = random(0, yLen);
    index = tempIndex;
    ifOurCar = tempIfOurCar;
    passengerList = new int[capacity];
  }
  
  // Move right: direction 0
  // Move left:  direction 1
  // Move down:  direction 2
  // Move up:    direction 3
  void changeDirection(int direction){
    xspeed = 0;
    yspeed = 0;
    switch(direction) {
      case 0: 
        xspeed = carSpeed;
        break;
      case 1: 
        xspeed = -carSpeed;
        break;    
      case 2:
        yspeed = carSpeed;
        break;
      case 3:        
        yspeed = -carSpeed;
        break;        
    }
  }

  void display() {
    strokeWeight(1);
    
    if((xpos >= 0)&&(ypos >= 0)){
      stroke(0);
      if(ifOurCar){
        fill(ourColor);
      }else{
        fill(oppoColor);
      }
      if(ifClicked){
        fill(0,0,0);
      }
      rectMode(CENTER);
      rect(xpos, ypos, carLeng, carLeng);
      fill(0);
      text(str(numPassenger),xpos,ypos+5);
    }
  }
  
  void move(){
    xpos = xpos + xspeed;
    ypos = ypos + yspeed;
    
    // If out of boundary,
    //   cars will enter from the other side 
    if(xpos > xLen){
      xpos = 0;
    }
    if(ypos > yLen){
      ypos = 0;
    }
    if(xpos < 0){
      xpos = xLen;
    }
    if(ypos < 0){
      ypos = yLen;
    }
  }
  
}