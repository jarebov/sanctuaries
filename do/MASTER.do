********************************************************************************
**************** MASTER PROGRAM: Sanctuaries ***********************************
********************************************************************************


************************************************************************
clear all
set more off

global user = 1 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
global path = "~/Dropbox/Research"// Barbara path
}
************************************************************************



********* Paths ************

global build_do    = "$path/sanctuaries/sanctuaries_git/do/build"
global analysis_do = "$path/sanctuaries/sanctuaries_git/do/analysis"
******************************




*************** BUILD DATA FROM RAW FILES **********************************

*County covariates:
run "$build_do/build_census_county_home_ownership.do"	// county covariates: home ownership rates from 2000, 2010 Censuses
run "$build_do/build_EOP_county_covariates.do" 	// county covariates: Equality of Opportunity Project covariates
run "$build_do/build_leip_vote_pres_elections_bycounty.do"	// county covariates: Presidential Election vote shares 2000-2012
run "$build_do/clean_bls.do"	//county covariates: BLS data on labor force stats for years 2005-2016
run "$build_do/clean_intercensal_pop.do"	//cleans Census Intercensal pop data. Generates total pop, pop in workng age, and pop by race
run "$build_do/clean_landarea_census2010.do"	//cleans land area info from Census 2010
run "$build_do/clean_saipe.do"	//cleans SAIPE (income and poverty) Census for years 2005-2015
******************

*Policies:
run "$build_do/10pct_sample_ICE_counties.do"	//generate a 10 pct random sample of counties from ICE no detainer list in order to lok at their policy changes carefully
run "$build_do/clean_upwork.do"	//cleans data on policies obtained from upwork
run "$build_do/match_icedetainer_countyid.do"// matches raw data from ICE detainer agreement "ICE_no_detainer_policies.xls" w/ county ids
******************


*Crime:
run "$build_do/build_urc_annual.do"	//build an annual county panel dataset with URC crime data from NACJD

******************



run "$build_do/clean_countyborder.do"	//cleans county_border files

***************** 	MERGE DATA	*********************************
run "$build_do/build_panel_covariates.do" // generates panel of covariates from different sources
run "$build_do/build_treat_control.do"		// generates panel of treatment and control using adjacency files and differen treatment definitions
