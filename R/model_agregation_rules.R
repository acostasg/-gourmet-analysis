# read https://www.r-bloggers.com/accessing-mysql-through-r/
# If you need, install libmariadbclient libraries
install.packages("RMySQL")
install.packages("xlsx", dep = T)
install.packages("C50", dep = T)
install.packages("rpart", dep = T)
install.packages("rpart.plot", dep = T)
install.packages("tree", dep = T)
install.packages("RWeka", dep = T)
install.packages("arules", dep = T)
library(arules)
library(xlsx)
library(rpart)
library(rpart.plot)
library(C50)
library(tree)
library(RWeka)
library(RMySQL)


#_____________________________________________________________________________________
#|                                                                                   |
#|   Analitzem una tenda aleatoria - podrem canviar de tenda en qualsevol moment     |
#|                                                                                   |
#|___________________________________________________________________________________|

# mydb = dbConnect(MySQL(), user='gourmetdb', password='gourmetdb', dbname='GOURMET', host='0.0.0.0')
# 
# rs = dbSendQuery(mydb, "
#                  SELECT
#                  CODVENTA,
#                  DESCRIPCION
#                  FROM GOURMET.LINEASTICKET
#                  JOIN GOURMET.PRODUCTO ON GOURMET.LINEASTICKET.CODPRODUCTO = GOURMET.PRODUCTO.CODPRODUCTO
#                  WHERE NOMBRETIENDA = 'Roma'
#                  ORDER BY CODVENTA
#                  ")
# 
# datos = fetch(rs, n=-1)

datos <- read.csv("/home/albert/Dropbox/uoc/UOC/MÀSTER - DATA SCIENCA/Mineria de dades/practica/Entrega/csv/model_agregation_rules.csv", header = TRUE, sep = ',')

datos = datos[,2:3] # clear autoincremental column

summary(datos)

# arreglem els atributs CODVENTA i DESCRIPTION per a que el detecti be com a qualitatiu
datos$CODVENTA <- factor(datos$CODVENTA)
datos$DESCRIPCION <- factor(datos$DESCRIPCION)
datos$DESCRIPCION <- as.factor(sapply(datos$DESCRIPCION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))

# write.csv(datos, file = "model_agregation_rules.csv")

summary(datos)

nrow(datos)
# [1] 11247

# ens assegurem que no hi ha valors a null
sapply(datos, function (x) (sum(is.na(x))))

# veiem que hi ha alguns productes que la seva adquisicio es mes frequent que altres
barplot(table(datos$DESCRIPCION), main = "Quantitat Productes adquirits")

# tambe observem que la mitjana de productes comprats per comanda ronda les 5 unitats "son compres petites"
barplot(table(datos$CODVENTA), main = "Total Productes adquirits per compra")


#_____________________
#|                   |
#|   Binarització    |
#|                   |
#|___________________|

# Llista per a cada usuari els productes comprats
mba <- split(x=datos[,"DESCRIPCION"],f=datos$CODVENTA)
summary(mba)

# total regisitres
sum(sapply(mba,length))
# [1] 11247

# Si hi ha duplicats els eliminen
mba <- lapply(mba,unique)

sum(sapply(mba,length))
# [1] 11042 , hem netejar 205 valors

# binaritzem
mba <- as(mba, "transactions")
class(mba)

# top 30 productes
itemFrequencyPlot(mba, topN = 30, type = "absolute")

# generem varies binaritzacións per veure qui genera un numero optim de regles
regles <- list()
num_regles <- list()
serie <- seq(0.0001, 0.001, by = 0.0001) 
for (k in serie)
{
  regles[[k*10000]] <- apriori(mba, parameter = list(support = k, confidence = 0.8))
  num_regles[k*10000] <- length(regles[[k*10000]])
}

num_regles <- unlist(num_regles)
plot(num_regles)
lines(num_regles, col="red")
for (i in 1:10)
{
  text(x = i, y = num_regles[i], pos = 4, num_regles[i])
}

# Amb 0.0002 les regles generades son 84. es un bon numero de regles asi que agafem aquest valor com a suport

regles_final <- regles[[2]]
summary(regles_final)
# set of 84 rules
# 
# rule length distribution (lhs + rhs):sizes
# 3  4 
# 54 30 
# 
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 3.000   3.000   3.000   3.357   4.000   4.000 

# les regles
inspect(regles_final)


# lhs                                                                               rhs                               support      confidence lift      count
# [1]  {Brut Extra Selection,Tinto Gran Reserva 82}                                   => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [2]  {Brut Chardonnay Blanc de Blancs,Danish Crumbly Blue}                          => {Camembert}                       0.0003871467 1           13.84987 2    
# [3]  {Camembert,Danish Crumbly Blue}                                                => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [4]  {Brut Premier Cru,Chocolate Truffle}                                           => {Provolone}                       0.0003871467 1           20.91498 2    
# [5]  {Camembert,Polvorones de Estepa}                                               => {Mozzarella di Bufala}            0.0003871467 1           18.78545 2    
# [6]  {Scotch Whiskey 15 anos,Shiraz-Cabernet 96}                                    => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [7]  {Shiraz-Cabernet 96,Tinto Reserva 94}                                          => {Scotch Whiskey 15 anos}          0.0003871467 1           17.39394 2    
# [8]  {Bra,Tiramisu}                                                                 => {Tinto Gran Reserva 91}           0.0003871467 1           12.75556 2    
# [9]  {Chardonnay en barrica 97,Mozzarella di Bufala}                                => {Scotch Whiskey 18 anos}          0.0003871467 1           24.60000 2    
# [10] {Chardonnay en barrica 97,Provolone}                                           => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [11] {Chardonnay en barrica 97,Tinto Reserva 94}                                    => {Provolone}                       0.0003871467 1           20.91498 2    
# [12] {Bourgogne Rouge 97,Goat Gouda}                                                => {Scotch Whiskey 15 anos}          0.0003871467 1           17.39394 2    
# [13] {Goat Gouda,Scotch Whiskey 15 anos}                                            => {Bourgogne Rouge 97}              0.0003871467 1           29.02247 2    
# [14] {Sage Derby,Sylvaner 96}                                                       => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [15] {Merlot 97,Sage Derby}                                                         => {Sylvaner 96}                     0.0003871467 1          198.69231 2    
# [16] {Iberico,Maasdam}                                                              => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [17] {Gorgonzola Dolce,Tinto Reserva 95}                                            => {Tinto Gran Reserva 82}           0.0003871467 1           21.88983 2    
# [18] {Bordeaux 97,Sauvignon Blanc 96}                                               => {Tinto Gran Reserva 91}           0.0003871467 1           12.75556 2    
# [19] {Asiago,Parmigiano Reggiano}                                                   => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [20] {Camembert,Zinfandel 96}                                                       => {Manchego}                        0.0003871467 1           17.75258 2    
# [21] {Brut Chardonnay Blanc de Blancs,Reserve Chardonnay 97}                        => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [22] {Brinata,Provolone}                                                            => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [23] {Postel,Tinto Reserva 95}                                                      => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [24] {Brut Chardonnay Blanc de Blancs,Extra Aged Gouda}                             => {Mature Cheddar}                  0.0003871467 1           15.56024 2    
# [25] {Monte Veronese,Semillon 99}                                                   => {Provolone}                       0.0003871467 1           20.91498 2    
# [26] {Monte Veronese,Provolone}                                                     => {Semillon 99}                     0.0003871467 1          198.69231 2    
# [27] {Parmigiano Reggiano,Tokay Pinot Gris 98}                                      => {Maasdam}                         0.0003871467 1           16.61093 2    
# [28] {Bordeaux 88,Tinto Gran Reserva 82}                                            => {Scotch Whiskey 18 anos}          0.0003871467 1           24.60000 2    
# [29] {Bordeaux 88,Chardonnay 98}                                                    => {Scotch Whiskey 15 anos}          0.0003871467 1           17.39394 2    
# [30] {Bordeaux 88,Tinto Gran Reserva 82}                                            => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [31] {Chardonnay 97,Galettes}                                                       => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [32] {Bourgogne Rouge 97,Yalumba Grenache 97}                                       => {Parmigiano Reggiano}             0.0003871467 1           14.76000 2    
# [33] {Maasdam,Yalumba Grenache 97}                                                  => {Parmigiano Reggiano}             0.0003871467 1           14.76000 2    
# [34] {Brutti e Buoni,Scotch Whiskey 21 anos}                                        => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [35] {Merlot 97,Scotch Whiskey 21 anos}                                             => {Brutti e Buoni}                  0.0003871467 1           19.34831 2    
# [36] {Sage Derby,Scotch Whiskey 15 anos}                                            => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [37] {Swiss Gruyere,Tinto Reserva 95}                                               => {Camembert}                       0.0003871467 1           13.84987 2    
# [38] {Chablis Chardonnay 97,Tiramisu}                                               => {Brutti e Buoni}                  0.0003871467 1           19.34831 2    
# [39] {Cabrales,Chardonnay 98}                                                       => {Brutti e Buoni}                  0.0005807201 1           19.34831 3    
# [40] {Brutti e Buoni,Cabrales}                                                      => {Chardonnay 98}                   0.0005807201 1           22.36364 3    
# [41] {Cabernet Sauvignon 97,Passendale}                                             => {Chablis Chardonnay 97/98}        0.0003871467 1           23.48182 2    
# [42] {Brut Chardonnay Blanc de Blancs,Pinot Noir 98}                                => {Brutti e Buoni}                  0.0003871467 1           19.34831 2    
# [43] {Monte Veronese,Tinto Crianza 96}                                              => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [44] {Gruyere de Comte,Provolone}                                                   => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [45] {Brut Reserva,Tinto Reserva 96}                                                => {Tinto Gran Reserva 82}           0.0003871467 1           21.88983 2    
# [46] {Brut Reserva,Tinto Gran Reserva 82}                                           => {Tinto Reserva 96}                0.0003871467 1           56.15217 2    
# [47] {Manchego,Mature Blue Stilton}                                                 => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [48] {Mature Blue Stilton,Mature Cheddar}                                           => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [49] {Cabernet Sauvignon 97,Tinto Reserva 95}                                       => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [50] {Bourgogne Rouge 97,Tinto Gran Reserva 89}                                     => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [51] {Chablis Chardonnay 97/98,Tinto Gran Reserva 89}                               => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [52] {Scotch Whiskey 15 anos,Tinto Crianza 96/97}                                   => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [53] {Layden Gin,Provolone}                                                         => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [54] {Cabernet Sauvignon 96,Gouda}                                                  => {Tinto Gran Reserva 91}           0.0003871467 1           12.75556 2    
# [55] {Bordeaux 88,Scotch Whiskey 18 anos,Tinto Gran Reserva 82}                     => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [56] {Bordeaux 88,Bordeaux 97,Scotch Whiskey 18 anos}                               => {Tinto Gran Reserva 82}           0.0003871467 1           21.88983 2    
# [57] {Bordeaux 88,Bordeaux 97,Tinto Gran Reserva 82}                                => {Scotch Whiskey 18 anos}          0.0003871467 1           24.60000 2    
# [58] {Bordeaux 97,Gouda,Scotch Whiskey 18 anos}                                     => {Camembert}                       0.0003871467 1           13.84987 2    
# [59] {Camembert,Gouda,Scotch Whiskey 18 anos}                                       => {Bordeaux 97}                     0.0003871467 1           14.93064 2    
# [60] {Bordeaux 97,Camembert,Gouda}                                                  => {Scotch Whiskey 18 anos}          0.0003871467 1           24.60000 2    
# [61] {Bordeaux 97,Camembert,Scotch Whiskey 18 anos}                                 => {Gouda}                           0.0003871467 1           58.70455 2    
# [62] {Brutti e Buoni,Chablis Chardonnay 97/98,Tinto Crianza 96}                     => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [63] {Brut Chardonnay Blanc de Blancs,Chablis Chardonnay 97/98,Tinto Crianza 96}    => {Brutti e Buoni}                  0.0003871467 1           19.34831 2    
# [64] {Brutti e Buoni,Manchego,Tiramisu}                                             => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [65] {Brutti e Buoni,Merlot 97,Tiramisu}                                            => {Manchego}                        0.0003871467 1           17.75258 2    
# [66] {Maasdam,Merlot 97,Tiramisu}                                                   => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [67] {Merlot 97,Tinto Reserva 95,Tiramisu}                                          => {Maasdam}                         0.0003871467 1           16.61093 2    
# [68] {Tinto Gran Reserva 91,Tinto Reserva 95,Tiramisu}                              => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [69] {Tinto Gran Reserva 91,Tinto Reserva 94,Tiramisu}                              => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [70] {Bordeaux 97,Chablis Chardonnay 97/98,Manchego}                                => {Provolone}                       0.0003871467 1           20.91498 2    
# [71] {Bordeaux 97,Manchego,Provolone}                                               => {Chablis Chardonnay 97/98}        0.0003871467 1           23.48182 2    
# [72] {Brutti e Buoni,Chablis Chardonnay 97/98,Tinto Reserva 95}                     => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [73] {Brut Chardonnay Blanc de Blancs,Chablis Chardonnay 97/98,Parmigiano Reggiano} => {Mature Cheddar}                  0.0003871467 1           15.56024 2    
# [74] {Brutti e Buoni,Merlot 97,Provolone}                                           => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [75] {Brutti e Buoni,Provolone,Tinto Reserva 95}                                    => {Merlot 97}                       0.0003871467 1           18.58273 2    
# [76] {Brutti e Buoni,Merlot 97,Tinto Reserva 95}                                    => {Provolone}                       0.0003871467 1           20.91498 2    
# [77] {Bordeaux 97,Mature Cheddar,Provolone}                                         => {Tinto Reserva 95}                0.0003871467 1           11.93072 2    
# [78] {Bordeaux 97,Provolone,Tinto Reserva 95}                                       => {Mature Cheddar}                  0.0003871467 1           15.56024 2    
# [79] {Bordeaux 97,Mature Cheddar,Tinto Reserva 95}                                  => {Provolone}                       0.0003871467 1           20.91498 2    
# [80] {Brut Chardonnay Blanc de Blancs,Brutti e Buoni,Mature Cheddar}                => {Camembert}                       0.0003871467 1           13.84987 2    
# [81] {Brutti e Buoni,Camembert,Mature Cheddar}                                      => {Brut Chardonnay Blanc de Blancs} 0.0003871467 1           14.27072 2    
# [82] {Brut Chardonnay Blanc de Blancs,Camembert,Mature Cheddar}                     => {Brutti e Buoni}                  0.0003871467 1           19.34831 2    
# [83] {Maasdam,Manchego,Tinto Reserva 95}                                            => {Tinto Reserva 94}                0.0003871467 1           10.83019 2    
# [84] {Parmigiano Reggiano,Scotch Whiskey 15 anos,Tinto Reserva 95}                  => {Merlot 97}                       0.0003871467 1           18.58273 2  
