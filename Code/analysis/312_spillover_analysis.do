*---------------------------------------------------
* Spillover analysis: construct treatment shifts, run DiD,
* and export graphs and table.
*
* Author: Jacopo
* Date: 2025-10-16
*
* Input:
*   $data/constructed data/final_investment_dataset_stata.csv
*   $data/constructed data/final_labor_demand_dataset_stata.csv
*
* Output:
*   $fig/dcdh_solar_investment_binary_spillover.pdf
*   $fig/dcdh_wind_investment_binary_spillover.pdf
*   $fig/dcdh_solar_labor_demand_spillover.pdf
*   $fig/dcdh_wind_labor_demand_spillover.pdf
*   $tab/reg_spillover.tex
*
* Requirements: did_multiplegt_dyn estout 
*---------------------------------------------------

* Install necessary packages
foreach pkg in did_multiplegt_dyn estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
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

***************************************************************************
*			Spillover analysis
***************************************************************************
* Flag groups where any row has treatment == 1
egen max_treated = max(treatment), by(census_tract_id)

* Drop groups where treatment ever occurred
drop if max_treated == 1

* Step 1: first treatment period per tract
bysort census_tract_id (period): egen spillover_first_treat = min(cond(spillover_treatment==1, period, .))

* Step 2: flag tracts whose first treatment is 2023-Q1
gen spillover_treat2023Q1 = (spillover_first_treat==period & year==2023 & quarter=="Q1")
bysort census_tract_id: egen spillover_tract_flag = max(spillover_treat2023Q1)

* Step 3: set treatment_shift
gen spillover_treatment_shift = 0

* For tracts first treated in 2023-Q1: start 2 periods earlier
replace spillover_treatment_shift = 1 if spillover_tract_flag==1 & period >= spillover_first_treat - 2

* For tracts first treated in other periods: start at first_treat
replace spillover_treatment_shift = 1 if spillover_tract_flag==0 & period >= spillover_first_treat
				 
eststo spill_solar: did_multiplegt_dyn investment_solar_binary ///
	census_tract_id period spillover_treatment_shift, ///
    effects(10) placebo(8) cluster(census_tract_id)  ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.003(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_spillover_solar_2, replace))
graph export "$output/dcdh_solar_investment_binary_spillover.pdf", replace	
				 
eststo spill_wind: did_multiplegt_dyn investment_wind_binary ///
	census_tract_id period spillover_treatment_shift, ///
    effects(10) placebo(8) cluster(census_tract_id)  ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.003(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_spillover_wind_2, replace))	
graph export "$output/dcdh_wind_investment_binary_spillover.pdf", replace

***************************************************************************
*		Labor Demand data
***************************************************************************
import delimited using ///
	"$data/constructed data/final_labor_demand_dataset_stata.csv", ///
    varnames(1) encoding(UTF-8) clear
	
* Install necessary packages
capture which did_multiplegt_dyn
if _rc ssc install did_multiplegt_dyn

* Step 1: first treatment period per tract
bysort county_id (period): egen first_treat = min(cond(treatment==1, period, .))

* Step 2: flag tracts whose first treatment is 2023-Q1
gen treat2023Q1 = (first_treat==period & year==2023 & quarter=="Q1")
bysort county_id: egen tract_flag = max(treat2023Q1)

* Step 3: set treatment_shift
gen treatment_shift = 0

* For tracts first treated in 2023-Q1: start 2 periods earlier
replace treatment_shift = 1 if tract_flag==1 & period >= first_treat - 2

* For tracts first treated in other periods: start at first_treat
replace treatment_shift = 1 if tract_flag==0 & period >= first_treat


gen job_vacancies_solar_num = real(solar_technologies_job_vacancies)
replace job_vacancies_solar_num = 0 if missing(job_vacancies_solar_num)

gen job_vacancies_wind_num = real(wind_technologies_job_vacancies_)
replace job_vacancies_wind_num = 0 if missing(job_vacancies_wind_num)

gen job_vacancies_y02e10_num = real(y02e10_technologies_job_vacancie)
replace job_vacancies_y02e10_num = 0 if missing(job_vacancies_y02e10_num)

* Flag groups where any row has treatment == 1
egen max_treated = max(treatment), by(county_id)

* Drop groups where treatment ever occurred
drop if max_treated == 1

* Step 1: first treatment period per tract
bysort county_id (period): egen spillover_first_treat = min(cond(spillover_treatment==1, period, .))

* Step 2: flag tracts whose first treatment is 2023-Q1
gen spillover_treat2023Q1 = (spillover_first_treat==period & year==2023 & quarter=="Q1")
bysort county_id: egen spillover_tract_flag = max(spillover_treat2023Q1)

* Step 3: set treatment_shift
gen spillover_treatment_shift = 0

* For tracts first treated in 2023-Q1: start 2 periods earlier
replace spillover_treatment_shift = 1 if spillover_tract_flag==1 & period >= spillover_first_treat - 2

* For tracts first treated in other periods: start at first_treat
replace spillover_treatment_shift = 1 if spillover_tract_flag==0 & period >= spillover_first_treat

eststo spill_dem_solar: did_multiplegt_dyn job_vacancies_solar_num ///
	county_id period spillover_treatment_shift, ///
    effects(10) placebo(8) cluster(county_id) ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.004(0.002)0.006, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_solar_ld_spillover_2, replace))
graph export "$output/dcdh_solar_labor_demand_spillover.pdf", replace	
				 
eststo spill_dem_wind: did_multiplegt_dyn job_vacancies_wind_num ///
	county_id period spillover_treatment_shift, ///
    effects(10) placebo(8) cluster(county_id) ///
    graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
				 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.004(0.002)0.006, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_wind_ld_spillover_2, replace))
graph export "$output/dcdh_wind_labor_demand_spillover.pdf", replace	

esttab * using "$output/reg_spillover.tex", ///
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
	