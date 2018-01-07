SELECT
  GOURMET.CLIENTE.REGION,
  GOURMET.CLIENTE.PROFESION,
  GOURMET.CLIENTE.NUMEROHIJOS,
  GOURMET.CLIENTE.SEXO,
  GOURMET.CABECERATICKET.HORA,
  GOURMET.CABECERATICKET.IMPORTETOTAL,
  DAYNAME(GOURMET.CABECERATICKET.FECHA) as DIA
FROM GOURMET.LINEASTICKET
  JOIN GOURMET.CABECERATICKET ON GOURMET.LINEASTICKET.CODVENTA = GOURMET.CABECERATICKET.CODVENTA
  JOIN GOURMET.CLIENTE ON GOURMET.CABECERATICKET.CODCLIENTE = GOURMET.CLIENTE.CODCLIENTE
ORDER BY GOURMET.CABECERATICKET.HORA;