# загрузка пакетов
library('R.utils')               # gunzip() для распаковки архивов 
library('dismo')                 # gmap() для загрузки Google карты
library('raster')                # функции для работы с растровыми картами в R
library('maptools')              # инструменты для создания картограмм
library('sp')                    # функция spplot()
library('RColorBrewer')          # цветовые палитры
require('rgdal')                 # функция readOGR()
require('plyr')                  # функция join()
library('ggplot2')               # функция ggplot()
library('scales')                # функция pretty_breaks()
library('mapproj')
library('data.table')

#ссылка на файл
ShapeFileURL <- "http://biogeo.ucdavis.edu/data/gadm2.8/shp/RUS_adm_shp.zip"

#создаём директорию и скачиваем файл
if(!file.exists('/stat')) dir.create('./stat')
if (!file.exists('./stat/RUS_adm_shp.zip')){
  download.file(ShapeFileURL,
                destfile = './stat/RUS_adm_shp.zip')
}

#распаковать архив
unzip('./stat/RUS_adm_shp.zip', exdir = './stat/RUS_adm_shp')
#список файлов
dir('./stat/RUS_adm_shp')

# прочитать данные уровня 1
Regions <- readShapePoly('./stat/RUS_adm_shp/RUS_adm1.shp')

# слот "данные"
Regions@data

df <- data.table(Regions@data)

# делаем фактор из имён областей (т.е. нумеруем их)
Regions@data$NAME_1 <- as.factor(Regions@data$NAME_1 )

# строим картограмму
spplot(Regions, 'NAME_1', scales = list(draw = T), col.regions = rainbow(n = 85))

# вариант с палитрой из пакета ColorBrewer и без координатной сетки
spplot(Regions, 'NAME_1', col.regions = brewer.pal(85, 'Set3'),
       par.settins = list(axis.line = list(col = NA)))

#загружаем данные с gks
library(XML)
fileURL1 <- 'http://www.gks.ru/free_doc/new_site/vvp/vrp98-15.xlsx'
if(!file.exists('./stat')) dir.create('./stat')
if(!file.exists('./stat/vrp98-15.xlsx')) {
  download.file(fileURL1,
                './stat/vrp98-15.xlsx')
}

fileURL2 <- 'http://www.gks.ru/free_doc/new_site/vvp/dusha98-15.xlsx'
if(!file.exists('./stat/vrp_dusha98-15.xlsx')) {
  download.file(fileURL2,
                './stat/vrp_dusha98-15.xlsx')
}

# обработка файлов вне R и сохранение в .csv
#открываем изменённый файл и продолжаем работу с ним
stat.Region <- read.csv('./stat/GRP.csv', 
                         sep = ',', dec = '.', as.is = T)

# вносим данные в файл карты
Regions@data <- merge(Regions@data, stat.Region,
                       by.x = 'NAME_1',
                       by.y = 'Region')

# задаём палитру-градиент
mypalette <- colorRampPalette(c('white', 'navyblue'))

# строим картограмму ВРП
spplot(Regions, 'GVP',
       col.regions = mypalette(20),
       col = 'black',
       par.settings = list(axis.line = list(col = NA)))

# то же - с названиями областей
spplot(Regions, 'GVP',
       col.regions = mypalette(20),
       col = 'black',
       main = 'ВРП, млн.руб.',
       panel = function(x, y, z, subscripts, ...){
         panel.polygonsplot(x, y, z, subscripts, ...)
         sp.text(coordinates(Regions),
                 Regions$NAME_1[subscripts], cex = 0.3)
       } )

#вторая карта
# строим картограмму ВРП на душу населения
spplot(Regions, 'GVP.D',
       col.regions = mypalette(20),
       col = 'black',
       par.settings = list(axis.line = list(col = NA)))


# то же - с названиями областей
spplot(Regions, 'GVP.D',
       col.regions = mypalette(20),
       col = 'black',
       main = 'ВРП на душу населения, млн.руб.',
       panel = function(x, y, z, subscripts, ...){
         panel.polygonsplot(x, y, z, subscripts, ...)
         sp.text(coordinates(Regions),
                 Regions$NAME_1[subscripts], cex = 0.3)
       })
