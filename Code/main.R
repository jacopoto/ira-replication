# Main R Script: Run Complete Analysis Pipeline
# Author: Joep Keuzenkamp
# Date: 2025-10-23
# Description: Executes the full analysis pipeline from data cleaning to visualization

# ============================================================================
# MONITORING SETUP - START
# ============================================================================
if (!require("pryr")) install.packages("pryr")
library(pryr)

# Create log file
log_file <- "system_requirements_log.txt"
sink(log_file, split = TRUE)  # Sends output to both console and file

cat("\n============================================================\n")
cat("SYSTEM REQUIREMENTS MONITORING\n")
cat("============================================================\n\n")
cat("Start Time:", as.character(Sys.time()), "\n\n")

# Initial measurements
gc()
initial_memory <- mem_used()
overall_start_time <- Sys.time()

# ============================================================================
# Set up project paths
# ============================================================================
# Set working directory to project root
project_root <- "C:/Users/Keuze001/Dropbox/IRA reproducibility package/IRA reproducibility package - CLEAN"
setwd(project_root)

# Define paths
data_path <- file.path(project_root, "Data")
output_path <- file.path(project_root, "Output")
code_path <- file.path(project_root, "Code")

# Initial storage sizes
data_size_initial <- sum(file.info(list.files(data_path, full.names = TRUE, recursive = TRUE))$size, na.rm = TRUE) / 1e9
output_size_initial <- sum(file.info(list.files(output_path, full.names = TRUE, recursive = TRUE))$size, na.rm = TRUE) / 1e9

# Load required packages
if (!require("rmarkdown")) install.packages("rmarkdown")
if (!require("knitr")) install.packages("knitr")
if (!require("here")) install.packages("here")
if (!require("sf")) install.packages("sf")
if (!require("stringr")) install.packages("stringr")
if (!require("stringi")) install.packages("stringi")
if (!require("dplyr")) install.packages("dplyr")
if (!require("tidyr")) install.packages("tidyr")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("readxl")) install.packages("readxl")
if (!require("lubridate")) install.packages("lubridate")
if (!require("MatchIt")) install.packages("MatchIt")
if (!require("cobalt")) install.packages("cobalt")
if (!require("glmnet")) install.packages("glmnet")
if (!require("xtable")) install.packages("xtable")
library(lubridate)
library(rmarkdown)
library(knitr)
library(here)
library(sf)
library(stringr)
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringi)
library(MatchIt)
library(cobalt)
library(glmnet)
library(xtable)

# Print start message
cat("\n========================================\n")
cat("Starting IRA Analysis Pipeline\n")
cat("Project root:", project_root, "\n")
cat("========================================\n\n")

# ============================================================================
# STEP 1: Run R Markdown files to build datasets that can be run in Stata
# ============================================================================

# ============================================================================
# STEP 1.1: Run R Markdown file to build descriptives data
# ============================================================================
cat("STEP 1.1: Running 11_build_descriptives_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "11_build_descriptives_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.1:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1")
})

# ============================================================================
# STEP 1.2: Run R Markdown file to build investment data
# ============================================================================
cat("STEP 1.2: Running 12_build_investment_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "12_build_investment_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.2 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.2:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.2")
})

# ============================================================================
# STEP 1.3: Run R Markdown file to build QCEW data
# ============================================================================
cat("STEP 1.3: Running 13_build_QCEW_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "13_build_QCEW_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.3 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.3:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.3")
})

# ============================================================================
# STEP 1.4: Run R Markdown file to build labor demand data
# ============================================================================
cat("STEP 1.4: Running 14_build_labordemand_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "14_build_labordemand_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.4 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.4:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.4")
})

# ============================================================================
# STEP 1.5: Run R Markdown file to build election data
# ============================================================================
cat("STEP 1.5: Running 15_build_election_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "15_build_election_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.5 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.5:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.5")
})

# ============================================================================
# STEP 1.6: Run R Markdown file to build back of the envelope data
# ============================================================================
cat("STEP 1.6: Running 16_build_backenvelope_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "16_build_backenvelope_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.6 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.6:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.6")
})

# ============================================================================
# STEP 1.7: Run R Markdown file to build vacancy validity data
# ============================================================================
cat("STEP 1.7: Running 17_build_vacancyvalidity_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "17_build_vacancyvalidity_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.7 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.7:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.7")
})

# ============================================================================
# STEP 1.8: Run R Markdown file to build auxiliary test data
# ============================================================================
cat("STEP 1.8: Running 18_build_auxiliarytest_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "18_build_auxiliarytest_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.8 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.8:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.8")
})

# ============================================================================
# STEP 1.9: Run R Markdown file to build political support statements data
# ============================================================================
cat("STEP 1.9: Running 19_build_politicalsupport_data.Rmd...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "19_build_politicalsupport_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.9 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.9:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.9")
})

# ============================================================================
# STEP 1.10: Run R Markdown file to build endogeneity analysis 1: excluding criterion 2 (investment)
# ============================================================================
cat("STEP 1.10: Running 110_build_investment_data_excluding_crit_2...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "110_build_investment_data_excluding_crit_2.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.10 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.10:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.10")
})

# ============================================================================
# STEP 1.11: Run R Markdown file to build endogeneity analysis 1: excluding criterion 2 (labor demand)
# ============================================================================
cat("STEP 1.11: Running 111_build_labordemand_data_excluding_crit_2...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "111_build_labordemand_data_excluding_crit_2.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.11 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.11:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.11")
})

# ============================================================================
# STEP 1.12: Run R Markdown file to build endogeneity analysis 2: including lagged unemployment rates (investment)
# ============================================================================
cat("STEP 1.12: 112_build_investment_data_with_unemployment...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "112_build_investment_data_with_unemployment.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.12 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.12:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.12")
})

# ============================================================================
# STEP 1.13: Run R Markdown file to build endogeneity analysis 2: including lagged unemployment rates (labor demand)
# ============================================================================
cat("STEP 1.13: 113_build_labordemand_data_with_unemployment...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "113_build_labordemand_data_with_unemployment.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.13 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.13:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.13")
})

# ============================================================================
# STEP 1.14: Run R Markdown file to perform matching on unemployment rates
# ============================================================================
cat("STEP 1.14: 114_build_matching_unemployment_no_LASSO...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "114_build_matching_unemployment_no_LASSO.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.14 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.14:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.14")
})

# ============================================================================
# STEP 1.15: Run R Markdown file to perform matching on all variables using LASSO
# ============================================================================
cat("STEP 1.15: 115_build_matching_LASSO...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "115_build_matching_LASSO.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.15 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.15:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.15")
})

# ============================================================================
# STEP 1.16: Run R Markdown file to build the dataset for House Elections
# ============================================================================
cat("STEP 1.16: 116_build_house_election_data...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "116_build_house_election_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.16 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.16:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.16")
})

# ============================================================================
# STEP 1.17: Run R Markdown file to build the dataset for Senate Elections
# ============================================================================
cat("STEP 1.17: 117_build_senate_election_data...\n")

tryCatch({
  rmarkdown::render(
    input = file.path(code_path, "cleaning", "117_build_senate_election_data.Rmd"),
    output_dir = file.path(code_path, "cleaning"),
    knit_root_dir = project_root,  # This sets the working directory for the Rmd
    quiet = FALSE,
    envir = new.env()  # Use a clean environment
  )
  cat("✓ Step 1.17 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 1.17:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 1.17")
})

# ============================================================================
# STEP 2: Run Stata do-file to build datasets used for descriptive trends
# ============================================================================

# ============================================================================
# STEP 2.1: Run Stata do-file to build investment trends dataset
# ============================================================================
cat("STEP 2: Running 21_build_investment_trends.do...\n")

tryCatch({
  # Check if Stata is available
  stata_path <- Sys.which("stata")
  if (stata_path == "") {
    # Try common Stata installation paths
    possible_paths <- c(
      "C:/Program Files/StataNow19SE/StataSE-64.exe",
      "C:/Program Files/Stata18SE/StataSE-64.exe",
      "C:/Program Files/Stata17/StataSE-64.exe",
      "C:/Program Files/Stata16/StataSE-64.exe",
      "C:/Program Files (x86)/Stata18/StataSE-64.exe",
      "C:/Program Files (x86)/Stata17/StataSE-64.exe",
      "C:/Program Files (x86)/Stata16/StataSE-64.exe"
    )
    
    stata_path <- NULL
    for (path in possible_paths) {
      if (file.exists(path)) {
        stata_path <- path
        break
      }
    }
    
    if (is.null(stata_path)) {
      stop("Stata executable not found. Please specify the correct path.")
    }
  }
  
  # Convert to Stata-friendly format (forward slashes)
  data_path_stata <- gsub("\\\\", "/", data_path)
  output_path_stata <- gsub("\\\\", "/", output_path)
  project_root_stata <- gsub("\\\\", "/", project_root)
  
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/cleaning/21_build_investment_trends.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 2.1 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 2.1:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 2.1")
})

# ============================================================================
# STEP 2.2: Run Stata do-file to build labor demand trends dataset
# ============================================================================
cat("STEP 2.2: Running 22_build_labor_demand_trends.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/cleaning/22_build_labor_demand_trends.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 2.2 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 2.2:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 2.2")
})

# ============================================================================
# STEP 2.3: Run Stata do-file to build election trends dataset
# ============================================================================
cat("STEP 2.3: Running 23_build_election_results.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/cleaning/23_build_election_results.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 2.3 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 2.3:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 2.3")
})

# ============================================================================
# STEP 3: Run Stata do-files to create visualizations and results
# ============================================================================

# ============================================================================
# STEP 3.1: Run Stata do-file to create the descriptive statistics table
# ============================================================================
cat("STEP 3.1: Running 31_make_summary_stats.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/31_make_summary_stats.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.1 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.1:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.1")
})

# ============================================================================
# STEP 3.2: Run Stata do-file to create the trends plot for investment
# ============================================================================
cat("STEP 3.2: Running 32_fig_investment_trend.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/32_fig_investments_trend.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.2 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.2:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.2")
})

# ============================================================================
# STEP 3.3: Run Stata do-file to create the trends plot for QCEW
# ============================================================================
cat("STEP 3.3: Running 33_plot_total_emp_trend.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/33_plot_total_emp_trend.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.3 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.3:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.3")
})

# ============================================================================
# STEP 3.4: Run Stata do-file to create the trends plot for labour demand
# ============================================================================
cat("STEP 3.4: Running 34_fig_labor_demand_trend.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/34_fig_labor_demand_trend.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.4 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.4:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.4")
})

# ============================================================================
# STEP 3.5: Run Stata do-file to create the trends plot for elections
# ============================================================================
cat("STEP 3.5: Running 35_fig_election_results.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/35_fig_election_results.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.5 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.5:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.5")
})

# ============================================================================
# STEP 3.6: Run Stata do-file to create the main regression results
# ============================================================================
cat("STEP 3.6: Running 36_main_reg_results.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/36_main_reg_results.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.6 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.6:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.6")
})

# ============================================================================
# STEP 3.7: Run Stata do-file to create the main regression results: QCEW
# ============================================================================
cat("STEP 3.7: Running 37_QCEW_reg_results.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/37_QCEW_reg_results.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.7 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.7:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.7")
})

# ============================================================================
# STEP 3.8: Run Stata do-file to create the main regression results: elections
# ============================================================================
cat("STEP 3.8: Running 38_plot_twfe_voting.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/38_plot_twfe_voting.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.8 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.8:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.8")
})

# ============================================================================
# STEP 3.9: Run Stata do-file to create the back of the envelope table
# ============================================================================
cat("STEP 3.9: Running 39_back_envelope.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/39_back_envelope.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.9 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.9:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.9")
})

# ============================================================================
# STEP 3.10: Run Stata do-file to create the back of the envelope table
# ============================================================================
cat("STEP 3.10: Running 310_job_vacancy_validity_tests.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/310_job_vacancy_validity_tests.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.10 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.10:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.10")
})

# ============================================================================
# STEP 3.11: Run Stata do-file to create the auxiliary analysis
# ============================================================================
cat("STEP 3.11: Running 311_auxiliary_analysis.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/311_auxiliary_analysis.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.11 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.11:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.11")
})

# ============================================================================
# STEP 3.12: Run Stata do-file to create the spillover analysis
# ============================================================================
cat("STEP 3.12: Running 312_spillover_analysis.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/312_spillover_analysis.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.12 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.12:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.12")
})

# ============================================================================
# STEP 3.13: Run Stata do-file to create the policy support analysis
# ============================================================================
cat("STEP 3.13: Running 313_plot_climate_support.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/313_plot_climate_support.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.13 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.13:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.13")
})

# ============================================================================
# STEP 3.14: Run Stata do-file to create the investment in levels results
# ============================================================================
cat("STEP 3.14: Running 314_investment_levels_results.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    'do "Code/analysis/314_investment_levels_results.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.14 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.14:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.14")
})

# ============================================================================
# STEP 3.15: Run Stata do-file to create the grey labor demand results
# ============================================================================
cat("STEP 3.15: Running 315_grey_labor_demand.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/315_grey_labor_demand.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.15 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.15:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.15")
})

# ============================================================================
# STEP 3.16: Run Stata do-file to create endogenity test 1: excluding criterion 2
# ============================================================================
cat("STEP 3.16: Running 316_main_reg_results_excluding_crit_2.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/316_main_reg_results_excluding_crit_2.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.16 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.16:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.16")
})

# ============================================================================
# STEP 3.17: Run Stata do-file to create endogenity test 2: including lagged unemployment
# ============================================================================
cat("STEP 3.17: Running 317_main_reg_results_with_unemployment.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/317_main_reg_results_with_unemployment.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.17 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.17:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.17")
})

# ============================================================================
# STEP 3.18: Run Stata do-file to create endogenity test 3: matching on unemployment
# ============================================================================
cat("STEP 3.18: Running 318_matching_unemployment_no_LASSO.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/318_matching_unemployment_no_LASSO.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.18 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.18:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.18")
})

# ============================================================================
# STEP 3.19: Run Stata do-file to create endogenity test 4: matching on all variables
# ============================================================================
cat("STEP 3.19: Running 319_matching_all_variables.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/319_matching_all_variables.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.19 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.19:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.19")
})

# ============================================================================
# STEP 3.20: Run Stata do-file to create part 1 excluding LA and Chicago
# ============================================================================
cat("STEP 3.20: 320_plot_total_emp_trend_excl_la_chi.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/320_plot_total_emp_trend_excl_la_chi.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.20 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.20:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.20")
})

# ============================================================================
# STEP 3.21: Run Stata do-file to create part 2 excluding LA and Chicago
# ============================================================================
cat("STEP 3.21: 321_QCEW_reg_results_excl_la_chi.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/321_QCEW_reg_results_excl_la_chi.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.21 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.21:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.21")
})

# ============================================================================
# STEP 3.22: Run Stata do-file to create part 3 excluding LA and Chicago
# ============================================================================
cat("STEP 3.22: 322_main_reg_results_excl_la_chi.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/322_main_reg_results_excl_la_chi.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.22 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.22:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.22")
})

# ============================================================================
# STEP 3.23: Run Stata do-file to create House Election results
# ============================================================================
cat("STEP 3.23: 323_plot_twfe_house_voting.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/323_plot_twfe_house_voting.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.23 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.23:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.23")
})

# ============================================================================
# STEP 3.24: Run Stata do-file to create Senate Election results
# ============================================================================
cat("STEP 3.24: 324_plot_twfe_senate_voting.do...\n")

tryCatch({
  # Create a temporary Stata script that sets globals and runs the do-file
  temp_do_file <- tempfile(fileext = ".do")
  writeLines(c(
    paste0('cd "', project_root_stata, '"'),
    paste0('global data "', data_path_stata, '"'),
    paste0('global output "', output_path_stata, '"'),
    paste0('global code "', project_root_stata, '"'),
    'do "Code/analysis/324_plot_twfe_senate_voting.do"'
  ), temp_do_file)
  
  # Run Stata with the temporary do-file
  system2(
    command = stata_path,
    args = c("/e", "do", shQuote(temp_do_file)),
    stdout = TRUE,
    stderr = TRUE
  )
  
  # Clean up temp file
  unlink(temp_do_file)
  
  cat("✓ Step 3.24 completed successfully\n\n")
}, error = function(e) {
  cat("✗ Error in Step 3.24:\n")
  cat(conditionMessage(e), "\n")
  stop("Pipeline halted due to error in Step 3.24")
})

# ============================================================================
# MONITORING - END
# ============================================================================

# Stop timer and get final measurements
overall_end_time <- Sys.time()
total_duration <- overall_end_time - overall_start_time
gc()
final_memory <- mem_used()

# Final storage
data_size_final <- sum(file.info(list.files(data_path, full.names = TRUE, recursive = TRUE))$size, na.rm = TRUE) / 1e9
output_size_final <- sum(file.info(list.files(output_path, full.names = TRUE, recursive = TRUE))$size, na.rm = TRUE) / 1e9

cat("\n\n============================================================\n")
cat("SYSTEM REQUIREMENTS SUMMARY\n")
cat("============================================================\n\n")

cat("Runtime:", format(total_duration), "\n")
cat("Peak Memory:", sprintf("%.2f GB", as.numeric(final_memory) / 1e9), "\n\n")

cat("Storage:\n")
cat(sprintf("  Data directory increase: %.2f GB\n", data_size_final - data_size_initial))
cat(sprintf("  Output directory increase: %.2f GB\n", output_size_final - output_size_initial))
cat(sprintf("  Total storage increase: %.2f GB\n", 
            (data_size_final - data_size_initial) + (output_size_final - output_size_initial)))

cat("\n============================================================\n")

# Stop logging
sink()

# ============================================================================
# Pipeline Complete
# ============================================================================
cat("\n========================================\n")
cat("Pipeline completed successfully!\n")
cat("Check the Output folder for results.\n")
cat("System requirements saved to:", log_file, "\n")
cat("========================================\n\n")

# Print quick summary to console
cat("--- SUMMARY ---\n")
cat(sprintf("Runtime: %s\n", format(total_duration)))
cat(sprintf("Peak Memory: %.2f GB\n", as.numeric(final_memory) / 1e9))
cat(sprintf("Storage Increase: %.2f GB\n", 
            (data_size_final - data_size_initial) + (output_size_final - output_size_initial)))
cat(sprintf("\nDetailed log: %s\n", log_file))