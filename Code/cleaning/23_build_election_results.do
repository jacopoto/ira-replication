*---------------------------------------------------
* This file builds yearly Republican vote-share trends
* by Energy Community status.
*
* Author: Jacopo
* Date: 05/09/2025
*
* Input: $data/constructed data/final_election_file.csv
*
* Output: $data/constructed data/trends_election_long.dta
*         $data/constructed data/trends_election_long.csv
*         (yearly two-party Republican vote shares by EC)
*---------------------------------------------------

clear all


* 1) Import
import delimited using "$data/constructed data/final_election_file.csv", ///
    varnames(1) stringcols(_all) encoding(UTF-8) clear
rename *, lower

* Key vars
local REP   republican_twoparty_voteshare_co
local STATE state_id

destring `REP' ec_ind_official_cohort_1_percent ec_ind_official_cohort_2_percent ec_ind_official_cohort_3_percent year, replace force

* EC flag from percentage fields (any positive → EC)
gen byte energy_community = (ec_ind_official_cohort_1_percent>0 | ec_ind_official_cohort_2_percent>0 | ec_ind_official_cohort_3_percent>0)
label define comm 0 "Non-EC" 1 "EC", replace
label values energy_community comm

* 2) Collapse to yearly means by EC
tempfile base
save `base'

* All counties
preserve
    collapse (mean) share = `REP', by(year energy_community)
    gen series = "All counties"
    tempfile all
    save `all'
restore

* Rust Belt only (IL IN MI OH PA WI) Fips codes: 17, 18, 26, 39, 42, 55
preserve
    use `base', clear
    keep if inlist(`STATE',"17", "18", "26", "39", "42", "55")
    collapse (mean) share = `REP', by(year energy_community)
    gen series = "Rust Belt"
    tempfile rb
    save `rb'
restore

* Stack and save
use `all', clear
append using `rb'
order year energy_community series share
sort  series energy_community year

save "$data/constructed data/trends_election_long.dta", replace
export delimited using "$data/constructed data/trends_election_long.csv", replace
