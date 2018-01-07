# read https://www.r-bloggers.com/accessing-mysql-through-r/
# If you need, install libmariadbclient libraries
install.packages("RMySQL")
library(RMySQL)
library(xlsx)
library(rpart)
library(rpart.plot)
library(C50)
library(ggplot2)
library(tree)
library(RWeka)
library(RMySQL)

#______________________________________________________
#|                                                     |
#|   Analisis ventes import total atributs clients     |
#|                                                     |
#|_____________________________________________________|


# mydb = dbConnect(MySQL(), user='gourmetdb', password='gourmetdb', dbname='GOURMET', host='0.0.0.0')
#
# rs = dbSendQuery(mydb, "
# SELECT IMPORTETOTAL, SEXO, FORMAPAGO, ESTADOCIVIL
# FROM GOURMET.CABECERATICKET
# JOIN GOURMET.CLIENTE ON GOURMET.CLIENTE.CODCLIENTE = GOURMET.CABECERATICKET.CODCLIENTE
# ")
# 
# datos = fetch(rs, n=-1)

datos <- read.csv("/home/albert/Dropbox/uoc/UOC/MÀSTER - DATA SCIENCA/Mineria de dades/practica/Entrega/csv/analisis_per_import_total.csv", header = TRUE, sep = ',')

datos = datos[,2:5] # clear autoincremental column

summary(datos)

# arreglem els atributs per a que el detecti be com a qualitatiu
datos$ESTADOCIVIL <- factor(datos$ESTADOCIVIL)
datos$FORMAPAGO <- factor(datos$FORMAPAGO)
datos$SEXO <- factor(datos$SEXO)

# write.csv(datos, file = "analisis_per_import_total.csv")

summary(datos)

# que sexo gasta mas
ggplot(data=datos, aes(x=SEXO, y=IMPORTETOTAL, fill=SEXO), title = "Import total de compres per sex")  + geom_bar(stat="identity", position="stack") 

# que estado civil gasta mas
ggplot(data=datos, aes(x=ESTADOCIVIL, y=IMPORTETOTAL, fill=ESTADOCIVIL), title = "Import total de compres per estat civil")  + geom_bar(stat="identity", position="stack") 

# forma de pago mas usada
ggplot(data=datos, aes(x=FORMAPAGO, fill=FORMAPAGO), title = "Tipus de pagament utilitzat") +
  geom_bar()

# forma de pago mas usada i per sexe (empresa, home o dona)
ggplot(data=datos, aes(x=FORMAPAGO, fill=SEXO), title = "Tipus de pagament utilitzat per sexe") +
  geom_bar()

# forma de pago mas usada i estat civil
ggplot(data=datos, aes(x=FORMAPAGO, fill=ESTADOCIVIL), title = "Tipus de pagament utilitzat estat civil") +
  geom_bar()
