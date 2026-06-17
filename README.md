# Replication Package: "Is Place-Based Green Industrial Policy Effective? Evidence from the Inflation Reduction Act"

## Contents

1. [Overview](#overview)
2. [Data Availability](#data-availability)
3. [Instructions for Replicators](#instructions-for-replicators)
4. [List of Exhibits](#list-of-exhibits)
5. [Requirements](#requirements)
6. [Code Description](#code-description)
7. [Folder Structure](#folder-structure)


## Overview

This replication package is hosted at https://github.com/jacopoto/ira-replication.

The package runs from `main.R`, which calls both R Markdown and Stata files. The R Markdown files compile datasets from the raw data. The Stata files produce the figures and tables.

## Data Availability

This section lists the data sources and how to access them. Replicators need the same data to reproduce the results.

We deposit all data in the repository except the Lightcast data. The Lightcast data generate the labor demand results. They are proprietary, and our license prohibits redistribution. We include the compiled Lightcast series used in the analysis, plus the full processing scripts. Researchers who hold a Lightcast license can reproduce these series exactly. All other datasets are public and listed below with download locations.

### Data Sources

Each dataset is listed below with its source, URL, access date, and license. Filenames match the names used in the `raw data` folder.

- Filename 1: Coal_Closures_EnergyComm_v2024_1.zip
- Source: EDX NETL's Energy Data eXchange
- URL: https://edx.netl.doe.gov/dataset/ira-energy-community-data-layers 
- Access year, month: 2025, October
- License: Public

- Filename 2: ira_coal_closure_energy_comm_2023v2.zip
- Source: EDX NETL's Energy Data eXchange
- URL: https://edx.netl.doe.gov/dataset/ira-energy-community-data-layers 
- Access year, month: 2025, October
- License: Public

- Filename 3: MSA_NMSA_EC_FFE_v2024_1.zip
- Source: EDX NETL's Energy Data eXchange
- URL: https://edx.netl.doe.gov/dataset/ira-energy-community-data-layers 
- Access year, month: 2025, October
- License: Public

- Filename 4: ira_data_msanmsa_ffe_ec_2023v2.zip
- Source: EDX NETL's Energy Data eXchange
- URL: https://edx.netl.doe.gov/resource/12f0dcca-0474-4bc1-87f2-ec6a977b7c5c/intended_use
- Access year, month: 2025, October
- License: Public

- Filename 5: MSA_NMSA_EC_FFE_Status_v2023_3.zip
- Source: EDX NETL's Energy Data eXchange
- URL: https://edx.netl.doe.gov/dataset/ira-energy-community-data-layers 
- Access year, month: 2025, October
- License: Public

- Filename 6: National Sub-State Geography Database [695 MB] (tlgdb_2020_a_us_substategeo.gdb)
- Source: United States Census Bureau
- URL: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-geodatabase-file.2020.html
- Access year, month: 2025, October
- License: Public

All EIA 860(M) datasets are downloaded from here and stored in the folder "eia_monthly_data"

- Filename 7: Preliminary Monthly Electric Generator Inventory (eia_monthly_data)
- Source: U.S. Energy Information Administration
- URL: https://www.eia.gov/electricity/data/eia860M/
- Access year, month: 2025, October
- License: Public

Quarterly Census of Employment and Wages datasets are downloaded from here and stored in the folder "quarterly_employment_data"

- Filename 8: Quarterly Census of Employment and Wages: County High-Level (quarterly_employment_data)
- Source: U.S. Bureau of Labor Statistics
- URL: https://www.bls.gov/cew/downloadable-data-files.htm
- Access year, month: 2025, October
- License: Public

- Filename 9: Regional Data GDP and Personal Income (CAGDP9__ALL_AREAS_2017_2022.csv)
- Source: U.S. Bureau of Economic Analysis
- URL: https://apps.bea.gov/itable/?ReqID=70&step=1&_gl=1*tsynxv*_ga*OTgzMDA3NDk2LjE3MTE2MzE0MDA.*_ga_J4698JNNFT*MTcyNDE2MDQ5MS4xNC4xLjE3MjQxNjA1MDcuNDQuMC4w#eyJhcHBpZCI6NzAsInN0ZXBzIjpbMSwyOSwyNSwzMSwyNiwyN10sImRhdGEiOltbIlRhYmxlSWQiLCI1MDMiXSxbIk1ham9yX0FyZWEiLCI0Il0sWyJTdGF0ZSIsWyJYWCJdXSxbIkFyZWEiLFsiWFgiXV0sWyJTdGF0aXN0aWMiLFsiLTEiXV0sWyJVbml0X29mX21lYXN1cmUiLCJMZXZlbHMiXV19
- Access year, month: 2023, November
- Variable Names: Time Period 2017-2022
- License: Public

- Filename 10: countypres_2000-2024.tab (downloaded as csv)
- Source: MIT Election Data + Science Lab
- URL: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
- Access year, month: 2025, October
- Variable Names: Time Period 2017-2022
- License: Public

- Filename 11: Educational attainment for adults age 25 and older for the United States, States, and counties, 1970–2023 (Education2023.csv)
- Source: U.S. Department of Agriculture
- URL: https://www.ers.usda.gov/data-products/county-level-data-sets/county-level-data-sets-download-data
- Access year, month: 2025, October
- License: Public

- Filename 12: Poverty estimates for the United States, States, and counties, 2023 (Poverty2023.csv)
- Source: U.S. Department of Agriculture
- URL: https://www.ers.usda.gov/data-products/county-level-data-sets/county-level-data-sets-download-data
- Access year, month: 2025, October
- License: Public

- Filename 13: Unemployment and median household income for the United States, States, and counties, 2000–23 (Unemployment2023.csv)
- Source: U.S. Department of Agriculture
- URL: https://www.ers.usda.gov/data-products/county-level-data-sets/county-level-data-sets-download-data
- Access year, month: 2025, October
- License: Public

- Filename 14: Yale Climate Opinion Maps (YCOM_2024_publicdata.csv)
- Source: Yale Program on Climate Change Communication
- URL: https://climatecommunication.yale.edu/visualizations-data/ycom-us/
- Access year, month: 2025, October
- License: Public

- Filename 15: 66600e58b2ec97558133d632_results (RESULTS CSV)
- Source: AID DATA A Research Lab at William & Mary. Goodman, S., BenYishay, A., Lv, Z., & Runfola, D. (2019). GeoQuery: Integrating HPC systems and public web-based geospatial data tools. Computers & geosciences, 122, 103-112.
- URL: https://geo.aiddata.org/#!/status/66600e58b2ec97558133d632
- Access year, month: 2025, October
- License: Public

- Filename 16: usa_adm2_geoquery_fips
- Source: AID DATA A Research Lab at William & Mary. Goodman, S., BenYishay, A., Lv, Z., & Runfola, D. (2019). GeoQuery: Integrating HPC systems and public web-based geospatial data tools. Computers & geosciences, 122, 103-112.
- URL: -
- Access year, month: 2024, August
- License: From personal correspondence this file was shared. 

- Filename 17: CIM
- Source: Clean Investment Monitor
- URL: https://climatedeck.rhg.com/app/main/dashboards/64e4127545c8dd0033460781
- Access year, month: 2025, October
- License: Private, but anyone can get access to the data through making an account.

- Filename 18: DECENNIALDP2020.DP1_2024-04-08T040530
- Source: United States Census Bureau
- URL: https://data.census.gov/table/DECENNIALDP2020.DP1?g=160XX00US0473420
- Access year, month: 2025, October
- License: Public. Due to the lapse of federal funding, this website is not being updated. Any inquiries submitted via data.census.gov will not be answered until appropriations are enacted.

- Filename 19: Educational Attainment 2018-2022_538028214885328561.xlsx
- Source: United States Census Bureau
- URL: https://covid19-uscensus.hub.arcgis.com/datasets/USCensus::educational-attainment-2018-2022-counties/explore?layer=2
- Access year, month: 2025, November
- License: Public. 

State-level election results for 2020 are available per state:
- Filename 20: Precinct-Level Returns 2020 by Individual State, each state-individual file should be downloaded
- Source: MIT Election Data + Science Lab
- URL: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/NT66Z3
- Access year, month: 2026, March
- License: Public. 

- Filename 21: HOUSE_precinct_general.zip
- Source: MIT Election Data + Science Lab
- URL: https://github.com/MEDSL/2018-elections-official/blob/master/HOUSE/HOUSE_precinct_general.zip
- Access year, month: 2026, March
- License: Public. 

- Filename 22: election-context-2018.csv
- Source: MIT Election Data + Science Lab
- URL: https://github.com/MEDSL/2018-elections-unoffical/blob/master/election-context-2018.csv
- Access year, month: 2026, March
- License: Public. 

State-level election results for 2024 are available per state:
- Filename 23: 2024-elections-official, each state-individual file should be downloaded
- Source: MIT Election Data + Science Lab
- URL: https://github.com/MEDSL/2024-elections-official/tree/main/individual_states
- Access year, month: 2026, March
- License: Public. 

State-level election results for 2022 are available per state:
- Filename 23: 2022-elections-official, each state-individual file should be downloaded
- Source: MIT Election Data + Science Lab
- URL: https://github.com/MEDSL/2022-elections-official/tree/main/individual_states
- Access year, month: 2026, March
- License: Public. 

- Filename 24: Lightcast Data
- Source: Lightcast
- URL: -
- Access year: 2025, July
- License: Private. These datasets are compiled from the raw Lightcast data.

### Statement about Rights

- [x] The authors have legitimate access to and permission to use all data used in this manuscript.
- [x] The authors have permission to redistribute the data in this package, except the Lightcast data. The Lightcast license prohibits redistribution of the raw data. See LICENSE.txt for details.

## Instructions for Replicators

Follow these steps to run the package.

- Replace the directory path in `main.R`.
- Run `main.R`. The scripts install any missing R and Stata packages, so you can skip manual installation.

## List of Exhibits

The table below maps each exhibit in the manuscript to its output file and the script that produces it.

The code reproduces all numbers reported in the text and all tables and figures in the paper.

| Exhibit name | Output filename | Script | Note |
|--------------|-----------------|--------|------|
| Table 1      | summary_stats_bygroup.tex | 31_make_summary_stats.do | Found in Output |
| Figure 1a     | solar_investment_trend.pdf   | 32_fig_investments_trend.do | Found in Output |
| Figure 1b     | wind_investment_trend.pdf   | 32_fig_investments_trend.do | Found in Output |
| Figure 1c     | ec_nonEC_employment_trend.pdf   | 33_plot_total_emp_trend.do | Found in Output |
| Figure 1d     | solar_labor_trend.pdf   | 34_fig_labor_demand_trend.do | Found in Output |
| Figure 1e     | wind_labor_trend.pdf   | 34_fig_labor_demand_trend.do | Found in Output |
| Figure 1f     | election_rust_ec.pdf   | 35_fig_election_results.do | Found in Output |
| Figure 2a     | dcdh_binary_solar_investment_shift.pdf   | 36_main_reg_results.do | Found in Output |
| Figure 2b     | dcdh_binary_wind_investment_shift.pdf   | 36_main_reg_results.do | Found in Output |
| Figure 2c     | dcdh_all_employment.pdf   | 37_QCEW_reg_results.do | Found in Output |
| Figure 2d     | dcdh_solar_labor_demand_shift.pdf   | 36_main_reg_results.do which calls 36_2_main_reg_results.do | Found in Output |
| Figure 2e     | dcdh_wind_labor_demand_shift.pdf   | 36_main_reg_results.do which calls 36_2_main_reg_results.do | Found in Output |
| Figure 2f     | esa_republican_voteshare_twfe_did_rust_belt.pdf | 38_plot_twfe_voting.do | Found in Output |
| Figure S1     | energy_communities_map_cohort_1.png   | 11_build_descriptives_data.Rmd | Found in Output |
| Figure S2     | energy_communities_map_cohort_2.png   | 11_build_descriptives_data.Rmd | Found in Output |
| Figure S3     | energy_communities_map_cohort_3.png   | 11_build_descriptives_data.Rmd | Found in Output |
| Figure S4     | election_all_ec.pdf   | 35_fig_election_results.do | Found in Output |
| Figure S5     | dcdh_solar_labor_demand_solar_investment.pdf   | 311_auxiliary_analysis.do | Found in Output |
| Figure S6 panel (a)     | dcdh_solar_investment_levels.pdf   | 314_investment_levels_results.do | Found in Output |
| Figure S6 panel (b)     | dcdh_wind_investment_levels.pdf   | 314_investment_levels_results.do | Found in Output |
| Figure S7 panel (a)     | dcdh_binary_solar_investment_shift_excluding_crit_2.pdf   | 316_main_reg_results_excluding_crit_2.do | Found in Output |
| Figure S7 panel (b)     | dcdh_binary_wind_investment_shift_excluding_crit_2.pdf   | 316_main_reg_results_excluding_crit_2.do | Found in Output |
| Figure S7 panel (c)     | dcdh_solar_labor_demand_shift_excluding_crit_2.pdf   | 316_2_main_reg_results_excluding_crit_2.do | Found in Output |
| Figure S7 panel (d)     | dcdh_wind_labor_demand_shift_excluding_crit_2.pdf   | 316_2_main_reg_results_excluding_crit_2.do | Found in Output |
| Figure S8 panel (a)     | dcdh_binary_solar_investment_shift_revisions_with_unemployment.pdf   | 317_main_reg_results_with_unemployment.do | Found in Output |
| Figure S8 panel (b)     | dcdh_binary_wind_investment_shift_revisions_with_unemployment.pdf   | 317_main_reg_results_with_unemployment.do | Found in Output |
| Figure S8 panel (c)     | dcdh_solar_labor_demand_shift_revisions_with_unemployment.pdf   | 317_2_main_reg_results_with_unemployment.do | Found in Output |
| Figure S8 panel (d)     | dcdh_wind_labor_demand_shift_revisions_with_unemployment.pdf   | 317_2_main_reg_results_with_unemployment.do | Found in Output |
| Figure S9 panel (a)     | love_plot_matching_investment_unemployment.pdf   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S9 panel (b)     | love_plot_matching_labor_demand_unemployment.pdf   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S9 panel (c)     | ps_density_matching_investment_unemployment.pdf   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S9 panel (d)     | ps_density_matching_labor_demand_unemployment.pdf   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S10 panel (a)     | dcdh_binary_solar_investment_shift_matched_unemployment_no_LASSO.pdf   | 318_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S10 panel (b)     | dcdh_binary_wind_investment_shift_matched_unemployment_no_LASSO.pdf   | 318_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S10 panel (c)     | dcdh_solar_labor_demand_shift_matched_unemployment_no_LASSO.pdf   | 318_2_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S10 panel (d)     | dcdh_wind_labor_demand_shift_matched_unemployment_no_LASSO.pdf   | 318_2_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Figure S11 panel (a)     | lasso_coefficients_investment_all_variables.png   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S11 panel (b)     | lasso_coefficients_labor_demand_all_variables.png   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S11 panel (c)     | love_plot_matching_investment_LASSO_all_variables.pdf   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S11 panel (d)     | love_plot_matching_labor_demand_LASSO_all_variables.pdf   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S11 panel (e)     | ps_density_matching_investment_LASSO_all_variables.pdf   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S11 panel (f)     | ps_density_matching_labor_demand_LASSO_all_variables.pdf   | 115_build_matching_LASSO.Rmd | Found in Output |
| Figure S12 panel (a)     | dcdh_binary_solar_investment_shift_matched_all_variables.pdf   | 319_matching_all_variables.do | Found in Output |
| Figure S12 panel (b)     | dcdh_binary_wind_investment_shift_matched_all_variables.pdf   | 319_matching_all_variables.do | Found in Output |
| Figure S12 panel (c)     | dcdh_solar_labor_demand_shift_matched_all_variables.pdf   | 319_2_matching_all_variables.do | Found in Output |
| Figure S12 panel (d)     | dcdh_wind_labor_demand_shift_matched_all_variables.pdf   | 319_2_matching_all_variables.do | Found in Output |
| Figure S13 panel (a)     | dcdh_solar_investment_binary_spillover.pdf   | 312_spillover_analysis.do | Found in Output |
| Figure S13 panel (b)     | dcdh_wind_investment_binary_spillover.pdf   | 312_spillover_analysis.do | Found in Output |
| Figure S13 panel (c)     | dcdh_solar_labor_demand_spillover.pdf   | 312_spillover_analysis.do | Found in Output |
| Figure S13 panel (d)     | dcdh_wind_labor_demand_spillover.pdf   | 312_spillover_analysis.do | Found in Output |
| Figure S14     | ec_nonEC_employment_trend_excl_la_chi.pdf   | 320_plot_total_emp_trend_excl_la_chi.do | Found in Output |
| Figure S15 panel (a)     | dcdh_binary_solar_investment_shift_excl_la_chi.pdf   | 322_main_reg_results_excl_la_chi.do | Found in Output |
| Figure S15 panel (b)     | dcdh_binary_wind_investment_shift_excl_la_chi.pdf   | 322_main_reg_results_excl_la_chi.do | Found in Output |
| Figure S15 panel (c)     | dcdh_solar_labor_demand_shift_excl_la_chi.pdf   | 322_2_main_reg_results_excl_la_chi.do | Found in Output |
| Figure S15 panel (d)     | dcdh_wind_labor_demand_shift_excl_la_chi.pdf   | 322_2_main_reg_results_excl_la_chi.do | Found in Output |
| Figure S16 panel (a)     | dcdh_grey_labor_demand.pdf   | 316_grey_labor_demand.do | Found in Output |
| Figure S16 panel (b)     | dcdh_grey_labor_demand_matched.pdf   | 316_grey_labor_demand.do | Found in Output |
| Figure S17 panel (a)     | dcdh_construction_employment.pdf   | 37_QCEW_reg_results.do | Found in Output |
| Figure S17 panel (b)     | dcdh_y02e10_labor_demand.pdf   | 37_QCEW_reg_results.do | Found in Output |
| Figure S18 panel (a)     | esa_republican_voteshare_twfe_did.pdf | 38_plot_twfe_voting.do | Found in Output |
| Figure S18 panel (b)     | esa_republican_voteshare_twfe_did_swing_states_year_state_FE.pdf | 38_plot_twfe_voting.do | Found in Output |
| Figure S19 panel (a)     | esa_republican_house_voteshare_twfe_did.pdf | 323_plot_twfe_house_voting.do | Found in Output |
| Figure S19 panel (b)     | esa_republican_house_voteshare_twfe_did_rust_belt.pdf | 323_plot_twfe_house_voting.do | Found in Output |
| Figure S20 panel (a)     | g1a_esa_republican_senate_voteshare_twfe_did.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure S20 panel (b)     | g1a_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure S20 panel (c)     | g1b_esa_republican_senate_voteshare_twfe_did.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure S20 panel (d)     | g1b_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure S20 panel (e)     | g2_esa_republican_senate_voteshare_twfe_did.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure S20 panel (f)     | g2_esa_republican_senate_voteshare_twfe_did_rust_belt.pdf | 324_plot_twfe_senate_voting.do | Found in Output |
| Figure A21 panel (a)     | esa_president_twfe_did.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (b)     | esa_president_twfe_did_swing_states_year_state_FE.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (c)     | esa_regulate_twfe_did.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (d)     | esa_regulate_twfe_did_swing_states_year_state_FE.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (e)     | esa_vote_twfe_did.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (f)     | esa_vote_twfe_did_swing_states_year_state_FE.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (g)     | esa_reducetax_twfe_did.pdf   | 313_plot_climate_support.do | Found in Output |
| Figure A21 panel (h)     | esa_reducetax_twfe_did_swing_states_year_state_FE.pdf   | 313_plot_climate_support.do | Found in Output |
| Table S1      | table_a1.tex | 39_back_envelope.do | Found in Output |
| Table S3      | table_results.tex | 310_job_vacancy_validity_tests.do | Found in Output |
| Table S5      | reg_invest_lab_dem.tex | 36_main_reg_results.do which calls 36_2_main_reg_results.do | Found in Output |
| Table S6     | solar_labor_demand_multipliers.tex   | 311_auxiliary_analysis.do | Found in Output |
| Table S7     | reg_levels.tex   | 314_investment_levels_results.do | Found in Output |
| Table S8     | reg_invest_lab_dem_excluding_crit_2.tex   | 316_main_reg_results_excluding_crit_2.do | Found in Output |
| Table S9     | reg_invest_lab_dem_revisions_with_unemployment.tex   | 317_main_reg_results_with_unemployment.do | Found in Output |
| Table S10 panel (a)    | sample_size_table_investment_unemployment.tex   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Table S10 panel (b)    | sample_size_table_labor_demand_unemployment.tex   | 114_build_matching_unemployment_no_LASSO.Rmd | Found in Output |
| Table S11     | reg_invest_lab_dem_matched_unemployment_no_LASSO.tex   | 318_matching_unemployment_no_LASSO.do | Found in Output |
| Table S12     | sample_size_table_investment_LASSO_all_variables.tex   | 115_build_matching_LASSO.do | Found in Output |
| Table S13     | reg_invest_lab_dem_matched_all_variables.tex   | 319_matching_all_variables.do | Found in Output |
| Table S14     | reg_spillover.tex   | 312_spillover_analysis.do | Found in Output |
| Table S15     | rob_empl_excl_la_chi.tex   | 321_QCEW_reg_results_excl_la_chi.do | Found in Output |
| Table S16     | reg_invest_lab_dem_excl_la_chi.tex   | 322_main_reg_results_excl_la_chi.do | Found in Output |
| Table S17    | grey_labor_demand.tex   | 316_grey_labor_demand.do | Found in Output |
| Table S18     | rob_empl.tex   | 37_QCEW_reg_results.do | Found in Output |
| Table S19     | esa_republican_voteshare_twfe_did.tex | 38_plot_twfe_voting.do | Found in Output |
| Table S20     | esa_republican_house_voteshare_twfe_did.tex | 323_plot_twfe_house_voting.do | Found in Output |
| Table S21 panel (a)     | g1a_esa_republican_senate_voteshare_twfe_did.tex | 324_plot_twfe_senate_voting.do | Found in Output |
| Table S21 panel (b)     | g1b_esa_republican_senate_voteshare_twfe_did.tex | 324_plot_twfe_senate_voting.do | Found in Output |
| Table S21 panel (c)     | g2_esa_republican_senate_voteshare_twfe_did.tex | 324_plot_twfe_senate_voting.do | Found in Output |
| Table S22     | esa_politics_fig1.tex   | 313_plot_climate_support.do | Found in Output |
| Table S23     | esa_politics_fig2.tex   | 313_plot_climate_support.do | Found in Output |


## Requirements

### Computational Requirements

Code was written and run on a 64-bit operating system, x64-based processor, Intel(R) Core(TM) Ultra 7 155U (1.70 GHz) Processor, and 31.5 GB of usable RAM.
Windows 11 Enterprise, version 25H2.

### Software Requirements

The package uses Stata and R. Use the versions and packages below. Different versions can change the results. All R and Stata packages also install from within the scripts if they are missing.

- **Stata version 18SE**

  - estout
  - did_multiplegt_dyn
  - reghdfe
  - coefplot
  - ftools
  
- **RStudio 2024.4.0.735**

- **R 4.4.0**

  -rmarkdown 2.29
  -knitr 1.49
  -here 1.0.1
  -sf 1.0.19
  -stringr 1.5.1
  -stringi 1.8.4
  -dplyr 1.1.4
  -tidyr 1.3.1
  -ggplot2 3.5.1
  -readxl 1.4.3
  -lubdridate 1.9.4
  -MatchIt 4.7.2
  -cobalt 4.6.1
  -glmnet 4.1.8
  -xtable 1.8.4


### Memory and Runtime and Storage Requirements

============================================================
SYSTEM REQUIREMENTS SUMMARY
============================================================

Runtime: 6.268215 hours 
Peak Memory: 3.62 GB 

Storage:
  Data directory increase: 0.04 GB
  Output directory increase: 0.00 GB
  Total storage increase: 0.04 GB

============================================================

## Code Description 

All code files are run by main.R. All data cleaning from the raw data files (and Lightcast intermediate data) by the R-markdown and Stata files in the `Code/cleaning` folder. These files write data files (csv and dta) to the folder `Data/constructed data`. Subsequently, all code files in the folder `Code/analysis` are run which write all figures and tables to the folder `Output`. 
Some files take a long time to run due to spatial operations and the computation of the de Chaisemartin & D'Haultfoeille DiD specifications.

## Folder Structure

In the main folder can be found the README, and three folder: `Code`, `Output`, and `Data`. Finally, in the main folder, we also add the system_requirements_log.txt which contains details on the system requirements regarding memory, runtime, and storage. After running the `main.R` this will be updated given your computer's settings.

`Output` is empty and filled after running `main.R` with all graphs and tables in the paper.
`Code` contains `main.R`, and two folder `analysis` and `cleaning`. The two folders are described above. `main.R` calls all scripts in both `cleaning` and `analysis`.
`Data` contains three folders `constructed data`, which is empty and filled after `main.R` runs all scripts in `cleaning`, `lightcast data`, which contains all the intermediate data from the Lightcast data, and `raw data` which contains all data files listed above.