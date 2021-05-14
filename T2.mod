### SETS ###

set types;              # tipos de marmelada
set months;             # meses do ano de 2057
set productionLines;    # linhas de produção que a companhia dispõe

### PARAMETERS ###

param mercuryPrices {months, types} >= 0;   # previsões dos preços da marmelada em mercúrio em função do mês e do tipo 
param venusPrices   {months, types} >= 0;   # previsões dos preços da marmelada em vénus em função do mês e do tipo 
param marsPrices    {months, types} >= 0;   # previsões dos preços da marmelada em marte em função do mês e do tipo 

param productionLinesCapacity {productionLines, types} >= 0; # capacidade máxima de uma linhas de produção em função da linha e do tipo de marmelada   

### VARIABLES ###

var mercuryShipped {months, types} >= 0; # unidades de marmelada enviada para mercúrio 
var venusShipped   {months, types} >= 0; # unidades de marmedada enviada para vénus
var marsShipped    {months, types} >= 0; # unidades de marmelada enviada para marte

var produced {months, types} >= 0;
var leftOver {months, types} >= 0;

var mercuryShuttle {months} binary; # variável que define se há envio para mercúrio 
var venusShuttle   {months} binary; # variável que define se há envio para vénus
var marsShuttle    {months} binary; # variável que define se há envio para marte

var mercurySold {months, types} >= 0;
var venusSold {months, types} >= 0;
var marsSold {months, types} >= 0;

var mercuryStock {months, types} >= 0;
var venusStock {months, types} >= 0;
var marsStock {months, types} >= 0;

### CONSTRAINTS ###

subject to mercuryMaxAmountShipped {m in months}: sum {t in types} mercuryShipped[m, t] <= 1000; # só podem ser enviadas até 1000 unidades de marmelada para mercúrio
subject to venusMaxAmountShipped   {m in months}: sum {t in types} venusShipped[m, t] <= 1000;   # só podem ser enviadas até 1000 unidades de marmelada para vénus
subject to marsMaxAmountShipped    {m in months}: sum {t in types} marsShipped[m, t] <= 1000;    # só podem ser enviadas até 1000 unidades de marmelada para marte

subject to productionLinesMaxCapacity {m in months, p in productionLines}: sum {t in types} 
produced[m, t] / productionLinesCapacity[p, t] <= 1;

subject to mercuryShuttleRestriction {m in months}: sum {t in types} mercuryShipped [m, t] <= 1000 * mercuryShuttle[m];
subject to venusShuttleRestriction {m in months}: sum {t in types} venusShipped [m, t] <= 1000 * venusShuttle[m];
subject to marsShuttleRestriction {m in months}: sum {t in types} marsShipped [m, t] <= 1000 * marsShuttle[m];

subject to firstMonthProduction   {t in types}: produced[1, t] = mercuryShipped[1, t] + venusShipped[1, t] + marsShipped[1, t] + leftOver[1, t];
subject to generalMonthProduction {m in 2 .. 12, t in types}: produced[m, t] = mercuryShipped[m, t] + venusShipped[m, t] + marsShipped[m, t] + leftOver[m, t] - leftOver[m - 1, t];  

subject to mercuryFirstMonthStored {t in types}: mercuryShipped[1, t] = mercurySold[1, t] + mercuryStock[1, t];
subject to mercuryGeneralMonthProduction { m in 2 .. 12, t in types}: mercuryShipped[m, t] = mercurySold[m, t] + mercuryStock[m, t] - mercuryStock[m - 1, t];

subject to venusFirstMonthStored {t in types}: venusShipped[1, t] = venusSold[1, t] + venusStock[1, t];
subject to venusGeneralMonthProduction { m in 2 .. 12, t in types}: venusShipped[m, t] = venusSold[m, t] + venusStock[m, t] - venusStock[m - 1, t];

subject to marsFirstMonthStored {t in types}: marsShipped[1, t] = marsSold[1, t] + marsStock[1, t];
subject to marsGeneralMonthProduction { m in 2 .. 12, t in types}: marsShipped[m, t] = marsSold[m, t] + marsStock[m, t] - marsStock[m - 1, t];

### OBJECTIVE ###

maximize revenue: 
sum {m in months, t in types} ( mercurySold[m, t]*mercuryPrices[m, t] + venusSold[m, t]*venusPrices[m, t] + marsSold[m, t]*marsPrices[m, t] - leftOver[m, t]) 
- sum {m in months} (mercuryShuttle[m] * 10000 + venusShuttle[m] * 10000 + marsShuttle[m] * 10000)
- sum {m in months, t in types} (mercuryStock[m, t] * 2 + venusStock[m, t] * 2 + marsStock[m, t] * 2);

end;