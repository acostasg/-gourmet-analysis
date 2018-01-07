# read https://www.r-bloggers.com/accessing-mysql-through-r/
# If you need, install libmariadbclient libraries
install.packages("RMySQL")
install.packages("xlsx", dep = T)
install.packages("C50", dep = T)
install.packages("rpart", dep = T)
install.packages("rpart.plot", dep = T)
install.packages("tree", dep = T)
install.packages("RWeka", dep = T)
library(xlsx)
library(rpart)
library(rpart.plot)
library(C50)
library(ggplot2)
library(tree)
library(RWeka)
library(RMySQL)

#_______________________________________________
#|                                              |
#|   Analisis ventes volum atributs clients     |
#|                                              |
#|______________________________________________|


#mydb = dbConnect(MySQL(), user='gourmetdb', password='gourmetdb', dbname='GOURMET', host='0.0.0.0')
#
# rs = dbSendQuery(mydb, "
# SELECT
#   GOURMET.PRODUCTO.DESCRIPCION,
#   GOURMET.FAMILIA.NOMBREFAMILIA,
#   GOURMET.NOMBRESUBFAMILIA.NOMBRESUBFAMILIA,
#   GOURMET.CLIENTE.REGION,
#   GOURMET.CLIENTE.PROFESION,
#   GOURMET.CLIENTE.NUMEROHIJOS,
#   GOURMET.CLIENTE.SEXO
# FROM GOURMET.LINEASTICKET
#   JOIN GOURMET.PRODUCTO ON GOURMET.LINEASTICKET.CODPRODUCTO = GOURMET.PRODUCTO.CODPRODUCTO
#   JOIN GOURMET.CABECERATICKET ON GOURMET.LINEASTICKET.CODVENTA = GOURMET.CABECERATICKET.CODVENTA
#   JOIN GOURMET.CLIENTE ON GOURMET.CABECERATICKET.CODCLIENTE = GOURMET.CLIENTE.CODCLIENTE
#   JOIN GOURMET.NOMBRESUBFAMILIA ON GOURMET.PRODUCTO.NOMBRESUBFAMILIA = GOURMET.NOMBRESUBFAMILIA.NOMBRESUBFAMILIA
#   JOIN GOURMET.FAMILIA ON GOURMET.NOMBRESUBFAMILIA.NOMBREFAMILIA = GOURMET.FAMILIA.NOMBREFAMILIA
# ORDER BY GOURMET.PRODUCTO.DESCRIPCION
#                  ")
# 
# datos = fetch(rs, n=-1)

datos <- read.csv("/home/albert/Dropbox/uoc/UOC/MÀSTER - DATA SCIENCA/Mineria de dades/practica/Entrega/csv/analisis_volum_de_vendes.csv", header = TRUE, sep = ',')

datos = datos[,2:9] # clear autoincremental column

summary(datos)

#clear data
# arreglem els atributs per a que el detecti be com a qualitatiu
datos$DESCRIPCION <- as.factor(sapply(datos$DESCRIPCION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$NOMBREFAMILIA <- as.factor(sapply(datos$NOMBREFAMILIA, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$NOMBRESUBFAMILIA <- as.factor(sapply(datos$NOMBRESUBFAMILIA, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$REGION <- as.factor(sapply(datos$REGION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$PROFESION <- as.factor(sapply(datos$PROFESION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$NUMEROHIJOS <- factor(sapply(datos$NUMEROHIJOS, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$SEXO <- as.factor(sapply(datos$SEXO, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))

# write.csv(datos, file = "analisis_volum_de_vendes.csv")

summary(datos)

nrow(datos)

#aleatoriament random
datos <- datos[ sample( nrow( datos )), ]

# ens assegurem que no hi ha valors a null
sapply(datos, function (x) (sum(is.na(x))))


# veiem que hi ha alguns subfamilies que la seva adquisicio es mes frequent que altres
ggplot(data=datos, aes(x=NOMBRESUBFAMILIA, fill=NOMBRESUBFAMILIA), main = "Volumen de compres per subfamilia") +
  geom_bar()

# veiem que hi ha alguns familia que la seva adquisicio es mes frequent que altres
ggplot(data=datos, aes(x=NOMBREFAMILIA, fill=NOMBREFAMILIA), main = "Volumen de compres per familia") +
  geom_bar()

# veiem la venta per regio
ggplot(data=datos, aes(x=REGION, fill=REGION), main = "Volumen de compres per regio") +
  geom_bar()

# veiem la venta per professio
ggplot(data=datos, aes(x=PROFESION, fill=PROFESION), main = "Volumen de compres per professio") +
  geom_bar()

# veiem la venta per professio
ggplot(data=datos, aes(x=NUMEROHIJOS, fill=NUMEROHIJOS), main = "Volumen de compres per nombre de fills") +
  geom_bar()

# veiem la venta per sexe del comprador
ggplot(data=datos, aes(x=SEXO, fill=SEXO), main = "Volumen de compres per sexe del comprador") +
  geom_bar()

#productes per frecuencia
frecuencia_productes = as.data.frame(summary.factor(datos$DESCRIPCION))
print(frecuencia_productes)

# Chocolate Truffle                                                    4848
# Tiramisu                                                             4558
# Tinto Reserva 95                                                     3880
# Camembert                                                            3424
# Tinto Reserva 94                                                     2767
# Tinto Gran Reserva 91                                                2744
# Bordeaux 97                                                          2603
# Brut Chardonnay Blanc de Blancs                                      2516
# Manchego                                                             2288
# Merlot 97                                                            2216
# Parmigiano Reggiano                                                  2155


