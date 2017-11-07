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

use "$path/sanctuaries/data/UCR_FBI/UCR_master_file/work/reta2007.dta"


*destring all offense counts:
foreach c in 0 1 2 3{
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
	
	}
}

** Generate state fips
*drop Virgin Islands, American Samoa, Puerto Rico, Guam, Panama canal:
drop if statecode=="62" | statecode=="54" |statecode=="52" | statecode=="53" | statecode=="55"
gen state_fips = ""
replace state_fips =	"02"	if statecode ==	"50"	
replace state_fips =	"01"	if statecode ==	"01"	
replace state_fips =	"05"	if statecode ==	"03"	
replace state_fips =	"04"	if statecode ==	"02"	
replace state_fips =	"06"	if statecode ==	"04"	
replace state_fips =	"08"	if statecode ==	"05"	
replace state_fips =	"09"	if statecode ==	"06"	
replace state_fips =	"11"	if statecode ==	"08"	
replace state_fips =	"10"	if statecode ==	"07"	
replace state_fips =	"12"	if statecode ==	"09"	
replace state_fips =	"13"	if statecode ==	"10"	
replace state_fips =	"15"	if statecode ==	"51"	
replace state_fips =	"19"	if statecode ==	"14"	
replace state_fips =	"16"	if statecode ==	"11"	
replace state_fips =	"17"	if statecode ==	"12"	
replace state_fips =	"18"	if statecode ==	"13"	
replace state_fips =	"20"	if statecode ==	"15"	
replace state_fips =	"21"	if statecode ==	"16"	
replace state_fips =	"22"	if statecode ==	"17"	
replace state_fips =	"25"	if statecode ==	"20"	
replace state_fips =	"24"	if statecode ==	"19"	
replace state_fips =	"23"	if statecode ==	"18"	
replace state_fips =	"26"	if statecode ==	"21"	
replace state_fips =	"27"	if statecode ==	"22"	
replace state_fips =	"29"	if statecode ==	"24"	
replace state_fips =	"28"	if statecode ==	"23"	
replace state_fips =	"30"	if statecode ==	"25"	
replace state_fips =	"37"	if statecode ==	"32"	
replace state_fips =	"38"	if statecode ==	"33"	
replace state_fips =	"31"	if statecode ==	"26"	
replace state_fips =	"33"	if statecode ==	"28"	
replace state_fips =	"34"	if statecode ==	"29"	
replace state_fips =	"35"	if statecode ==	"30"	
replace state_fips =	"32"	if statecode ==	"27"	
replace state_fips =	"36"	if statecode ==	"31"	
replace state_fips =	"39"	if statecode ==	"34"	
replace state_fips =	"40"	if statecode ==	"35"	
replace state_fips =	"41"	if statecode ==	"36"	
replace state_fips =	"42"	if statecode ==	"37"	
replace state_fips =	"44"	if statecode ==	"38"	
replace state_fips =	"45"	if statecode ==	"39"	
replace state_fips =	"46"	if statecode ==	"40"	
replace state_fips =	"47"	if statecode ==	"41"	
replace state_fips =	"48"	if statecode ==	"42"	
replace state_fips =	"49"	if statecode ==	"43"	
replace state_fips =	"51"	if statecode ==	"45"	
replace state_fips =	"50"	if statecode ==	"44"	
replace state_fips =	"53"	if statecode ==	"46"	
replace state_fips =	"55"	if statecode ==	"48"	
replace state_fips =	"54"	if statecode ==	"47"	
replace state_fips =	"56"	if statecode ==	"49"



**Destring year
replace year = "20"+year
destring year, replace


/*Month Included In: Used only if an agency does not submit a return, say for January, 
	but indicates on the February return that it includes the January data. In this case,
	the January area would have "02" in this field with the remainder of the month data
	initialized to field defaults of zeros and blanks, as applicable*/









/*









* reshape in month form
keep oricode state cod*
gen id = _n
reshape long	cod1_c0_m cod2_c0_m cod3_c0_m cod4_c0_m cod5_c0_m cod6_c0_m cod7_c0_m	 		///
				cod8_c0_m cod9_c0_m cod10_c0_m cod11_c0_m cod12_c0_m cod13_c0_m cod14_c0_m 		///
				cod15_c0_m cod16_c0_m cod17_c0_m cod18_c0_m cod19_c0_m cod20_c0_m cod21_c0_m 	///
				cod22_c0_m cod23_c0_m cod24_c0_m cod25_c0_m cod26_c0_m cod27_c0_m cod28_c0_m	///
				cod1_c1_m cod2_c1_m cod3_c1_m cod4_c1_m cod5_c1_m cod6_c1_m cod7_c1_m	 		///
				cod8_c1_m cod9_c1_m cod10_c1_m cod11_c1_m cod12_c1_m cod13_c1_m cod14_c1_m 		///
				cod15_c1_m cod16_c1_m cod17_c1_m cod18_c1_m cod19_c1_m cod20_c1_m cod21_c1_m 	///
				cod22_c1_m cod23_c1_m cod24_c1_m cod25_c1_m cod26_c1_m cod27_c1_m cod28_c1_m	///
				cod1_c2_m cod2_c2_m cod3_c2_m cod4_c2_m cod5_c2_m cod6_c2_m cod7_c2_m	 		///
				cod8_c2_m cod9_c2_m cod10_c2_m cod11_c2_m cod12_c2_m cod13_c2_m cod14_c2_m 		///
				cod15_c2_m cod16_c2_m cod17_c2_m cod18_c2_m cod19_c2_m cod20_c2_m cod21_c2_m 	///
				cod22_c2_m cod23_c2_m cod24_c2_m cod25_c2_m cod26_c2_m cod27_c2_m cod28_c2_m	///
				cod1_c3_m cod2_c3_m cod3_c3_m cod4_c3_m cod5_c3_m cod6_c3_m cod7_c3_m	 		///
				cod8_c3_m cod9_c3_m cod10_c3_m cod11_c3_m cod12_c3_m cod13_c3_m cod14_c3_m 		///
				cod15_c3_m cod16_c3_m cod17_c3_m cod18_c3_m cod19_c3_m cod20_c3_m cod21_c3_m 	///
				cod22_c3_m cod23_c3_m cod24_c3_m cod25_c3_m cod26_c3_m cod27_c3_m cod28_c3_m	///
				, i(id) j(month)
drop id
gen id = _n
rename cod*_c*_m cod*_c*

reshape long	cod1_c cod2_c cod3_c cod4_c cod5_c cod6_c cod7_c	 		///
				cod8_c cod9_c cod10_c cod11_c cod12_c cod13_c cod14_c 		///
				cod15_c cod16_c cod17_c cod18_c cod19_c cod20_c cod21_c 	///
				cod22_c cod23_c cod24_c cod25_c cod26_c cod27_c cod28_c	///
				, i(id) j(result)	
				
drop id
gen id = _n
rename cod*_c cod*
forvalues n = 1 / 28{
destring cod`n', replace force
}

egen offense = rowsum(cod1 cod2 cod3 cod4 cod5 cod6 cod7 cod8 cod9 cod10 cod11 cod12 cod13 cod14 cod15 cod16 cod17 cod18 cod19 cod20 cod21 cod22 cod23 cod24 cod25 cod26 cod27 cod28)				
