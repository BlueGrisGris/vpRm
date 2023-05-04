

### Modified Pscalar from Winbourne et al 2021
Pscalar <- function(EVI, EVImax, EVImin){
	Pscalar <- (EVI - EVImin)/(EVImax-EVImin)
	Pscalar[Pscalar < 0] <- 0 
	Pscalar[Pscalar > 1] <- 1 
	return(Pscalar )
}#end func Pscalar

### simplified Tscalar for forests.  avg value from mahadevan 2008
Tscalar <- function(Tair, Tmin, Tmax){
	return(.85)
}#end func Tscalar 

Tscalar <- function(Tair, Tmin, Tmax){
	### mean of 2 Topt vals in Winbourne 2021's piecewise
	Topt <- 25
	Tscalar <- ((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-Topt)^2)
	Tscalar[Tscalar>1] <- 1
	Tscalar[Tscalar<0] <- 0
	return(Tscalar)
}#end func Tscalar

### From Mahadevan 2008
mah_Wscalar <- function(LSWI,LSWImax){
	return(
		(1+LSWI)/(1+LSWImax)
	)#end return
}#end func Wscalar

### simplified Wscalar for forests.  avg value from mahadevan 2008
Wscalar <- function(LSWI,LSWImax, tt){
	mahadevan_monthly_Wscalar <- c(
		0.98
		, 0.97
		, 0.82
		, 0.75
		, 0.81
		, 0.88
		, 0.88
		, 0.88
		, 0.88
		, 0.80
		, 0.75
		, 0.78
	)#end c
	Wscalar <- mahadevan_monthly_Wscalar[lubridate::month(tt)]
	return(Wscalar)
}#end function Wscalar
