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
param AppleDemandHistorical {APPLEDEMANDS,HISTORICAL};
param AppleSupply {APPLESUPPLIERS};

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

var Build {SIZES,PACKHOUSES}, integer;
var Flow {(i,j) in ARCS} >= Lower[i,j],<=Upper[i,j];

minimize TotalCost :
  sum {(i,j) in ARCS}
    Cost[i, j] * Flow[i, j] + sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*Build[s,i];

#subject to UseSupply {i in AVOCADOSUPPLIERS}:
#  sum {(i,j) in ARCS} Flow[i, j]/Conversion[j] = Supply[i];

#subject to MeetDemand {j in AVOCADODEMANDS}:
#  sum {(i,j) in ARCS} Flow[i, j] = Demand[j];

subject to conserveFlow {j in NODES}:
  sum {(i,j) in ARCS} Flow[i, j] - sum {(j,k) in ARCS}Flow[j, k] >= netDemand[j];

subject to MeetCapacity {i in PACKHOUSES}:
  sum {(i,j) in ARCS} Flow[i, j] <= sum{s in SIZES} PackingRate[s]*Build[s,i];
