*---------------------------------------------------
* This file builds Panel A (tracts) and Panel B (counties)
* summary tables split by Control / Cohort1 EC / Cohort2 EC.
*
* Author: Jacopo 
* Date: 10/25 
*
* Input:
*   $ROOT/datasets/constructed data/descriptive_stats_census_tract
*   $ROOT/datasets/constructed data/descriptive_stats_county
*
* Output:
*   $tab/summary_stats_bygroup.tex
*
* Notes:
*   - Run after settings do (defines $ROOT and $tab).
*---------------------------------------------------

* Install necessary packages
foreach pkg in estout {
    capture which `pkg'
    if _rc {
        display "Installing `pkg'..."
        ssc install `pkg', replace
    }
}

* Program to convert p-value to stars
capture program drop star_from_p
program define star_from_p, rclass
    args pval
    if `pval' < 0.01      return local star "***"
    else if `pval' < 0.05 return local star "**"
    else if `pval' < 0.10 return local star "*"
    else                  return local star ""
end

*******************************************************
* Panel A: Census tracts
*******************************************************
clear
import delimited "$data/constructed data/descriptive_stats_census_tract", ///
    varnames(1) encoding(UTF-8) case(preserve)

* ensure MW vars are numeric (CSV may have "NA" or commas)
foreach x in total_population_2020 total_MW_2022_Q2 hydro_MW_2022_Q2 natural_gas_MW_2022_Q2 ///
             coal_MW_2022_Q2 other_fossil_MW_2022_Q2 solar_MW_2022_Q2 ///
             onshore_wind_MW_2022_Q2 nuclear_MW_2022_Q2 {
    capture confirm numeric variable `x'
    if _rc destring `x', replace ignore("NA, ")
}

* labels (no dates)
label var area                    "Area (\$ km^2\$)"
label var total_population_2020   "Total population"
label var total_MW_2022_Q2        "Total capacity (MW)"
label var hydro_MW_2022_Q2        "Hydro (MW)"
label var natural_gas_MW_2022_Q2  "Natural gas (MW)"
label var coal_MW_2022_Q2         "Coal (MW)"
label var other_fossil_MW_2022_Q2 "Other fossil (MW)"
label var solar_MW_2022_Q2        "Solar (MW)"
label var onshore_wind_MW_2022_Q2 "Onshore wind (MW)"
label var nuclear_MW_2022_Q2      "Nuclear (MW)"

local vlistA area total_population_2020 ///
    total_MW_2022_Q2 hydro_MW_2022_Q2 natural_gas_MW_2022_Q2 ///
    coal_MW_2022_Q2 other_fossil_MW_2022_Q2 solar_MW_2022_Q2 ///
    onshore_wind_MW_2022_Q2 nuclear_MW_2022_Q2

* Open file and write header
capture file close tex
file open tex using "$output/summary_stats_bygroup.tex", write replace

file write tex "\begin{tabular}{l*{4}{c}}" _n
file write tex "\toprule" _n
file write tex " & Control & Cohort 1 EC & Cohort 2 EC & Cohort 3 EC \\" _n
file write tex "\midrule" _n
file write tex "\multicolumn{5}{l}{\textbf{Panel A: Census tracts}} \\" _n

foreach v of local vlistA {
    
    * Get variable label
    local lab : variable label `v'
    if "`lab'" == "" local lab "`v'"
    
    * Subheading for generation capacity
    if "`v'" == "total_MW_2022_Q2" {
        file write tex "\quad \emph{Generation capacity:} & & & & \\" _n
    }
    
    * Control mean/sd
    quietly summarize `v' if ec_ind_official==0
    local m0 = trim("`: display %12.1fc r(mean)'")
    local s0 = trim("`: display %12.1fc r(sd)'")
    
    * Cohort1 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_1==1
    local m1 = trim("`: display %12.1fc r(mean)'")
    local s1 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_1==1, ///
        by(ec_ind_official_cohort_1) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st1 "`r(star)'"
    }
    else local st1 ""
    
    * Cohort2 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_2==1
    local m2 = trim("`: display %12.1fc r(mean)'")
    local s2 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_2==1, ///
        by(ec_ind_official_cohort_2) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st2 "`r(star)'"
    }
    else local st2 ""
    
    * Cohort3 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_3==1
    local m3 = trim("`: display %12.1fc r(mean)'")
    local s3 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_3==1, ///
        by(ec_ind_official_cohort_3) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st3 "`r(star)'"
    }
    else local st3 ""
    
    * Write mean row and SD row
    file write tex "`lab' & `m0' (`s0') & `m1' (`s1')`st1' & `m2' (`s2')`st2' & `m3' (`s3')`st3' \\" _n
}

* Observations row
quietly count if ec_ind_official==0
local n0 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_1==1
local n1 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_2==1
local n2 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_3==1
local n3 = trim("`: display %12.0fc r(N)'")

file write tex "Observations & `n0' & `n1' & `n2' & `n3' \\" _n
file write tex "\midrule" _n

*******************************************************
* Panel B: Counties
*******************************************************
clear
import delimited "$data/constructed data/descriptive_stats_county", ///
    varnames(1) encoding(UTF-8) case(preserve)

keep if county_id != 48301

rename perecentage_no_high_school_count percentage_no_high_school_count 

* make possibly-string numerics truly numeric (handles "NA" and commas)
foreach v in ///
    mean_wind_density_potential_coun mean_wind_potential_county_2019 mean_solar_potential_county_2019 ///
    percentage_* ///
    rural_urban_continuum_code_2023 urban_influence_code_2013 poverty_rate_2023_county unemployment_rate_2022 ///
    gdp_per_capita gdp_trade_per_capita gdp_transportation_utilities_per ///
    gdp_manufacturing_information_pe gdp_natural_resources_mining_per gdp_government_per_capita {
    capture confirm numeric variable `v'
    if _rc destring `v', replace ignore("NA, ")
}

* nice labels
label var mean_wind_density_potential_coun   "Wind density"
label var mean_wind_potential_county_2019    "Wind potential"
label var mean_solar_potential_county_2019   "Solar potential"

label var percentage_college_county_19_23    "Some college"
label var percentage_bachelor_county_19_23   "Bachelor"
label var percentage_high_school_county_19   "High school"
label var percentage_no_high_school_count    "No high school"

label var rural_urban_continuum_code_2023    "Rural--urban code"
label var urban_influence_code_2013          "Urban influence"
label var poverty_rate_2023_county           "Poverty rate (\%)"
label var unemployment_rate_2022             "Unemployment rate (\%)"

label var gdp_per_capita                     "GDP per capita"
label var gdp_trade_per_capita               "GDP trade per capita"
label var gdp_transportation_utilities_per   "GDP transport \& utilities pc"
label var gdp_manufacturing_information_pe   "GDP manuf. \& information pc"
label var gdp_natural_resources_mining_per   "GDP nat. res. \& mining pc"
label var gdp_government_per_capita          "GDP government per capita"

* variable groups
local energy  mean_wind_density_potential_coun mean_wind_potential_county_2019 mean_solar_potential_county_2019
local educ    percentage_college_county_19_23 percentage_bachelor_county_19_23 percentage_high_school_county_19 percentage_no_high_school_count
local chars   rural_urban_continuum_code_2023 urban_influence_code_2013 poverty_rate_2023_county unemployment_rate_2022
local gdpvars gdp_per_capita gdp_trade_per_capita gdp_transportation_utilities_per gdp_manufacturing_information_pe gdp_natural_resources_mining_per gdp_government_per_capita

local vlistB `energy' `educ' `chars' `gdpvars'

file write tex "\multicolumn{5}{l}{\textbf{Panel B: Counties}} \\" _n

foreach v of local vlistB {
    
    * Get variable label
    local lab : variable label `v'
    if "`lab'" == "" local lab "`v'"
    
    * Subheadings
    if "`v'" == "mean_wind_density_potential_coun" {
        file write tex "\quad \emph{Energy potential:} & & & & \\" _n
    }
    if "`v'" == "percentage_college_county_19_23" {
        file write tex "\quad \emph{Education (\%):} & & & & \\" _n
    }
    if "`v'" == "rural_urban_continuum_code_2023" {
        file write tex "\quad \emph{County characteristics:} & & & & \\" _n
    }
    if "`v'" == "gdp_per_capita" {
        file write tex "\quad \emph{GDP per capita (by activity):} & & & & \\" _n
    }
    
    * Control mean/sd
    quietly summarize `v' if ec_ind_official==0
    local m0 = trim("`: display %12.1fc r(mean)'")
    local s0 = trim("`: display %12.1fc r(sd)'")
    
    * Cohort1 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_1==1
    local m1 = trim("`: display %12.1fc r(mean)'")
    local s1 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_1==1, ///
        by(ec_ind_official_cohort_1) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st1 "`r(star)'"
    }
    else local st1 ""
    
    * Cohort2 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_2==1
    local m2 = trim("`: display %12.1fc r(mean)'")
    local s2 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_2==1, ///
        by(ec_ind_official_cohort_2) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st2 "`r(star)'"
    }
    else local st2 ""
    
    * Cohort3 mean/sd + t-test vs Control
    quietly summarize `v' if ec_ind_official_cohort_3==1
    local m3 = trim("`: display %12.1fc r(mean)'")
    local s3 = trim("`: display %12.1fc r(sd)'")
    
    capture ttest `v' if ec_ind_official==0 | ec_ind_official_cohort_3==1, ///
        by(ec_ind_official_cohort_3) unequal
    if _rc == 0 {
        star_from_p `r(p)'
        local st3 "`r(star)'"
    }
    else local st3 ""
    
    * Write mean row and SD row
    file write tex "`lab' & `m0' (`s0') & `m1' (`s1')`st1' & `m2' (`s2')`st2' & `m3' (`s3')`st3' \\" _n
}

* Observations row
quietly count if ec_ind_official==0
local n0 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_1==1
local n1 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_2==1
local n2 = trim("`: display %12.0fc r(N)'")
quietly count if ec_ind_official_cohort_3==1
local n3 = trim("`: display %12.0fc r(N)'")

file write tex "Observations & `n0' & `n1' & `n2' & `n3' \\" _n
file write tex "\bottomrule" _n
file write tex "\end{tabular}" _n

file close tex