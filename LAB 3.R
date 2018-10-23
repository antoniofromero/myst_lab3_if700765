# -- Borrar todos los elementos del environment
rm(list=ls())
mdir <- getwd()

# -- Establecer el sistema de medicion de la computadora
Sys.setlocale(category = "LC_ALL", locale = "")

# -- Huso horario
Sys.setenv(tz="America/Monterrey", TZ="America/Monterrey")
options(tz="America/Monterrey", TZ="America/Monterrey")

# -- Cargar y/o instalar en automatico paquetes a utilizar -- #

pkg <- c("base","downloader","dplyr","fBasics","forecast","grid",
         "gridExtra","httr","jsonlite","lmtest","lubridate","moments",
         "matrixStats", "PerformanceAnalytics","plyr","quantmod",
         "reshape2","RCurl","RMySQL", "stats","scales","tseries",
         "TTR","TSA","XML","xts","zoo")

inst <- pkg %in% installed.packages()
if(length(pkg[!inst]) > 0) install.packages(pkg[!inst])
instpackages <- lapply(pkg, library, character.only=TRUE)

# -- Cargar archivos desde GitHub -- #

RawGitHub <- "https://raw.githubusercontent.com/IFFranciscoME/"
ROandaAPI <- paste(RawGitHub,"ROandaAPI/master/ROandaAPI.R",sep="")
downloader::source_url(ROandaAPI,prompt=FALSE,quiet=TRUE)

# -- Parametros para usar API-OANDA

# Tipo de cuenta practice/live
OA_At <- "practice"
# ID de cuenta
OA_Ai <- 1742531
# Token para llamadas a API
OA_Ak <- "ada4a61b0d5bc0e5939365e01450b614-4121f84f01ad78942c46fc3ac777baa6" 
# Hora a la que se considera "Fin del dia"
OA_Da <- 17
# Uso horario
OA_Ta <- "America/Mexico_City"
# Instrumento
OA_In <- "EUR_USD"
# Granularidad o periodicidad de los precios H4 = Cada 4 horas
OA_Pr <- "H4"
# Multiplicador de precios para convertir a PIPS
MultPip_MT1 <- 10000

Precios_Oanda <- HisPrices(AccountType = OA_At, Granularity = OA_Pr,
                           DayAlign = OA_Da, TimeAlign = OA_Ta, Token = OA_Ak,
                           Instrument = OA_In, 
                           Start = NULL, End = NULL, Count = 900)

#ALMA <- ALMA(Precios_Oanda$Close)

#lista <- list()

#for(i in 10:length(ALMA)){ #porque los 10 primeros son NaN

#if(Precios_Oanda$Close[i] > ALMA[i])lista[i] <- 'Vende'
#else lista[i] <- 'Compra'
#}

#H <- Precios_Oanda$High
#L <- Precios_Oanda$Low
#C <- Precios_Oanda$Close

#HCL <- data.frame(H,L,C)

#BBands(HCL, n = 20, sd = 2)


DEMA <- DEMA(Precios_Oanda$Close, n = 10, v = 1, wilder = FALSE, ratio = NULL)

Historico <- data.frame("Date" = Precios_Oanda$TimeStamp,
                        "Precio_Open" = Precios_Oanda$Open,
                        "Precio_Close" = Precios_Oanda$Close,
                        "DEMA" = DEMA,
                        "Balance" = 0,
                        "Unidades" = 0, "Unidades_a" = 0,
                        "Operacion" = NA, "Utilidad" = 0, "Mensaje" = NA)


#Valores Iniciales y Primeros Calculos de la Matriz

Historico$DEMA [1:20] <- 0
Pip <- 10000
Historico$Utilidad <- (Historico$Precio_Open[1] - Historico$Precio_Close[1])* Pip
Historico$Balance <- Historico$Utilidad[1]
Historico$Unidades[1] <- Pip
Historico$Unidades_a[1] <- Pip
Historico$Operacion[1] <- "Inicio"
Historico$Mensaje[1] <- "Inicializacion de cartera" 

#Ciclo "for" para los siguientes Calculos de la Matriz

for(i in 20:length(Historico$Date)){
  
  if(Historico$Precio_Close[i] > Historico$DEMA[i]){ 
    
    Historico$Utilidad[i] <-(Historico$Precio_Close[i]-Historico$Precio_Open)*Pip
    Historico$Balance[i] <- Historico$Balance[i-1]+Historico$Utilidad[i]
    Historico$Unidades[i] <- Pip
    Historico$Unidades_a[i] <- Historico$Unidades_a[i-1]+Historico$Unidades[i]
    Historico$Operacion[i] <-"Comprar"
    Historico$Mensaje[i] <- "Compra exitosa"
    }
  
  else if(Historico$Precio_Close[i] < Historico$DEMA[i]){
    
    Historico$Utilidad[i] <-(Historico$Precio_Open[i]-Historico$Precio_Close)*Pip
    Historico$Balance[i] <- Historico$Balance[i-1]-Historico$Utilidad[i]
    Historico$Unidades[i] <- Pip
    Historico$Unidades_a[i] <- Historico$Unidades_a[i-1]-Historico$Unidades[i]
    Historico$Operacion[i] <-"Vender"
    Historico$Mensaje[i] <- "Venta existosa"
    }
  
  
  else { #Se mantiene igual
    
    Historico$Utilidad[i] <-Historico$Utilidad[i-1]
    Historico$Balance[i] <- Historico$Balance[i-1]
    Historico$Unidades[i] <- 0
    Historico$Unidades_a[i] <- Historico$Unidades_a[i-1]
    Historico$Operacion[i] <-"SO" #Sin Operación
    Historico$Mensaje[i] <- "Sin operacion"
    
  }
  
}
  



