

**  GENERAL DO-FILE META-DATA
**  Program:		CB_cricket_000a
**  Project:      	Competitive Balance for Domestic 50-Over Tournaments
**  Analyst:		Kern Rocke
**	Date Created:	14/02/2021
**	Date Modified: 	14/02/2021
**  Algorithm Task: Development of C5 and C5ICB

*Minor cleaning
drop if Year == .
label var Year "League Year"
label var Team "League Team"
label var Wins "Number of wins"
label var Losses "Number of losses"
label var Draws "Number of Draws"
label var Points "League Points"


/*
C5 Ratio = 
Total points won by the top 5 teams/Total number of points won by all teams

C5ICB =
C5 / (5/Number of teams in the league)

*/

*--------------------------------------------------------------------------------

*Sort data by year and points to obtain top teams by ranking of points
gsort Year -Points 

*Create ranking variable
by Year, sort : egen rank = seq()
label var rank "League Ranking"

*Points of top 5 team
by Year, sort : egen float point_5 = total(Points) if rank<=5
label var point_5 "Points of top 5 teams"

*Replace missing value with previous estimate
fillmissing point_5, with(previous)


*Points of all teams
by Year, sort : egen float point_total = total(Points)
label var point_total "Total Point of all teams"


*Create C5 Ratio
gen C5 = .
replace C5 = point_5/point_total
label var C5 "C5- Five-club concentration ratio"

*Total number of teams for each year
by Year, sort: gen n_teams = _N
label var n_teams "Total number of teams"

*Create C5ICB variable
gen C5ICB = C5 / (5/n_teams)
replace C5ICB = C5ICB*100
label var C5ICB "C5 Competitive Balance Index"

*Reduce dataset for simplicity
collapse (mean) C5ICB C5, by(Year)
label var C5ICB "C5 Competitive Balance Index"
label var C5 "C5- Five-club concentration ratio"

*----------------------------END------------------------------------------------
