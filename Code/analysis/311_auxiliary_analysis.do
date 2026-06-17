* Install necessary packages
foreach pkg in did_multiplegt_dyn estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

* Now import your data (note: $data not $constructed data)
import delimited using ///
    "$data/constructed data/final_solar_labor_demand_solar_investment_stata.csv", ///
    varnames(1) encoding(UTF-8) clear

gen job_vacancies_solar_num = real(solar_technologies_job_vacancies)
replace job_vacancies_solar_num = 0 if missing(job_vacancies_solar_num)

************************************************************************
*		Table A.4: Solar Investment Labor Demand Multipliers
************************************************************************

* Keep only variables needed for the estimation to speed up computation 
preserve 
	keep job_vacancies_solar_num county_id time_index treatment_solar_binary
	
	eststo solar_labor: did_multiplegt_dyn ///
		job_vacancies_solar_num county_id time_index treatment_solar_binary, ///
		effects(10) placebo(8) cluster(county_id) ///
		graphoptions(legend(off) ///
                 yline(0, lpattern(dash) lcolor(gs8)) ///
                 xline(0, lpattern(dash) lcolor(gs8)) ///
                 ytitle(Estimate, size(large)) ///
                 xtitle(Quarters from t=-1, size(large)) ///
                 plotregion(margin(zero)) ///
                 ylabel(-0.001(0.001)0.003, labsize(large)) ///
				 xlabel(, labsize(large)) ///
				 xsize(5.6) ///
				 pcycle(1) ///
                 name(graph_solar, replace))
	graph export "$output/dcdh_solar_labor_demand_solar_investment.pdf", replace
	
	* Export the table
	esttab solar_labor using "$output/solar_labor_demand_multipliers.tex", ///
		replace booktabs se nonote wide noobs ///
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
		mtitles("Solar Labour Demand") ///
		collabels(,none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		substitute(\_ _)
		
restore