model;

set AVOCADO_SUPPLIERS;
set APPLE_SUPPLIERS;
set PACKHOUSES;
set AVOCADO_DEMANDS;
set APPLE_DEMANDS;
set SIZES;
set HISTORICAL;
set AVOCADO_NODES := (AVOCADO_SUPPLIERS) union (PACKHOUSES) union (AVOCADO_DEMANDS);
set AVOCADO_ARCS := (AVOCADO_SUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross AVOCADO_DEMANDS);
set APPLE_NODES := (APPLE_SUPPLIERS) union (PACKHOUSES) union (APPLE_DEMANDS);
set APPLE_ARCS := (APPLE_SUPPLIERS cross PACKHOUSES) union (PACKHOUSES cross APPLE_DEMANDS);

param AvocadoSupplierToPackhouse {AVOCADO_SUPPLIERS,PACKHOUSES};
param AvocadoPackhouseToDemand {PACKHOUSES,AVOCADO_DEMANDS};
param AvocadoDemandHistorical {AVOCADO_DEMANDS,HISTORICAL};
param AvocadoCost {AVOCADO_ARCS};
param AvocadoSupply {AVOCADO_SUPPLIERS} >= 0;
param AvocadoDemand {AVOCADO_DEMANDS} >= 0;
param AvocadoLower {AVOCADO_ARCS} >= 0 , default 0;
param AvocadoUpper {(i,j) in AVOCADO_ARCS} >= AvocadoLower[i,j], default Infinity;

param AppleSupplierToPackhouse {APPLE_SUPPLIERS,PACKHOUSES};
param ApplePackhouseToDemand {PACKHOUSES,APPLE_DEMANDS};
param AppleDemandHistorical {APPLE_DEMANDS,HISTORICAL};
param AppleCost {APPLE_ARCS};
param AppleSupply {APPLE_SUPPLIERS} >= 0;
param AppleDemand {APPLE_DEMANDS} >= 0;
param AppleLower {APPLE_ARCS} >= 0, default 0;
param AppleUpper {(i,j) in APPLE_ARCS} >= AppleLower[i,j], default Infinity;

param PackingRate {SIZES} >= 0;
param MachineCost {SIZES} >= 0;

param NetDemandAvocado {n in AVOCADO_NODES}:=
	if n in AVOCADO_SUPPLIERS then -AvocadoSupply[n] else if n in AVOCADO_DEMANDS then AvocadoDemand[n];
param NetDemandApples {n in APPLE_NODES}:=
	if n in APPLE_SUPPLIERS then -AppleSupply[n] else if n in APPLE_DEMANDS then AppleDemand[n];

var AvocadoBuild {SIZES,PACKHOUSES} >=0, <= Infinity, integer;
var AvocadoFlow {(i,j) in AVOCADO_ARCS} >= AvocadoLower[i,j], <= AvocadoUpper[i,j], integer; # Added integer constraint 4/09/18
var AppleBuild {SIZES,PACKHOUSES}, >= 0, <= Infinity, integer;
var AppleFlow {(i,j) in APPLE_ARCS} >= AppleLower[i,j], <= AppleUpper[i,j], integer; # Added integer constraint 4/09/18

minimize TotalCost :
  sum {(i,j) in AVOCADO_ARCS}
    AvocadoCost[i, j] * AvocadoFlow[i, j] + sum{s in SIZES, i in PACKHOUSES} MachineCost[s] * AvocadoBuild[s,i] +  sum {(k,l) in APPLE_ARCS}
    AppleCost[k, l] * AppleFlow[k, l] + sum{s in SIZES, k in PACKHOUSES} MachineCost[s] * AppleBuild[s,k];

subject to ConserveFlowAvocados {j in AVOCADO_NODES}:
  sum {(i,j) in AVOCADO_ARCS} AvocadoFlow[i, j] - sum {(j,k) in AVOCADO_ARCS}AvocadoFlow[j, k] >= NetDemandAvocado[j];

subject to MeetCapacityAvocados {i in PACKHOUSES}:
  sum {(i,j) in AVOCADO_ARCS} AvocadoFlow[i, j] <= sum{s in SIZES} PackingRate[s] * AvocadoBuild[s,i];

subject to ConserveFlowApples {j in APPLE_NODES}:
  sum {(i,j) in APPLE_ARCS} AppleFlow[i, j] - sum {(j,k) in APPLE_ARCS}AppleFlow[j, k] >= NetDemandApples[j];

subject to MeetCapacityApples {i in PACKHOUSES}:
  sum {(i,j) in APPLE_ARCS} AppleFlow[i, j] <= sum{s in SIZES} PackingRate[s] * AppleBuild[s,i];

