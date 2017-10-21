*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: balance_table.do																				*
*						builds tables of sumstats to show balance between treatment and control									*
*																																*
*********************************************************************************************************************************

clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
}

clear all
set more off

****
use covariates.dta, clear

** generate useful variables
gen pop_density = tot_pop / land_area if year == 2010
gen wkage_share = workingage / tot_pop if year == 2010
gen lf_participation = laborforce / tot_pop if year == 2010
gen mig_in_rate = mig_inflow if year == 2005
gen mig_out_rate = mig_outflow if year == 2005
gen medianinc = median if year == 2010
gen democratic = dem_vote if year == 2008
gen share_black = black_pop / tot_pop if year == 2010
gen share_hisp = hisp_pop / tot_pop if year == 2010
gen u_rate = urate if year == 2010
gen homeown = home_own_frac if year == 2010

** keep relevant variables
collapse (mean) pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic 	///
				share_black share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r 		///
				cs_born_foreign rel_tot cs_fam_wkidsinglemom homeown medianinc tot_pop, by(fips stateabbr)
drop if stateabbr == ""			


** merge treatment nr. 1: county detainer
sort fips
merge 1:m fips using treat_control.dta	
gen other = _m == 1
drop _m

* label variables
label variable pop_density 			"pop. density (2010)"
label variable wkage_share 			"working age pop. (2010)"
label variable lf_participation		"LF participation (2010)"
label variable mig_in_rate 			"in-migration (2004)"
label variable mig_out_rate 		"out-migration"
label variable democratic 			"share democratic (2008)"
label variable share_black 			"share black (2010)"
label variable share_hisp 			"share hispanic (2010)"
label variable u_rate 				"unemployment rate (2010)"
label variable gini 				"Gini coefficient (2000)"
label variable ccd_exp_tot 			"school expenditure per-pupil (1997)"
label variable ccd_pup_tch_ratio 	"pupil-teacher ratio (1997)"
label variable score_r 				"pctile test scores (2004)"
label variable dropout_r 			"school dropout rate (2001)"
label variable cs_born_foreign 		"share foreign born (2000)"
label variable rel_tot 				"share religious (2000)"
label variable cs_fam_wkidsinglemom "share single mothers (2000)"
label variable homeown 				"home ownership rate (2000)"
label variable medianinc 			"median income (2010)"
label variable treat 				"no ICE detainer"

capture log close
log using "$out/balance.log", replace

** Table of simple comparisons of treated vs border, weighted by population 
gen weight = tot_pop / nr_border 

eststo s1: estpost tabstat	pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic share_black 		///
							share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r cs_born_foreign 			///
							rel_tot cs_fam_wkidsinglemom homeown median [aw = weight], by(treat) statistics(mean sd) columns(statistics) listwise
esttab s1 using $out/balance_noICE_border.doc, main(mean a3) aux(sd a3) nostar unstack nonote label replace noisily nogaps

foreach var in pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic share_black 		///
							share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r cs_born_foreign 			///
							rel_tot cs_fam_wkidsinglemom homeown median {
reg `var' treat [aw = weight]
}

* using border FE				
				
foreach var in pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic share_black 		///
							share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r cs_born_foreign 			///
							rel_tot cs_fam_wkidsinglemom homeown median {
areg `var' treat [aw = weight], a(border_id) cluster(border_id)
}



** Tables
preserve
drop *border*
duplicates drop
tab treat // check it's equal to 91 for treat == 1
gen treat2 = treat
replace treat2 = 0 if other == 1
eststo s1: estpost tabstat	pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic share_black 		///
							share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r cs_born_foreign 			///
							rel_tot cs_fam_wkidsinglemom homeown, by(treat2) statistics(mean sd) columns(statistics) listwise
esttab s1 using $out/balance_noICE_all.doc, main(mean a3) aux(sd a3) nostar unstack nonote label replace noisily nogaps

foreach var in pop_density wkage_share lf_participation mig_in_rate mig_out_rate democratic share_black 		///
							share_hisp u_rate gini ccd_exp_tot ccd_pup_tch_ratio score_r dropout_r cs_born_foreign 			///
							rel_tot cs_fam_wkidsinglemom homeown median {
reg `var' treat2 [aw = tot_pop]
}
log close
