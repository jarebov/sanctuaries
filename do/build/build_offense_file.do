*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: build_offense_file.do																			*
*						generates files with offenses at county-month-year, from URC-RetA files									* 
*																																*
*********************************************************************************************************************************

clear all
set more off

**************************
global user = 1 // 1 Jaime, 2 Barbara
if $user == 1{
	global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
	global path = "~/Dropbox/Research"
}
**************************

*foreach y of numlist 2000/2008 2010/2016{

local y = 2007

use "$path/sanctuaries/data/UCR_FBI/UCR_master_file/work/reta`y'.dta", clear


*drop Virgin Islands, American Samoa, Puerto Rico, Guam, Panama canal:
drop if statecode=="62" | statecode=="54" |statecode=="52" | statecode=="53" | statecode=="55"


/*Drop agencies that do not submit records directly. (If an agency did not submit its
	records directly -perhaps because of small size- the variable coveredby records
	the ORI of the agency through which it submitted its crime reports)		
	I have checked and all crimes are practically zero for those agencies covered by someone else*/					
drop if coveredby!=""

*keep only "Number of Actual Offenses"
drop cod*_c0_m*
drop cod*_c2_m*
drop cod*_c3_m*

*destring all offense counts:
foreach c in 1 {
	foreach k of numlist 1/28{
		foreach m of numlist 1/12{

		*negative entries have letter codes (see codebook) replace (still not sure what a negative entry means though)
		qui replace cod`k'_c`c'_m`m' = "0"   if cod`k'_c`c'_m`m'=="0000}"
		qui replace cod`k'_c`c'_m`m' = "-1"  if cod`k'_c`c'_m`m'=="0000J"
		qui replace cod`k'_c`c'_m`m' = "-2"  if cod`k'_c`c'_m`m'=="0000K"
		qui replace cod`k'_c`c'_m`m' = "-3"  if cod`k'_c`c'_m`m'=="0000L"
		qui replace cod`k'_c`c'_m`m' = "-4"  if cod`k'_c`c'_m`m'=="0000M"
		qui replace cod`k'_c`c'_m`m' = "-5"  if cod`k'_c`c'_m`m'=="0000N"
		qui replace cod`k'_c`c'_m`m' = "-6"  if cod`k'_c`c'_m`m'=="0000O"
		qui replace cod`k'_c`c'_m`m' = "-7"  if cod`k'_c`c'_m`m'=="0000P"
		qui replace cod`k'_c`c'_m`m' = "-8"  if cod`k'_c`c'_m`m'=="0000Q"
		qui replace cod`k'_c`c'_m`m' = "-9"  if cod`k'_c`c'_m`m'=="0000R"
		qui replace cod`k'_c`c'_m`m' = "-10" if cod`k'_c`c'_m`m'=="0001}"
		qui replace cod`k'_c`c'_m`m' = "-11" if cod`k'_c`c'_m`m'=="0001J"
		qui replace cod`k'_c`c'_m`m' = "-12" if cod`k'_c`c'_m`m'=="0001K"
		qui replace cod`k'_c`c'_m`m' = "-13" if cod`k'_c`c'_m`m'=="0001L"
		qui replace cod`k'_c`c'_m`m' = "-14" if cod`k'_c`c'_m`m'=="0001M"
		qui replace cod`k'_c`c'_m`m' = "-15" if cod`k'_c`c'_m`m'=="0001N"
		
		/* this code identifies the nonnumeric values
		gen byte notnumeric = real(cod`k'_c`c'_m`m')==.
		tab cod`k'_c`c'_m`m' if notnumeric==1
		*/
		
		/*some nonnumeric values that do not correspond to the ones in the codebook.
		They seem to be typographic errors. "0001P" for example, seems to correspond
		to a number between 10 and 19. "0002M" seems to correspond to a number between
		20 and 29. However it is not obvious whether this is the case. Set to missing, and then 
		smooth out along with other missing values. Alternatively, we can substitue "0001P" with 14.5,
		"0002M" with 24.5 and so on and so forth.
		values if needed (for year 2007):
		- "0001P" (one instance)
		- "0002M" (one instance)
		- "0001Q" (one instance)
		- "0001R" (one instance)
		- "0003O" (one instance)
		- "0002J" (one instance)
		- "0006P" (one instance)
		- "0003R" (one instance)
		- "0005M" (one instance)
		*/
		
		
		destring cod`k'_c`c'_m`m', replace force
		replace cod`k'_c`c'_m`m'=. if cod`k'_c`c'_m`m'==999 | cod`k'_c`c'_m`m'==9999 //means missing according to Maltz & Weiss (2006)
		/*
		drop notnumeric
		*/
		}
	}
}


*destring officer killed and assaulted variables:
foreach m of numlist 1/12{
	foreach v in offkillfel_m offkillacc_m offasslt_m{	
	
		*negative entries have letter codes (see codebook) replace (still not sure what a negative entry means though)
		qui replace `v'`m' = "0"    if `v'`m' =="0000}"
		qui replace `v'`m' = "-1"   if `v'`m' =="0000J"
		qui replace `v'`m' = "-2"   if `v'`m' =="0000K"
		qui replace  `v'`m' = "-3"  if `v'`m' =="0000L"
		qui replace  `v'`m' = "-4"  if `v'`m' =="0000M"
		qui replace  `v'`m' = "-5"  if `v'`m' =="0000N"
		qui replace  `v'`m' = "-6"  if `v'`m' =="0000O"
		qui replace  `v'`m' = "-7"  if `v'`m' =="0000P"
		qui replace  `v'`m' = "-8"  if `v'`m' =="0000Q"
		qui replace  `v'`m' = "-9"  if `v'`m' =="0000R"
		qui replace  `v'`m' = "-10" if `v'`m' =="0001}"
		qui replace  `v'`m' = "-11" if `v'`m' =="0001J"
		qui replace  `v'`m' = "-12" if `v'`m' =="0001K"
		qui replace  `v'`m' = "-13" if `v'`m' =="0001L"
		qui replace  `v'`m' = "-14" if `v'`m' =="0001M"
		qui replace  `v'`m' = "-15" if `v'`m' =="0001N"
		
		
		destring `v'`m', replace force
		replace `v'`m'=. if `v'`m'==999|`v'`m'==9999
	
	}
}



**Destring year
replace year = "20"+year
destring year, replace
assert year==`y'


** merge state and county FIPS
gen ori7 = oricode //for merge 2000-2012


/* This was done to check the missing crosswalk values 2000-2012
preserve

	keep if _merge==1
	keep ori7 statecode popd1county mailadline1 mailadline2 mailadline3 mailadline4
	save "$path/sanctuaries/data/temp/merge1_`y'.dta", replace
restore
*/

local y=2007
if inrange(`y',2000,2012) {
	merge 1:1 ori7 using "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012_expanded.dta", keepusing(fstate fcounty)
	drop if _merge==2
	drop _merge
}



if inrange(`y',2013,2016) {
	*two- step procedure using 2012 crosswalk and then the generated corsswalk
}


*generate unique county FIPS code (combining state and county)
tostring fstate, replace
replace fstate = "0" + fstate if strlen(fstate)==1

tostring fcounty, replace
replace fcounty = "0" + fcounty if strlen(fcounty)==2
replace fcounty = "00" + fcounty if strlen(fcounty)==1

gen fips = fstate + fcounty





/*Sum up the seven index crimes for each agency and each year*/

*drop the other crimes and subcrime categories:
foreach c in 2 4 5 7 8 9 10 12 13 14 15 16 18 19 20 22 24 25 26 27 28{
	drop cod`c'_c1_m*
}

*sum up the remaining seven for each month
foreach m of numlist 1/12{
	egen codtot_m`m' = rowtotal(cod1_c1_m`m' cod3_c1_m`m' cod6_c1_m`m' cod11_c1_m`m' cod17_c1_m`m' cod21_c1_m`m' cod23_c1_m`m')
}



							/*Missing data issues*/

*drop agencies that in a given year they don't report crime on ANY month
drop if codtot_m1<=0 & codtot_m2<=0 & codtot_m3<=0 & codtot_m4<=0 & codtot_m5<=0 ///
		& codtot_m6<=0 & codtot_m7<=0 & codtot_m8<=0 & codtot_m9<=0 & codtot_m10<=0 ///
		& codtot_m11<=0 & codtot_m12<=0


/*number with positive reporting and reporting pattern*/
foreach m of numlist 1/12{

	gen d`m'=0
	replace d`m'=1 if codtot_m`m'>0
	
	tostring d`m', gen(d`m's)
}		

gen rep_number = d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8 + d9 + d10 + d11 + d12
gen rep_pattern = d1s + d2s + d3s + d4s + d5s + d6s + d7s + d8s + d9s + d10s + d11s + d12s


*categorize into annual
gen rep_annual=0
replace rep_annual=1 if rep_pattern=="000000000001"

*categorize into biannual
gen rep_biannual=0
replace rep_biannual=1 if rep_pattern=="000001000001"


*categorize into quarterly
gen rep_quarterly=0
replace rep_quarterly=1 if rep_pattern=="001001001001"


******impute average values for relevant months for agencies cateogrized as annual, biannual, and quarterly:

*generate relevant division values
foreach c in 1 3 6 11 17 21 23{ //7 index crimes
	foreach d in 3 6 12{ //number to divide by
		foreach m in 3 6 9 12{ //reference month
			gen cod`c'_c1_m`m'_d`d' = cod`c'_c1_m`m'/`d'
		}
	}
	
}

*generate new imputed variable version for each crime
foreach m of numlist 1/12{

	foreach c in 1 3 6 11 17 21 23{

		gen cod`c'_c1_i_m`m' =  cod`c'_c1_m`m'
		
		* reported annually:
		replace cod`c'_c1_i_m`m' = cod`c'_c1_m12_d12 if rep_annual==1
		
		*reported biannually:
		if inrange(`m',1,6){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m6_d6 if rep_biannual==1
		}
		if inrange(`m',7,12){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m12_d6 if rep_biannual==1
		}
		
		*reported quarterly:
		if inrange(`m',1,3){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m3_d3 if rep_quarterly==1
		}
		if inrange(`m',4,6){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m6_d3 if rep_quarterly==1
		}
		if inrange(`m',6,9){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m9_d3 if rep_quarterly==1
		}
		if inrange(`m',10,12){
			replace cod`c'_c1_i_m`m' = cod`c'_c1_m12_d3 if rep_quarterly==1
		}
	}
	egen codtot_i_m`m' = rowtotal(cod1_c1_i_m`m' cod3_c1_i_m`m' cod6_c1_i_m`m' cod11_c1_i_m`m' cod17_c1_i_m`m' cod21_c1_i_m`m' cod23_c1_i_m`m')
		
}



 
/*
/*Month Included In: Used only if an agency does not submit a return, say for January, 
	but indicates on the February return that it includes the January data. In this case,
	the January area would have "02" in this field with the remainder of the month data
	initialized to field defaults of zeros and blanks, as applicable*/
	
/*---> if say, the data for January is recorded in February, assign both February and
		January as value for each crime equal to February/2  */	

foreach m of numlist 1/12{
	destring monthinclin_m`m', replace
}

foreach j of numlist 1/12{ 
	foreach k of numlist 1/12{ 
		gen rec_k`k'_j`j'=0
		replace rec_k`k'_j`j'=1 if monthinclin_m`k'==`j' // = 1 if data from month k is recorded in month j
	
	}
}

*number of months k whose data is recorded in month j
foreach j of numlist 1/12{
	egen rec_j`j'_occurrence = rowtotal(rec_k1_j`j' rec_k2_j`j' rec_k3_j`j' rec_k4_j`j' rec_k5_j`j' rec_k6_j`j' rec_k7_j`j' rec_k8_j`j' rec_k9_j`j' rec_k10_j`j' rec_k11_j`j' rec_k12_j`j')
}


/*for each offense, for each month, generate new variable that divides the number of offenses
 by the actual number of months it is capturing (monthinclin + 1)*/

 foreach c of numlist 1/28{ //number of offenses
	foreach j of numlist 1/12{ //number of months
		gen cod`c'_c1_norm_m`j' = cod`c'_c1_m`j'
		replace cod`c'_c1_norm_m`j' = cod`c'_c1_m`j'/(rec_j`j'_occurrence+1) if rec_j`j'_occurrence>=1
	}
} 
 
/*now, assign that value to the rest of the relevant months*/
foreach c of numlist 1/28{ //number of offenses
	foreach k of numlist 1/12{ //number of months for potential change
		foreach j of numlist 1/12{ //number of potential months where actual data is recorded
			replace cod`c'_c1_norm_m`k' = cod`c'_c1_norm_m`j' if rec_k`k'_j`j'==1
		}
	}
}

drop rec_k*_j* rec_j*_occurrence
*/




/*Reshape to long form, monthly panel*/
reshape long cod1_c1_m cod3_c1_m cod6_c1_m cod11_c1_m cod17_c1_m cod21_c1_m cod23_c1_m ///
				cod1_c1_i_m cod3_c1_i_m cod6_c1_i_m cod11_c1_i_m cod17_c1_i_m cod21_c1_i_m cod23_c1_i_m ///
				codtot_m codtot_i_m ///
			, i(oricode) j(month)


collapse (sum) cod*_c1_m cod*_c1_i_m codtot_m codtot_i_m, by(fips month)

