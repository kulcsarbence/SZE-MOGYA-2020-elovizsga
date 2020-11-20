# Sets and parameters
param nRows;
param cashierCount;
param cashierLength;
set ProductGroups;
param space{ProductGroups};
param averagePrice{ProductGroups};
set MustBeTogether within {ProductGroups, ProductGroups};
set MustBeSeparated within {ProductGroups, ProductGroups};
param maxRowLength;
set CustomerGroups;
param count{CustomerGroups};
param probabilityToBuy{CustomerGroups};
param buys{CustomerGroups, ProductGroups} binary;


set Rows := 1..nRows;
set Cashiers := 1..cashierCount;

param M := 100;

# Variables
var productInRow{Rows, ProductGroups} binary;
var lengthOfRow{Rows} >= 0;
var cashierInRow{Rows, Cashiers} binary;
var customerBuysPlus{Rows, CustomerGroups} >= 0;
var isThereSomethingHeWantsToBuy{Rows, CustomerGroups} binary;
var isCashierInRow{Rows} binary;

# Constraints

s.t. calculateIfCashierIsInRow{c in Cashiers, r in Rows}:
	isCashierInRow[r] >= cashierInRow[r,c];

s.t. calculateIfIsThereSomethingHeWantsToBuy{r in Rows, cg in CustomerGroups, p in ProductGroups}:
	isThereSomethingHeWantsToBuy[r,cg] >= buys[cg,p] * productInRow[r,p];

s.t. oneProductHasToBeInOneRowOnly{p in ProductGroups}:
	sum{r in Rows} productInRow[r,p]=1;

s.t. calculateLengthOfRows{r in Rows}:
	lengthOfRow[r] = sum{p in ProductGroups} productInRow[r,p]*space[p] + sum{c in Cashiers} cashierInRow[r,c]*cashierLength;

s.t. eachCashierNeedsToBePlacedInARow{c in Cashiers}:
	sum{r in Rows} cashierInRow[r,c]=1;

s.t. maxRowLengths{r in Rows}:
	lengthOfRow[r] <= maxRowLength;

s.t. mustBeInSameRowTheseProducts{r in Rows, (p1,p2) in MustBeTogether}:
	productInRow[r,p1] = productInRow[r,p2];

s.t. mustBeSeparatedTheseProducts{r in Rows, (p1,p2) in MustBeSeparated}:
	productInRow[r,p1] <= 1 - productInRow[r,p2];

s.t. customerBuysWithGivenProbabilityIfThereIsAProductHeWantedToBuy{r in Rows, cg in CustomerGroups}:
	customerBuysPlus[r,cg] >= sum{p2 in ProductGroups: buys[cg,p2]==0} productInRow[r,p2]*averagePrice[p2]*probabilityToBuy[cg] - M*(1-isThereSomethingHeWantsToBuy[r,cg]);

s.t. customerBuysWithGivenProbabilityIfThereIsAProductHeWantedToBuySECOND{r in Rows, cg in CustomerGroups}:
	customerBuysPlus[r,cg] <= sum{p2 in ProductGroups: buys[cg,p2]==0} productInRow[r,p2]*averagePrice[p2]*probabilityToBuy[cg] + M*(1-isThereSomethingHeWantsToBuy[r,cg]);

s.t. ifThereIsACashierThenOnThatRowThisHasNoEffect{r in Rows, cg in CustomerGroups}:
	customerBuysPlus[r,cg] >= 0-M*(1-isCashierInRow[r]);

s.t. ifThereIsACashierThenOnThatRowThisHasNoEffectSECOND{r in Rows, cg in CustomerGroups}:
	customerBuysPlus[r,cg] <= 0+M*(1-isCashierInRow[r]);

# Objective function

maximize OverallPlusBuys: 
	sum{cg in CustomerGroups, r in Rows} customerBuysPlus[r,cg]*count[cg];

# Print out
solve;

printf "%f\n",sum{cg in CustomerGroups, r in Rows} customerBuysPlus[r,cg]*count[cg];

end;
