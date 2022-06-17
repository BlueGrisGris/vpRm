### Modified Tscalar form Winbourne et al 2021
Tscalar <- function(Tair, Tmin, Tmax){
	### piecewise function from Winbourne et al 2021
	pw_idx <- findInterval(Tair , c(-Inf, 20, 30, Inf))
	Tscalar <- list(
		((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-20)^2)
		, 1
		, ((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-30)^2)
	     )[[pw_idx]] #end list
	return(Tscalar)
}#end func Tscalar

### Modified Pscalar from Winbourne et al 2021
Pscalar <- function(EVI, EVImax, EVImin){
	return(
	       (EVI - EVImin)/(EVImax-EVImin)
	       )#end return
}#end func Pscalar
