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
library(tree)
library(RWeka)
library(RMySQL)

#___________________________________________________________
#|                                                          |
#|  Analitzem les ventes sota les propietat dels clients    |
#|                                                          |
#|__________________________________________________________|

# mydb = dbConnect(MySQL(), user='gourmetdb', password='gourmetdb', dbname='GOURMET', host='0.0.0.0')
# 
# rs = dbSendQuery(mydb, "
# SELECT
#   GOURMET.FAMILIA.NOMBREFAMILIA,
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
# ORDER BY GOURMET.PRODUCTO.DESCRIPCION;
#                  ")
# 
# datos = fetch(rs, n=-1)

datos <- read.csv("/home/albert/Dropbox/uoc/UOC/MÀSTER - DATA SCIENCA/Mineria de dades/practica/Entrega/csv/model_decision_tree_rpart.csv" ,  header = TRUE, sep = ',')

datos = datos[,2:6] # clear autoincremental column

summary(datos)

# arreglem els atributs per a que el detecti be com a qualitatiu
datos$NOMBREFAMILIA <- as.factor(sapply(datos$NOMBREFAMILIA, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$REGION <- as.factor(sapply(datos$REGION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$PROFESION <- as.factor(sapply(datos$PROFESION, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$NUMEROHIJOS <- factor(sapply(datos$NUMEROHIJOS, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))
datos$SEXO <- as.factor(sapply(datos$SEXO, function (x) (chartr('áéíóúñäëïöüàèìòù','aeiounaeiouaeiou', x))))

# write.csv(datos, file = "model_decision_tree_rpart.csv")

summary(datos)

nrow(datos)

#aleatoriament
datos <- datos[ sample( nrow( datos )), ]

# ens assegurem que no hi ha valors a null
sapply(datos, function (x) (sum(is.na(x))))

# veiem que hi ha alguns família que la seva adquisició es mes freqüent que altres
barplot(table(datos$NOMBREFAMILIA), main = "Quantitat productes per família")

# veiem la venta de productes per professió
barplot(table(datos$PROFESION), main = "Quantitat Productes per professió")

# veiem la venta de productes per nombre de fills
barplot(table(datos$NUMEROHIJOS), main = "Quantitat Productes per nombre de fills")

# veiem la venta de productes per sexe
barplot(table(datos$SEXO), main = "Quantitat Productes per sexe")

# veiem  la regió
barplot(table(datos$REGION), main = "Quantitat Productes per v")

X <- datos[,2:5]
y <- datos[,1]

# calculate split 1/3 to test. This number is where the dataset must split the values
split <- length(datos$NOMBREFAMILIA) - round(length(datos$NOMBREFAMILIA)/3)
train <- datos[1:split,1:5]
testInputs <- X[ (split + 1):length(datos$NOMBREFAMILIA),]
testOutput <- y[(split + 1):length(datos$NOMBREFAMILIA)]


#creem el model grow tree
model <- rpart(NOMBREFAMILIA ~., data = train, control = rpart.control(minsplit = 0.001, cp = 0))
printcp(model)

# Classification tree:
#   rpart(formula = NOMBREFAMILIA ~ ., data = train, control = rpart.control(minsplit = 0.001, 
#                                                                            cp = 0))
# 
# Variables actually used in tree construction:
#   [1] NUMEROHIJOS PROFESION   REGION      SEXO       
# 
# Root node error: 50427/63219 = 0.79766
# 
# n= 63219 

rsq.rpart(model) # visualize cross-validation results 

#prune 
#seleccionem el millor atribut com a separador
bestcp <- model$cptable[which.min(model$cptable[,"xerror"]),"CP"]
model.pruned <- prune(model, cp = bestcp)
prp(model.pruned, faclen = 0, cex = 0.8, extra = 1)

# Executem el mètode de perdició amb les dades de test
prediccio = predict(model.pruned,testInputs ,type="class")

# Podem avaluar la precisió del model utilitzant les dades de prova que hem reservat
sum( prediccio == testOutput ) / length( prediccio )
#[1] 0.218577

printcp(model) # display the results 

# Classification tree:
#   rpart(formula = NOMBREFAMILIA ~ ., data = train, control = rpart.control(minsplit = 0.001, 
#                                                                            cp = 0))
# 
# Variables actually used in tree construction:
#   [1] NUMEROHIJOS PROFESION   REGION      SEXO       
# 
# Root node error: 50444/63219 = 0.79792
# 
# n= 63219 

plotcp(model) # visualize cross-validation results 

summary(model) # detailed summary of splits

plot(model, uniform=TRUE, 
     main="Classification Tree for Kyphosis")
text(model, use.n=TRUE, all=TRUE, cex=.8)

#random forest

# Random Forest prediction of Kyphosis data
library(randomForest)
fit <- randomForest(NOMBREFAMILIA ~., data = datos)
print(fit) # view results 
importance(fit) # importance of each predictor

# MeanDecreaseGini
# REGION             600.17721
# PROFESION          112.26541
# NUMEROHIJOS        599.87146
# SEXO                62.50985

# Executem el mètode de perdició amb les dades de test
prediccio = predict(fit,testInputs ,type="class")

# Podem avaluar la precisió del model utilitzant les dades de prova que hem reservat
sum( prediccio == testOutput ) / length( prediccio )
#[1] 0.2227214

