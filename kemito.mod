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
param AvocadoDemandHistorical {AVOCADODEMANDS,HISTORICAL};

set NODES := (AVOCADOSUPPLIERS) union (PACKHOUSES) union (AVOCADODEMANDS);
set ARCS := (AVOCADOSUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross AVOCADODEMANDS);

param Cost {ARCS};
param AvocadoSupply {AVOCADOSUPPLIERS} >= 0;
param AvocadoDemand {AVOCADODEMANDS} >= 0;
param Lower {ARCS} >= 0 , default 0;
param Upper {(i,j) in ARCS} >= Lower[i,j], default 99999999999;
param PackingRate {SIZES} >= 0;
param MachineCost {SIZES} >= 0;

param netDemand {n in NODES}:=
	if n in AVOCADOSUPPLIERS then -AvocadoSupply[n] else if n in AVOCADODEMANDS then AvocadoDemand[n];

var Build {SIZES,PACKHOUSES} >=0, <=50, integer;
var Flow {(i,j) in ARCS} >= Lower[i,j],<=Upper[i,j];

set APPLENODES := (APPLESUPPLIERS) union (PACKHOUSES) union (APPLEDEMANDS);
set APPLEARCS := (APPLESUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross APPLEDEMANDS);

param AppleDemandHistorical {APPLEDEMANDS,HISTORICAL};
param ApplePackhouseToDemand {PACKHOUSES,APPLEDEMANDS};
param AppleSupplierToPackhouse {APPLESUPPLIERS,PACKHOUSES};
param AppleCost {APPLEARCS};
param AppleSupply {APPLESUPPLIERS} >= 0;
param AppleDemand {APPLEDEMANDS} >= 0;
param AppleLower {APPLEARCS} >= 0 , default 0;
param AppleUpper {(i,j) in APPLEARCS} >= AppleLower[i,j], default 99999999999;

param netDemandApples {n in APPLENODES}:=
	if n in APPLESUPPLIERS then -AppleSupply[n] else if n in APPLEDEMANDS then AppleDemand[n];

var AppleBuild {SIZES,PACKHOUSES}, >= 0, <= 50, integer;
var AppleFlow {(i,j) in APPLEARCS} >= AppleLower[i,j],<=AppleUpper[i,j];

minimize TotalCost :
  sum {(i,j) in ARCS}
    Cost[i, j] * Flow[i, j] + sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*Build[s,i] +  sum {(k,l) in APPLEARCS}
    AppleCost[k, l] * AppleFlow[k, l] + sum{s in SIZES, k in PACKHOUSES} MachineCost[s]*AppleBuild[s,k];


#subject to UseSupply {i in AVOCADOSUPPLIERS}:
#  sum {(i,j) in ARCS} Flow[i, j]/Conversion[j] = Supply[i];

#subject to MeetDemand {j in AVOCADODEMANDS}:
#  sum {(i,j) in ARCS} Flow[i, j] = Demand[j];

subject to conserveFlow {j in NODES}:
  sum {(i,j) in ARCS} Flow[i, j] - sum {(j,k) in ARCS}Flow[j, k] >= netDemand[j];

subject to MeetCapacity {i in PACKHOUSES}:
  sum {(i,j) in ARCS} Flow[i, j] <= sum{s in SIZES} PackingRate[s]*Build[s,i];
  
subject to conserveFlowApples {j in APPLENODES}:
  sum {(i,j) in APPLEARCS} AppleFlow[i, j] - sum {(j,k) in APPLEARCS}AppleFlow[j, k] >= netDemandApples[j];

subject to MeetCapacityApples {i in PACKHOUSES}:
  sum {(i,j) in APPLEARCS} AppleFlow[i, j] <= sum{s in SIZES} PackingRate[s]*AppleBuild[s,i];
  
  
