# Sets and parameters - yes
param nRows;
param cashierCount;
param cashierLength;
set ProductGroups;
param space{ProductGroups};
set Rows := 1..nRows;
set Cashiers := 1..cashierCount;

# Variables
var productInRow{Rows, ProductGroups} binary;
var lengthOfRow{Rows} >= 0;
var cashierInRow{Rows, Cashiers} binary;
var lengthOfStore >= 0;

# Constraints
s.t. oneProductHasToBeInOneRowOnly{p in ProductGroups}:
	sum{r in Rows} productInRow[r,p]=1;

s.t. calculateLengthOfRows{r in Rows}:
	lengthOfRow[r] = sum{p in ProductGroups} productInRow[r,p]*space[p] + sum{c in Cashiers} cashierInRow[r,c]*cashierLength;

s.t. eachCashierNeedsToBePlacedInARow{c in Cashiers}:
	sum{r in Rows} cashierInRow[r,c]=1;

s.t. calculateLengthOfStore{r in Rows}:
	lengthOfStore >= lengthOfRow[r];

# Objective function

minimize LengthOfShop: lengthOfStore;

# Print out
solve;

printf "%f\n",lengthOfStore;

# Data
data;


param nRows         :=   3;
param cashierCount  :=   1;
param cashierLength := 2.5;

set ProductGroups :=  Group1 Group2 Group3 Group4 Group5 Group6 Group7 Group8;

param space :=
Group1	0.04
Group2	0.62
Group3	0.13
Group4	1.28
Group5	0.56
Group6	0.21
Group7	1.39
Group8	1.47
;
end;
