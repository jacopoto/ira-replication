*---------------------------------------------------
* Plot quarterly MA(4) labor-demand series by EC status
*
* Author: Jacopo
* Date: 05/09/2025
*
* Input:  $data/constructed data/trends_labor_demand_long.dta
* Output: $fig/wind_labor_trend.pdf
*         $fig/solar_labor_trend.pdf
*---------------------------------------------------

clear all

* 1) Load
use "$data/constructed data/trends_labor_demand_long.dta", clear
format tq %tq
label define comm 0 "Non-EC" 1 "EC", replace
label values energy_community comm

* Start at 2019q1
drop if tq < yq(2019,1)

* Last-point labels per line
preserve
    bysort series energy_community (tq): keep if _n==_N
    keep series energy_community tq share_ma4
    gen str20 ecstr = cond(energy_community==1,"EC","Non-EC")
    tempfile lastpts
    save `lastpts'
restore
merge m:1 series energy_community tq share_ma4 using `lastpts', nogen keep(master match)

* X-axis: major ticks in odd years, minor ticks in even years
summ tq, meanonly
local ystart = max(2019, year(dofq(r(min))))
local yend   = max(2025, year(dofq(r(max))))

local xlab_major
local xtick_minor
forvalues y = `ystart'(1)`yend' {
    local tq = yq(`y',1)
    if mod(`y',2)==1 {
        local xlab_major `xlab_major' `tq'
    }
    else {
        local xtick_minor `xtick_minor' `tq'
    }
}

* y-axis definition (shared across graphs)
local ymin  0.0005
local ymax  0.0035
local ystep 0.0005

* Event lines and labels
local t2020 = yq(2020,1)
local t2022 = yq(2022,3)
local t2023 = yq(2023,1)
local ypos  = 0.00345   // inside axis range

* Common graph settings
local LW medthick

*-----------------------------*
* 2) Wind vacancies
*-----------------------------*
preserve
    keep if series=="Wind"
    sort energy_community tq
    twoway ///
        line share_ma4 tq if energy_community==1, sort lwidth(`LW') lcolor(stc1) ///
    ||  line share_ma4 tq if energy_community==0, sort lwidth(`LW') lcolor(stc2) ///
		lpattern(dash) ///
        ytitle("Share of Vacancies", size(large)) xtitle("") ///
        ylabel(`ymin'(`ystep')`ymax', labsize(large)) ///
        xlabel(`xlab_major', format(%tqCCYY) labsize(large)) ///
        xtick(`xtick_minor') ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        xline(`t2020' `t2022' `t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
        text(`ypos' `t2020' "TCDTR" "Act",  place(n) size(large)) ///
        text(`ypos' `t2022' "Start" "IRA",  place(nw) size(large)) ///
        text(`ypos' `t2023' "EC" "Bonus",   place(ne) size(large)) ///
        graphregion(margin(t=8)) ///
        name(wind_labor_trend, replace)
    graph display wind_labor_trend, xsize(5.6)
    graph export "$output/wind_labor_trend.pdf", replace
restore

*-----------------------------*
* 3) Solar vacancies
*-----------------------------*
preserve
    keep if series=="Solar"
    sort energy_community tq
    twoway ///
        line share_ma4 tq if energy_community==1, sort lwidth(`LW') lcolor(stc1) ///
    ||  line share_ma4 tq if energy_community==0, sort lwidth(`LW') lcolor(stc2) ///
		lpattern(dash) ///
        ytitle("Share of Vacancies", size(large)) xtitle("") ///
        ylabel(`ymin'(`ystep')`ymax', labsize(large)) ///
        xlabel(`xlab_major', format(%tqCCYY) labsize(large)) ///
        xtick(`xtick_minor') ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        xline(`t2020' `t2022' `t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
        text(`ypos' `t2020' "TCDTR" "Act",  place(n) size(large)) ///
        text(`ypos' `t2022' "Start" "IRA",  place(nw) size(large)) ///
        text(`ypos' `t2023' "EC" "Bonus",   place(ne) size(large)) ///
        graphregion(margin(t=8)) ///
        name(solar_labor_trend, replace)
    graph display solar_labor_trend, xsize(5.6)
    graph export "$output/solar_labor_trend.pdf", as(pdf) replace
restore

*-----------------------------*
* 4) Grey vacancies
*-----------------------------*
preserve
    keep if series=="Grey"
    sort energy_community tq
    twoway ///
        line share_ma4 tq if energy_community==1, sort lwidth(`LW') lcolor(stc1) ///
    ||  line share_ma4 tq if energy_community==0, sort lwidth(`LW') lcolor(stc2) ///
		lpattern(dash) ///
        ytitle("Share of Vacancies", size(large)) xtitle("") ///
        ylabel(`ymin'(`ystep')`ymax', labsize(large)) ///
        xlabel(`xlab_major', format(%tqCCYY) labsize(large)) ///
        xtick(`xtick_minor') ///
        legend(off) ///
        yscale(range(`ymin' `ymax')) ///
        xline(`t2020' `t2022' `t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
        text(`ypos' `t2020' "TCDTR" "Act",  place(n) size(large)) ///
        text(`ypos' `t2022' "Start" "IRA",  place(nw) size(large)) ///
        text(`ypos' `t2023' "EC" "Bonus",   place(ne) size(large)) ///
        graphregion(margin(t=8)) ///
        name(grey_labor_trend, replace)
    graph display grey_labor_trend, xsize(5.6)
    graph export "$output/grey_labor_trend.pdf", replace
restore