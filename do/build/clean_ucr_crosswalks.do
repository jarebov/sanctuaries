*clean UCR crosswalks (2000, 2005, 2012)

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






**************************			/*2012*/
import delimited "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_2012/ICPSR_35158/ICPSR_35158/DS0001/35158-0001-Data.tsv", clear

drop if ori7=="-1" //our link variable. missing when duplicate ORI, with 9 digit code
isid ori7

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012.dta", replace 



**************************			/*2005*/
use "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_2005/ICPSR_04634/ICPSR_04634/DS0001/04634-0001-Data.dta", clear
rename LAT INTPTLAT
rename LONG INTPTLONG

rename *, lower

drop if ori7=="" //our link variable. missing when duplicate ORI, with 9 digit code
isid ori7

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2005.dta", replace 



**************************			/*2000*/

qui infix	///	
	str	state	1-2	///
	str	county	3-37	///
	str agency	38-87	///
	str agencyid	88-103	///
	str ori7	104-110	///
	str	agentype	111-111	///
	str govidnu	112-120	///
	str govname	121-184	///
	str govtype	185-186	///
	str fstate	187-188	///
	str fcounty	189-191	///
	str fplace	192-196	///
	str placenm	197-248	///
	str classcd	249-250	///
	str partofcd	251-255	///
	str	partofnm	256-307	///
	str	othcode	308-312	///
	str othname	313-364	///
	str fmsa	365-368	///
	str fmsaname	369-433	///
	str ustateno	434-435	///
	str uctyno	436-438	///
	str umsa	439-441	///
	str	upopgrp	442-443	///
	str upopcov	444-452	///
	str cpop	453-463	///
	str ucovby	464-470	///
	str umultico	471-471	///
	str intptlat	472-482	///
	str intptlong	483-493	///
	str pop	494-502	///
	str house	503-510	///
	str miles	511-523	///
	str zipcode	524-528	///
	str ziprange	529-530	///
	str add1	531-575	///
	str add2	576-620	///
	str add3	621-665	///
	str add4	666-710	///
	str add5	711-719	///
	str hqcode	720-727	///
	str source	728-728	///
	using "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_2000/ICPSR_04082/ICPSR_04082/DS0001/04082-0001-Data.txt", clear
	
drop if ori7=="" //our link variable. missing when duplicate ORI, with 9 digit code
isid ori7

destring fcounty, replace
destring fstate, replace

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2000.dta", replace 	
	
	
	
	
	
	
/*It turns out that 2012 encompasses the older versions. It still misses some
	agencies though, when matching to Reta 2000-2012. I coded manually the fips
	state and county codes for this ~26 instances or so. let's combine
	2012 with the manually added to have a comprehensive crosswalk for the
	years 2000-2012 (2013 onwards is a different matter)*/	
	
import excel "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_handmade_missing_cases2012.xlsx", sheet("Sheet1") firstrow clear
	
append using 	"$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012.dta"
isid ori7

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012_expanded.dta", replace 






/*Years 2013 onwards*/

/* ICPSR latest crosswalk is 2012. Since then new agencies have arised, and thus when 
	matching the 2012 crosswalk to later UCR years, there are numerous observations which
	are not matched. However, I can use the 2012 matches to create another crosswalk, that 
	instead of using ORICODE (ORI7) as linking variable, uses the UCR state and county codes
	and links it to the relevant FIPS codes*/

use "$path/sanctuaries/data/UCR_FBI/UCR_master_file/work/reta2012.dta", clear

gen ori7=oricode //for merge
*drop Virgin Islands, American Samoa, Puerto Rico, Guam, Panama canal:
drop if statecode=="62" | statecode=="54" |statecode=="52" | statecode=="53" | statecode=="55"

merge 1:1 ori7 using "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012_expanded.dta"
drop _merge

drop if popd1county==""


collapse (median) fstate (median) fcounty , by(statecode popd1county)
isid statecode popd1county

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_2013onwards.dta", replace 





/*Handmade cases for 2013 onwards that eluded the above approach*/
	
import excel "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_handmade_missing_cases2013onwards.xlsx", sheet("Sheet1") firstrow clear
	
isid ori7	

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_handmade_missing_cases2013onwards.dta", replace 	
	
	
	
	
