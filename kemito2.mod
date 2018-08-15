#test change for commenting

model;
set AVOCADOSUPPLIERS;
set APPLESUPPLIERS;
set PACKHOUSES;
set AVOCADODEMANDS;
set APPLEDEMANDS;
set SIZES;
set HISTORICAL;

param AvocadoSupplierToPackhouse {AVOCADOSUPPLIERS,PACKHOUSES};
param AvocadoPackhouseToDemand {PACKHOUSES,AVOCADODEMANDS};
param AvocadoDemand {AVOCADODEMANDS};

set NODES := (AVOCADOSUPPLIERS) union (PACKHOUSES) union (AVOCADODEMANDS);
set ARCS := (AVOCADOSUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross AVOCADODEMANDS);

param Cost {ARCS};
param AvocadoSupply {AVOCADOSUPPLIERS} >= 0;
param AvocadoDemandHistorical {AVOCADODEMANDS,HISTORICAL} >= 0;
param PackingRate {SIZES} >= 0;
param MachineCost {SIZES} >= 0;

param netDemand {n in NODES, h in HISTORICAL}:=
	if n in AVOCADOSUPPLIERS then -AvocadoSupply[n] else if n in AVOCADODEMANDS then AvocadoDemandHistorical[n,h];

var Build {SIZES,PACKHOUSES} >=0, <=50, integer;
var Flow {(i,j) in ARCS,h in HISTORICAL} >= 0,<=99999999999999;

set APPLENODES := (APPLESUPPLIERS) union (PACKHOUSES) union (APPLEDEMANDS);
set APPLEARCS := (APPLESUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross APPLEDEMANDS);

param AppleDemandHistorical {APPLEDEMANDS,HISTORICAL};
param ApplePackhouseToDemand {PACKHOUSES,APPLEDEMANDS};
param AppleSupplierToPackhouse {APPLESUPPLIERS,PACKHOUSES};
param AppleCost {APPLEARCS};
param AppleSupply {APPLESUPPLIERS} >= 0;
param AppleDemand {APPLEDEMANDS} >= 0;

param netDemandApples {n in APPLENODES, h in HISTORICAL}:=
	if n in APPLESUPPLIERS then -AppleSupply[n] else if n in APPLEDEMANDS then AppleDemandHistorical[n,h];



	
var AppleBuild {SIZES,PACKHOUSES}, >= 0, <= 50, integer;
var AppleFlow {(i,j) in APPLEARCS, h in HISTORICAL} >= 0,<= 9999999999999;

var AvocadoConfigCost = sum{s in SIZES, i in PACKHOUSES} 1000*MachineCost[s]*Build[s,i];
var AppleConfigCost = sum{s in SIZES, i in PACKHOUSES} 1000*MachineCost[s]*AppleBuild[s,i];
var MinCost = min{h in HISTORICAL} (sum {(i,j) in ARCS} Cost[i, j] * Flow[i, j, h] + sum {(k,l) in APPLEARCS} AppleCost[k, l] * AppleFlow[k, l, h]) + AvocadoConfigCost + AppleConfigCost ;
var MaxCost = max{h in HISTORICAL} (sum {(i,j) in ARCS} Cost[i, j] * Flow[i, j, h] +sum {(k,l) in APPLEARCS} AppleCost[k, l] * AppleFlow[k, l, h]) + AvocadoConfigCost + AppleConfigCost ;
var ExpectedCost = (sum {(i,j) in ARCS,h in HISTORICAL} Cost[i, j] * Flow[i, j, h] + sum {(k,l) in APPLEARCS,h in HISTORICAL} AppleCost[k, l] * AppleFlow[k, l, h])/10 + AvocadoConfigCost + AppleConfigCost;


minimize TotalCost :
  sum {(i,j) in ARCS,h in HISTORICAL}
    Cost[i, j] * Flow[i, j, h] + sum{s in SIZES, i in PACKHOUSES} 1000*MachineCost[s]*Build[s,i] +  sum {(k,l) in APPLEARCS, h in HISTORICAL}
    AppleCost[k, l] * AppleFlow[k, l, h] + sum{s in SIZES, k in PACKHOUSES} 1000*MachineCost[s]*AppleBuild[s,k];


#subject to UseSupply {i in AVOCADOSUPPLIERS}:
#  sum {(i,j) in ARCS} Flow[i, j]/Conversion[j] = Supply[i];

#subject to MeetDemand {j in AVOCADODEMANDS}:
#  sum {(i,j) in ARCS} Flow[i, j] = Demand[j];

subject to conserveFlow {j in NODES,  h in HISTORICAL}:
  sum {(i,j) in ARCS} Flow[i, j, h] - sum {(j,k) in ARCS}Flow[j, k, h] >= netDemand[j,h];

subject to MeetCapacity {i in PACKHOUSES, h in HISTORICAL}:
  sum {(i,j) in ARCS} Flow[i, j, h] <= sum{s in SIZES} PackingRate[s]*Build[s,i];
  
subject to conserveFlowApples {j in APPLENODES, h in HISTORICAL}:
  sum {(i,j) in APPLEARCS} AppleFlow[i, j, h] - sum {(j,k) in APPLEARCS}AppleFlow[j, k, h] >= netDemandApples[j,h];

subject to MeetCapacityApples {i in PACKHOUSES, h in HISTORICAL}:
  sum {(i,j) in APPLEARCS} AppleFlow[i, j, h] <= sum{s in SIZES} PackingRate[s]*AppleBuild[s,i];
  

