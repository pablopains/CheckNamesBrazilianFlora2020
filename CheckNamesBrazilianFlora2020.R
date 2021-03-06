###---------------------------------------------------------------------###
###                    CheckNamesBrazilianFlora2020	                    ###
###    Permite consultar informa��es do Projeto Flora do Brasil 2020    ###
###                                                                     ###
### Autor: Pablo Hendrigo Alves de Melo - pablopains@yahoo.com.br       ###
### Last update: 20-11-2019                                             ### 
###---------------------------------------------------------------------###

###---------------------------------------------------------------------###
# instru��es
# acessar http://ipt.jbrj.gov.br/jbrj/resource?r=lista_especies_flora_brasil
# download the latest version of this resource data as a Darwin Core Archive (DwC-A)
# unzip the file and save it to the working directory
###---------------------------------------------------------------------###

###---------------------------------------------------------------------###
# rm(list = ls())
# memory.limit(size = 1.75e13) 
# tempdir <- function() "D:\\temps"
# unlockBinding("tempdir", baseenv())
# assignInNamespace("tempdir", tempdir, ns="base", envir=baseenv())
# assign("tempdir", tempdir, baseenv())
# lockBinding("tempdir", baseenv())
# tempdir()
# setwd('C:/Dados/GitHub/CheckNamesBrazilianFlora2020')
###---------------------------------------------------------------------###

if(!require(pacman)) install.packages("pacman")
pacman::p_load(data.table, raster,stringr, stringdist, flora,rlang)

taxon.full <- fread(paste0(getwd(),"/taxon.txt"))

t <- taxon.full$taxonRank %in% c("ESPECIE","VARIEDADE","SUB_ESPECIE", "FORMA")
taxon <- taxon.full[t,]

g <- taxon.full$taxonRank %in% c("GENERO")
df.genus <- taxon.full[g,]
df.genus$genus <- toupper(df.genus$genus)

f <- taxon.full$taxonRank %in% c("FAMILIA")
df.family <- taxon.full[f,]
df.family$family <- toupper(df.family$family)

distribution <- fread(paste0(getwd(),"/distribution.txt"))

speciesprofile <- fread(paste0(getwd(),"/speciesprofile.txt"))

resourcerelationship <- fread(paste0(getwd(),"/resourcerelationship.txt"))

###---------------------------------------------------------------------###
habito.FloraBR2020 <-function(id=NA,retorno='D')
{  
  habito.d  = data.frame(�rvore = 0,
                          Subarbusto = 0,
                          Arbusto = 0,
                          Erva = 0,
                          Palmeira = 0,
                          Suculenta = 0,
                          Liana_vol�vel_trepadeira = 0,
                          Desconhecida = 0,
                          Dracen�ide = 0,
                          Bambu = 0,
                          Talosa = 0,
                          Saprobio = 0,
                          Aqu�tica_Pl�ncton = 0,
                          Aqu�tica_Bentos = 0,
                          Simbionte = 0,
                          Tapete = 0,
                          Folhosa = 0,
                          Tufo = 0,
                          Aqu�tica_Neuston = 0,
                          Parasita = 0,
                          Coxim = 0,
                          Trama = 0,
                          Pendente = 0,
                          Dendr�ide = 0,
                          Flabelado = 0)
  
   habito.t  = c('�rvore', #'Árvore', # 
                'Subarbusto',
                'Arbusto',
                'Erva',
                'Palmeira',
                'Suculenta',
                'Liana/vol�vel/trepadeira',
                'Desconhecida',
                'Dracen�ide',
                'Bambu',
                'Talosa',
                'Saprobio',
                'Aqu�tica-Pl�ncton', #'Aqu�tica-Pl�ncton',
                'Aqu�tica-Bentos', #'Aquática-Bentos', #'Aqu�tica-Bentos',
                'Simbionte',
                'Tapete',
                'Folhosa',
                'Tufo',
                'Aqu�tica-Neuston',
                'Parasita',
                'Coxim',
                'Trama',
                'Pendente',
                'Dendr�ide',
                'Flabelado')
  
  #            'Liana/volúvel/trepadeira',
  
  # Encoding(habito.t) = 'latin1' # 'UTF-8'  
  
  o <- id == speciesprofile$id
  or <- speciesprofile[o,]
  if (nrow(or)>0) {
    x = or$lifeForm[1]
    x = gsub('\\"|\\{|\\}',
             "",
             x)
    x2 = strsplit(x,':')[[1]]
    
    habito.tmp =  strsplit( gsub('\\[', "", strsplit(x2[2],']')[[1]][1]),',')[[1]] 
    Encoding(habito.tmp) = "UTF-8"
    
    
    d2 <-  gsub(" ", "",habito.t) %in% habito.tmp
    habito.d[1,d2] <- 1
  }
  
  habito = data.frame(habito.d)
  
  if (retorno!='D'){
    
  
    habito.texto=''
    for (cc in 1:length(habito.t)){
      if (habito[cc]==1)   {habito.texto=paste0(habito.texto,
                                            ifelse(habito.texto=='','',', '),
                                            habito.t[cc])}
    }  
    return(habito.texto)
  }  
  
  return(habito)
} 

###---------------------------------------------------------------------###

substrato.FloraBR2020<-function(id=NA, retorno='D')
{
  # id=119546
  
  substrato.d = data.frame(
    Terricola = 0,
    Rupicola = 0,
    Epifita = 0,
    Hemiep�fita = 0,
    Aqu�tica = 0,
    Hemiparasita = 0,
    Parasita = 0,
    Desconhecido = 0,
    Sapr�fita = 0,
    Cortic�cola = 0,
    Tronco_em_decomposi��o = 0,
    Solo = 0,
    Planta_viva_raiz = 0,
    Epixila = 0,Rocha = 0,
    Planta_viva_cortex_do_caule = 0,
    Areia = 0,
    Sub_aerea = 0,
    Folhedo = 0,
    Ed�fica = 0,
    Planta_viva_fruto = 0,
    Planta_viva_inflorescencia = 0,
    Planta_viva_folha = 0,
    Folhedo_aereo = 0,
    Agua = 0,
    Saxicola = 0,
    Epifila = 0,
    Simbionte_incluindo_fungos_liquenizados = 0)
  
  substrato.t = c(
    'Terr�cola',
    'Rup�cola',
    'Ep�fita',
    'Hemiep�fita',
    'Aqu�tica',
    'Hemiparasita',
    'Parasita',
    'Desconhecido',
    'Sapr�fita',
    'Cortic�cola',
    'Tronco em decomposi��o',
    'Solo',
    'Planta viva - raiz',
    'Epixila,Rocha',
    'Planta viva - c�rtex do caule',
    'Areia',
    'Sub-a�rea',
    'Folhedo',
    'Ed�fica',
    'Planta viva - fruto',
    'Planta viva - infloresc�ncia',
    'Planta viva - folha',
    'Folhedo a�reo',
    '�gua',
    'Sax�cola',
    'Ep�fila',
    'Simbionte (incluindo fungos liquenizados)')
    
  o <- id == speciesprofile$id
  or <- speciesprofile[o,]
  if (nrow(or)>0) {
    x = or$lifeForm[1]
    x = gsub('\\"|\\{|\\}',
             "",
             x)
    x2 = strsplit(x,':')[[1]]
    
    substrato.tmp =  strsplit( gsub('\\[', "", strsplit(x2[3],']')[[1]][1]),',')[[1]] 
    Encoding(substrato.tmp) = "UTF-8"
    
    d2 <-  gsub(" ", "",substrato.t) %in% substrato.tmp
    substrato.d[1,d2] <- 1
  }
  
  substrato = data.frame(substrato.d)
  
  if (retorno!='D'){
    substrato.texto=''
    for (cc in 1:length(substrato.t)){
      if (substrato[cc]==1)   {substrato.texto=paste0(substrato.texto,
                                                ifelse(substrato.texto=='','',', '),
                                                substrato.t[cc])}
    }
    return(substrato.texto)  
  }  
  return(substrato)
}
  
###---------------------------------------------------------------------###

distribuicao.uf.FloraBR2020<-function(id=NA)
{
  uf.d <- data.frame( AC=0, AL=0, AM=0, AP=0, BA=0, CE=0, DF=0, ES=0, GO=0, MA=0, MG=0,MS=0, MT=0, PA=0, PB=0, PE=0, PI=0, PR=0, RJ=0, RN=0, RO=0, RR=0, RS=0, SC=0, SE=0, SP=0, TO=0)      
  
  d <- id == distribution$id
  uf <- distribution[d,]
  
  for (i in 1:NROW(uf))
  {
    d2 <-  paste0("BR-",colnames(uf.d)) %in% uf$locationID[i]
    uf.d[1,d2] <- 1
  }
  return(uf.d)
}
###---------------------------------------------------------------------###

endemismo.Brasil.FloraBR2020 <-function(id=NA)
{  
  
  endemism = ""
  
  o <- id == distribution$id
  or <- distribution[o,]
  if (nrow(or)>0) {
    x = or$occurrenceRemarks[1]
    x = gsub('\\"|\\{|\\}',
             "",
             x)
    x2 = strsplit(x,':')[[1]]
    
    endemism = gsub('\\[|\\]', "", strsplit(x2[2],',')[[1]][1]) 
  }
  
  endemismo = data.frame(endemism)
  
  return(endemismo)
}  

###---------------------------------------------------------------------###

dominiofitogeografico.FloraBR2020 <-function(id=NA)
{  
  
  dominiofitogeografico.d  = data.frame(AtlanticRainforest=0,
                                        AmazonRainforest=0,
                                        Caatinga=0,
                                        CentralBrazilianSavanna=0,
                                        Pampa=0, 
                                        Pantanal=0) 
  
  # dominiofitogeografico.t  = c('AtlanticRainforest',
  #                              'AmazonRainforest',
  #                              'Caatinga',
  #                              'CentralBrazilianSavanna',
  #                              'Pampa', 
  #                              'Pantanal') 
  
  # portugues
  dominiofitogeografico.t  = c('Mata Atl�ntica',
                               'Amaz�nia',
                               'Caatinga',
                               'Cerrado',
                               'Pampa', 
                               'Pantanal') 
  
  o <- id == distribution$id
  or <- distribution[o,]
  if (nrow(or)>0) {
    x = or$occurrenceRemarks[1]
    x = gsub('\\"|\\{|\\}',
             "",
             x)
    x2 = strsplit(x,':')[[1]]
    
    phytogeographicDomain =  strsplit( gsub('\\[', "", strsplit(x2[3],']')[[1]][1]),',')[[1]] 
    d2 <-  gsub(" ", "",phytogeographicDomain) %in% dominiofitogeografico.t
    dominiofitogeografico.d[1,d2] <- 1
  }
  
  dominiofitogeografico = data.frame(dominiofitogeografico.d)
  
  return(dominiofitogeografico)
}  

###---------------------------------------------------------------------###

tipovegetacao.FloraBR2020 <-function(id=NA)
{  
  tipovegetacao.d  = data.frame(  AREA_ANTROPICA = 0,
                                  CAATINGA = 0,
                                  CAMPINARANA = 0,
                                  CAMPO_DE_ALTITUDE = 0,
                                  CAMPO_DE_VARZEA = 0,
                                  CAMPO_LIMPO = 0,
                                  CAMPO_RUPESTRE = 0,
                                  CARRASCO = 0,
                                  CERRADO = 0,
                                  FLORESTA_CILIAR_OU_GALERIA = 0,
                                  FLORESTA_DE_IGAPO = 0,
                                  FLORESTA_DE_TERRA_FIRME = 0,
                                  FLORESTA_DE_VARZEA = 0,
                                  FLORESTA_ESTACIONAL_DECIDUAL = 0,
                                  FLORESTA_ESTACIONAL_PERENIFOLIA = 0,
                                  FLORESTA_ESTACIONAL_SEMIDECIDUAL = 0,
                                  FLORESTA_OMBROFILA = 0,
                                  FLORESTA_OMBROFILA_MISTA = 0,
                                  MANGUEZAL = 0,
                                  PALMEIRAL = 0,
                                  RESTINGA = 0,
                                  SAVANA_AMAZONICA = 0,
                                  VEGETACAO_AQUATICA = 0,
                                  VEGETACAO_SOBRE_AFLORAMENTOS_ROCHOSOS = 0)  
  
  # tipovegetacao.t  = c( "Anthropic area",
  #                      "Caatinga (stricto sensu)",
  #                      "Amazonian Campinarana",
  #                      "High Altitude Grassland",
  #                      "Flooded Field (V�rzea)",
  #                      "Grassland",
  #                      "Highland Rocky Field",
  #                      "Carrasco Vegetation",
  #                      "Cerrado (lato sensu)",
  #                      "Riverine Forest and/or Gallery Forest",
  #                      "Inundated Forest (Igap�)",
  #                      "Terra Firme Forest",
  #                      "Inundated Forest (V�rzea)",
  #                      "Seasonally Deciduous Forest",
  #                      "Seasonal Evergreen Forest",
  #                      "Seasonally Semideciduous Forest",
  #                      "Ombrophyllous Forest (Tropical Rain Forest)",
  #                      "Mixed Ombrophyllous Forest",
  #                      "Mangrove",
  #                      "Palm Grove",
  #                      "Coastal Forest (Restinga)",
  #                      "Amazonian Savanna",
  #                      "Aquatic vegetation",
  #                      "Rock outcrop vegetation")
  
  # portugues
  tipovegetacao.t  = c( "�rea Antr�pica",
                        "Caatinga (stricto sensu)",
                        "Campinarana",
                        "Campo de Altitude",
                        "Campo de V�rzea",
                        "Campo Limpo",
                        "Campo Rupestre",
                        "Carrasco",
                        "Cerrado (lato sensu)",
                        "Floresta Ciliar ou Galeria",
                        "Floresta de Igap�",
                        "Floresta de Terra Firme",
                        "Floresta de V�rzea",
                        "Floresta Estacional Decidual",
                        "Floresta Estacional Perenif�lia",
                        "Floresta Estacional Semidecidual",
                        "Floresta Ombr�fila (= Floresta Pluvial)",
                        "Floresta Ombr�fila Mista",
                        "Manguezal",
                        "Palmeiral",
                        "Restinga",
                        "Savana Amaz�nica",
                        "Vegeta��o Aqu�tica",
                        "Vegeta��o Sobre Afloramentos Rochosos")
  
  o2 <- id == speciesprofile$id
  or2 <- speciesprofile[o2,]
  
  if (nrow(or2)>0) {
    x = gsub('\\"|\\{|\\}',
             "",
             or2)
    x2 = strsplit(x,':')[[2]]
    
    vegetationType =  strsplit( gsub('\\[', "", strsplit(x2[4],']')[[1]][1]),',')[[1]] 
    d2 <- tipovegetacao.t %in%  vegetationType
    tipovegetacao.d[1,d2] <- 1
    
  }
  
  tipovegetacao = data.frame(tipovegetacao.d)
  
  return(tipovegetacao)
}  
###---------------------------------------------------------------------###

nome.aceito.FloraBR2020.base <- function(genus="", specificEpithet="" , infraspecificEpithet="")
{
  #  estrutura de retorno
  nameNA <-data.frame("id" = NA,
                      "taxonID" = NA,
                      "acceptedNameUsageID" = NA,
                      "parentNameUsageID" = NA,
                      "originalNameUsageID" = NA,
                      "scientificName" = NA,
                      "acceptedNameUsage" = NA,
                      "parentNameUsage" = NA,
                      "namePublishedIn" = NA,
                      "namePublishedInYear" = NA,
                      "higherClassification" = NA,
                      "kingdom" = NA,
                      "phylum" = NA,
                      "class" = NA,
                      "order" = NA,
                      "family" = NA,
                      "genus" = NA,
                      "specificEpithet" = NA,
                      "infraspecificEpithet" = NA,
                      "taxonRank" = NA,
                      "scientificNameAuthorship" = NA,
                      "taxonomicStatus" = NA,
                      "nomenclaturalStatus" = NA,
                      "modified" = NA,
                      "bibliographicCitation" = NA,
                      "references" = NA,
                      stringsAsFactors = F )
  
  # tratamento dos parametros
  genus <- ifelse(is.na(genus),'', genus)
  specificEpithet <- ifelse(is.na(specificEpithet), '', specificEpithet)
  infraspecificEpithet <- ifelse(is.na(infraspecificEpithet),'',infraspecificEpithet)
  
  specificEpithet <- gsub("[0-9]","", specificEpithet )
  specificEpithet <- gsub('cf.',"", specificEpithet, fixed=T )
  specificEpithet <- gsub('aff.',"", specificEpithet, fixed=T )
  specificEpithet <- gsub('sp.',"", specificEpithet, fixed=T)
  
  infraspecificEpithet <- gsub('subsp.',"", infraspecificEpithet, fixed=T )
  infraspecificEpithet <- gsub('var.',"", infraspecificEpithet, fixed=T )
  
  genus <- str_trim(genus)
  specificEpithet <- str_trim(specificEpithet)
  infraspecificEpithet <- str_trim(infraspecificEpithet)
  
  # definindo n�vel taxonomico da busca
  return.data <- nameNA
  name <- {}
  
  if (genus != "" & specificEpithet =="" )
  {
    index <- toupper(genus) == df.genus$genus & df.genus$taxonomicStatus == 'NOME_ACEITO'
    name <- df.genus[index,]
    
    if (NROW(name)>0)
    {
      return.data <- name
      
      return.data$statusCode = 'genus only'
      return.data$status <- 'genus only'
    }else{
      
      index <- toupper(genus) == df.family$family & df.family$taxonomicStatus == 'NOME_ACEITO'
      name <- df.family[index,]
      if (NROW(name)>0)
      {
        return.data <- name
        
        return.data$statusCode = 'family only'
        return.data$status <- 'family only'
      }else{
        return.data$statusCode = '0 - not found'
        return.data$status <- 'not found'
      }  
    } 
    #
    return(return.data)
  }
  ###
  
  if (genus!="" )
  {
    if (genus != "" & specificEpithet != "" & infraspecificEpithet == "") # esp�cie
    {index <- (paste0(genus, specificEpithet) == paste0(taxon$genus, taxon$specificEpithet)) & taxon$taxonRank == "ESPECIE"}  
    
    if (genus != "" & specificEpithet != "" & infraspecificEpithet != "") # subsp. e var.
    {index <- (paste0(genus, specificEpithet, infraspecificEpithet ) == paste0(taxon$genus, taxon$specificEpithet, taxon$infraspecificEpithet)) & taxon$taxonRank %in% c('VARIEDADE','SUB_ESPECIE', 'FORMA')}  
    
    name <- taxon[index,]
    
    if (NROW(name)>=2)
    {
      index <- name$taxonomicStatus == "NOME_ACEITO"
      name <- name[index,]
      
      x.id <- unique(name$taxonID)
      for (x in 1:length(x.id))
      { 
        if (NROW(resourcerelationship[resourcerelationship$id %in% x.id[x],])>0)
        {
          index <- name$id == x.id[x]
          name <- name[index,]
          break()
        }
      }
      
      if (NROW(name)>=2)
      {
        return.data <- nameNA
        return.data$statusCode <- paste0('3 - more than one name accepted (',NROW(name),')') 
        return.data$status <- 'name without resolution'
        return(return.data)
      }
      
    }  
    
    if (NROW(name) == 0 & infraspecificEpithet != '')
    {
      return.data$statusCode = '0 - not found'
      return.data$status <- 'not found'
      return(return.data)
    }    
    
    if (NROW(name) == 0)
    {
      loc_vet <- grep(paste0(genus, " ", specificEpithet), taxon$acceptedNameUsage)
      if (length(loc_vet)>0)
      {
        x.parentNameUsageID <- unique(taxon[c(loc_vet), ]$parentNameUsageID)
        
        index <- resourcerelationship$relatedResourceID == x.parentNameUsageID
        
        x.taxonID <- resourcerelationship[index,]$id
        
        index <- distribution$id == x.taxonID
        x.distribution <- distribution[index,]
        
        if (NROW(x.distribution)==0)
        {
          return.data$statusCode <- '7 - Does not occur in Brazil OR Unknown distribution'
          return.data$status <- 'Does not occur in Brazil OR Unknown distribution'
          return(return.data)
        }  
        else
        {
          index <- taxon$taxonID %in% x.taxonID & ifelse(infraspecificEpithet=='', TRUE, taxon$taxonRank != 'ESPECIE')        
          return.data <- taxon[index,]
          return.data$statusCode <- '8 - Condi��o inadequada de retorno'
          return.data$status <- 'name without resolution'
          return(return.data)
        }  
      }
      
      if (genus != "" & specificEpithet != "" & infraspecificEpithet == "") # esp�cie
      {index <- (paste0(genus, specificEpithet) == paste0(taxon$genus, taxon$specificEpithet)) & taxon$taxonRank == "ESPECIE"}  
      
      if (genus != "" & specificEpithet != "" & infraspecificEpithet != "") # subsp. e var.
      {index <- (paste0(genus, specificEpithet, infraspecificEpithet ) == paste0(taxon$genus, taxon$specificEpithet, taxon$infraspecificEpithet)) & taxon$taxonRank %in% c('VARIEDADE','SUB_ESPECIE', 'FORMA')}  
      
      name <- taxon[index,]
      if (NROW(name)>=2)
      {
        return.data$statusCode <- '9 - synonyms homonyms'
        return.data$status <- 'name without resolution'
        return(return.data)
      }  
      
      return.data$statusCode <- '0 - not found'
      return.data$status <- 'not found'
      return(return.data)
    }
    
    # quado sin�nimo, buscar pelo nome aceito
    if (name$taxonomicStatus %in% c("SINONIMO",""))
    {
      if (!is.na(name$acceptedNameUsageID))
      {
        index <- taxon$taxonID == name$acceptedNameUsageID
        return.data <- taxon[index,]
        return.data$statusCode <- '5.1 - replaced synonym'
        return.data$status <- 'updated synonym'
        
        ##manha - Begonia quetamensis
        if (NROW(return.data)==0)
        {
          return.data <- nameNA
          return.data$taxonomicStatus <- name$taxonomicStatus
          return.data$nomenclaturalStatus <- name$nomenclaturalStatus
          return.data$statusCode <- '2.1 - Name accepted (reported) not found or Does not occur in Brazil'
          return.data$status <- 'name without resolution'
        }
        
        if (return.data$taxonomicStatus %in% c("SINONIMO",""))
        {
          return.data <- nameNA
          return.data$taxonomicStatus <- name$taxonomicStatus
          return.data$nomenclaturalStatus <- name$nomenclaturalStatus
          return.data$statusCode <- '6.1 - Name accepted (reported) not is accepted'
          return.data$status <- 'name without resolution'
        }  

        return(return.data)
      }  
      else
      {
        if (NROW(name)==0)
        {
          return.data <- name
          return.data$statusCode <- '1 - synonym without accepted name resolution'
          return.data$status <- 'name without resolution'
          return(return.data)
        }
        else
        {  
          if (NROW(name)>=2)
          {
            index <- name$taxonomicStatus == "NOME_ACEITO"
            name <- name[index,]
          }  
          
          index <- resourcerelationship$id %in% name$taxonID
          x.relatedResourceID <- resourcerelationship[index, ]$relatedResourceID
          
          index <- taxon$taxonID == x.relatedResourceID
          name <- taxon[index, ]
          
          # Aegiphila medullosa
          if (NROW(name)==0)
          {
            return.data <- nameNA
            return.data$statusCode <- '1.1 - synonym without accepted name resolution'
            return.data$status <- 'name without resolution'
            return(return.data)
          }  
          else
          { 
            
            if (name$taxonomicStatus %in% c("SINONIMO",""))
            {
              if (NROW(name)>=2)
              {
                return.data <- nameNA
                return.data$statusCode <- paste0('4 - more than one synonym without accepted name resolution (',NROW(name),')')
                return.data$status <- 'name without resolution'
                return(return.data)
              }

              if (name$taxonomicStatus %in% c("SINONIMO",""))
              {
                if (is.na(name$acceptedNameUsageID))
                {
                  return.data <- nameNA
                  return.data$statusCode <- '1.2 - synonym without accepted name resolution'
                  return.data$status <- 'updated synonym'
                  return(return.data)
                }  
                else
                {
                  index <- taxon$taxonID == name$acceptedNameUsageID
                  return.data <- taxon[index,]
                  return.data$statusCode <- '5.2 - replaced synonym of synonym'
                  return.data$status <- 'updated synonym'
                  
                  
                  ##manha -  Ludwigia repens
                  if (NROW(return.data)==0)
                  {
                    return.data <- nameNA
                    return.data$taxonomicStatus <- name$taxonomicStatus
                    return.data$nomenclaturalStatus <- name$nomenclaturalStatus
                    return.data$statusCode <- '2.2 - Name accepted (reported) not found or Does not occur in Brazil'
                    return.data$status <- 'name without resolution'
                    
                  }  
                  
                  if (return.data$taxonomicStatus %in% c("SINONIMO",""))
                  {
                    return.data <- nameNA
                    return.data$taxonomicStatus <- name$taxonomicStatus
                    return.data$nomenclaturalStatus <- name$nomenclaturalStatus
                    return.data$statusCode <- '6.2 - Name accepted (reported) not is accepted'
                    return.data$status <- 'name without resolution'
                    
                  }  
                  return(return.data)
                }  
              } 
            }
            else
            {
              return.data <- name
              return.data$statusCode <- 'OK'
              return.data$status <- 'OK'
            }
          }
        }  
      }
    }
    else
    {
      return.data <- name
      return.data$statusCode <- 'OK'
      return.data$status <- 'OK'
    }  
  }
  else
  {
    return.data$statusCode <- 'empty'
    return.data$status <- 'empty'
  }
  
  #print(NROW(return.data))
  return(return.data)
  
}  

###---------------------------------------------------------------------###

nome.aceito.FloraBR2020 <- function(genus="", specificEpithet="" , infraspecificEpithet="")
{
  x = nome.aceito.FloraBR2020.base(genus, specificEpithet, infraspecificEpithet)
  x$statusDistribution <- "" 
  
  x$scientificNamewithoutAuthor <- ""
  x$scientificNamewithoutAuthorFull <- ""
  x$group <- ""
  
  if (x$statusCode == '7 - Does not occur in Brazil OR Unknown distribution')
  {
    x$statusDistribution <- 'Does not occur in Brazil OR Unknown distribution'
    return(x)
  } 

  if (is.na(x$id))
  {
    return(x)  
  }
  
  if (!is.na(nchar(x$acceptedNameUsage)>1)) { x$acceptedNameUsage <- iconv(x$acceptedNameUsage, to="latin1", from="utf-8")}  
  if (!is.na(nchar(x$parentNameUsage)>1)) { x$parentNameUsage <- iconv(x$parentNameUsage, to="latin1", from="utf-8")}  
  
  if (!is.na(nchar(x$higherClassification)>1))
  {
    x$higherClassification <- iconv(x$higherClassification, to="latin1", from="utf-8")
    x$group <-  strsplit(x$higherClassification,";")[[1]][2]
    x$scientificName <- iconv(x$scientificName, to="latin1", from="utf-8")
    x$scientificNameAuthorship <- iconv(x$scientificNameAuthorship, to="latin1", from="utf-8")
    x$bibliographicCitation <- iconv(x$bibliographicCitation, to="latin1", from="utf-8")
    
    if (x$group == 'Algas')
    {
      x$family <- paste0(x$class, ' (class)')
    }  
    
    if (x$group == 'Fungos')
    {
      x$family <- paste0(x$order, ' (order)')
    }  

  }else{
    x$group <- NA
  } 

  if (x$status %in% c('genus only', 'family only') )
  {
    if(x$taxonRank=="GENERO")
    {
      x$genus <- paste0(toupper(substr(x$genus,1,1)), tolower(substr(x$genus,2,nchar(x$genus))))
      x$scientificNamewithoutAuthor <- x$genus
      x$scientificNamewithoutAuthorFull <- x$genus
    }
    
    if(x$taxonRank=="FAMILIA")
    {
      x$family <- paste0(toupper(substr(x$family,1,1)), tolower(substr(x$family,2,nchar(x$family))))
      x$scientificNamewithoutAuthor <- x$family
      x$scientificNamewithoutAuthorFull <- x$family
    }
    x$statusDistribution <- ''
    return(x)
  } 
  
  x.distribution_sp <- distribution[distribution$id == x$taxonID, ]
  x.distribution_sub_var <- distribution[distribution$id %in% unique(taxon[taxon$parentNameUsageID == x$taxonID,]$taxonID),]
  
  if ( (NROW(x.distribution_sp) == 0) | (NROW(x.distribution_sub_var) == 0) )
  {
    if ( (x$nomenclaturalStatus %in% c("NOME_CORRETO","")) &   
         ( (NROW(x.distribution_sp) == 0) & (NROW(x.distribution_sub_var) == 0) ) )
    {
      x$statusDistribution <- 'Does not occur in Brazil OR Unknown distribution'
    } 
  }
  
  if(x$taxonRank=="ESPECIE")
  {
    x$scientificNamewithoutAuthor <- paste0(x$genus," ", x$specificEpithet)
    x$scientificNamewithoutAuthorFull <- paste0(x$genus," ", x$specificEpithet)
  }
  
  if(x$taxonRank=="VARIEDADE")
  {
    x$scientificNamewithoutAuthor <- paste0(x$genus," ", x$specificEpithet, " ", x$infraspecificEpithet)
    x$scientificNamewithoutAuthorFull <- paste0(x$genus," ", x$specificEpithet, " var. ", x$infraspecificEpithet)
  }
  
  if(x$taxonRank=="SUB_ESPECIE")
  {
    x$scientificNamewithoutAuthor <- paste0(x$genus," ", x$specificEpithet, " ", x$infraspecificEpithet)
    x$scientificNamewithoutAuthorFull <- paste0(x$genus," ", x$specificEpithet, " subsp. ", x$infraspecificEpithet)
  }
  
  if(x$taxonRank=="FORMA")
  {
    x$scientificNamewithoutAuthor <- paste0(x$genus," ", x$specificEpithet, " ", x$infraspecificEpithet)
    x$scientificNamewithoutAuthorFull <- paste0(x$genus," ", x$specificEpithet, " f. ", x$infraspecificEpithet)
  }
  return(x)
}

###---------------------------------------------------------------------###
confere.lista.FloraBR2020 <- function(genus,specificEpithet,infraspecificEpithet)
{
  
  x <- lx <- {}
  g=as.character(genus)
  s=as.character(specificEpithet)
  i=as.character(infraspecificEpithet)

  for (t in 1:length(g)){
    x=nome.aceito.FloraBR2020(g[t], s[t], i[t])
    lx = rbind(lx,x)
  }
  
  return(lx)
  
}  

###---------------------------------------------------------------------###
occurrenceRemarks.FloraBR2020 <-function(id=NA)
{  
  endemism = ""
  
  dominiofitogeografico.d  = data.frame(AtlanticRainforest=0,
                                        AmazonRainforest=0,
                                        Caatinga=0,
                                        CentralBrazilianSavanna=0,
                                        Pampa=0, 
                                        Pantanal=0) 
  # ingles
  # dominiofitogeografico.t  = c('Atlantic Rainforest',
  #                              'Amazon Rainforest',
  #                              'Caatinga',
  #                              'Central Brazilian Savanna',
  #                              'Pampa', 
  #                              'Pantanal') 
  
  # portugues
  dominiofitogeografico.t  = c('Mata Atl�ntica',
                               'Amaz�nia',
                               'Caatinga',
                               'Cerrado',
                               'Pampa', 
                               'Pantanal') 
  
  tipovegetacao.d  = data.frame(  AREA_ANTROPICA = 0,
                                  CAATINGA = 0,
                                  CAMPINARANA = 0,
                                  CAMPO_DE_ALTITUDE = 0,
                                  CAMPO_DE_VARZEA = 0,
                                  CAMPO_LIMPO = 0,
                                  CAMPO_RUPESTRE = 0,
                                  CARRASCO = 0,
                                  CERRADO = 0,
                                  FLORESTA_CILIAR_OU_GALERIA = 0,
                                  FLORESTA_DE_IGAPO = 0,
                                  FLORESTA_DE_TERRA_FIRME = 0,
                                  FLORESTA_DE_VARZEA = 0,
                                  FLORESTA_ESTACIONAL_DECIDUAL = 0,
                                  FLORESTA_ESTACIONAL_PERENIFOLIA = 0,
                                  FLORESTA_ESTACIONAL_SEMIDECIDUAL = 0,
                                  FLORESTA_OMBROFILA = 0,
                                  FLORESTA_OMBROFILA_MISTA = 0,
                                  MANGUEZAL = 0,
                                  PALMEIRAL = 0,
                                  RESTINGA = 0,
                                  SAVANA_AMAZONICA = 0,
                                  VEGETACAO_AQUATICA = 0,
                                  VEGETACAO_SOBRE_AFLORAMENTOS_ROCHOSOS = 0)  
  
  # ing
  # tipovegetacao.t  = c( "Anthropic area",
  #                       "Caatinga (stricto sensu)",
  #                       "Amazonian Campinarana",
  #                       "High Altitude Grassland",
  #                       "Flooded Field (V�rzea)",
  #                       "Grassland",
  #                       "Highland Rocky Field",
  #                       "Carrasco Vegetation",
  #                       "Cerrado (lato sensu)",
  #                       "Riverine Forest and/or Gallery Forest",
  #                       "Inundated Forest (Igap�)",
  #                       "Terra Firme Forest",
  #                       "Inundated Forest (V�rzea)",
  #                       "Seasonally Deciduous Forest",
  #                       "Seasonal Evergreen Forest",
  #                       "Seasonally Semideciduous Forest",
  #                       "Ombrophyllous Forest (Tropical Rain Forest)",
  #                       "Mixed Ombrophyllous Forest",
  #                       "Mangrove",
  #                       "Palm Grove",
  #                       "Coastal Forest (Restinga)",
  #                       "Amazonian Savanna",
  #                       "Aquatic vegetation",
  #                       "Rock outcrop vegetation")
  
  # portugues
  tipovegetacao.t  = c( "�rea Antr�pica",
                        "Caatinga (stricto sensu)",
                        "Campinarana",
                        "Campo de Altitude",
                        "Campo de V�rzea",
                        "Campo Limpo",
                        "Campo Rupestre",
                        "Carrasco",
                        "Cerrado (lato sensu)",
                        "Floresta Ciliar ou Galeria",
                        "Floresta de Igap�",
                        "Floresta de Terra Firme",
                        "Floresta de V�rzea",
                        "Floresta Estacional Decidual",
                        "Floresta Estacional Perenif�lia",
                        "Floresta Estacional Semidecidual",
                        "Floresta Ombr�fila (= Floresta Pluvial)",
                        "Floresta Ombr�fila Mista",
                        "Manguezal",
                        "Palmeiral",
                        "Restinga",
                        "Savana Amaz�nica",
                        "Vegeta��o Aqu�tica",
                        "Vegeta��o Sobre Afloramentos Rochosos")

  o <- id == distribution$id
  or <- distribution[o,]

  if ((nrow(or)>0) & (or$occurrenceRemarks[1] != "{}")) {
    x = or$occurrenceRemarks[1]
    Encoding(x) = "UTF-8"
    
    x = gsub('\\"|\\{|\\}',
             "",
             x)
    x2 = strsplit(x,':')[[1]]
    
    # ajuste necess�rio para endemismos desconhecidos
    if (x2[1]!='phytogeographicDomain') {
      endemism = gsub('\\[|\\]', "", strsplit(x2[2],',')[[1]][1]) 
      
      phytogeographicDomain =  strsplit( gsub('\\[', "", strsplit(x2[3],']')[[1]][1]),',')[[1]] 
      d2 <-  dominiofitogeografico.t %in% phytogeographicDomain
      dominiofitogeografico.d[1,d2] <- 1
      
      # vegetationType =  strsplit( gsub('\\[', "", strsplit(x2[4],']')[[1]][1]),',')[[1]] 
      # d2 <- tipovegetacao.t %in%  vegetationType
      # tipovegetacao.d[1,d2] <- 1
    } else {
      
      #endemism = 'unknown' 
      
      endemism = 'It does not occur in Brazil' 
      
      phytogeographicDomain =  strsplit( gsub('\\[', "", strsplit(x2[2],']')[[1]][1]),',')[[1]] 
      d2 <-  dominiofitogeografico.t %in% phytogeographicDomain
      dominiofitogeografico.d[1,d2] <- 1
      
      # vegetationType =  strsplit( gsub('\\[', "", strsplit(x2[3],']')[[1]][1]),',')[[1]] 
      # d2 <- tipovegetacao.t %in%  vegetationType
      # tipovegetacao.d[1,d2] <- 1
      
    }
      
    
    o2 <- id == speciesprofile$id
    or2 <- speciesprofile[o2,]
    
    x = gsub('\\"|\\{|\\}',
             "",
             or2)
    x2 = strsplit(x,':')[[2]]
    
    vegetationType =  strsplit( gsub('\\[', "", strsplit(x2[4],']')[[1]][1]),',')[[1]] 
    d2 <- tipovegetacao.t %in%  vegetationType
    tipovegetacao.d[1,d2] <- 1
    
    
    
  }
  
  
  endemismo = data.frame(endemism)
  dominiofitogeografico = data.frame(dominiofitogeografico.d)
  tipovegetacao = data.frame(tipovegetacao.d)
  
  occurrenceRemarks <- list(endemismo = endemismo,
                            dominiofitogeografico = dominiofitogeografico,
                            tipovegetacao = tipovegetacao)
  
  return(occurrenceRemarks)
  
}  

###---------------------------------------------------------------------###

