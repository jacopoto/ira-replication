* Install necessary packages
foreach pkg in did_multiplegt_dyn estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

* Import the list of matched census tracts first
import delimited using "$data/constructed data/matched_panel_labor_demand_LASSO_revisions.csv", clear
* Keep only the ID variable (assuming it's called census_tract_id)
keep county_id
* Remove duplicates if any
duplicates drop county_id, force
* Save as temporary file
tempfile matched_ids
save `matched_ids'

import delimited using ///
	"$data/constructed data/final_labor_demand_dataset_stata.csv", ///
    varnames(1) encoding(UTF-8) clear
	
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

gen grey_technologies_job__num = real(grey_technologies_job_vacancies_)
replace grey_technologies_job__num = 0 if missing(grey_technologies_job__num)

did_multiplegt_dyn grey_technologies_job__num county_id period treatment_shift, ///
    effects(10) placebo(8) cluster(county_id) ///
    graphoptions(legend(off) /// ///
				 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
                 ytitle(Estimate, size(large)) ///
                 xtitle(Quarters from t=-1, size(large)) ///
				 ylabel(-0.005(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 pcycle(1) ///
				 xsize(8) ///
                 plotregion(margin(zero)) ///
                 name(graph_fossil_employment, replace))	
graph export "$output/dcdh_grey_labor_demand.pdf", replace	

est sto model_grey

* Merge with matched IDs, keeping only matches
merge m:1 county_id using `matched_ids', keep(matched) nogen

did_multiplegt_dyn grey_technologies_job__num county_id period treatment_shift, ///
    effects(10) placebo(8) cluster(county_id) ///
    graphoptions(legend(off) /// ///
				 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
                 ytitle(Estimate, size(large)) ///
                 xtitle(Quarters from t=-1, size(large)) ///
				 ylabel(-0.005(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 pcycle(1) ///
				 xsize(8) ///
                 plotregion(margin(zero)) ///
                 name(graph_fossil_employment, replace))	
graph export "$output/dcdh_grey_labor_demand_matched.pdf", replace	

est sto model_grey_matched

esttab model_* using "$output/grey_labor_demand.tex", ///
	replace booktabs se nonumber nonote wide noobs ///
	mtitles("Full Sample" "Matched Sample") ///
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