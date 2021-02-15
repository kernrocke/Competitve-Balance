

clear
capture log close
cls

**  GENERAL DO-FILE META-DATA
**  Program:		CB_cricket_001
**  Project:      	Competitive Balance for Domestic 50-Over Tournaments
**  Analyst:		Kern Rocke
**	Date Created:	14/02/2021
**	Date Modified: 	14/02/2021
**  Algorithm Task: Country comparison of Competitive Balance


** DO-FILE SET UP COMMANDS
version 13
clear all
macro drop _all
set more 1
set linesize 150

** Set working directories: this is for DATASET and LOG files
local datapath "/Users/kernrocke/OneDrive - The University of the West Indies"
local dopath "/Users/kernrocke/OneDrive - The University of the West Indies/Github Repositories"
local logpath "/Users/kernrocke/OneDrive - The University of the West Indies"

**Set up user driven command
ssc install fillmissing, replace

*--------------------------------------------------------------------------------
**WEST INDIES
*Load in data for data management and analysis (WI-Super 50 Regional Tournament)
import excel using "`datapath'/Manuscripts/Competitive Balance/Data/WI_Super_50.xlsx", sheet("WI") firstrow clear

*Run CB and CBICB analysis
do "`dopath'/Competitve-Balance/CB_cricket_000a.do"

*Create country variable
gen country = 2 // West Indies

*Save dataset
save "`datapath'/Manuscripts/Competitive Balance/Data/WI_50_CB.dta", replace
*--------------------------------------------------------------------------------
**ENGLAND
*Load in data for data management and analysis (Eng- Natwest Blast Tournament)
import excel using "`datapath'/Manuscripts/Competitive Balance/Data/WI_Super_50.xlsx", sheet("Eng") firstrow clear

*Run CB and CBICB analysis
do "`dopath'/Competitve-Balance/CB_cricket_000a.do"

*Create country variable
gen country = 1 // England

*Save dataset
save "`datapath'/Manuscripts/Competitive Balance/Data/Eng_50_CB.dta", replace
*--------------------------------------------------------------------------------

use "`datapath'/Manuscripts/Competitive Balance/Data/Eng_50_CB.dta", clear
append using "`datapath'/Manuscripts/Competitive Balance/Data/WI_50_CB.dta"

label define country 1 "England" 2" West Indies"
label value country country


*Bar Chart of C5ICB by Year

#delimit;
twoway 
	(connected C5ICB Year if country == 1)
	(connected C5ICB Year if country == 2)
			, 
			
			yscale(reverse) 
			ylabel(100(10)180, angle(horizontal) nogrid)
			xlabel(2009(1)2019, angle(45))
			
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(10)
			
			title("C5ICB by Year" "Domestic 50-Over Cricket Tournaments", 
				c(black) size(medium))
			
			name(C5ICB)
			legend(on  col(2) order(1 2) 
				lab(1 "England") 
				lab(2 "West Indies")
			
			region(fcolor(gs16) lw(vthin) ))
;
#delimit cr
*--------------------------------------------------------------------------------
