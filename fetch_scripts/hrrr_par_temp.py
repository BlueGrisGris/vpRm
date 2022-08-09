### https://github.com/blaylockbk/Herbie
### https://blaylockbk.github.io/Herbie/_build/html/
from herbie import Herbie
from herbie.tools import fast_Herbie, fast_Herbie_download
import pandas as pd

start_time = "2019-08-20 00:00"
#end_time = "2019-08-20 23:00"
end_time = "2020-12-31 23:00"

times = pd.date_range(start_time, end_time, freq = "1H")
times

HH_par = fast_Herbie_download(
    DATES = times
  , model='hrrr'
  , product='sfc'
  , fxx=0
  , searchString = "DSWRF"
  #, save_dir = "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/hrrr_par"
  , save_dir = "~/Downloads/par"
)#end Herbie


HH_temperature = fast_Herbie_download(
    DATES = times
  , model='hrrr'
  , product='sfc'
  , fxx=0
  , searchString = "TMP:2 m"
  #, save_dir = "/n/wofsy_lab2/Users/emanninen/vprm/driver_data/hrrr_temperature"
  , save_dir = "~/Downloads/temp"
)#end Herbie

HH_temperature 
