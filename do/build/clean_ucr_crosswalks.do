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

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2012.dta", replace 



**************************			/*2005*/
use "$path/sanctuaries/data/UCR_FBI/crosswalks/cw_2005/ICPSR_04634/ICPSR_04634/DS0001/04634-0001-Data.dta", clear
rename LAT INTPTLAT
rename LONG INTPTLONG

rename *, lower

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

save "$path/sanctuaries/data/UCR_FBI/crosswalks/work/cw_ucr_2000.dta", replace 	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
