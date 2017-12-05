# <p align="center"> ** Part II: Eagle Taxi Project **  </p>
<p align="center"> *Alexander Forte, Mika Chestnut, Will Bullock*  </p>
***
## **Introduction**
The emergence of on-demand services highlights the growing need for efficient and effective delivery and routing algorithms. Ride-hailing services like Uber and e-commerce giants like Amazon all strive to find the most lucrative and resource-sensitive strategies in order to maximize their businesses' productivity. There are several different approaches to this problem, commonly referred to as the Vehichle Routing Problem, which prioritize different factors in thier method, whether it be passengers, driving time, distance, and car pooling. As algorithmic consultants for the new ride-sharing company, *Eagle Taxi*, we developed a greedy car pool strategy to overtake the competition of Uber and Lyft.

***
## **Summary of Experiment**
### OurMove() Algortihm
* Our routing algorithm utilizes a pure greedy strategy to pick up passengers when the car is idle (0 passengers), moving towards the closest passenger.

```java
if(cars[i].numPassenger == 0){
   /*move to the taxi towards closest
   passenger waiting to be picked up
   if the taxi is empty*/

   //place holder for car's minimum distance from pickup
   float closest=2000;

   //find the passenger with the closest pickup
   for(int j=0;j<numPassengers;j++){
   //Iterates through all idle passengers to check their distance from the car's current position

      if(passengers[j].ifIdle){
         int k=(int)(passengers[j].index);
         //Use Manhattan distances due to grid environment
         float dist=abs(passengers[k].startX-cars[i].xpos)+abs(passengers[k].startY-cars[i].ypos);

         //updates the current passenger closet to the respective car
         if(dist<closest){
            closest=dist;
            pass=k;
         }
     }

   //moves taxi towards the closest passenger's pickup location
   if(abs(passengers[pass].startX-cars[i].xpos) > 10){
     if(passengers[pass].startX >= cars[i].xpos){
       cars[i].changeDirection(0);
     }else{
       cars[i].changeDirection(1);
     }
   }

   if(abs(passengers[pass].startY-cars[i].ypos) > 10){
     if(passengers[pass].startY >= cars[i].ypos){
       cars[i].changeDirection(2);
     }else{
       cars[i].changeDirection(3);
     }
   }
 }```
   * When there is at least one passenger in the car, our algorithm uses Manhattan distances (due to the grid orientation of the environment) to drop off the passenger with the closest destination.
  ```java
  else {
    //Move to the destination of the passenger with the closest destination
    float shortest=2000;

    //finds the passenger with the closest drop off
    for(int j=0;j<cars[i].numPassenger;j++){
    //Iterates through all passengers to check their distance from destination

      int k=cars[i].passengerList[j];
      //Use Manhattan distances due to grid environment
      float dist=abs(passengers[k].destX-cars[i].xpos)+abs(passengers[k].destY-cars[i].ypos);

      //updates the current passenger closet to their destination
      if(dist<shortest){
         shortest=dist;
         pass=k;
      }
    }

    //moves taxi towards the closest passenger's destination
    if(abs(passengers[pass].destX-cars[i].xpos) > 10){
      if(passengers[pass].destX >= cars[i].xpos){
        cars[i].changeDirection(0);
      }else{
        cars[i].changeDirection(1);
      }
    }

    if(abs(passengers[pass].destY-cars[i].ypos) > 10){
      if(passengers[pass].destY >= cars[i].ypos){
        cars[i].changeDirection(2);
      }else{
        cars[i].changeDirection(3);
      }
    }
  }```
   * En route to this destination, if one of the cars is not at full capacity, it will pick up passengers in its path. If a new passenger needs to be dropped off at a closer destination than the previous closest, the route will update and this cycle will continue until the time frame ends.

### Thought Process
* The intuition behind this algorithm is to continually search for the nearest destination because:
  1. The  quicker trips result in more lower fare rides, but the algorithm aims to execute a large quantity of these rides to capitalize on the time constraint of the competition.
  2. The car only has a capacity of 5, so by dropping off the passenger with the closest destination, the quicker the taxi can add another potential trip.
* Adding to this strategy of quickness, the algorithm will find the nearest idle passenger if the car is empty to ensure the quickest turnaround time to another trip.
* This algorithm also was implemented to mimic the behaviour of an actual taxi in the sense that it aims to leverage quick trips to build up smaller, but more frequent fares.

### Correctness

* The algorithm executes this goal because it has access to the information of all the passengers starting and ending points. Therefore it can use Manhattan distances to sum the difference in X and Y coordinates of the car and destination/passenger to determing either the closest passenger or destination. The algorithim then simply uses the changeDirection() function to move towards the predetermined location.

***
## **Experiment Results**
### <p align="center">Seed: 1</p>
#### <p align="center">*Our Score=2537.2964  |  Opponent Score: 622.69965*</p>
![my screenshot](/Users/wbullock/Desktop/TaxiSeed-1.png)


### <p align="center">Seed: 14</p>
#### <p align="center">*Our Score=2227.5356  |  Opponent Score: 1737.8099*</p>
![my screenshot](/Users/wbullock/Desktop/TaxiSeed-14.png)

### <p align="center">Seed: 29</p>
#### <p align="center">*Our Score=2502.464  |  Opponent Score: 1917.6663*</p>
![my screenshot](/Users/wbullock/Desktop/TaxiSeed-29.png)

### <p align="center">Seed: 135</p>
#### <p align="center">*Our Score=2667.2622  |  Opponent Score: 1837.3572*</p>
![my screenshot](/Users/wbullock/Desktop/TaxiSeed-135.png)

### <p align="center">Seed: 629</p>
#### <p align="center">*Our Score=2387.6208  |  Opponent Score: 1847.3228*</p>
![my screenshot](/Users/wbullock/Desktop/TaxiSeed-629.png)

## Summary

Seed | Our Score | Opp. Score|
---  |  ---        |  ----|
1 | 2537.2964 | 622.69965
14 |2227.5356 | 1737.8099
29 | 2502.464 | 1917.6663
135 | 2667.2622 | 1837.3572
629 |2387.6208 | 1847.3228
*Avg.* | *2464.4358* | *1592.57117*

 * While our implementation of ourMove() is a simple hueristic, its preformance against the dumb greedy strategy shows the effectiveness of prioritizing speed and proximity.
 * This algorithm is clearly a baseline implementation of one of many routing algorithms and fails to optimize the route given each set of passengers.
