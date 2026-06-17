********************************************************************************
* ESA TWFE by year, cluster at county, optional year×state FE
* No file writes except final graph exports. Uses $data, $fig, $tab.
********************************************************************************
clear all

* Install necessary packages
foreach pkg in ftools reghdfe coefplot estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

********************************************************************************
* Import
********************************************************************************
import delimited using "$data/constructed data/final_political_support_file.csv", ///
    clear varn(1)

generate ec_ind_official = (ec_ind_official_cohort_1_percent > 0 | ec_ind_official_cohort_2_percent > 0 | ec_ind_official_cohort_3_percent > 0)
	
* Clean numerics
foreach v in year state_id county_id ec_ind_official ///
             president_county_annual vote_county_annual ///
             reducetax_county_annual regulate_county_annual {
    capture confirm numeric variable `v'
    if _rc {
        destring `v', replace ignore(",% $") force
    }
}
label var ec_ind_official "EC official"

* sets (comma-separated for inlist)
local rustbelt  39,18,17,55,26,42,19,21,24,27,29,54
local swing     13,4,26,32,37,42,55

********************************************************************************
* Helper: estimate, plot, and store estimate
********************************************************************************
cap program drop run_esa
program define run_esa, rclass
    // usage: run_esa outcome [if], name(stem) [base(year)] [yearstatefe]
    syntax varname [if], NAME(string) [BASE(integer 2021) YEARSTATEFE]

    preserve
        if "`if'" != "" keep `if'

        local base = `base'
        fvset base `base' year

        quietly {
            if "`yearstatefe'" != "" {
                egen year_state = group(year state_id)
                reghdfe `varlist' ib`base'.year##i.ec_ind_official, ///
                    absorb(county_id year_state) vce(cluster county_id)
            }
            else {
                reghdfe `varlist' ib`base'.year##i.ec_ind_official, ///
                    absorb(county_id) vce(cluster county_id)
            }
        }

        local estid = substr("`name'",1,27)
        estimates store `estid'

        * ---------- Extract coefficients ----------
        matrix b = e(b)
        matrix V = e(V)
        
        local cn : colnames b
        local years ""
        foreach c of local cn {
            if regexm("`c'","^([0-9]{4})\.year#1\.ec_ind_official$") {
                local yr = regexs(1)
                if `yr' != `base' {
                    local years `years' `yr'
                }
            }
        }
        
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
        local n_years = `i' - 1

        tempfile original_data
        save `original_data'
        
        clear
        local total_obs = `n_years' + 1
        set obs `total_obs'
        gen position = _n
        gen year = .
        gen coef = .
        gen se = .
        gen ci_lower = .
        gen ci_upper = .

        forval j = 1/`n_years' {
            replace year = `year_`j'' in `j'
            replace coef = coef_`j'[1,1] in `j'
            replace se = se_`j'[1,1] in `j'
            replace ci_lower = coef - 1.96*se in `j'
            replace ci_upper = coef + 1.96*se in `j'
        }

        local ref_pos = 1
        forval j = 1/`n_years' {
            if `year_`j'' < `base' {
                local ref_pos = `j' + 1
            }
        }
        
        replace year = `base' in `total_obs'
        replace coef = 0 in `total_obs'
        replace position = `ref_pos' in `total_obs'
        replace position = position + 1 if year > `base' & !missing(year)
        sort position

        local gname = substr("esa_`name'",1,32)
        
        quietly summarize position if year == `base'
        local xline_pos = r(mean)
        
        quietly count
        local n_total = r(N)
        local xlabel_spec ""
        forval pos = 1/`n_total' {
            quietly summarize year if position == `pos'
            local yr_at_pos = r(mean)
            if `yr_at_pos' == `base' {
                local event_time = 0
            }
            else {
                local event_time = `yr_at_pos' - `base'
            }
            local xlabel_spec `"`xlabel_spec' `pos' "`event_time'""'
        }
        
        local xmin = 0.5
        local xmax = `n_total' + 0.5

        twoway (rcap ci_lower ci_upper position, lcolor(stc1)) ///
               (scatter coef position, mcolor(stc1) msymbol(O) msize(medium)), ///
               yline(0, lcolor(gs8)) ///
               xline(`xline_pos', lcolor(gs8)) ///
               xlabel(`xlabel_spec', labsize(large)) ///
               xscale(range(`xmin' `xmax')) ///
               xtitle("Years from t=-1", size(large)) ytitle("Estimates", size(large)) ///
               ylabel(, labsize(large)) ///
               plotregion(margin(zero)) xsize(5.6) legend(off) ///
               name(`gname', replace)

        use `original_data', clear
    restore
end

********************************************************************************
* PRESIDENT
********************************************************************************
run_esa president_county_annual if !missing(president_county_annual), ///
    name(president_twfe_did)

run_esa president_county_annual if !missing(president_county_annual) & ///
    inlist(state_id, `rustbelt'), ///
    name(president_twfe_did_rust_belt) yearstatefe

run_esa president_county_annual if !missing(president_county_annual) & ///
    inlist(state_id, `swing'), ///
    name(president_twfe_did_swing_states_year_state_FE) yearstatefe

********************************************************************************
* VOTE  — reference year = 2020
********************************************************************************
run_esa vote_county_annual if !missing(vote_county_annual), ///
    name(vote_twfe_did) base(2020)

run_esa vote_county_annual if !missing(vote_county_annual) & ///
    inlist(state_id, `rustbelt'), ///
    name(vote_twfe_did_rust_belt) base(2020) yearstatefe

run_esa vote_county_annual if !missing(vote_county_annual) & ///
    inlist(state_id, `swing'), ///
    name(vote_twfe_did_swing_states_year_state_FE) base(2020) yearstatefe

********************************************************************************
* REDUCE TAX
********************************************************************************
run_esa reducetax_county_annual if !missing(reducetax_county_annual), ///
    name(reducetax_twfe_did)

run_esa reducetax_county_annual if !missing(reducetax_county_annual) & ///
    inlist(state_id, `rustbelt'), ///
    name(reducetax_twfe_did_rust_belt) yearstatefe

run_esa reducetax_county_annual if !missing(reducetax_county_annual) & ///
    inlist(state_id, `swing'), ///
    name(reducetax_twfe_did_swing_states_year_state_FE) yearstatefe

********************************************************************************
* REGULATE
********************************************************************************
run_esa regulate_county_annual if !missing(regulate_county_annual), ///
    name(regulate_twfe_did)

run_esa regulate_county_annual if !missing(regulate_county_annual) & ///
    inlist(state_id, `rustbelt'), ///
    name(regulate_twfe_did_rust_belt) yearstatefe

run_esa regulate_county_annual if !missing(regulate_county_annual) & ///
    inlist(state_id, `swing'), ///
    name(regulate_twfe_did_swing_states_year_state_FE) yearstatefe

********************************************************************************
* TABLES: Event-time coefficients (LaTeX via esttab)
********************************************************************************

local EST_PRES_F  = substr("president_twfe_did",1,27)
local EST_PRES_SW = substr("president_twfe_did_swing_states_year_state_FE",1,27)
local EST_PRES_RB = substr("president_twfe_did_rust_belt",1,27)
local EST_REG_F   = substr("regulate_twfe_did",1,27)
local EST_REG_SW  = substr("regulate_twfe_did_swing_states_year_state_FE",1,27)
local EST_REG_RB  = substr("regulate_twfe_did_rust_belt",1,27)
local EST_VOTE_F  = substr("vote_twfe_did",1,27)
local EST_VOTE_SW = substr("vote_twfe_did_swing_states_year_state_FE",1,27)
local EST_VOTE_RB = substr("vote_twfe_did_rust_belt",1,27)
local EST_TAX_F   = substr("reducetax_twfe_did",1,27)
local EST_TAX_SW  = substr("reducetax_twfe_did_swing_states_year_state_FE",1,27)
local EST_TAX_RB  = substr("reducetax_twfe_did_rust_belt",1,27)

* Base years per outcome
local base_default 2021
local base_vote    2020

* Three columns: l c c c
local COLS 4

* ---- Figure 1 ----
local preheadA  "\begin{tabular}{l*{3}{c}} \toprule"
local postheadA "\midrule \multicolumn{`COLS'}{l}{\textbf{Panel A: President Should Do More About Global Warming}} \\"
local prestatsA "\midrule"
local postfootA "\midrule"

local postheadB "\multicolumn{`COLS'}{l}{\textbf{Panel B: Regulate CO\textsubscript{2} As Pollutant}} \\"
local prestatsB "\midrule"
local postfootB "\bottomrule \end{tabular}"

* ---- Figure 2 ----
local prehead2A  "\begin{tabular}{l*{3}{c}} \toprule"
local posthead2A "\midrule \multicolumn{`COLS'}{l}{\textbf{Panel A: President's View on Global Warming Important}} \\"
local prestats2A "\midrule"
local postfoot2A "\midrule"

local posthead2B "\multicolumn{`COLS'}{l}{\textbf{Panel B: Introduce Carbon Tax}} \\"
local prestats2B "\midrule"
local postfoot2B "\bottomrule \end{tabular}"

* =========================
* Helper macro: build keep/coeflabels for a given estimate and base year
* =========================
* (inlined below for each panel since Stata macros can't return macros cleanly)

* =========================
* Figure 1: President & Regulate
* =========================
local base `base_default'

estimates restore `EST_PRES_F'
tempname b_f1
matrix `b_f1' = e(b)
local cn_f1 : colfullnames `b_f1'

local all_years ""
foreach nm of local cn_f1 {
    local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
    if `ok' {
        local yy = regexs(1)
        if "`yy'"=="" local yy = regexs(2)
        if "`yy'"!="`base'" {
            local all_years `all_years' `yy'
        }
    }
}

local sorted_years ""
foreach y of local all_years {
    if "`sorted_years'" == "" {
        local sorted_years `y'
    }
    else {
        local inserted 0
        local new_list ""
        foreach sy of local sorted_years {
            if `y' < `sy' & `inserted' == 0 {
                local new_list `new_list' `y'
                local inserted 1
            }
            local new_list `new_list' `sy'
        }
        if `inserted' == 0 local new_list `new_list' `y'
        local sorted_years `new_list'
    }
}

local pre_years ""
local post_years ""
foreach yy of local sorted_years {
    if `yy' < `base' local pre_years `pre_years' `yy'
    else              local post_years `post_years' `yy'
}

local common_keep ""
local common_clabs ""
local first_post_var ""

foreach yy of local sorted_years {
    if `yy' < `base' {
        foreach nm of local cn_f1 {
            local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
            if `ok' {
                local test_yy = regexs(1)
                if "`test_yy'"=="" local test_yy = regexs(2)
                if "`test_yy'" == "`yy'" {
                    local common_keep "`common_keep' `nm'"
                    local delta = `base' - `yy'
                    local common_clabs `"`common_clabs' `nm' "\$\hat{\delta}_`delta'^{pl}\$ (`yy')""'
                    continue, break
                }
            }
        }
    }
}

local post_count = 1
foreach yy of local post_years {
    foreach nm of local cn_f1 {
        local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
        if `ok' {
            local test_yy = regexs(1)
            if "`test_yy'"=="" local test_yy = regexs(2)
            if "`test_yy'" == "`yy'" {
                local common_keep "`common_keep' `nm'"
                local common_clabs `"`common_clabs' `nm' "\$\hat{\delta}_`post_count'\$ (`yy')""'
                if "`first_post_var'" == "" local first_post_var "`nm'"
                local ++post_count
                continue, break
            }
        }
    }
}

esttab `EST_PRES_F' `EST_PRES_RB' `EST_PRES_SW' using "$output/esa_politics_fig1_revisions.tex", ///
    replace fragment booktabs noobs nolines nonote ///
    keep(`common_keep') coeflabels(`common_clabs') ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations")) ///
    mtitles("Full sample" "Rust Belt" "Swing states") ///
    substitute(\_ _) ///
    prehead(`preheadA') posthead(`postheadA') prefoot(`prestatsA') postfoot(`postfootA') ///
    refcat(`first_post_var' "\addlinespace", nolabel)

esttab `EST_REG_F' `EST_REG_RB' `EST_REG_SW' using "$output/esa_politics_fig1_revisions.tex", ///
    append fragment booktabs noobs nolines nonote ///
    keep(`common_keep') coeflabels(`common_clabs') ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations")) ///
    nonumber nomtitles ///
    substitute(\_ _) ///
    posthead(`postheadB') prefoot(`prestatsB') postfoot(`postfootB') ///
    refcat(`first_post_var' "\addlinespace", nolabel)

* =========================
* Figure 2: Vote (base=2020) & Carbon tax (base=2021)
* =========================

* --- VOTE: base = 2020 ---
local base `base_vote'

estimates restore `EST_VOTE_F'
matrix b1 = e(b)
local cn1 : colfullnames b1
estimates restore `EST_VOTE_RB'
matrix b2 = e(b)
local cn2 : colfullnames b2
estimates restore `EST_VOTE_SW'
matrix b3 = e(b)
local cn3 : colfullnames b3

local all_years_vote ""
foreach nm of local cn1 {
    local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
    if `ok' {
        local yy = regexs(1)
        if "`yy'"=="" local yy = regexs(2)
        if "`yy'"!="`base'" & strpos(" `cn2' "," `nm' ") {
            local all_years_vote `all_years_vote' `yy'
        }
    }
}

local sorted_years_vote ""
foreach y of local all_years_vote {
    if "`sorted_years_vote'" == "" {
        local sorted_years_vote `y'
    }
    else {
        local inserted 0
        local new_list ""
        foreach sy of local sorted_years_vote {
            if `y' < `sy' & `inserted' == 0 {
                local new_list `new_list' `y'
                local inserted 1
            }
            local new_list `new_list' `sy'
        }
        if `inserted' == 0 local new_list `new_list' `y'
        local sorted_years_vote `new_list'
    }
}

local pre_years_vote ""
local post_years_vote ""
foreach yy of local sorted_years_vote {
    if `yy' < `base' local pre_years_vote `pre_years_vote' `yy'
    else              local post_years_vote `post_years_vote' `yy'
}

local keep_VOTE ""
local clabs_VOTE ""
local first_post_var_vote ""

foreach yy of local sorted_years_vote {
    if `yy' < `base' {
        foreach nm of local cn1 {
            local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
            if `ok' {
                local test_yy = regexs(1)
                if "`test_yy'"=="" local test_yy = regexs(2)
                if "`test_yy'" == "`yy'" & strpos(" `cn2' "," `nm' ") {
                    local keep_VOTE "`keep_VOTE' `nm'"
                    local delta = `base' - `yy'
                    local clabs_VOTE `"`clabs_VOTE' `nm' "\$\hat{\delta}_`delta'^{pl}\$ (`yy')""'
                    continue, break
                }
            }
        }
    }
}

local post_count = 1
foreach yy of local post_years_vote {
    foreach nm of local cn1 {
        local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
        if `ok' {
            local test_yy = regexs(1)
            if "`test_yy'"=="" local test_yy = regexs(2)
            if "`test_yy'" == "`yy'" & strpos(" `cn2' "," `nm' ") {
                local keep_VOTE "`keep_VOTE' `nm'"
                local clabs_VOTE `"`clabs_VOTE' `nm' "\$\hat{\delta}_`post_count'\$ (`yy')""'
                if "`first_post_var_vote'" == "" local first_post_var_vote "`nm'"
                local ++post_count
                continue, break
            }
        }
    }
}

esttab `EST_VOTE_F' `EST_VOTE_RB' `EST_VOTE_SW' using "$output/esa_politics_fig2_revisions.tex", ///
    replace fragment booktabs noobs nolines nonote ///
    keep(`keep_VOTE') coeflabels(`clabs_VOTE') ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations")) ///
    mtitles("Full sample" "Rust Belt" "Swing states") ///
    substitute(\_ _) ///
    prehead(`prehead2A') posthead(`posthead2A') prefoot(`prestats2A') postfoot(`postfoot2A') ///
    refcat(`first_post_var_vote' "\addlinespace", nolabel)

* --- CARBON TAX: base = 2021 ---
local base `base_default'

estimates restore `EST_TAX_F'
matrix b1 = e(b)
local cn1 : colfullnames b1
estimates restore `EST_TAX_RB'
matrix b2 = e(b)
local cn2 : colfullnames b2
estimates restore `EST_TAX_SW'
matrix b3 = e(b)
local cn3 : colfullnames b3

local all_years_tax ""
foreach nm of local cn1 {
    local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
    if `ok' {
        local yy = regexs(1)
        if "`yy'"=="" local yy = regexs(2)
        if "`yy'"!="`base'" & strpos(" `cn2' "," `nm' ") {
            local all_years_tax `all_years_tax' `yy'
        }
    }
}

local sorted_years_tax ""
foreach y of local all_years_tax {
    if "`sorted_years_tax'" == "" {
        local sorted_years_tax `y'
    }
    else {
        local inserted 0
        local new_list ""
        foreach sy of local sorted_years_tax {
            if `y' < `sy' & `inserted' == 0 {
                local new_list `new_list' `y'
                local inserted 1
            }
            local new_list `new_list' `sy'
        }
        if `inserted' == 0 local new_list `new_list' `y'
        local sorted_years_tax `new_list'
    }
}

local pre_years_tax ""
local post_years_tax ""
foreach yy of local sorted_years_tax {
    if `yy' < `base' local pre_years_tax `pre_years_tax' `yy'
    else              local post_years_tax `post_years_tax' `yy'
}

local keep_TAX ""
local clabs_TAX ""
local first_post_var_tax ""

foreach yy of local sorted_years_tax {
    if `yy' < `base' {
        foreach nm of local cn1 {
            local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
            if `ok' {
                local test_yy = regexs(1)
                if "`test_yy'"=="" local test_yy = regexs(2)
                if "`test_yy'" == "`yy'" & strpos(" `cn2' "," `nm' ") {
                    local keep_TAX "`keep_TAX' `nm'"
                    local delta = `base' - `yy'
                    local clabs_TAX `"`clabs_TAX' `nm' "\$\hat{\delta}_`delta'^{pl}\$ (`yy')""'
                    continue, break
                }
            }
        }
    }
}

local post_count = 1
foreach yy of local post_years_tax {
    foreach nm of local cn1 {
        local ok = regexm("`nm'","(^[0-9]+)\.year#1\.ec_ind_official|^1\.ec_ind_official#([0-9]+)\.year")
        if `ok' {
            local test_yy = regexs(1)
            if "`test_yy'"=="" local test_yy = regexs(2)
            if "`test_yy'" == "`yy'" & strpos(" `cn2' "," `nm' ") {
                local keep_TAX "`keep_TAX' `nm'"
                local clabs_TAX `"`clabs_TAX' `nm' "\$\hat{\delta}_`post_count'\$ (`yy')""'
                if "`first_post_var_tax'" == "" local first_post_var_tax "`nm'"
                local ++post_count
                continue, break
            }
        }
    }
}

esttab `EST_TAX_F' `EST_TAX_RB' `EST_TAX_SW' using "$output/esa_politics_fig2_revisions.tex", ///
    append fragment booktabs noobs nolines nonote ///
    keep(`keep_TAX') coeflabels(`clabs_TAX') ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N, fmt(%9.0fc) labels("Observations")) ///
    nonumber nomtitles ///
    substitute(\_ _) ///
    posthead(`posthead2B') prefoot(`prestats2B') postfoot(`postfoot2B') ///
    refcat(`first_post_var_tax' "\addlinespace", nolabel)

********************************************************************************
* EXPORT GRAPHS AS PDF
********************************************************************************

local targets ///
    esa_president_twfe_did ///
    esa_president_twfe_did_rust_belt ///
    esa_president_twfe_did_swing_states_year_state_FE ///
    esa_regulate_twfe_did ///
    esa_regulate_twfe_did_rust_belt ///
    esa_regulate_twfe_did_swing_states_year_state_FE ///
    esa_vote_twfe_did ///
    esa_vote_twfe_did_rust_belt ///
    esa_vote_twfe_did_swing_states_year_state_FE ///
    esa_reducetax_twfe_did ///
    esa_reducetax_twfe_did_rust_belt ///
    esa_reducetax_twfe_did_swing_states_year_state_FE

foreach f of local targets {
    local gname = substr("`f'",1,32)
    capture graph export "$output/`f'_revisions.pdf", name(`gname') as(pdf) replace
    if _rc {
        di as error "Graph not found: `f'  (looked for name `gname')"
    }
    else {
        di as txt "Saved: $output/`f'_revisions.pdf"
    }
}