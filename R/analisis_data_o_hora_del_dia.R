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

#_________________________________________________________
#|                                                       |
#|   Analisis hores o dies volum ventes per  clients     |
#|                                                       |
#|_______________________________________________________|

#mydb = dbConnect(MySQL(), user='gourmetdb', password='gourmetdb', dbname='GOURMET', host='0.0.0.0')

# rs = dbSendQuery(mydb, "
# SELECT
#   GOURMET.CLIENTE.REGION,
#   GOURMET.CLIENTE.PROFESION,
#   GOURMET.CLIENTE.NUMEROHIJOS,
#   GOURMET.CLIENTE.SEXO,
#   GOURMET.CABECERATICKET.HORA,
#   GOURMET.CABECERATICKET.IMPORTETOTAL,
#   DAYNAME(GOURMET.CABECERATICKET.FECHA) as DIA
# FROM GOURMET.LINEASTICKET
#   JOIN GOURMET.CABECERATICKET ON GOURMET.LINEASTICKET.CODVENTA = GOURMET.CABECERATICKET.CODVENTA
#   JOIN GOURMET.CLIENTE ON GOURMET.CABECERATICKET.CODCLIENTE = GOURMET.CLIENTE.CODCLIENTE
# ORDER BY GOURMET.CABECERATICKET.HORA
#                  ")
# 
# datos = fetch(rs, n=-1)

datos <- read.csv("/home/albert/Dropbox/uoc/UOC/MÀSTER - DATA SCIENCA/Mineria de dades/practica/Entrega/csv/analisis_data_o_hora_del_dia.csv", header = TRUE, sep = ',')

datos = datos[,2:8] # clear autoincremental column

summary(datos)

# clear data
# arreglem els atributs per a que el detecti be com a qualitatiu
datos$REGION <- as.factor(sapply(datos$REGION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$PROFESION <- as.factor(sapply(datos$PROFESION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$NUMEROHIJOS <- as.factor(sapply(datos$NUMEROHIJOS, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$SEXO <- as.factor(sapply(datos$SEXO, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$HORA <- as.factor(sapply(datos$HORA, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$DIA <- factor(sapply(datos$DIA, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))

# write.csv(datos, file = "analisis_data_o_hora_del_dia.csv")

summary(datos)

nrow(datos)

#aleatoriamentl rando
datos <- datos[ sample( nrow( datos )), ]

# ens assegurem que no hi ha valors a null
sapply(datos, function (x) (sum(is.na(x))))

#En general hores del dia de mes compra
ggplot(data=datos, aes(x=HORA, fill=HORA), title = "Hora del dia")  + geom_bar() 

#Dia de la semana de mes compres
ggplot(data=datos, aes(x=DIA, fill=DIA), title = "Dia de la seamana de mes compres")  + geom_bar() 

#analisis per sexes del client
ggplot(data=datos, aes(x=HORA, y=HORA, fill=SEXO), title = "Hoa del i sexe del client")  + geom_bar(stat="identity", position="stack") 

ggplot(data=datos, aes(x=DIA, y=DIA, fill=SEXO), title = "Dia de la semana i sexe del client")  + geom_bar(stat="identity", position="stack") 

#analisis per regio del client
ggplot(data=datos, aes(x=HORA, y=HORA, fill=REGION), title = "Hora del dia i regio del client")  + geom_bar(stat="identity", position="stack") 

ggplot(data=datos, aes(x=DIA, y=DIA, fill=REGION), title = "Dia de la semana i regio del client")  + geom_bar(stat="identity", position="stack") 

#analisis per professio del client
ggplot(data=datos, aes(x=HORA, y=HORA, fill=PROFESION), title = "Hora de la semana i professio del client")  + geom_bar(stat="identity", position="stack") 

ggplot(data=datos, aes(x=DIA, y=DIA, fill=PROFESION), title = "Dia de la semana i professio del client")  + geom_bar(stat="identity", position="stack") 

#analisis per numero de fills del client
ggplot(data=datos, aes(x=HORA, y=HORA, fill=NUMEROHIJOS), title = "Hola de la semana i numero de fills del client")  + geom_bar(stat="identity", position="stack") 

ggplot(data=datos, aes(x=DIA, y=DIA, fill=NUMEROHIJOS), title = "Dia de la semana i numero de fills del client")  + geom_bar(stat="identity", position="stack") 

#analisis per importe total 
ggplot(data=datos, aes(x=HORA, y=IMPORTETOTAL, fill=IMPORTETOTAL), title = "Hora i importe total")  + geom_point(size=3)

ggplot(data=datos, aes(x=DIA, y=IMPORTETOTAL, fill=IMPORTETOTAL), title = "Dia de la semana i importe total")  + geom_point(size=3)



