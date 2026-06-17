*---------------------------------------------------
* TWFE DiD event-study for Republican two-party vote share by EC status
*
* Date: [Updated date]
*
* Input:  $data/constructed data/final_election_file.csv
* Output: [same files]
*---------------------------------------------------

* ---------- Load ----------
import delimited using "$data/constructed data/house_election_data.csv", ///
    varnames(1) encoding(UTF-8) clear

* ---------- Harmonize ----------
destring year state_id county_id ec_ind_official_cohort_1_percent ///
	ec_ind_official_cohort_2_percent ec_ind_official_cohort_3_percent ///
    reublican_voteshare reublican_voteshare, ///
    replace force
gen ec_ind_official = 0
replace ec_ind_official = 1 if (ec_ind_official_cohort_1_percent!=0 | ///
    ec_ind_official_cohort_2_percent!=0 | ///
    ec_ind_official_cohort_3_percent!=0) & ///
    !missing(ec_ind_official_cohort_1_percent, ///
             ec_ind_official_cohort_2_percent, ///
             ec_ind_official_cohort_3_percent)

* Outcome fallback
local y reublican_voteshare
cap confirm variable `y'
if _rc local y reublican_voteshare

* FE ids and base year for event-time
egen year_state = group(year state_id)
fvset base 2020 year  // CHANGED: from 2020 to 2022

* ---------- Common graph options ----------
local keep_g    keep(*.year#1.ec_ind_official 1.ec_ind_official#*.year)
local relabel_g rename("^([0-9]+).*$" = "\1", regex)
local gopts     vertical yline(0, lcolor(gs8) lpattern(solid)) ///
               xline(3, lcolor(gs8)) xtitle("") ytitle("Estimates", size(large)) /// // CHANGED: xline from 5.5 to 4
               plotregion(margin(zero)) ylabel(-.03(.01).02, labsize(large)) ///
               xlabel(, labsize(large)) xsize(5.6) ciopts(recast(rcap)) legend(off)

* ---------- Regressions + Figures ----------
* FULL SAMPLE
eststo clear
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo full

preserve
* ---------- Extract coefficients ----------
matrix b = e(b)
matrix V = e(V)

* Get coefficients and SEs for year#ec_ind_official interactions
local years 2016 2018 2022 2024  // CHANGED: new year list
local i = 1
foreach yr of local years {
    local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
    if `pos' != . {
        matrix coef_`i' = b[1, `pos']
        matrix se_`i' = sqrt(V[`pos', `pos'])
        local year_`i' = `yr'
        local ++i
    }
}

* Create dataset with results
clear
set obs 5  // CHANGED: from 7 to 5
gen position = _n
gen year = .
gen coef = .
gen se = .
gen ci_lower = .
gen ci_upper = .

* Fill in estimated coefficients
forval j = 1/4 {  // CHANGED: from 6 to 4 (4 non-reference years)
    replace year = `year_`j'' in `j'
    replace coef = coef_`j'[1,1] in `j'
    replace se = se_`j'[1,1] in `j'
    replace ci_lower = coef - 1.96*se in `j'
    replace ci_upper = coef + 1.96*se in `j'
}

* Add reference period (2022) at position 4  // CHANGED: from 2020 to 2022, position from 7 to 5
replace year = 2020 in 5
replace coef = 0 in 5
replace position = 3 in 5

* Adjust positions so 2022 is in the middle  // CHANGED: from 2020 to 2022
replace position = position + 1 if year > 2020 & !missing(year)

* Sort by position
sort position

* ---------- Create plot ----------
twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
       (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
       yline(0, lcolor(gs8)) ///
       xline(3, lcolor(gs8)) ///  // CHANGED: from 6 to 4
       xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2", labsize(large)) ///  // CHANGED: new labels
       xtitle("Elections from t=-1", size(large)) ytitle("Estimates", size(large)) ///
       ylabel(-.03(.01).02, labsize(large)) ///
       xscale(range(0.5 5.5)) ///  // CHANGED: from 0.5 7.5 to 0.5 5.5
       plotregion(margin(zero)) xsize(5.6) legend(off) ///
       name(esa_full, replace)
graph export "$output/esa_republican_house_voteshare_twfe_did.pdf", replace
restore

* RUST BELT (OH IN IL WI MI PA IA KY MD MN MO WV)
preserve
keep if inlist(state_id, 39,18,17,55,26,42,19,21,24,27,29,54)
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo rust

* ---------- Extract coefficients ----------
matrix b = e(b)
matrix V = e(V)

* Get coefficients and SEs for year#ec_ind_official interactions
local years 2016 2018 2022 2024  // CHANGED
local i = 1
foreach yr of local years {
    local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
    if `pos' != . {
        matrix coef_`i' = b[1, `pos']
        matrix se_`i' = sqrt(V[`pos', `pos'])
        local year_`i' = `yr'
        local ++i
    }
}

* Create dataset with results
clear
set obs 5  // CHANGED
gen position = _n
gen year = .
gen coef = .
gen se = .
gen ci_lower = .
gen ci_upper = .

* Fill in estimated coefficients
forval j = 1/4 {  // CHANGED
    replace year = `year_`j'' in `j'
    replace coef = coef_`j'[1,1] in `j'
    replace se = se_`j'[1,1] in `j'
    replace ci_lower = coef - 1.96*se in `j'
    replace ci_upper = coef + 1.96*se in `j'
}

* Add reference period (2022)  // CHANGED
replace year = 2020 in 5
replace coef = 0 in 5
replace position = 3 in 5

* Adjust positions so 2022 is in the middle  // CHANGED
replace position = position + 1 if year > 2020 & !missing(year)

* Sort by position
sort position

* ---------- Create plot ----------
twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
       (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
       yline(0, lcolor(gs8)) ///
       xline(3, lcolor(gs8)) ///  // CHANGED
       xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2", labsize(large)) ///  // CHANGED
       xtitle("Elections from t=-1", size(large)) ytitle("Estimates", size(large)) ///
       ylabel(-.03(.01).02, labsize(large)) ///
       xscale(range(0.5 5.5)) ///  // CHANGED
       plotregion(margin(zero)) xsize(5.6) legend(off) ///
       name(esa_rb, replace)
graph export "$output/esa_republican_house_voteshare_twfe_did_rust_belt.pdf", replace
restore

* SWING STATES (GA AZ MI NV NC PA WI)
preserve
keep if inlist(state_id, 13,4,26,32,37,42,55)
reghdfe `y' i.year##i.ec_ind_official, absorb(county_id year_state) cluster(county_id)
eststo swing

* ---------- Extract coefficients ----------
matrix b = e(b)
matrix V = e(V)

* Get coefficients and SEs for year#ec_ind_official interactions
local years 2016 2018 2022 2024  // CHANGED
local i = 1
foreach yr of local years {
    local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
    if `pos' != . {
        matrix coef_`i' = b[1, `pos']
        matrix se_`i' = sqrt(V[`pos', `pos'])
        local year_`i' = `yr'
        local ++i
    }
}

* Create dataset with results
clear
set obs 5  // CHANGED
gen position = _n
gen year = .
gen coef = .
gen se = .
gen ci_lower = .
gen ci_upper = .

* Fill in estimated coefficients
forval j = 1/4 {  // CHANGED
    replace year = `year_`j'' in `j'
    replace coef = coef_`j'[1,1] in `j'
    replace se = se_`j'[1,1] in `j'
    replace ci_lower = coef - 1.96*se in `j'
    replace ci_upper = coef + 1.96*se in `j'
}

* Add reference period (2022)  // CHANGED
replace year = 2020 in 5
replace coef = 0 in 5
replace position = 3 in 5

* Adjust positions so 2022 is in the middle  // CHANGED
replace position = position + 1 if year > 2020 & !missing(year)

* Sort by position
sort position

* ---------- Create plot ----------
twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
       (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
       yline(0, lcolor(gs8)) ///
       xline(3, lcolor(gs8)) ///  // CHANGED
       xlabel(1 "-2" 2 "-1" 3 "0" 4 "1" 5 "2", labsize(large)) ///  // CHANGED
       xtitle("Elections from t=-1", size(large)) ytitle("Estimates", size(large)) ///
       ylabel(-.03(.01).02, labsize(large)) ///
       xscale(range(0.5 5.5)) ///  // CHANGED
       plotregion(margin(zero)) xsize(5.6) legend(off) ///
       name(esa_swing, replace)
graph export "$output/esa_republican_house_voteshare_twfe_did_swing_states_year_state_FE.pdf", replace
restore

********************************************************************************
* TABLE: Event-time interactions only (ref = 2022)  // CHANGED
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
        local yr = regexs(1)
        local keep_int `keep_int' `c'
        // CHANGED: Updated labels for new years
        if `yr' == 2016 local clabs `clabs' `c' "\$\hat{\delta}_{-3}^{pl}\$ (2016)"
        else if `yr' == 2018 local clabs `clabs' `c' "\$\hat{\delta}_{-2}^{pl}\$ (2018)"
        else if `yr' == 2022 local clabs `clabs' `c' "\$\hat{\delta}_{1}\$ (2022)"
        else if `yr' == 2024 local clabs `clabs' `c' "\$\hat{\delta}_2\$ (2024)"
    }
    else if regexm("`c'","^1\.ec_ind_official#([0-9]{4})\.year$") {
        local yr = regexs(1)
        local keep_int `keep_int' `c'
        // CHANGED: Updated labels for new years
        if `yr' == 2016 local clabs `clabs' `c' "\$\hat{\delta}_{-3}^{pl}\$ (2016)"
        else if `yr' == 2018 local clabs `clabs' `c' "\$\hat{\delta}_{-2}^{pl}\$ (2018)"
        else if `yr' == 2020 local clabs `clabs' `c' "\$\hat{\delta}_{2}\$ (2022)"
        else if `yr' == 2024 local clabs `clabs' `c' "\$\hat{\delta}_1\$ (2024)"
    }
}

* Export table: only year×treat terms, labeled by bare years
esttab full rust swing using "$output/esa_republican_house_voteshare_twfe_did.tex", ///
    replace `common_options' ///
    mlabels("Full sample" "Rust Belt" "Swing states", depvar) ///
    keep(`keep_int') ///
    coeflabels(`clabs') ///
	substitute(\_ _) ///
    refcat(2024.year#1.ec_ind_official "\addlinespace", nolabel)