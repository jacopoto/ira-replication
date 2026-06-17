* Install necessary packages
foreach pkg in estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

import delimited using ///
	"$data/constructed data/job_vacancy_validity_tests.csv", ///
    varnames(1) encoding(UTF-8) clear
    
** First, encode the string variable to numeric
encode ec_ind_official, gen(ec_ind_official_num)
drop if ec_ind_official == "NA"

** First declare panel structure
xtset county_id year

** Adjust the year variable
keep if year < 2023
gen year_adj = year - 2018

** Convert job_vacancy_rate from string to numeric
destring job_vacancy_rate, replace force
drop if missing(job_vacancy_rate)

** Create interaction term manually
gen year_ec = year_adj * ec_ind_official_num

** Run the three regressions and store results
eststo clear

eststo model1: areg job_vacancy_rate year_adj year_ec, absorb(county_id)
eststo model2: areg avg_closing_time year_adj year_ec, absorb(county_id)
eststo model3: areg share_with_naics year_adj year_ec, absorb(county_id)

** Export to LaTeX file
esttab model1 model2 model3 using "$output/table_results.tex", ///
    replace ///
    booktabs ///
    nonumbers ///
	nonote ///
    collabels(none) ///
    keep(year_adj year_ec) ///
    order(year_adj year_ec) ///
    cells(b(fmt(3) star) se(fmt(4) par)) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 r2_a, fmt(%12.0fc 3 3) labels("Observations" "\$R^{2}\$" "Adjusted \$R^{2}\$")) ///
    varlabels(year_adj "Year" ///
              year_ec "Year $\times$ EC") ///
    mtitles("\makecell{Job vacancies\\employed}"  "\makecell{Time to closing\\all vacancies}"  ///
		"\makecell{Share vacancies\\with NAICS}")