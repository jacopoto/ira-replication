* Install necessary packages
foreach pkg in did_multiplegt_dyn estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}
	
* Import your full data first
import delimited using "$data/constructed data/investment_dataset_stata_with_unemployment.csv", ///
    varnames(1) encoding(UTF-8) clear

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

destring unemployment_lag1 unemployment_lag2 unemployment_lag3, replace force

* Keep only variables needed for the estimation to speed up computation 
preserve 
	keep investment_*_binary census_tract_id period treatment_shift unemployment_lag1 unemployment_lag2 unemployment_lag3
	
	eststo dyn_solar: did_multiplegt_dyn ///
		investment_solar_binary census_tract_id period treatment_shift, ///
		effects(10) placebo(8) cluster(census_tract_id)  ///
		controls(unemployment_lag1 unemployment_lag2 unemployment_lag3) ///
		graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.001(0.001)0.005, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_solar_binary, replace))	
	graph export "$output/dcdh_binary_solar_investment_shift_revisions_with_unemployment.pdf", replace
	
	scalar did_invest_solar = e(Av_tot_effect)
	display "Average DiD investment effect (solar): " did_invest_solar

				 
	eststo dyn_wind: did_multiplegt_dyn ///
		investment_wind_binary census_tract_id period treatment_shift, ///
		effects(10) placebo(8) cluster(census_tract_id)  ///
		controls(unemployment_lag1 unemployment_lag2 unemployment_lag3) ///
		graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.001(0.001)0.005, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_wind_binary, replace)) 	
	graph export "$output/dcdh_binary_wind_investment_shift_revisions_with_unemployment.pdf", replace
	
	scalar did_invest_wind = e(Av_tot_effect)
	display "Average DiD investment effect (wind): " did_invest_wind

restore

summ investment_solar_binary if (ec_ind_official_cohort_1 == 1 & treatment == 0 & period < 21) | (ec_ind_official_cohort_2 == 1 & treatment == 0 & period < 26) | (ec_ind_official_cohort_3 == 1 & treatment == 0 & period < 27)
scalar treated_pre = r(mean)

summ investment_solar_binary if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year < 2023)
scalar control_pre = r(mean)

summ investment_solar_binary if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year > 2022)
scalar control_post = r(mean)

* Counterfactual treated post mean
scalar treated_counterfactual_post = treated_pre + (control_post - control_pre)

* Percent change relative to counterfactual
scalar percent_change_solar_invest = (did_invest_solar / treated_counterfactual_post) * 100
scalar percent_change_solar_invest_2 = (did_invest_solar / treated_pre) * 100

display "Solar Investment: DiD percent change relative to pre-IRA mean = " percent_change_solar_invest_2 "%"
display "Solar Investment: DiD percent change relative to counterfactual mean = " percent_change_solar_invest "%"

* Run labor demand do to eststore estimates to be shown in table
do "$code/Code/analysis/317_2_main_reg_results_with_unemployment.do"

esttab dyn_* lab_* using "$output/reg_invest_lab_dem_revisions_with_unemployment.tex", ///
	replace booktabs se nonote wide noobs ///
	mtitles("Solar" "Wind" "Solar" "Wind") ///
	mgroups("Investment" "Labour Demand", pattern(1 0 1 0 ) ///
		prefix(\multicolumn{@span}{c}{) suffix(}) span ///
		erepeat(\cmidrule(lr){@span})) ///
	b(%9.3f) se(%9.3f) ///
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