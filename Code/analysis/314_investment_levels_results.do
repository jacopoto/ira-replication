*---------------------------------------------------
* Install required user-written packages
*---------------------------------------------------
local packages "estout did_multiplegt_dyn"

foreach pkg of local packages {
    capture which `pkg'
    if _rc {
        display as text "Installing `pkg'..."
        ssc install `pkg', replace
    }
    else {
        display as text "`pkg' already installed"
    }
}

import delimited using "$data/constructed data/investment_dataset_stata.csv", ///
    varnames(1) encoding(UTF-8) clear
	
* Install necessary packages
capture which did_multiplegt_dyn
if _rc ssc install did_multiplegt_dyn

* Step 1: first treatment period per tract
bysort census_tract_id (period): egen first_treat = min(cond(treatment==1, period, .))

* Step 2: flag tracts whose first treatment is 2023-Q1
gen treat2023Q1 = (first_treat==period & year==2023 & quarter=="Q1")
bysort census_tract_id: egen tract_flag = max(treat2023Q1)

* Step 3: set treatment_shift
gen treatment_shift = 0

* For tracts first treated in 2023-Q1: start 2 periods earlier
replace treatment_shift = 1 if tract_flag==1 & period >= first_treat - 2

* For tracts first treated in other periods: start at first_treat
replace treatment_shift = 1 if tract_flag==0 & period >= first_treat

**************************************************************************
*		Investment in levels
**************************************************************************
eststo levels_solar: did_multiplegt_dyn investment_solar census_tract_id ///
	period treatment_shift, ///
    effects(10) placebo(8) cluster(census_tract_id)  ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
				 xlabel(, labsize(large)) ///
				 xsize(8) ///
				 pcycle(1) ///
                 ylabel(-500000(200000)800000, format(%12.0fc) labsize(large)) ///
                 name(graph_solar, replace))	
graph export "$output/dcdh_solar_investment_levels.pdf", replace	

scalar did_invest_solar = e(Av_tot_effect)

summ investment_solar if (ec_ind_official_cohort_1 == 1 & treatment == 0 & period < 21) | (ec_ind_official_cohort_2 == 1 & treatment == 0 & period < 26) | (ec_ind_official_cohort_3 == 1 & treatment == 0 & period < 27)
scalar treated_pre = r(mean)

summ investment_solar if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year < 2023)
scalar control_pre = r(mean)

summ investment_solar if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year > 2022)
scalar control_post = r(mean)

* Counterfactual treated post mean
scalar treated_counterfactual_post = treated_pre + (control_post - control_pre)

* Percent change relative to counterfactual
scalar percent_change_solar_invest = (did_invest_solar / treated_counterfactual_post) * 100
scalar percent_change_solar_invest_2 = (did_invest_solar / treated_pre) * 100

display "Solar Investment: DiD percent change relative to pre-IRA mean = " percent_change_solar_invest_2 "%"
display "Solar Investment: DiD percent change relative to counterfactual mean = " percent_change_solar_invest "%"

eststo levels_wind: did_multiplegt_dyn investment_wind census_tract_id ///
	period treatment_shift, ///
    effects(10) placebo(8) cluster(census_tract_id)   ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
				 xlabel(, labsize(large)) ///
				 xsize(8) ///
				 pcycle(1) ///
                 ylabel(-500000(200000)800000, format(%12.0fc) labsize(large)) ///
                 name(graph_wind, replace))	
graph export "$output/dcdh_wind_investment_levels.pdf", replace	
				 
esttab levels_* using "$output/reg_levels.tex", ///
	replace booktabs se nonote wide noobs ///
	mtitles("Solar" "Wind" "Solar" "Wind") ///
	b(%12.0fc) se(%12.0fc) ///
	refcat(Av_tot_eff "\addlinespace", nolabel) ///
	order(Placebo_8 Placebo_7 Placebo_6 Placebo_5 Placebo_4 Placebo_3 Placebo_2 ///
		  Placebo_1 Effect_1 Effect_2 Effect_3 Effect_4 Effect_5 Effect_6 ///
		  Effect_7 Effect_8 Effect_9 Effect_10 Av_tot_eff) ///
	coeflabels(Effect_1 "$\hat{\delta}_1$" Effect_2 "$\hat{\delta}_2$" ///
		Effect_3 "$\hat{\delta}_3$" Effect_4 "$\hat{\delta}_4$" ///
		Effect_5 "$\hat{\delta}_5$" Effect_6 "$\hat{\delta}_6$" ///
		Effect_7 "$\hat{\delta}_7$" Effect_8 "$\hat{\delta}_8$" ///
		Effect_9 "$\hat{\delta}_9$" Effect_10 "$\hat{\delta}_{10}$" ///
		Av_tot_eff "$\hat{\delta}$" ///
		Placebo_1 "$\hat{\delta}_1^{pl}$" Placebo_2 "$\hat{\delta}_2^{pl}$" ///
		Placebo_3 "$\hat{\delta}_3^{pl}$" Placebo_4 "$\hat{\delta}_4^{pl}$" ///
		Placebo_5 "$\hat{\delta}_5^{pl}$" Placebo_6 "$\hat{\delta}_6^{pl}$" ///
		Placebo_7 "$\hat{\delta}_7^{pl}$" Placebo_8 "$\hat{\delta}_8^{pl}$") ///
		substitute(\_ _) ///
		collabels(,none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01)
		