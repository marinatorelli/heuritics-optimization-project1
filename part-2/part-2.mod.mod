/*sets*/

#Part 1
set ENTRANCE;
set ELEMENT;

#Part 2
set ROBOTS;
set GALLERIES;

/*subsets of ENTRANCE*/
set MAIN within ENTRANCE;		#East entrance
set NOTMAIN within ENTRANCE;	#West and North entrances
set WEST within ENTRANCE;		#West entrance
set NORTH within ENTRANCE;		#North entrance

/*subsets of ELEMENT*/
set MCH_TRN within ELEMENT;		#Vending machines and turnstiles only
set TURNSTILE within ELEMENT;	#Turnstiles only

/*subsets of ROBOTS*/
set NOTWEST within ROBOTS;		#Robots r3, r5 and r6
set NOTEAST within ROBOTS;		#Robots r2 and r4

/*subsets of GALLERIES*/
set WESTGALLERIES within GALLERIES;	
set EASTGALLERIES within GALLERIES;
set HALLSAB within GALLERIES;
set HALLSCD within GALLERIES;


/* parameters */

#Part 1
param WaitingTime	{m in ENTRANCE};
param ReductionTime	{n in ELEMENT};
param CostPerDay	{n in ELEMENT};


#Part 2
param TimePresentation {m in ROBOTS};
param EnergyPerUnit {m in ROBOTS};
param MaxEnergy {m in ROBOTS};
param NumItems {n in GALLERIES};


/*decision variables*/
var units {m in ENTRANCE, n in ELEMENT} integer;
var assign {m in ROBOTS, n in GALLERIES} binary;


/*Objective Function*/
minimize Time : (sum{m in ROBOTS, n in GALLERIES} assign[m,n]*NumItems[n]*TimePresentation[m]) + ((sum{m in ENTRANCE} (WaitingTime[m]-(sum{n in ELEMENT} units[m,n]*ReductionTime[n])))/3);

/*Constraints*/

##Part 1

#Total investment for purchasing all elements for all three entrances shall be not greater than €1000:
s.t. TotalCost : sum{m in ENTRANCE, n in ELEMENT} units[m,n]*CostPerDay[n] <= 1000;

#Main entrance investment shall be less than 10% over the investment of any of the secondary entrances:
s.t. MainOverSecondaryCost{s in NOTMAIN} : ((sum{n in ELEMENT} units[s,n]*CostPerDay[n])*1.1)-(sum{m in MAIN, n in ELEMENT} units[m,n]*CostPerDay[n]) >= 0.1;

#Number of vending machines and turnstiles in main entrance shall be more than those of any secondary entrance:
s.t. MainOverSecondaryQuantity{s in NOTMAIN} : (sum{m in MAIN, n in MCH_TRN} units[m,n])-(sum{n in MCH_TRN} units[s,n]) >= 1;

#West entrance shall have more turnstiles than North entrance:
s.t. WestOverNorthQuantity : (sum{m in WEST, n in TURNSTILE} units[m,n])-(sum{m in NORTH, n in TURNSTILE} units[m,n]) >= 1;

#Main entrance shall have at least two units of each element (vending machines, turnstiles and employees):
s.t. MainMinTwoOfEachElement{m in MAIN, n in ELEMENT}:  units[m,n] >= 2;

#Any secondary entrance shall have at least one unit of each element (vending machines, turnstiles and employees):
s.t. SecondaryMinOneOfEachElement{m in NOTMAIN, n in ELEMENT}: units[m,n] >= 1;

#The reduction in the average waiting time shall be larger in the main entrance than in any of the secondary ones:
s.t. ReductionTimeMainOverSecondary{s in NOTMAIN} : (sum{m in MAIN, n in ELEMENT} units[m,n]*ReductionTime[n])-(sum{n in ELEMENT} units[s,n]*ReductionTime[n]) >= 1;


##Part 2

#Each gallery shall have only one robot:
s.t. OneRobotPerGallerie{n in GALLERIES} : sum{m in ROBOTS} assign[m,n] = 1;

#Each robot shall be assigned to at least two galleries:
s.t. EachRobotMinTwoGaleries{m in ROBOTS} : sum{n in GALLERIES} assign[m,n] >= 2;

#Each robot shall not be assigned to more than three galleries:
s.t. EachRobotMaxThreeGalleries{m in ROBOTS} : sum{n in GALLERIES} assign[m,n] <=3;

#Robots r3, r5 and r6 shall not be assigned to west side galleries:
s.t. NotInWestSide : sum{m in NOTWEST, n in WESTGALLERIES} assign[m,n] = 0;

#Robots r2 and r4 shall not be assigned to east side galleries:
s.t. NotInEastSide: sum{m in NOTEAST, n in EASTGALLERIES} assign[m,n] = 0;

#Robots assigned to galleries C,D (or both) shall also be assigned to galleries A, B (or both):
s.t. IfHallsCD_AlsoHallsAB{m in ROBOTS} : (2*(sum{n in HALLSAB} assign[m,n]))-(sum{n in HALLSCD} assign[m,n]) >= 0;

#Robots shall be assigned to galleries which have enough energy to introduce all items in them:
s.t. EnoughEnergyForGallery{m in ROBOTS} : MaxEnergy[m]-(sum{n in GALLERIES} assign[m,n]*NumItems[n]*EnergyPerUnit[m]) >= 0;

#Presentations in the west side galleries shall take 10% longer than those in the east side:
s.t. WestTakesLonger : (1.1*(sum{m in ROBOTS, n in WESTGALLERIES} assign[m,n]*NumItems[n]*TimePresentation[m]))-(sum{m in ROBOTS, n in EASTGALLERIES} assign[m,n]*NumItems[n]*TimePresentation[m]) >= 0.1;

end;
