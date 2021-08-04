**  GENERAL DO-FILE META-DATA
**  Program:		CB_chess_000a
**  Project:      	Competitive Balance for Champions Chess Tour
**  Analyst:		Kern Rocke
**	Date Created:	01/06/2021
**	Date Modified: 	04/08/2021
**  Algorithm Task: Development of Competitive Balance Indices

** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150

*Set working directory
local datapath "/Users/kernrocke/Downloads"


*Load in data (Skilling Open)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Skilling Open") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Skilling Open"
save "`datapath'/Skilling_Open_Chess.dta", replace

*Load in data (Airthings Masters)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Airthings Masters") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Airthings Masters"
save "`datapath'/Airthings_Masters_Chess.dta", replace

*Load in data (Opera Euro Rapid)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Opera Euro Rapid") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Opera Euro Rapid"
save "`datapath'/Opera_Euro_Rapid_Chess.dta", replace

*Load in data (Magnus Carlsen Invitational)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Magnus Carlsen Invitational") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Magnus Carlsen Invitational"
save "`datapath'/Magnus_Carlsen_Invitational_Chess.dta", replace

*Load in data (New in Chess Classic)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("New In Chess Classic") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "New in Chess Classic"
save "`datapath'/New_in_Chess_Classic_Chess.dta", replace

*Load in data (FTX Crypto Cup)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("FTX Crypto Cup") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "FTX Crypto Cup"
save "`datapath'/FTX_Crypto_Cup_Chess.dta", replace

*Load in data (Goldmoney Asian Open)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Goldmoney Asian Open") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Goldmoney Asian Open"
save "`datapath'/Goldmoney_Asian_Open_Chess.dta", replace

*Load in data (Chessable Masters)
import excel "`datapath'/Champions_Chess_Tour.xlsx", sheet("Chessable Masters") firstrow clear
rename A rank
label var rank "Competition Ranking"
keep rank Points ELO
gen competition = "Chessable Masters"
save "`datapath'/Chessable_Masters.dta", replace

*Merge all data together
use "`datapath'/Skilling_Open_Chess.dta"
append using "`datapath'/Airthings_Masters_Chess.dta"
append using "`datapath'/Opera_Euro_Rapid_Chess.dta"
append using "`datapath'/Magnus_Carlsen_Invitational_Chess.dta"
append using "`datapath'/New_in_Chess_Classic_Chess.dta"
append using "`datapath'/FTX_Crypto_Cup_Chess.dta"
append using "`datapath'/Goldmoney_Asian_Open_Chess.dta"
append using "`datapath'/Chessable_Masters.dta"
label var competition "Competition"


by competition, sort : egen float point_5 = total(Points) if rank<=5
label var point_5 "Points of top 5 players"

*Replace missing value with previous estimate
fillmissing point_5, with(previous)


*Points of all teams
by competition, sort : egen float point_total = total(Points)
label var point_total "Total Point of all teams"


*Create C5 Ratio
gen C5 = .
replace C5 = point_5/point_total
label var C5 "C5- Five-club concentration ratio"

*Total number of teams for each year
by competition, sort: gen n_players = _N
label var n_players "Total number of players"

*Create C5ICB variable
gen C5ICB = C5 / (5/n_players)
replace C5ICB = C5ICB*100
label var C5ICB "C5 Competitive Balance Index"

*Create S
gen S2 = (Points/point_total)^2

*Create HHI
by competition, sort: egen float HHI = total(S2)
label var HHI "HerfindahlÐHirschman Index"

*Creat HICB
gen HICB = HHI/(1/n_players)
replace HICB = HICB*100
label var HICB "HHI of Competitive Balance"

*Checking average FIDE ranking for each tournament
tabstat ELO, by(competition) stat(mean min max)

*Reduce dataset for simplicity
collapse (mean) C5ICB C5 HHI HICB ELO, by(competition)
label var C5ICB "C5 Competitive Balance Index"
label var C5 "C5- Five-club concentration ratio"
label var HICB "HHI of Competitive Balance"
label var HHI "HerfindahlÐHirschman Index"
label var ELO "FIDE Ranking"


*Create new competiton variable
gen compete = .
replace compete = 1 if competition == "Skilling Open"
replace compete = 2 if competition == "Airthings Masters"
replace compete = 3 if competition == "Opera Euro Rapid"
replace compete = 4 if competition == "Magnus Carlsen Invitational"
replace compete = 5 if competition == "New in Chess Classic"
replace compete = 6 if competition == "FTX Crypto Cup" 
replace compete = 7 if competition == "Goldmoney Asian Open"
replace compete = 8 if competition == "Chessable Masters"

label var compete "Champions Chess Tour"
label define compete 1"Skilling Open" 2"Airthings Masters" 3"Opera Euro Rapid" 4"Magnus Carlsen Invitational" 5"New in Chess Classic" 6"FTX Crypto Cup" 7"Goldmoney Asian Open" 8"Chessable Masters"
label value compete compete

*--------------------------------------------------------------------------------
*Line Chart of C5ICB by Year

#delimit;
twoway 
	(connected C5ICB compete, sort)
			, 
			
			yscale(reverse) 
			ylabel(100(5)130, angle(horizontal) nogrid)
			yline(100)
			xlabel(#7, angle(forty_five) labsize(small) valuelabel)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(10)
			
			title("C5ICB by Year" "Champions Chess Tour", 
				c(black) size(medium))
			
			name(C5ICB)

			
			
;
#delimit cr
*--------------------------------------------------------------------------------

*--------------------------------------------------------------------------------
*Line Chart of HICB by Year

#delimit;
twoway 
	(connected HICB compete, sort)
			, 
			
			yscale(reverse) 
			ylabel(100(2)116, angle(horizontal) nogrid)
			yline(100)
			xlabel(#7, angle(forty_five) labsize(small) valuelabel)
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(10)
			
			title("HICB by Year" "Champions Chess Tour", 
				c(black) size(medium))
			
			name(HICB)

			
			
;
#delimit cr
*--------------------------------------------------------------------------------

erase "`datapath'/Skilling_Open_Chess.dta"
erase "`datapath'/Airthings_Masters_Chess.dta"
erase "`datapath'/Opera_Euro_Rapid_Chess.dta"
erase "`datapath'/Magnus_Carlsen_Invitational_Chess.dta"
erase "`datapath'/New_in_Chess_Classic_Chess.dta"
erase "`datapath'/FTX_Crypto_Cup_Chess.dta"
erase "`datapath'/Goldmoney_Asian_Open_Chess.dta"
erase "`datapath'/Chessable_Masters.dta"


