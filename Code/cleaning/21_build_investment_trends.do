*---------------------------------------------------
* This file builds quarterly investment trends for
* solar and wind by Energy Community status.
*
* Author: Jacopo
* Date: 04/09/2025
*
* Input: $data/constructed data/final_investment_dataset_stata.csv
*
* Output: $data/constructed data/trends_investment_long.dta
*         $data/constructed data/trends_investment_long.csv
*         (quarterly shares and MA(4) smoothed series)
*---------------------------------------------------

clear all

*-----------------------------*
* 1) Import and basic cleaning
*-----------------------------*
import delimited using "$data/constructed data/investment_dataset_stata.csv", ///
    varnames(1) stringcols(_all) encoding(UTF-8) clear

destring ec_ind_official_cohort_1 ec_ind_official_cohort_2 ec_ind_official_cohort_3 ///
         investment_wind_binary investment_solar_binary, replace force

gen byte energy_community = (ec_ind_official_cohort_1==1 | ec_ind_official_cohort_2==1 | ec_ind_official_cohort_3==1)
replace energy_community = 0 if missing(energy_community)
capture label drop comm
label define comm 0 "Non-energy" 1 "Energy"
label values energy_community comm

*-----------------------------*
* 2) Parse quarter to %tq
*-----------------------------*
capture drop y q tq
gen int  y = real(year)
gen byte q = real(subinstr(lower(quarter), "q", "", .))   // handles "Q1" or "1"
assert !missing(y) & inrange(q,1,4)
gen tq = yq(y, q)
format tq %tq

*-----------------------------*
* 3) Collapse to quarterly shares by community
*-----------------------------*
tempfile base
save `base'

* Wind
preserve
    collapse (mean) share = investment_wind_binary, by(tq energy_community)
    gen series = "Wind"
    tempfile wind
    save `wind'
restore

* Solar
preserve
    use `base', clear
    collapse (mean) share = investment_solar_binary, by(tq energy_community)
    gen series = "Solar"
    tempfile solar
    save `solar'
restore

* Stack wind and solar
use `wind', clear
append using `solar'

*-----------------------------*
* 4) Tidy labels and order
*-----------------------------*
label values energy_community comm
order tq energy_community series share
sort series energy_community tq

*-----------------------------*
* 5) MA(4) smoothing for plotting
*-----------------------------*
egen gid = group(series energy_community)
xtset gid tq
sort gid tq
by gid: gen share_ma4 = (share + L.share + L2.share + L3.share)/4

save "$data/constructed data/trends_investment_long.dta", replace
export delimited using "$data/constructed data/trends_investment_long.csv", replace
