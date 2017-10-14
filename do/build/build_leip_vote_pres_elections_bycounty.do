/* compute county-level voting shares for 2000, 2004, 2008, 2012 presidential elections */

************************************************************************
clear all
set more off

global user = 1 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
global path = // Barbara path
}
************************************************************************


****************************** 2000 Presidential Election ******************************
import excel "$path/sanctuaries/data/dave_leip_election_data/Pres_Election_Data_2000.xlsx", sheet("County") cellrange(A1:M3465) clear

drop C D E F G H I

drop if A=="" & B=="" & J=="" & K=="" & L=="" & M==""

rename A county_name
rename B state_abbrev
rename J gore_vote_frac
rename K bush_vote_frac
rename L nader_vote_frac
rename M other_vote_frac

drop if gore_vote_frac=="Gore"
drop if state_abbrev=="T" //observations for states in aggregate
drop if state_abbrev=="PR" //drop Puerto Rico
drop if gore_vote_frac=="" //Alaska duplicate observations with missing info
drop if county_name=="Overseas"

destring gore_vote_frac, replace
destring bush_vote_frac, replace
destring other_vote_frac, replace
destring nader_vote_frac, replace


/*there are a few duplicates in terms of county_name and state_abbrev. i'm going
	to sort the ambiguity looking at the raw data and changing names in a meaningful way*/
replace county_name = "St. Louis City"	if county_name=="St. Louis" & state_abbrev=="MO" & inrange(gore_vote_frac,.7,.8)
replace county_name = "Bedford City"	if county_name=="Bedford"   & state_abbrev=="VA" & inrange(gore_vote_frac,.4,.5)		
replace county_name = "Fairfax City"	if county_name=="Fairfax"   & state_abbrev=="VA" & inrange(gore_vote_frac,.45,.46)		
replace county_name = "Franklin City"	if county_name=="Franklin"  & state_abbrev=="VA" & inrange(gore_vote_frac,.5,.6)	
replace county_name = "Richmond City"	if county_name=="Richmond"  & state_abbrev=="VA" & inrange(gore_vote_frac,.6,.7)
replace county_name = "Roanoke City"	if county_name=="Roanoke"   & state_abbrev=="VA" & inrange(gore_vote_frac,.5,.6)	
	
	
gen rep_vote_frac=bush_vote_frac
gen dem_vote_frac=gore_vote_frac
replace other_vote_frac=nader_vote_frac+other_vote_frac
drop bush_vote_frac	gore_vote_frac nader_vote_frac

gen year=2000

order county_name state_abbrev year rep_vote_frac dem_vote_frac other_vote_frac

save "$path/sanctuaries/data/output_datasets/pres_election_2000_bycounty.dta", replace 







****************************** 2004 Presidential Election ******************************
import excel "$path/sanctuaries/data/dave_leip_election_data/Pres_Election_Data_2004.xlsx", sheet("County") cellrange(A1:M3420) firstrow case(lower) clear

drop totalvote k e n margin h i

drop if expandatleft=="" & b=="" & kerry==. & bush==. & nader==. & other==.

rename expandatleft county_name
rename b			state_abbrev

drop if state_abbrev=="T" //observations for states in aggregate
drop if state_abbrev=="PR" //drop Puerto Rico
drop if county_name=="Overseas"
drop if kerry==. //Alaska duplicate observations with missing info

/*there are a few duplicates in terms of county_name and state_abbrev. i'm going
	to sort the ambiguity looking at the raw data and changing names in a meaningful way*/
replace county_name = "Bedford City"	if county_name=="Bedford"   & state_abbrev=="VA" & inrange(kerry,.4,.5)		
replace county_name = "Fairfax City"	if county_name=="Fairfax"   & state_abbrev=="VA" & inrange(kerry,.5,.52)		
replace county_name = "Franklin City"	if county_name=="Franklin"  & state_abbrev=="VA" & inrange(kerry,.5,.6)	
replace county_name = "Richmond City"	if county_name=="Richmond"  & state_abbrev=="VA" & inrange(kerry,.65,.75)
replace county_name = "Roanoke City"	if county_name=="Roanoke"   & state_abbrev=="VA" & inrange(kerry,.5,.6)
replace county_name = "St. Louis City"	if county_name=="St. Louis" & state_abbrev=="MO" & inrange(kerry,.8,.81)
replace county_name = "Baltimore City"	if county_name=="Baltimore" & state_abbrev=="MD" & inrange(kerry,.8,.85)

rename bush rep_vote_frac
rename kerry dem_vote_frac
gen other_vote_frac = nader + other
drop nader other

gen year=2004

order county_name state_abbrev year rep_vote_frac dem_vote_frac other_vote_frac

save "$path/sanctuaries/data/output_datasets/pres_election_2004_bycounty.dta", replace 



****************************** 2008 Presidential Election ******************************
import excel "$path/sanctuaries/data/dave_leip_election_data/Pres_Election_Data_2008.xlsx", sheet("County") cellrange(A1:M3456) firstrow case(lower) clear

drop totalvote o m n margin h i

drop if expandatleft=="" & b=="" & obama==. & mccain==. & nader==. & other==.

rename expandatleft county_name
rename b			state_abbrev

drop if state_abbrev=="T" //observations for states in aggregate
drop if state_abbrev=="PR" //drop Puerto Rico
drop if county_name=="Overseas"
drop if obama==. //Alaska duplicate observations with missing info


/*there are a few duplicates in terms of county_name and state_abbrev. i'm going
	to sort the ambiguity looking at the raw data and changing names in a meaningful way*/
replace county_name = "Bedford City"	if county_name=="Bedford"   & state_abbrev=="VA" & inrange(obama,.4,.5)		
replace county_name = "Fairfax City"	if county_name=="Fairfax"   & state_abbrev=="VA" & inrange(obama,.57,.58)		
replace county_name = "Franklin City"	if county_name=="Franklin"  & state_abbrev=="VA" & inrange(obama,.6,.7)	
replace county_name = "Richmond City"	if county_name=="Richmond"  & state_abbrev=="VA" & inrange(obama,.7,.8)
replace county_name = "Roanoke City"	if county_name=="Roanoke"   & state_abbrev=="VA" & inrange(obama,.6,.7)
replace county_name = "St. Louis City"	if county_name=="St. Louis" & state_abbrev=="MO" & inrange(obama,.8,.9)
replace county_name = "Baltimore City"	if county_name=="Baltimore" & state_abbrev=="MD" & inrange(obama,.8,.9)

rename mccain rep_vote_frac
rename obama dem_vote_frac
gen other_vote_frac = nader + other
drop nader other

gen year=2008

order county_name state_abbrev year rep_vote_frac dem_vote_frac other_vote_frac

save "$path/sanctuaries/data/output_datasets/pres_election_2008_bycounty.dta", replace 




****************************** 2012 Presidential Election ******************************
import excel "$path/sanctuaries/data/dave_leip_election_data/Pres_Election_Data_2012.xlsx", sheet("County") cellrange(A1:M3458) firstrow case(lower) clear

drop totalvote o r f margin h i l

drop if expandatleft=="" & b=="" & obama==. & romney==.  & other==.

rename expandatleft county_name
rename b			state_abbrev

drop if state_abbrev=="T" //observations for states in aggregate
drop if state_abbrev=="PR" //drop Puerto Rico
drop if county_name=="Overseas"
drop if obama==. //Alaska duplicate observations with missing info


/*there are a few duplicates in terms of county_name and state_abbrev. i'm going
	to sort the ambiguity looking at the raw data and changing names in a meaningful way*/
replace county_name = "Bedford City"	if county_name=="Bedford"   & state_abbrev=="VA" & inrange(obama,.4,.5)		
replace county_name = "Fairfax City"	if county_name=="Fairfax"   & state_abbrev=="VA" & inrange(obama,.57,.58)		
replace county_name = "Franklin City"	if county_name=="Franklin"  & state_abbrev=="VA" & inrange(obama,.6,.7)	
replace county_name = "Richmond City"	if county_name=="Richmond"  & state_abbrev=="VA" & inrange(obama,.7,.8)
replace county_name = "Roanoke City"	if county_name=="Roanoke"   & state_abbrev=="VA" & inrange(obama,.6,.7)
replace county_name = "St. Louis City"	if county_name=="St. Louis" & state_abbrev=="MO" & inrange(obama,.8,.9)
replace county_name = "Baltimore City"	if county_name=="Baltimore" & state_abbrev=="MD" & inrange(obama,.8,.9)

rename romney rep_vote_frac
rename obama dem_vote_frac
rename other other_vote_frac

gen year=2012

order county_name state_abbrev year rep_vote_frac dem_vote_frac other_vote_frac

save "$path/sanctuaries/data/output_datasets/pres_election_2012_bycounty.dta", replace 

