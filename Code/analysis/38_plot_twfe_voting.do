*---------------------------------------------------
* TWFE DiD event-study for Republican two-party vote share by EC status
*
* Date: 10/27/2025
*
* Input:  $data/constructed data/final_election_file.csv
* Output: $fig/esa_republican_voteshare_twfe_did.pdf
*         $fig/esa_republican_voteshare_twfe_did_rust_belt.pdf
*         $fig/esa_republican_voteshare_twfe_did_swing_states_year_state_FE.pdf
*         $tab/esa_republican_voteshare_twfe_did.tex
*---------------------------------------------------


* ---------- Load ----------
import delimited using "$data/constructed data/final_election_file.csv", ///
    varnames(1) encoding(UTF-8) clear

* ---------- Harmonize ----------
destring year state_id county_id ec_ind_official_cohort_1_percent ///
	ec_ind_official_cohort_2_percent ec_ind_official_cohort_3_percent ///
    republican_twoparty_voteshare_co republican_twoparty_voteshare_co, ///
    replace force
gen ec_ind_official = 0
replace ec_ind_official = 1 if (ec_ind_official_cohort_1_percent!=0 | ///
    ec_ind_official_cohort_2_percent!=0 | ///
    ec_ind_official_cohort_3_percent!=0) & ///
    !missing(ec_ind_official_cohort_1_percent, ///
             ec_ind_official_cohort_2_percent, ///
             ec_ind_official_cohort_3_percent)
			 
* Outcome fallback
local y republican_twoparty_voteshare_co
cap confirm variable `y'
if _rc local y republican_twoparty_voteshare_county

* FE ids and base year for event-time
egen year_state = group(year state_id)
fvset base 2020 year

* ---------- Common graph options ----------
local keep_g    keep(*.year#1.ec_ind_official 1.ec_ind_official#*.year)
local relabel_g rename("^([0-9]+).*$" = "\1", regex)
local gopts     vertical yline(0, lcolor(gs8) lpattern(solid)) ///
               xline(5.5, lcolor(gs8)) xtitle("") ytitle("Estimates", size(large)) ///
               plotregion(margin(zero)) ylabel(-.03(.01).02, labsize(large)) ///
               xlabel(, labsize(large)) xsize(5.6) ciopts(recast(rcap)) legend(off)

* ---------- Regressions + Figures ----------
* FULL SAMPLE
eststo clear
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo full

coefplot, `keep_g' `relabel_g' `gopts' name(esa_full, replace)
graph export "$output/esa_republican_voteshare_twfe_did.pdf", replace

* RUST BELT (OH IN IL WI MI PA IA KY MD MN MO WV)
preserve
keep if inlist(state_id, 39,18,17,55,26,42,19,21,24,27,29,54)
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo rust

coefplot, `keep_g' `relabel_g' `gopts' name(esa_rb, replace)
graph export "$output/esa_republican_voteshare_twfe_did_rust_belt.pdf", replace
restore

* SWING STATES (GA AZ MI NV NC PA WI)
preserve
keep if inlist(state_id, 13,4,26,32,37,42,55)
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo swing

coefplot, `keep_g' `relabel_g' `gopts' name(esa_swing, replace)
graph export "$output/esa_republican_voteshare_twfe_did_swing_states_year_state_FE.pdf", replace
restore

********************************************************************************
* TABLE: Event-time interactions only (ref = 2020)
********************************************************************************
* Common esttab options (no factor labels)
local common_options nobase booktabs b(%9.3f) se(%9.3f) ///
    collabels(none) obslast ///
    stats(r2 N, fmt(3 %9.0fc) labels("\(R^{2}\)" "Obs.")) ///
    nocons nonote varwidth(25) interaction(" $\times$ ")

* Build keep list + clean labels from FULL model's coefficient names
est restore full
matrix b = e(b)
local cn : colnames b
local keep_int
local clabs
foreach c of local cn {
    if regexm("`c'","^([0-9]{4})\.year#1\.ec_ind_official$") {
        local keep_int `keep_int' `c'
        local clabs `clabs' `c' "`=regexs(1)'"
    }
    else if regexm("`c'","^1\.ec_ind_official#([0-9]{4})\.year$") {
        local keep_int `keep_int' `c'
        local clabs `clabs' `c' "`=regexs(1)'"
    }
}

* Export table: only year×treat terms, labeled by bare years
esttab full rust swing using "$output/esa_republican_voteshare_twfe_did.tex", ///
    replace `common_options' ///
    mlabels("Full sample" "Rust Belt" "Swing states", depvar) ///
    keep(`keep_int') ///
    coeflabels(`clabs')
