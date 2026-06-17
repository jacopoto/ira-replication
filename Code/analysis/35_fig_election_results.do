*---------------------------------------------------
* Plot yearly Republican vote share by EC status
*
* Author: Jacopo
* Date: 05/09/2025
*
* Input:  $data/constructed data/trends_election_long.dta
* Output: $fig/election_all_ec.pdf
*         $fig/election_rust_ec.pdf
*---------------------------------------------------

clear all

* 1) Load
use "$data/constructed data/trends_election_long.dta", clear
label define comm 0 "Non-EC" 1 "EC", replace
label values energy_community comm

* Restrict to presidential years (≥2000)
drop if year < 2000

* Ticks at presidential elections: 2000,2004,...,2024(+)
local ystart = 2000
summ year, meanonly
local yend = max(2024, r(max))
local xlab_pres
forvalues y = `ystart'(4)`yend' {
    local xlab_pres `xlab_pres' `y'
}

* Y-axis shared across graphs
summ share, meanonly
local ymin = floor(r(min)*20)/20
local ymax = ceil(r(max)*20)/20
if (`ymin'==`ymax') local ymax = `ymin' + 0.05
local ystep 0.05

* Event lines and labels
local t2020 = 2020
local t2022 = 2022
local t2023 = 2023
local ypos  = `ymax'+ 0.01

local LW medthick

*-----------------------------*
* All counties
*-----------------------------*
preserve
    keep if series=="All counties"
    sort energy_community year
    twoway ///
        line share year if energy_community==1, sort lwidth(`LW') lcolor(stc1) ///
    ||  line share year if energy_community==0, sort lwidth(`LW') lcolor(stc2) ///
		lpattern(dash) ///
        ytitle("Republican vote share", size(large)) xtitle("") ///
        ylabel(`ymin'(`ystep')`ymax', labsize(large) format(%3.2f)) ///
        xlabel(`xlab_pres', labsize(large)) ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        xline(`t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
        text(`ypos' `t2023' "EC" "Bonus",   place(sw) size(large)) ///
        graphregion(margin(t=8)) ///
        name(election_all_ec, replace)
    graph display election_all_ec, xsize(5.6)
    graph export "$output/election_all_ec.pdf", replace
restore

*-----------------------------*
* Rust Belt only
*-----------------------------*
preserve
    keep if series=="Rust Belt"
    sort energy_community year
    twoway ///
        line share year if energy_community==1, sort lwidth(`LW') lcolor(stc1) ///
    ||  line share year if energy_community==0, sort lwidth(`LW') lcolor(stc2) ///
		lpattern(dash) ///
        ytitle("Republican vote share", size(large)) xtitle("") ///
        ylabel(`ymin'(`ystep')`ymax', labsize(large) format(%3.2f)) ///
        xlabel(`xlab_pres', labsize(large)) ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        xline(`t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
        text(`ypos' `t2023' "EC" "Bonus",   place(sw) size(large)) ///
        graphregion(margin(t=8)) ///
        name(election_rust_ec, replace)
    graph display election_rust_ec, xsize(5.6)
    graph export "$output/election_rust_ec.pdf", replace
restore
