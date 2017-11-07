*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: build_offense_file.do																			*
*						generates files with offenses at county-month-year, from URC-ASR files									* 
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
		destring cod`k'_c`c'_m`m', replace
		}
	}
}








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
