*---------------------------------------------------
* TWFE DiD event-study: Republican two-party vote share by EC status
* Group 1a (Class III+I): 2016, 2018, 2022, 2024 — ref = 2018
* Group 1b (Class III+II): 2016, 2020, 2022       — ref = 2020
* Group 2  (Class I+II):   2018, 2020, 2024        — ref = 2020 (2016 excluded)
*---------------------------------------------------

* ---------- Load ----------
import delimited using "$data/constructed data/senate_election_data.csv", ///
    varnames(1) encoding(UTF-8) clear

* ---------- Harmonize ----------
destring year state_id county_id ec_ind_official_cohort_1_percent ///
    ec_ind_official_cohort_2_percent ec_ind_official_cohort_3_percent ///
    reublican_voteshare, replace force

gen ec_ind_official = 0
replace ec_ind_official = 1 if ///
    (ec_ind_official_cohort_1_percent != 0 | ///
     ec_ind_official_cohort_2_percent != 0 | ///
     ec_ind_official_cohort_3_percent != 0) & ///
    !missing(ec_ind_official_cohort_1_percent, ///
             ec_ind_official_cohort_2_percent, ///
             ec_ind_official_cohort_3_percent)

local y reublican_voteshare

* ---------- Identify cycle groups ----------
bysort state_id: egen has_2022 = max(!missing(`y') & year == 2022)
bysort state_id: egen has_2024 = max(!missing(`y') & year == 2024)
bysort state_id: egen has_2020 = max(!missing(`y') & year == 2020)

gen cycle_group = .
replace cycle_group = 1 if has_2022 == 1 & has_2024 == 1   // Class III+I
replace cycle_group = 2 if has_2022 == 1 & has_2024 == 0   // Class III+II
replace cycle_group = 3 if has_2022 == 0                   // Class I+II

* ---------- FE identifier ----------
egen year_state = group(year state_id)

* ---------- Common esttab options ----------
local common_options nobase booktabs b(%9.3f) se(%9.3f) ///
    collabels(none) obslast ///
    stats(r2 N, fmt(3 %9.0fc) labels("\(R^{2}\)" "Obs.")) ///
    nocons nonote varwidth(25) interaction(" $\times$ ")

* ---------- Helper: Group 1a plots ----------
* ref=2018; pre: 2016; post: 2022, 2024
cap program drop plot_g1a
program define plot_g1a
    syntax, estname(string) gname(string) title(string)

    preserve
    est restore `estname'
    matrix b = e(b)
    matrix V = e(V)

    local years_g1a 2016 2022 2024
    local i = 1
    foreach yr of local years_g1a {
        local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
        if `pos' != . {
            matrix coef_`i' = b[1, `pos']
            matrix se_`i'   = sqrt(V[`pos', `pos'])
            local year_`i'  = `yr'
            local ++i
        }
    }
    local n_found = `i' - 1

    clear
    set obs 4
    gen position = _n
    gen year     = .
    gen coef     = .
    gen se       = .
    gen ci_lower = .
    gen ci_upper = .

    forval j = 1/`n_found' {
        replace year     = `year_`j'' in `j'
        replace coef     = coef_`j'[1,1] in `j'
        replace se       = se_`j'[1,1]   in `j'
        replace ci_lower = coef - 1.96*se in `j'
        replace ci_upper = coef + 1.96*se in `j'
    }

    replace year     = 2018 in 4
    replace coef     = 0    in 4
    replace se       = 0    in 4
    replace ci_lower = 0    in 4
    replace ci_upper = 0    in 4

    replace position = 1    if year == 2016
    replace position = 2    if year == 2018
    replace position = 3    if year == 2022
    replace position = 4    if year == 2024
    sort position

    twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
           (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
           yline(0, lcolor(gs8)) ///
           xline(2, lcolor(gs8)) ///
           xlabel(1 "t-1 (2016)" 2 "t0 (2018)" 3 "t+2 (2022)" 4 "t+3 (2024)", ///
                  labsize(medium)) ///
           xtitle("Election cycle", size(large)) ytitle("Estimates", size(large)) ///
           title("`title'", size(medium)) ///
           ylabel(-.03(.01).02, labsize(large)) ///
           xscale(range(0.5 4.5)) ///
           plotregion(margin(zero)) xsize(5.6) legend(off) ///
           name(`gname', replace)
    restore
end

* ---------- Helper: Group 1b plots ----------
* ref=2020; pre: 2016; post: 2022
cap program drop plot_g1b
program define plot_g1b
    syntax, estname(string) gname(string) title(string)

    preserve
    est restore `estname'
    matrix b = e(b)
    matrix V = e(V)

    local years_g1b 2016 2022
    local i = 1
    foreach yr of local years_g1b {
        local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
        if `pos' != . {
            matrix coef_`i' = b[1, `pos']
            matrix se_`i'   = sqrt(V[`pos', `pos'])
            local year_`i'  = `yr'
            local ++i
        }
    }
    local n_found = `i' - 1

    clear
    set obs 3
    gen position = _n
    gen year     = .
    gen coef     = .
    gen se       = .
    gen ci_lower = .
    gen ci_upper = .

    forval j = 1/`n_found' {
        replace year     = `year_`j'' in `j'
        replace coef     = coef_`j'[1,1] in `j'
        replace se       = se_`j'[1,1]   in `j'
        replace ci_lower = coef - 1.96*se in `j'
        replace ci_upper = coef + 1.96*se in `j'
    }

    replace year     = 2020 in 3
    replace coef     = 0    in 3
    replace se       = 0    in 3
    replace ci_lower = 0    in 3
    replace ci_upper = 0    in 3

    replace position = 1    if year == 2016
    replace position = 2    if year == 2020
    replace position = 3    if year == 2022
    sort position

    twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
           (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
           yline(0, lcolor(gs8)) ///
           xline(2, lcolor(gs8)) ///
           xlabel(1 "t-1 (2016)" 2 "t0 (2020)" 3 "t+1 (2022)", labsize(medium)) ///
           xtitle("Election cycle", size(large)) ytitle("Estimates", size(large)) ///
           title("`title'", size(medium)) ///
           ylabel(-.03(.01).02, labsize(large)) ///
           xscale(range(0.5 3.5)) ///
           plotregion(margin(zero)) xsize(5.6) legend(off) ///
           name(`gname', replace)
    restore
end

* ---------- Helper: Group 2 plots ----------
* ref=2020; pre: 2018; post: 2024
cap program drop plot_g2
program define plot_g2
    syntax, estname(string) gname(string) title(string)

    preserve
    est restore `estname'
    matrix b = e(b)
    matrix V = e(V)

    local years_g2 2018 2024
    local i = 1
    foreach yr of local years_g2 {
        local pos = colnumb(b, "`yr'.year#1.ec_ind_official")
        if `pos' != . {
            matrix coef_`i' = b[1, `pos']
            matrix se_`i'   = sqrt(V[`pos', `pos'])
            local year_`i'  = `yr'
            local ++i
        }
    }
    local n_found = `i' - 1

    clear
    set obs 3
    gen position = _n
    gen year     = .
    gen coef     = .
    gen se       = .
    gen ci_lower = .
    gen ci_upper = .

    forval j = 1/`n_found' {
        replace year     = `year_`j'' in `j'
        replace coef     = coef_`j'[1,1] in `j'
        replace se       = se_`j'[1,1]   in `j'
        replace ci_lower = coef - 1.96*se in `j'
        replace ci_upper = coef + 1.96*se in `j'
    }

    replace year     = 2020 in 3
    replace coef     = 0    in 3
    replace se       = 0    in 3
    replace ci_lower = 0    in 3
    replace ci_upper = 0    in 3
    replace position = 2    in 3
    replace position = 3    if year == 2024
    sort position

    twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
           (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
           yline(0, lcolor(gs8)) ///
           xline(2, lcolor(gs8)) ///
           xlabel(1 "t-1 (2018)" 2 "t0 (2020)" 3 "t+1 (2024)", labsize(medium)) ///
           xtitle("Election cycle", size(large)) ytitle("Estimates", size(large)) ///
           title("`title'", size(medium)) ///
           ylabel(-.03(.01).02, labsize(large)) ///
           xscale(range(0.5 3.5)) ///
           plotregion(margin(zero)) xsize(5.6) legend(off) ///
           name(`gname', replace)
    restore
end

********************************************************************************
* GROUP 1a: Class III+I — ref = 2018
********************************************************************************

fvset base 2018 year
eststo clear

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 1, ///
    absorb(county_id year_state) cluster(county_id)
eststo g1a_full

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 1 & ///
    inlist(state_id, 39,18,17,55,26,42,19,21,24,27,29,54), ///
    absorb(county_id year_state) cluster(county_id)
eststo g1a_rust

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 1 & ///
    inlist(state_id, 13,4,26,32,37,42,55), ///
    absorb(county_id year_state) cluster(county_id)
eststo g1a_swing

* ---------- Plots: Group 1a ----------
plot_g1a, estname(g1a_full)  gname(g1a_esa_full)  title("Full sample")
graph export "$output/g1a_esa_republican_senate_voteshare_twfe_did.pdf", ///
    name(g1a_esa_full) replace

plot_g1a, estname(g1a_rust)  gname(g1a_esa_rust)  title("Rust Belt")
graph export "$output/g1a_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf", ///
    name(g1a_esa_rust) replace

plot_g1a, estname(g1a_swing) gname(g1a_esa_swing) title("Swing states")
graph export "$output/g1a_esa_republican_senate_voteshare_twfe_did_swing_states.pdf", ///
    name(g1a_esa_swing) replace

* ---------- Table: Group 1a ----------
est restore g1a_full
matrix b = e(b)
local cn : colnames b
local keep_int
local clabs
foreach c of local cn {
    local yr = ""
    if regexm("`c'", "^([0-9]{4})\.year#1\.ec_ind_official$") local yr = regexs(1)
    else if regexm("`c'", "^1\.ec_ind_official#([0-9]{4})\.year$") local yr = regexs(1)
    if "`yr'" != "" {
        local keep_int `keep_int' `c'
        if      "`yr'" == "2016" local clabs `clabs' `c' "\$\hat{\delta}_{-1}^{pl}\$ (2016)"
        else if "`yr'" == "2022" local clabs `clabs' `c' "\$\hat{\delta}_{1}\$ (2022)"
        else if "`yr'" == "2024" local clabs `clabs' `c' "\$\hat{\delta}_{2}\$ (2024)"
    }
}

esttab g1a_full g1a_rust g1a_swing ///
    using "$output/g1a_esa_republican_senate_voteshare_twfe_did.tex", ///
    replace `common_options' ///
    mlabels("Full sample" "Rust Belt" "Swing states", depvar) ///
    keep(`keep_int') ///
    coeflabels(`clabs') ///
    substitute(\_ _) ///
    refcat(2022.year#1.ec_ind_official "\addlinespace", nolabel)

********************************************************************************
* GROUP 1b: Class III+II — ref = 2020
* Note: year != 2018 excludes any spurious special-election observations;
*       Group 1b regular elections are 2016, 2020, 2022 only.
********************************************************************************

fvset base 2020 year
eststo clear

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 2 & year != 2018, ///
    absorb(county_id year_state) cluster(county_id)
eststo g1b_full

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 2 & year != 2018 & ///
    inlist(state_id, 39,18,17,55,26,42,19,21,24,27,29,54), ///
    absorb(county_id year_state) cluster(county_id)
eststo g1b_rust

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 2 & year != 2018 & ///
    inlist(state_id, 13,4,26,32,37,42,55), ///
    absorb(county_id year_state) cluster(county_id)
eststo g1b_swing

* ---------- Plots: Group 1b ----------
plot_g1b, estname(g1b_full)  gname(g1b_esa_full)  title("Full sample")
graph export "$output/g1b_esa_republican_senate_voteshare_twfe_did.pdf", ///
    name(g1b_esa_full) replace

plot_g1b, estname(g1b_rust)  gname(g1b_esa_rust)  title("Rust Belt")
graph export "$output/g1b_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf", ///
    name(g1b_esa_rust) replace

plot_g1b, estname(g1b_swing) gname(g1b_esa_swing) title("Swing states")
graph export "$output/g1b_esa_republican_senate_voteshare_twfe_did_swing_states.pdf", ///
    name(g1b_esa_swing) replace

* ---------- Table: Group 1b ----------
est restore g1b_full
matrix b = e(b)
local cn : colnames b
local keep_int
local clabs
foreach c of local cn {
    local yr = ""
    if regexm("`c'", "^([0-9]{4})\.year#1\.ec_ind_official$") local yr = regexs(1)
    else if regexm("`c'", "^1\.ec_ind_official#([0-9]{4})\.year$") local yr = regexs(1)
    if "`yr'" != "" {
        local keep_int `keep_int' `c'
        if      "`yr'" == "2016" local clabs `clabs' `c' "\$\hat{\delta}_{-2}^{pl}\$ (2016)"
        else if "`yr'" == "2022" local clabs `clabs' `c' "\$\hat{\delta}_{1}\$ (2022)"
    }
}

esttab g1b_full g1b_rust g1b_swing ///
    using "$output/g1b_esa_republican_senate_voteshare_twfe_did.tex", ///
    replace `common_options' ///
    mlabels("Full sample" "Rust Belt" "Swing states", depvar) ///
    keep(`keep_int') ///
    coeflabels(`clabs') ///
    substitute(\_ _) ///
    refcat(2022.year#1.ec_ind_official "\addlinespace", nolabel)

********************************************************************************
* GROUP 2: Class I+II — ref = 2020 (2016 special election excluded)
********************************************************************************

fvset base 2020 year
eststo clear

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 3 & year != 2016, ///
    absorb(county_id year_state) cluster(county_id)
eststo g2_full

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 3 & year != 2016 & ///
    inlist(state_id, 39,18,17,55,26,42,19,21,24,27,29,54), ///
    absorb(county_id year_state) cluster(county_id)
eststo g2_rust

reghdfe `y' i.year##i.ec_ind_official if cycle_group == 3 & year != 2016 & ///
    inlist(state_id, 13,4,26,32,37,42,55), ///
    absorb(county_id year_state) cluster(county_id)
eststo g2_swing

* ---------- Plots: Group 2 ----------
plot_g2, estname(g2_full)  gname(g2_esa_full)  title("Full sample")
graph export "$output/g2_esa_republican_senate_voteshare_twfe_did.pdf", ///
    name(g2_esa_full) replace

plot_g2, estname(g2_rust)  gname(g2_esa_rust)  title("Rust Belt")
graph export "$output/g2_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf", ///
    name(g2_esa_rust) replace

plot_g2, estname(g2_swing) gname(g2_esa_swing) title("Swing states")
graph export "$output/g2_esa_republican_senate_voteshare_twfe_did_swing_states.pdf", ///
    name(g2_esa_swing) replace

* ---------- Table: Group 2 ----------
est restore g2_full
matrix b = e(b)
local cn : colnames b
local keep_int
local clabs
foreach c of local cn {
    local yr = ""
    if regexm("`c'", "^([0-9]{4})\.year#1\.ec_ind_official$") local yr = regexs(1)
    else if regexm("`c'", "^1\.ec_ind_official#([0-9]{4})\.year$") local yr = regexs(1)
    if "`yr'" != "" {
        local keep_int `keep_int' `c'
        if      "`yr'" == "2018" local clabs `clabs' `c' "\$\hat{\delta}_{-1}^{pl}\$ (2018)"
        else if "`yr'" == "2024" local clabs `clabs' `c' "\$\hat{\delta}_{1}\$ (2024)"
    }
}

esttab g2_full g2_rust g2_swing ///
    using "$output/g2_esa_republican_senate_voteshare_twfe_did.tex", ///
    replace `common_options' ///
    mlabels("Full sample" "Rust Belt" "Swing states", depvar) ///
    keep(`keep_int') ///
    coeflabels(`clabs') ///
    substitute(\_ _) ///
    refcat(2024.year#1.ec_ind_official "\addlinespace", nolabel)
