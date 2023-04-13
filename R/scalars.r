### Modified Tscalar form Winbourne et al 2021
Tscalar <- function(Tair, Tmin, Tmax){
	### mean of 2 Topt vals in Winbourne 2021's piecewise
	Topt <- 25
	return(
		((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-Topt)^2)
	)#end return
}#end func Tscalar

### Modified Pscalar from Winbourne et al 2021
Pscalar <- function(EVI, EVImax, EVImin){
	Pscalar <- (EVI - EVImin)/(EVImax-EVImin)
	Pscalar[Pscalar < 0] <- 0 
	Pscalar[Pscalar > 1] <- 1 
	return(Pscalar )
}#end func Pscalar

### From Mahadevan 2008
Wscalar <- function(LSWI,LSWImax){
	return(
		(1+LSWI)/(1+LSWImax)
	)#end return
}#end func Wscalar
