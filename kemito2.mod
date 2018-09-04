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
param AvocadoDemand {AVOCADO_DEMANDS};
param AvocadoCost {AVOCADO_ARCS};
param AvocadoSupply {AVOCADO_SUPPLIERS} >= 0;
param AvocadoDemandHistorical {AVOCADO_DEMANDS,HISTORICAL} >= 0;

param AppleDemandHistorical {APPLE_DEMANDS,HISTORICAL};
param ApplePackhouseToDemand {PACKHOUSES,APPLE_DEMANDS};
param AppleSupplierToPackhouse {APPLE_SUPPLIERS,PACKHOUSES};
param AppleCost {APPLE_ARCS};
param AppleSupply {APPLE_SUPPLIERS} >= 0;
param AppleDemand {APPLE_DEMANDS} >= 0;

param PackingRate {SIZES} >= 0;
param MachineCost {SIZES} >= 0;

param NetDemandAvocado {n in AVOCADO_NODES, h in HISTORICAL}:=
	if n in AVOCADO_SUPPLIERS then -AvocadoSupply[n] else if n in AVOCADO_DEMANDS then AvocadoDemandHistorical[n,h];

param NetDemandApples {n in APPLE_NODES, h in HISTORICAL}:=
	if n in APPLE_SUPPLIERS then -AppleSupply[n] else if n in APPLE_DEMANDS then AppleDemandHistorical[n,h];

var AvocadoBuild {SIZES,PACKHOUSES} >=0, <=Infinity, integer;
var AvocadoFlow {(i,j) in AVOCADO_ARCS,h in HISTORICAL} >= 0,<=Infinity, integer; # 4/09/18 added integer constraint

var AppleBuild {SIZES,PACKHOUSES}, >= 0, <= Infinity, integer;
var AppleFlow {(i,j) in APPLE_ARCS, h in HISTORICAL} >= 0,<= Infinity, integer; # 4/09/18 added integer constraint

var AvocadoConfigCost = sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*AvocadoBuild[s,i];
var AppleConfigCost = sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*AppleBuild[s,i];
var MinCost = min {h in HISTORICAL} (sum {(i,j) in AVOCADO_ARCS} AvocadoCost[i, j] * AvocadoFlow[i, j, h] + sum {(k,l) in APPLE_ARCS} AppleCost[k, l] * AppleFlow[k, l, h]) + AvocadoConfigCost + AppleConfigCost ;
var MaxCost = max {h in HISTORICAL} (sum {(i,j) in AVOCADO_ARCS} AvocadoCost[i, j] * AvocadoFlow[i, j, h] +sum {(k,l) in APPLE_ARCS} AppleCost[k, l] * AppleFlow[k, l, h]) + AvocadoConfigCost + AppleConfigCost ;
var ExpectedCost = (sum {(i,j) in AVOCADO_ARCS, h in HISTORICAL} AvocadoCost[i, j] * AvocadoFlow[i, j, h] + sum {(k,l) in APPLE_ARCS,h in HISTORICAL} AppleCost[k, l] * AppleFlow[k, l, h])/10 + AvocadoConfigCost + AppleConfigCost;

# Original objective function
minimize TotalCost :
  sum {(i,j) in AVOCADO_ARCS, h in HISTORICAL}
    AvocadoCost[i, j] * AvocadoFlow[i, j, h] + sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*AvocadoBuild[s,i] +  sum {(k,l) in APPLE_ARCS, h in HISTORICAL}
    AppleCost[k, l] * AppleFlow[k, l, h] + sum{s in SIZES, k in PACKHOUSES} MachineCost[s]*AppleBuild[s,k];

# Trying different objective function - multiplying build costs by 10 for the 10 periods
/* minimize TotalCost :
	sum {(i,j) in AVOCADO_ARCS, h in HISTORICAL}
		AvocadoCost[i, j] * AvocadoFlow[i, j, h] + 10*(sum{s in SIZES, i in PACKHOUSES} MachineCost[s]*AvocadoBuild[s,i]) +  sum {(k,l) in APPLE_ARCS, h in HISTORICAL}
		AppleCost[k, l] * AppleFlow[k, l, h] + 10*(sum{s in SIZES, k in PACKHOUSES} MachineCost[s]*AppleBuild[s,k]); */

subject to ConserveFlowAvocados {j in AVOCADO_NODES,  h in HISTORICAL}:
  sum {(i,j) in AVOCADO_ARCS} AvocadoFlow[i, j, h] - sum {(j,k) in AVOCADO_ARCS}AvocadoFlow[j, k, h] >= NetDemandAvocado[j,h];

subject to MeetCapacityAvocados {i in PACKHOUSES, h in HISTORICAL}:
  sum {(i,j) in AVOCADO_ARCS} AvocadoFlow[i, j, h] <= sum{s in SIZES} PackingRate[s]*AvocadoBuild[s,i];

subject to ConserveFlowApples {j in APPLE_NODES, h in HISTORICAL}:
  sum {(i,j) in APPLE_ARCS} AppleFlow[i, j, h] - sum {(j,k) in APPLE_ARCS}AppleFlow[j, k, h] >= NetDemandApples[j,h];

subject to MeetCapacityApples {i in PACKHOUSES, h in HISTORICAL}:
  sum {(i,j) in APPLE_ARCS} AppleFlow[i, j, h] <= sum{s in SIZES} PackingRate[s]*AppleBuild[s,i];
