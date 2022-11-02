### https://github.com/blaylockbk/Herbie
### https://blaylockbk.github.io/Herbie/_build/html/
from herbie import Herbie
from herbie.tools import fast_Herbie, fast_Herbie_download
import pandas as pd
import sys

#start_time = "2019-08-20 00:00"
#end_time = "2020-12-31 23:00"

#times = pd.date_range(start_time, end_time, freq = "1H")

times = sys.argv[1]
print(times)

HH_par = fast_Herbie_download(
    DATES = times
  , model='hrrr'
  , product='sfc'
  , fxx=0
  , searchString = "DSWRF"
  , save_dir = "~/Downloads/par"
)#end fast_Herbie_download

HH_temp = fast_Herbie_download(
    DATES = times
  , model='hrrr'
  , product='sfc'
  , fxx=0
  , searchString = "TMP:2 m"
  , save_dir = "~/Downloads/temp"
)#end fast_Herbie_download
