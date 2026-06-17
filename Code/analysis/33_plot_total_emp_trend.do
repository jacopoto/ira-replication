*---------------------------------------------------
* EC vs Non-EC employment trends (MA(4))
*
* Author: Jacopo
* Date: 07/10/2025
*
* Purpose: estimate dynamic DiD and plot quarterly MA(4) series by ever-EC status.
*
* Inputs:
* $data/constructed data/final_employment_dataset_stata.csv
*
* Outputs:
* $fig/dcdh_all_employment.pdf
* $fig/ec_nonEC_employment_trend.pdf
*
*
* Notes:
* EC defined as ever treated at county_id.
* MA(4) is trailing four-quarter average.
* Sample starts at 2019q1.
*---------------------------------------------------


* EC vs Non-EC employment trend with ever-treated definition
import delimited using "$data/constructed data/final_employment_dataset_stata.csv", ///
    varnames(1) encoding(UTF-8) clear

* Ever-treated at any time → EC
gen byte tr = treatment==1 if !missing(treatment)
bysort county_id: egen byte ever_ec = max(tr)
replace ever_ec = 0 if missing(ever_ec)

label define comm 0 "Non-EC" 1 "EC", replace
label values ever_ec comm

* Quarter variable
gen quarter_num = mod(period-1, 4) + 1
gen tq = yq(year, quarter_num)
format tq %tq

* Start at 2019q1
drop if tq < yq(2018,2)

* Collapse to mean employment per quarter by EC status
destring all_employment, replace force
collapse (mean) all_employment, by(ever_ec tq)

* 4-quarter trailing moving average
gen ecid = ever_ec
tsset ecid tq
bysort ecid (tq): gen emp_ma4 = (all_employment + L1.all_employment + L2.all_employment + L3.all_employment)/4

drop if missing(emp_ma4)


* Axis ticks
summ tq, meanonly
local ystart = max(2019, year(dofq(r(min))))
local yend   = max(2025, year(dofq(r(max))))
local xlab_major
local xtick_minor
forvalues y = `ystart'(1)`yend' {
    local tqv = yq(`y',1)
    if mod(`y',2)==1 local xlab_major `xlab_major' `tqv'
    else              local xtick_minor `xtick_minor' `tqv'
}

* Y-axis: 0 to 170k with thousands separators
local ymin 110000
local ymax 170000
local ystep 10000

* Event lines
local t2020 = yq(2020,1)
local t2022 = yq(2022,3)
local t2023 = yq(2023,1)

* Label height
summ emp_ma4
local ypos = 170000

local LW medthick

twoway ///
    line emp_ma4 tq if ecid==1, sort lwidth(`LW') lcolor(stc1) ///
||  line emp_ma4 tq if ecid==0, sort lwidth(`LW') lcolor(stc2) ///
	lpattern(dash) ///
    ytitle("Mean employment", size(large)) xtitle("") ///
    xlabel(`xlab_major', format(%tqCCYY) labsize(large)) ///
    xtick(`xtick_minor') legend(off) ///
    xline(`t2020' `t2022' `t2023', lpattern(dash) lcolor(gs8) lwidth(thin)) ///
	ylabel(`ymin'(`ystep')`ymax', format(%12.0fc) labsize(large)) ///
    yscale(range(`ymin' `ymax')) ///
    text(`ypos' `t2020' "TCDTR" "Act",  place(n)  size(large)) ///
    text(`ypos' `t2022' "Start" "IRA",  place(nw) size(large)) ///
    text(`ypos' `t2023' "EC" "Bonus",   place(ne) size(large)) ///
    graphregion(margin(t=8)) name(emp_trend, replace)
graph display emp_trend, xsize(5.6)
graph export "$output/ec_nonEC_employment_trend.pdf", replace
