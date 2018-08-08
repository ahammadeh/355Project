#test change for commenting

model;
set SUPPLY_NODES;
set PLANT_NODES;
set DEMAND_NODES;
set SIZES;

param FromMineCost {SUPPLY_NODES,PLANT_NODES};
param ToCustCost {PLANT_NODES,DEMAND_NODES};

set NODES :=(SUPPLY_NODES) union (PLANT_NODES) union (DEMAND_NODES);
set ARCS := (SUPPLY_NODES cross PLANT_NODES) union (PLANT_NODES cross DEMAND_NODES);

param Cost {ARCS};
param Supply {SUPPLY_NODES} >= 0;
param Demand {DEMAND_NODES} >= 0;
param LOWER {ARCS} >= 0 , default 0;
param UPPER {(i,j) in ARCS} >= LOWER[i,j], default 99999999999;
param Capacity {SIZES} >= 0;
param CCost {SIZES} >= 0;
param Conversion {NODES} >=0, default 1;

param netDemand {n in NODES}:=
	if n in SUPPLY_NODES then -Supply[n] else if n in DEMAND_NODES then Demand[n];

var Build {SIZES,PLANT_NODES}, binary;
var Flow {(i,j) in ARCS} >= LOWER[i,j],<=UPPER[i,j];

minimize TotalCost :
  sum {(i,j) in ARCS}
    Cost[i, j] * Flow[i, j] + sum{s in SIZES, i in PLANT_NODES} 1000000*CCost[s]*Build[s,i];

#subject to UseSupply {i in SUPPLY_NODES}:
#  sum {(i,j) in ARCS} Flow[i, j]/Conversion[j] = Supply[i];

#subject to MeetDemand {j in DEMAND_NODES}:
#  sum {(i,j) in ARCS} Flow[i, j] = Demand[j];

subject to conserveFlow {j in NODES}:
  sum {(i,j) in ARCS} Flow[i, j]/Conversion[j] - sum {(j,k) in ARCS}Flow[j, k] >= netDemand[j];
  
subject to MeetCapacity {i in PLANT_NODES}:
  sum {(i,j) in ARCS} Flow[i, j] <= sum{s in SIZES} Capacity[s]*Build[s,i];
  
subject to maxPlants {i in PLANT_NODES}:
  sum {s in SIZES} Build[s,i] <=1;
  
