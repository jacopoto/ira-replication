* Install necessary packages
foreach pkg in did_multiplegt_dyn estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

import delimited using ///
	"$data/constructed data/final_labor_demand_dataset_stata.csv", ///
    varnames(1) encoding(UTF-8) clear
	
drop if county_id == 06037
drop if county_id == 17031

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

* Keep only variables needed for the estimation to speed up computation 
preserve 

	keep job_vacancies_*_num county_id period treatment_shift
				 
	eststo lab_solar: did_multiplegt_dyn ///
		job_vacancies_solar_num county_id period treatment_shift, ///
		effects(10) placebo(8) cluster(county_id)  ///
		graphoptions(legend(off) ///
				yline(0, lpattern(dash) lcolor(gs8)) ///
				xline(0, lpattern(dash) lcolor(gs8)) ///
				ytitle(Estimate, size(large)) ///
				xtitle(Quarters from t=-1, size(large)) ///
				plotregion(margin(zero)) ///
				ylabel(-0.002(0.001)0.003, labsize(large)) ///
				xlabel(, labsize(large)) ///
				xsize(5.6) ///
				pcycle(1) ///
				name(graph_solar_labor_demand, replace))
	graph export "$output/dcdh_solar_labor_demand_shift_excl_la_chi.pdf", replace
	
	scalar did_labor_solar = e(Av_tot_effect)
	display "Average DiD Labor effect (solar): " did_labor_solar
				 
	eststo lab_wind: did_multiplegt_dyn ///
		job_vacancies_wind_num county_id period treatment_shift, ///
		effects(10) placebo(8) cluster(county_id)  ///
		graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
				 ytitle(Estimate, size(large)) ///
				 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.002(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_wind_labor_demand, replace))
	graph export "$output/dcdh_wind_labor_demand_shift_excl_la_chi.pdf", replace
				
	scalar did_labor_wind = e(Av_tot_effect)
	display "Average DiD Labor effect (wind): " did_labor_wind
	
restore

summ job_vacancies_solar_num if (ec_ind_official_cohort_1 == 1 & treatment == 0 & period < 31) | (ec_ind_official_cohort_2 == 1 & treatment == 0 & period < 38) | (ec_ind_official_cohort_3 == 1 & treatment == 0 & period < 39)
scalar treated_pre = r(mean)

summ job_vacancies_solar_num if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year < 2023)
scalar control_pre = r(mean)

summ job_vacancies_solar_num if (ec_ind_official_cohort_1 == 0 & ec_ind_official_cohort_2 == 0 & ec_ind_official_cohort_3 == 0 & year > 2022)
scalar control_post = r(mean)

* Counterfactual treated post mean
scalar treated_counterfactual_post = treated_pre + (control_post - control_pre)

* Percent change relative to counterfactual
scalar percent_change_solar_labor = (did_labor_solar / treated_counterfactual_post) * 100
scalar percent_change_solar_labor_2 = (did_labor_solar / treated_pre) * 100

display "Solar Labor Demand: DiD percent change relative to counterfactual mean = " percent_change_solar_labor "%"
display "Solar Labor Demand: DiD percent change relative to pre-IRA mean = " percent_change_solar_labor_2 "%"