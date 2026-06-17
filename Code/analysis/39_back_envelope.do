/*==============================================================================
Generate Table A.1: EC Solar Investment Analysis
From separate Panel A and Panel B datasets
==============================================================================*/

clear all

/*==============================================================================
PART 1: LOAD AND PROCESS PANEL A DATA
==============================================================================*/

import delimited "$data/constructed data/back_envelope_panel_A.csv", clear

* Convert string variables to numeric
destring total_nameplate_capacity_mw, replace force
destring n_generators, replace force
destring total_capex, replace force
destring n_investments, replace force
destring annual_tco2, replace force
destring annual_mwh, replace force

* Filter to Energy Communities
gen ec_ind = (ec_ind_official_cohort_1 == 1 | ec_ind_official_cohort_2 == 1 | ec_ind_official_cohort_3==1)

/*==============================================================================
PART 2: CALCULATE PANEL A STATISTICS
==============================================================================*/

* Mean nameplate capacity for solar generators in ECs
egen total_capacity = total(total_nameplate_capacity_mw) if ec_ind == 1 & !missing(n_generators) & n_generators > 0
egen total_n_gens = total(n_generators) if ec_ind == 1 & !missing(n_generators) & n_generators > 0
gen mean_capacity_temp = total_capacity / total_n_gens
sum mean_capacity_temp
scalar mean_capacity = r(mean)
drop mean_capacity_temp total_capacity total_n_gens

display "Mean nameplate capacity in ECs: " %10.2f mean_capacity " MW"

* Calculate lifetime MWh for different capacity factors
scalar hours_per_year = 8760
scalar lifetime_years = 20
scalar cf_15 = 0.15
scalar cf_225 = 0.225
scalar cf_30 = 0.30

scalar mwh_15 = mean_capacity * cf_15 * hours_per_year * lifetime_years
scalar mwh_225 = mean_capacity * cf_225 * hours_per_year * lifetime_years
scalar mwh_30 = mean_capacity * cf_30 * hours_per_year * lifetime_years

* Calculate CAPEX statistics
egen total_capex_sum = total(total_capex) if ec_ind == 1 & !missing(n_investments) & n_investments > 0
egen total_n_invest = total(n_investments) if ec_ind == 1 & !missing(n_investments) & n_investments > 0
gen mean_capex_temp = total_capex_sum / total_n_invest
sum mean_capex_temp
scalar mean_capex = r(mean)

* Get total CAPEX for Panel B calculations
sum total_capex_sum
scalar total_capex = r(mean)
drop mean_capex_temp total_capex_sum total_n_invest

display "Mean CAPEX: $" %15.0fc mean_capex
display "Total CAPEX: $" %15.0fc total_capex

* Calculate CAPEX per MWh
scalar capex_mwh_15 = mean_capex / mwh_15
scalar capex_mwh_225 = mean_capex / mwh_225
scalar capex_mwh_30 = mean_capex / mwh_30

* Calculate weighted CO2 intensity
egen total_tco2_sum = total(annual_tco2) if ec_ind == 1 & !missing(annual_mwh)
egen total_gen_mwh_sum = total(annual_mwh) if ec_ind == 1 & !missing(annual_mwh)
gen weighted_co2_temp = total_tco2_sum / total_gen_mwh_sum
sum weighted_co2_temp
scalar co2_intensity = r(mean)
drop weighted_co2_temp total_tco2_sum total_gen_mwh_sum

display "Weighted CO2 intensity: " %6.4f co2_intensity " tCO2/MWh"

* Calculate CAPEX per tCO2
scalar capex_tco2_15 = capex_mwh_15 / co2_intensity
scalar capex_tco2_225 = capex_mwh_225 / co2_intensity
scalar capex_tco2_30 = capex_mwh_30 / co2_intensity

* Calculate government expenditure per tCO2
scalar gov_ec_15 = capex_tco2_15 * 0.1 * 244 / 144
scalar gov_ec_225 = capex_tco2_225 * 0.1 * 244 / 144
scalar gov_ec_30 = capex_tco2_30 * 0.1 * 244 / 144

scalar gov_itc_15 = capex_tco2_15 * 0.4 * 244 / 144
scalar gov_itc_225 = capex_tco2_225 * 0.4 * 244 / 144
scalar gov_itc_30 = capex_tco2_30 * 0.4 * 244 / 144

/*==============================================================================
PART 3: LOAD AND PROCESS PANEL B DATA
==============================================================================*/

import delimited "$data/constructed data/back_envelope_panel_B.csv", clear

* Convert string variables to numeric
destring total_capex, replace force
destring number_solar_vacancies, replace force

* Calculate total capex
summarize total_capex
scalar total_capex_sum = r(mean) * r(N)
display "Total CAPEX: " %15.0fc total_capex_sum

* Calculate total vacancies (adjusted)
egen total_vac_sum = total(number_solar_vacancies) if !missing(number_solar_vacancies)
sum total_vac_sum
scalar total_vacancies = r(mean) - r(mean) / 1.29
drop total_vac_sum

display "Total job vacancies: " %10.0fc total_vacancies

* Fiscal outlays for Panel B
scalar ec_rate = 0.1
scalar itc_rate = 0.4
scalar marginal_share = 2.44 / 1.44

scalar fiscal_ec = total_capex_sum * ec_rate
scalar fiscal_itc = total_capex_sum * itc_rate

scalar cost_per_vac_ec = fiscal_ec / total_vacancies
scalar cost_per_vac_itc = fiscal_itc / total_vacancies

display "Cost per vacancy (EC only): $" %10.2fc cost_per_vac_ec
display "Cost per vacancy (ITC+EC): $" %10.2fc cost_per_vac_itc

/*==============================================================================
PART 4: CREATE COMBINED TABLE (TABULAR ONLY)
==============================================================================*/

* Create local macros for all values
local mean_cap_str = string(mean_capacity, "%3.0f")

local mwh_15_str = string(mwh_15, "%15.0fc")
local mwh_225_str = string(mwh_225, "%15.0fc")
local mwh_30_str = string(mwh_30, "%15.0fc")

local capex_mwh_15_str = string(capex_mwh_15, "%10.2f")
local capex_mwh_225_str = string(capex_mwh_225, "%10.2f")
local capex_mwh_30_str = string(capex_mwh_30, "%10.2f")

local capex_tco2_15_str = string(capex_tco2_15, "%10.2f")
local capex_tco2_225_str = string(capex_tco2_225, "%10.2f")
local capex_tco2_30_str = string(capex_tco2_30, "%10.2f")

local gov_ec_15_str = string(gov_ec_15, "%10.2f")
local gov_ec_225_str = string(gov_ec_225, "%10.2f")
local gov_ec_30_str = string(gov_ec_30, "%10.2f")

local gov_itc_15_str = string(gov_itc_15, "%10.2f")
local gov_itc_225_str = string(gov_itc_225, "%10.2f")
local gov_itc_30_str = string(gov_itc_30, "%10.2f")

local fiscal_ec_str = string(fiscal_ec/1e9, "%5.3f")
local fiscal_itc_str = string(fiscal_itc/1e9, "%5.3f")

local total_vac_str = string(total_vacancies, "%10.0fc")

local cost_ec_str = string(cost_per_vac_ec, "%10.0fc")
local cost_itc_str = string(cost_per_vac_itc, "%10.0fc")

file open texfile using "$output/table_a1.tex", write replace

* Begin tabular
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n

* Panel A Header
file write texfile "\multicolumn{4}{l}{\textbf{Panel A. Emission abatement per " ///
    "`mean_cap_str' MW plant over 20 years}}\\" _n
file write texfile "\midrule" _n
file write texfile "Scenario & 15\% CF & 22.5\% CF & 30\% CF \\" _n
file write texfile "\cmidrule(lr){2-4}" _n
file write texfile "\addlinespace[0.6em]" _n

* Panel A rows
file write texfile "MWh generated (plant lifetime) & `mwh_15_str' & `mwh_225_str' & `mwh_30_str' \\" _n
file write texfile "CAPEX per MWh & `capex_mwh_15_str' & `capex_mwh_225_str' & `capex_mwh_30_str' \\" _n
file write texfile "CAPEX per tCO\$_2\$ & `capex_tco2_15_str' & `capex_tco2_225_str' & `capex_tco2_30_str' \\" _n
file write texfile "Government Expenditure (EC) per tCO\$_2\$ & `gov_ec_15_str' & `gov_ec_225_str' & `gov_ec_30_str' \\" _n
file write texfile "Government Expenditure (EC + ITC) per tCO\$_2\$ & `gov_itc_15_str' & `gov_itc_225_str' & `gov_itc_30_str' \\" _n

* Panel B Header
file write texfile "\midrule" _n
file write texfile "\multicolumn{4}{l}{\textbf{Panel B. Job Creation}}\\" _n
file write texfile "\midrule" _n
file write texfile "Component & EC bonus only & \multicolumn{2}{c}{ITC+EC} \\" _n
file write texfile "\cmidrule(lr){2-2}\cmidrule(lr){3-4}" _n
file write texfile "\addlinespace[0.6em]" _n

* Panel B rows
file write texfile "A. Fiscal outlays & \\$`fiscal_ec_str' b & \multicolumn{2}{c}{\\$`fiscal_itc_str' b} \\" _n
file write texfile "Jobs (vacancies) & `total_vac_str' & \multicolumn{2}{c}{`total_vac_str'} \\" _n
file write texfile "Cost per vacancy & \\$`cost_ec_str' & \multicolumn{2}{c}{\\$`cost_itc_str'} \\" _n

* End tabular
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n

file close texfile

display _n(2) "============================================"
display "Table A.1 created successfully!"
display "============================================"
display "LaTeX file: output/table_a1.tex"
display "============================================" _n

* Display summary statistics
display "Summary Statistics:"
display "-------------------"
display "Mean nameplate capacity: " %10.2f mean_capacity " MW"
display "Total CAPEX: $" %15.0fc total_capex " (" string(total_capex/1e9, "%5.3f") " billion)"
display "Weighted CO2 intensity: " %6.4f co2_intensity " tCO2/MWh"
display "Total job vacancies: " %10.0fc total_vacancies
display "-------------------" _n