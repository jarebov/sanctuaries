/* select, label and save county-level covariates from Equality of Opportunity Project data.
 I only process those covariates I think might be relevant for us. The whole list of covariates
 can be found in the online_table4_readme.pdf document*/

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
use "$path/sanctuaries/data/EqualityOfOpportunity/online_table4.dta", clear



label var cs_race_theil_2000	"EOP-racial segregation theil index-2000 census"
label var cs00_seg_inc 			"EOP-income segregation-2000 census"
label var hhinc00				"EOP-hh inc per capita-2000 census"
label var gini 					"EOP-gini coef hh inc-IRS records 1996-2000"
label var gini99 				"EOP-gini coef hh inc bottom99%-IRS 1996-2000"
label var ccd_exp_tot			"EOP-school exp per student-CommonCoreData 1996-97"
label var ccd_pup_tch_ratio		"EOP-student teacher ratio-CommonCoreData 1996-97"
label var score_r				"EOP-test score pctile grds3-8 inc adj-GlobalReportCard2004-05-07"
label var dropout_r				"EOP-HS dropout rate inc adj-CommonCoreData 2000-01"
label var frac_worked1416		"EOP-14-16 LFP rate - IRS 1985-87 birth cohorts"
label var mig_inflow			"EOP-migration inflow rate - IRS 2004-05"
label var mig_outflow			"EOP-migration outflow rate - IRS 2004-05"
label var cs_born_foreign		"EOP-share foreign born - 2000 census"
label var rel_tot				"EOP-frac religious-Association of Religion Data Archives 1999-2001"
label var cs_fam_wkidsinglemom	"EOP-frac children single mothers-2000 census"
label var med_rent_am			"EOP-median month rent above median inc hh-2000 census"
label var med_rent_bm			"EOP-median month rent below median inc hh-2000 census"
label var med_house_price_am 	"EOP-median house price above median inc hh-2000 census"
label var med_house_price_bm 	"EOP-median house price below median inc hh-2000 census"


keep cty2000 county_name state_id stateabbrv statename cs_race_theil_2000	cs00_seg_inc 	///
		hhinc00	gini 	gini99 	ccd_exp_tot	ccd_pup_tch_ratio	score_r	dropout_r	///
		frac_worked1416	mig_inflow	mig_outflow	cs_born_foreign	rel_tot	cs_fam_wkidsinglemom	///
		med_rent_am	med_rent_bm	med_house_price_am	med_house_price_bm
		
		
save "$path/sanctuaries/data/output_datasets/EOP_county_covariates.dta", replace		
