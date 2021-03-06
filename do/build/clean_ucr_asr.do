*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_ucr_asr.do																				*
*						cleans UCR ASR files - generates files with arrests at county-month-year								* 
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"


** 2000-2009
*qui foreach yr in 00 01 02 03 04 05 06 07 08 09 {
qui foreach yr in 07 08 09 {
noisily disp "`yr'"

** Agency header file

quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	agency_header	14-15	///
str	year	16-17	///
str	msa	18-20	///
str	county	21-23	///
str	seqnum	24-28	///
str	suburban	29	///
str	corecity	30	///
str	covered	31	///
str	population	32-40	///
str	agencyname	41-64	///
str	statename	65-70	///
str	filler	71-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR`yr'.DAT", clear
keep if agency_header == "00"
drop agency_header
drop filler
sort oricode
save "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta", replace


** Monthly header file

clear
quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	month	14-15	///
str	year	16-17	///
str	monthlyheader	18-20	///
str	breakdown	21	///
str	areo	22	///
str	zerodata	24	///
str	lastupdate	25-31	///
str	previousupdate	32-38	///
str	previous2update	39-45	///
str	juvenile_disp_ind	46	///
str	juvenile_disp_refjuv	57-61	///
str	juvenile_disp_refotherpol	62-66	///
str	juvenile_disp_refcriminalcourt	67-71	///
str	filler	72-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR`yr'.DAT", clear
drop if month == "00"
keep if monthlyheader == "000"
drop monthlyheader breakdown filler
sort oricode month
save "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta", replace


** Master file

clear
quietly infix 		///
str	asr_id	1-1	///		
str	statecode	2-3	///		
str	oricode	4-10 str group	11-12	///
str	division	13-13	///		
str	month	14-15	///		
str	year	16-17	///		
str	offensecode	18-20	///		
str	occurrences	21-23	///		
str	arrestcode_1	24-26	///
str	arrestcounter_1	27-31	///
str	arrestcode_2	32-34	///
str	arrestcounter_2	35-39	///
str	arrestcode_3	40-42	///
str	arrestcounter_3	43-47	///
str	arrestcode_4	48-50	///
str	arrestcounter_4	51-55	///
str	arrestcode_5	56-58	///
str	arrestcounter_5	59-63	///
str	arrestcode_6	64-66	///
str	arrestcounter_6	67-71	///
str	arrestcode_7	72-74	///
str	arrestcounter_7	75-79	///
str	arrestcode_8	80-82	///
str	arrestcounter_8	83-87	///
str	arrestcode_9	88-90	///
str	arrestcounter_9	91-95	///
str	arrestcode_10	96-98	///
str	arrestcounter_10	99-103 str arrestcode_11	104-106	///
str	arrestcounter_11	107-111	///
str	arrestcode_12	112-114	///
str	arrestcounter_12	115-119	///
str	arrestcode_13	120-122	///
str	arrestcounter_13	123-127	///
str	arrestcode_14	128-130	///
str	arrestcounter_14	131-135	///
str	arrestcode_15	136-138	///
str	arrestcounter_15	139-143	///
str	arrestcode_16	144-146	///
str	arrestcounter_16	147-151	///
str	arrestcode_17	152-154	///
str	arrestcounter_17	155-159	///
str	arrestcode_18	160-162	///
str	arrestcounter_18	163-167	///
str	arrestcode_19	168-170	///
str	arrestcounter_19	171-175	///
str	arrestcode_20	176-178	///
str	arrestcounter_20	179-183	///
str	arrestcode_21	184-186	///
str	arrestcounter_21	187-191	///
str	arrestcode_22	192-194	///
str	arrestcounter_22	195-199	///
str	arrestcode_23	200-202	///
str	arrestcounter_23	203-207	///
str	arrestcode_24	208-210	///
str	arrestcounter_24	211-215	///
str	arrestcode_25	216-218	///
str	arrestcounter_25	219-223	///
str	arrestcode_26	224-226	///
str	arrestcounter_26	227-231	///
str	arrestcode_27	232-234	///
str	arrestcounter_27	235-239	///
str	arrestcode_28	240-242	///
str	arrestcounter_28	243-247	///
str	arrestcode_29	248-250	///
str	arrestcounter_29	251-255	///
str	arrestcode_30	256-258	///
str	arrestcounter_30	259-263	///
str	arrestcode_31	264-266	///
str	arrestcounter_31	267-271	///
str	arrestcode_32	272-274	///
str	arrestcounter_32	275-279	///
str	arrestcode_33	280-282	///
str	arrestcounter_33	283-287	///
str	arrestcode_34	288-290	///
str	arrestcounter_34	291-295	///
str	arrestcode_35	296-298	///
str	arrestcounter_35	299-303	///
str	arrestcode_36	304-306	///
str	arrestcounter_36	307-311	///
str	arrestcode_37	312-314	///
str	arrestcounter_37	315-319	///
str	arrestcode_38	320-322	///
str	arrestcounter_38	323-327	///
str	arrestcode_39	328-330	///
str	arrestcounter_39	331-335	///
str	arrestcode_40	336-338	///
str	arrestcounter_40	339-343	///
str	arrestcode_41	344-346	///
str	arrestcounter_41	347-351	///
str	arrestcode_42	352-354	///
str	arrestcounter_42	355-359	///
str	arrestcode_43	360-362	///
str	arrestcounter_43	363-367	///
str	arrestcode_44	368-370	///
str	arrestcounter_44	371-375	///
str	arrestcode_45	376-378	///
str	arrestcounter_45	379-383	///
str	arrestcode_46	384-386	///
str	arrestcounter_46	387-391	///
str	arrestcode_47	392-394	///
str	arrestcounter_47	395-399	///
str	arrestcode_48	400-402	///
str	arrestcounter_48	403-407	///
str	arrestcode_49	408-410	///
str	arrestcounter_49	411-415	///
str	arrestcode_50	416-418	///
str	arrestcounter_50	419-423	///
str	arrestcode_51	424-426	///
str	arrestcounter_51	427-431	///
str	arrestcode_52	432-434	///
str	arrestcounter_52	435-439	///
str	arrestcode_53	440-442	///
str	arrestcounter_53	443-447	///
str	arrestcode_54	448-450	///
str	arrestcounter_54	451-455	///
str	arrestcode_55	456-458	///
str	arrestcounter_55	459-463	///
str	arrestcode_56	464-466	///
str	arrestcounter_56	467-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR`yr'.DAT", clear
drop if month == "00"
drop if offensecode == "000"
sort oricode month
merge m:1 oricode using "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
drop _m
rm "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
sort oricode month
merge m:1 oricode month using "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
rm "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
drop _m
save "UCR_FBI/UCR_master_file/work/arrest_total`yr'.dta", replace
}


** 2010-2012 and 2014
qui foreach yr in 10 11 12 14 {
noisily disp "`yr'"

** Agency header file
quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	agency_header	14-15	///
str	year	16-17	///
str	msa	18-20	///
str	county	21-23	///
str	seqnum	24-28	///
str	suburban	29	///
str	corecity	30	///
str	covered	31	///
str	population	32-40	///
str	agencyname	41-64	///
str	statename	65-70	///
str	filler	71-471	///
using "UCR_FBI/UCR_master_file/cd_content/asr20`yr'mth/ASR`yr'.txt", clear
keep if agency_header == "00"
drop agency_header
drop filler
sort oricode
save "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta", replace


** Monthly header file

clear
quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	month	14-15	///
str	year	16-17	///
str	monthlyheader	18-20	///
str	breakdown	21	///
str	areo	22	///
str	zerodata	24	///
str	lastupdate	25-31	///
str	previousupdate	32-38	///
str	previous2update	39-45	///
str	juvenile_disp_ind	46	///
str	juvenile_disp_refjuv	57-61	///
str	juvenile_disp_refotherpol	62-66	///
str	juvenile_disp_refcriminalcourt	67-71	///
str	filler	72-471	///
using "UCR_FBI/UCR_master_file/cd_content/asr20`yr'mth/ASR`yr'.txt", clear
drop if month == "00"
keep if monthlyheader == "000"
drop monthlyheader breakdown filler
sort oricode month
save "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta", replace


** Master file

clear
quietly infix 		///
str	asr_id	1-1	///		
str	statecode	2-3	///		
str	oricode	4-10 str group	11-12	///
str	division	13-13	///		
str	month	14-15	///		
str	year	16-17	///		
str	offensecode	18-20	///		
str	occurrences	21-23	///		
str	arrestcode_1	24-26	///
str	arrestcounter_1	27-31	///
str	arrestcode_2	32-34	///
str	arrestcounter_2	35-39	///
str	arrestcode_3	40-42	///
str	arrestcounter_3	43-47	///
str	arrestcode_4	48-50	///
str	arrestcounter_4	51-55	///
str	arrestcode_5	56-58	///
str	arrestcounter_5	59-63	///
str	arrestcode_6	64-66	///
str	arrestcounter_6	67-71	///
str	arrestcode_7	72-74	///
str	arrestcounter_7	75-79	///
str	arrestcode_8	80-82	///
str	arrestcounter_8	83-87	///
str	arrestcode_9	88-90	///
str	arrestcounter_9	91-95	///
str	arrestcode_10	96-98	///
str	arrestcounter_10	99-103 str arrestcode_11	104-106	///
str	arrestcounter_11	107-111	///
str	arrestcode_12	112-114	///
str	arrestcounter_12	115-119	///
str	arrestcode_13	120-122	///
str	arrestcounter_13	123-127	///
str	arrestcode_14	128-130	///
str	arrestcounter_14	131-135	///
str	arrestcode_15	136-138	///
str	arrestcounter_15	139-143	///
str	arrestcode_16	144-146	///
str	arrestcounter_16	147-151	///
str	arrestcode_17	152-154	///
str	arrestcounter_17	155-159	///
str	arrestcode_18	160-162	///
str	arrestcounter_18	163-167	///
str	arrestcode_19	168-170	///
str	arrestcounter_19	171-175	///
str	arrestcode_20	176-178	///
str	arrestcounter_20	179-183	///
str	arrestcode_21	184-186	///
str	arrestcounter_21	187-191	///
str	arrestcode_22	192-194	///
str	arrestcounter_22	195-199	///
str	arrestcode_23	200-202	///
str	arrestcounter_23	203-207	///
str	arrestcode_24	208-210	///
str	arrestcounter_24	211-215	///
str	arrestcode_25	216-218	///
str	arrestcounter_25	219-223	///
str	arrestcode_26	224-226	///
str	arrestcounter_26	227-231	///
str	arrestcode_27	232-234	///
str	arrestcounter_27	235-239	///
str	arrestcode_28	240-242	///
str	arrestcounter_28	243-247	///
str	arrestcode_29	248-250	///
str	arrestcounter_29	251-255	///
str	arrestcode_30	256-258	///
str	arrestcounter_30	259-263	///
str	arrestcode_31	264-266	///
str	arrestcounter_31	267-271	///
str	arrestcode_32	272-274	///
str	arrestcounter_32	275-279	///
str	arrestcode_33	280-282	///
str	arrestcounter_33	283-287	///
str	arrestcode_34	288-290	///
str	arrestcounter_34	291-295	///
str	arrestcode_35	296-298	///
str	arrestcounter_35	299-303	///
str	arrestcode_36	304-306	///
str	arrestcounter_36	307-311	///
str	arrestcode_37	312-314	///
str	arrestcounter_37	315-319	///
str	arrestcode_38	320-322	///
str	arrestcounter_38	323-327	///
str	arrestcode_39	328-330	///
str	arrestcounter_39	331-335	///
str	arrestcode_40	336-338	///
str	arrestcounter_40	339-343	///
str	arrestcode_41	344-346	///
str	arrestcounter_41	347-351	///
str	arrestcode_42	352-354	///
str	arrestcounter_42	355-359	///
str	arrestcode_43	360-362	///
str	arrestcounter_43	363-367	///
str	arrestcode_44	368-370	///
str	arrestcounter_44	371-375	///
str	arrestcode_45	376-378	///
str	arrestcounter_45	379-383	///
str	arrestcode_46	384-386	///
str	arrestcounter_46	387-391	///
str	arrestcode_47	392-394	///
str	arrestcounter_47	395-399	///
str	arrestcode_48	400-402	///
str	arrestcounter_48	403-407	///
str	arrestcode_49	408-410	///
str	arrestcounter_49	411-415	///
str	arrestcode_50	416-418	///
str	arrestcounter_50	419-423	///
str	arrestcode_51	424-426	///
str	arrestcounter_51	427-431	///
str	arrestcode_52	432-434	///
str	arrestcounter_52	435-439	///
str	arrestcode_53	440-442	///
str	arrestcounter_53	443-447	///
str	arrestcode_54	448-450	///
str	arrestcounter_54	451-455	///
str	arrestcode_55	456-458	///
str	arrestcounter_55	459-463	///
str	arrestcode_56	464-466	///
str	arrestcounter_56	467-471	///
using "UCR_FBI/UCR_master_file/cd_content/asr20`yr'mth/ASR`yr'.txt", clear
drop if month == "00"
drop if offensecode == "000"
sort oricode month
merge m:1 oricode using "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
drop _m
rm "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
sort oricode month
merge m:1 oricode month using "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
rm "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
drop _m
save "UCR_FBI/UCR_master_file/work/arrest_total`yr'.dta", replace
}

** 2013, 2015, 2016

qui foreach yr in 13 15 16 {
noisily disp "`yr'"

** Agency header file
quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	agency_header	14-15	///
str	year	16-17	///
str	msa	18-20	///
str	county	21-23	///
str	seqnum	24-28	///
str	suburban	29	///
str	corecity	30	///
str	covered	31	///
str	population	32-40	///
str	agencyname	41-64	///
str	statename	65-70	///
str	filler	71-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR20`yr'.txt", clear
keep if agency_header == "00"
drop agency_header
drop filler
sort oricode
save "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta", replace


** Monthly header file

clear
quietly infix 		///
str	asr_id	1-1	///
str	statecode	2-3	///
str	oricode	4-10 str group	11-12	///
str	division	13-13	///
str	month	14-15	///
str	year	16-17	///
str	monthlyheader	18-20	///
str	breakdown	21	///
str	areo	22	///
str	zerodata	24	///
str	lastupdate	25-31	///
str	previousupdate	32-38	///
str	previous2update	39-45	///
str	juvenile_disp_ind	46	///
str	juvenile_disp_refjuv	57-61	///
str	juvenile_disp_refotherpol	62-66	///
str	juvenile_disp_refcriminalcourt	67-71	///
str	filler	72-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR20`yr'.txt", clear
drop if month == "00"
keep if monthlyheader == "000"
drop monthlyheader breakdown filler
sort oricode month
save "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta", replace


** Master file

clear
quietly infix 		///
str	asr_id	1-1	///		
str	statecode	2-3	///		
str	oricode	4-10 str group	11-12	///
str	division	13-13	///		
str	month	14-15	///		
str	year	16-17	///		
str	offensecode	18-20	///		
str	occurrences	21-23	///		
str	arrestcode_1	24-26	///
str	arrestcounter_1	27-31	///
str	arrestcode_2	32-34	///
str	arrestcounter_2	35-39	///
str	arrestcode_3	40-42	///
str	arrestcounter_3	43-47	///
str	arrestcode_4	48-50	///
str	arrestcounter_4	51-55	///
str	arrestcode_5	56-58	///
str	arrestcounter_5	59-63	///
str	arrestcode_6	64-66	///
str	arrestcounter_6	67-71	///
str	arrestcode_7	72-74	///
str	arrestcounter_7	75-79	///
str	arrestcode_8	80-82	///
str	arrestcounter_8	83-87	///
str	arrestcode_9	88-90	///
str	arrestcounter_9	91-95	///
str	arrestcode_10	96-98	///
str	arrestcounter_10	99-103 str arrestcode_11	104-106	///
str	arrestcounter_11	107-111	///
str	arrestcode_12	112-114	///
str	arrestcounter_12	115-119	///
str	arrestcode_13	120-122	///
str	arrestcounter_13	123-127	///
str	arrestcode_14	128-130	///
str	arrestcounter_14	131-135	///
str	arrestcode_15	136-138	///
str	arrestcounter_15	139-143	///
str	arrestcode_16	144-146	///
str	arrestcounter_16	147-151	///
str	arrestcode_17	152-154	///
str	arrestcounter_17	155-159	///
str	arrestcode_18	160-162	///
str	arrestcounter_18	163-167	///
str	arrestcode_19	168-170	///
str	arrestcounter_19	171-175	///
str	arrestcode_20	176-178	///
str	arrestcounter_20	179-183	///
str	arrestcode_21	184-186	///
str	arrestcounter_21	187-191	///
str	arrestcode_22	192-194	///
str	arrestcounter_22	195-199	///
str	arrestcode_23	200-202	///
str	arrestcounter_23	203-207	///
str	arrestcode_24	208-210	///
str	arrestcounter_24	211-215	///
str	arrestcode_25	216-218	///
str	arrestcounter_25	219-223	///
str	arrestcode_26	224-226	///
str	arrestcounter_26	227-231	///
str	arrestcode_27	232-234	///
str	arrestcounter_27	235-239	///
str	arrestcode_28	240-242	///
str	arrestcounter_28	243-247	///
str	arrestcode_29	248-250	///
str	arrestcounter_29	251-255	///
str	arrestcode_30	256-258	///
str	arrestcounter_30	259-263	///
str	arrestcode_31	264-266	///
str	arrestcounter_31	267-271	///
str	arrestcode_32	272-274	///
str	arrestcounter_32	275-279	///
str	arrestcode_33	280-282	///
str	arrestcounter_33	283-287	///
str	arrestcode_34	288-290	///
str	arrestcounter_34	291-295	///
str	arrestcode_35	296-298	///
str	arrestcounter_35	299-303	///
str	arrestcode_36	304-306	///
str	arrestcounter_36	307-311	///
str	arrestcode_37	312-314	///
str	arrestcounter_37	315-319	///
str	arrestcode_38	320-322	///
str	arrestcounter_38	323-327	///
str	arrestcode_39	328-330	///
str	arrestcounter_39	331-335	///
str	arrestcode_40	336-338	///
str	arrestcounter_40	339-343	///
str	arrestcode_41	344-346	///
str	arrestcounter_41	347-351	///
str	arrestcode_42	352-354	///
str	arrestcounter_42	355-359	///
str	arrestcode_43	360-362	///
str	arrestcounter_43	363-367	///
str	arrestcode_44	368-370	///
str	arrestcounter_44	371-375	///
str	arrestcode_45	376-378	///
str	arrestcounter_45	379-383	///
str	arrestcode_46	384-386	///
str	arrestcounter_46	387-391	///
str	arrestcode_47	392-394	///
str	arrestcounter_47	395-399	///
str	arrestcode_48	400-402	///
str	arrestcounter_48	403-407	///
str	arrestcode_49	408-410	///
str	arrestcounter_49	411-415	///
str	arrestcode_50	416-418	///
str	arrestcounter_50	419-423	///
str	arrestcode_51	424-426	///
str	arrestcounter_51	427-431	///
str	arrestcode_52	432-434	///
str	arrestcounter_52	435-439	///
str	arrestcode_53	440-442	///
str	arrestcounter_53	443-447	///
str	arrestcode_54	448-450	///
str	arrestcounter_54	451-455	///
str	arrestcode_55	456-458	///
str	arrestcounter_55	459-463	///
str	arrestcode_56	464-466	///
str	arrestcounter_56	467-471	///
using "UCR_FBI/UCR_master_file/cd_content/ASR20`yr'.txt", clear
drop if month == "00"
drop if offensecode == "000"
sort oricode month
merge m:1 oricode using "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
drop _m
rm "UCR_FBI/UCR_master_file/work/agencyheader`yr'.dta"
sort oricode month
merge m:1 oricode month using "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
rm "UCR_FBI/UCR_master_file/work/monthlyheader`yr'.dta"
drop _m
save "UCR_FBI/UCR_master_file/work/arrest_total`yr'.dta", replace
}
