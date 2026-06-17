*---------------------------------------------------
* Build quarterly labor-demand trends for solar and wind
* by Energy Community (EC) status.
*
* Author: Jacopo
* Date: 05/09/2025
*
* Input:  $data/constructed data/final_labor_demand_dataset_stata.csv
*
* Output: $data/constructed data/trends_labor_demand_long.dta
*---------------------------------------------------

clear all

*-----------------------------*
* 1) Import and basics
*-----------------------------*
import delimited using "$data/constructed data/final_labor_demand_dataset_stata.csv", ///
    varnames(1) stringcols(_all) encoding(UTF-8) clear
rename *, lower

* Key vars (edit only if names differ)
local SOLAR solar_technologies_job_vacancies
local WIND  wind_technologies_job_vacancies_
local GREY grey_technologies_job_vacancies_

destring `SOLAR' `WIND' `GREY' ec_ind_official_cohort_1 ec_ind_official_cohort_2 ec_ind_official_cohort_3, replace force

* EC flag
gen byte energy_community = (ec_ind_official_cohort_1==1 | ec_ind_official_cohort_2==1 | ec_ind_official_cohort_3==1)
replace energy_community = 0 if missing(energy_community)
label define comm 0 "Non-EC" 1 "EC", replace
label values energy_community comm

*-----------------------------*
* 2) Build quarterly date %tq
*-----------------------------*
gen int  y = real(year)
gen byte q = real(subinstr(lower(quarter), "q", "", .))   // handles "Q1" or "1"
gen tq = yq(y, q)
format tq %tq
drop if missing(tq)

*-----------------------------*
* 3) Collapse to quarterly means by EC
*-----------------------------*
tempfile base
save `base'

* Wind
preserve
    collapse (mean) share = `WIND', by(tq energy_community)
    gen series = "Wind"
    tempfile wind
    save `wind'
restore

* Solar
preserve
    use `base', clear
    collapse (mean) share = `SOLAR', by(tq energy_community)
    gen series = "Solar"
    tempfile solar
    save `solar'
restore

* Grey
preserve
    use `base', clear
    collapse (mean) share = `GREY', by(tq energy_community)
    gen series = "Grey"
    tempfile grey
    save `grey'
restore

* Stack
use `wind', clear
append using `solar'
append using `grey'

*-----------------------------*
* 4) Tidy + MA(4) smoothing
*-----------------------------*
order tq energy_community series share
sort  series energy_community tq

egen gid = group(series energy_community)
xtset gid tq
by gid: gen share_ma4 = (share + L.share + L2.share + L3.share)/4

*-----------------------------*
* 5) Save
*-----------------------------*
save "$data/constructed data/trends_labor_demand_long.dta", replace
