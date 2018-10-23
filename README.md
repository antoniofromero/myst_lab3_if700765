# myst_lab3_if700765

Laboratorio 3 de la clase de microestructuras y sistemas de trading.

Este laboraotio trató de hacer una estrategía de trading de análisis técnico, del cual fue elegido DEMA (Double Exponential Average), en el código se usa una serie de funciones dadas por el profesor Francisco Muñoz para bajar los precios desde OANDA. Posteriormente se hace el cálculo de DEMA gracias a la paquetería TTR. Una vez teniendo los resultados de DEMA se procede a crear una matriz donde se hacen los correpondientes cálculos de la estrategía de compra y venta de EUR_USD.

La estrategía sólo consiste en comprar si el precio de cierre es mayor a el resultado DEMA, y vender si el precio de cierre es menor a DEMA. En el caso de que no se presente ninguna diferencia entre en indicador y el precio de cierre la posición se mentiene igual y no hay operación alguna.
