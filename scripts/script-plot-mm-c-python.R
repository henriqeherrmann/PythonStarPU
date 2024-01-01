#!/usr/bin/Rscript 
args <- commandArgs(trailingOnly = TRUE)
diretorio <- args[1]

library(dplyr)
library(ggplot2)
options(crayon.enabled = FALSE)

                                        # diretorio = "./"
lapply(
list.files(path = diretorio, pattern = "result*", full.names=TRUE, recursive = TRUE),   # lista todos que comecam com result
    function(x){
        print(basename(x))
        arq <- strsplit(basename(x), split="-", fixed=TRUE) %>% unlist # quebra o nome do arquivo por -
        app <- arq[2]
        rep <- arq[3]
        caso <- arq[4]
        threads <- gsub(".txt", "", arq[6])
        
        linhaTempo <- grep("Tempo:", readLines(x), value = TRUE)
        tempo <- (strsplit(linhaTempo, split = ":", fixed = TRUE) %>% unlist)[2]
        tibble(
            App = app,
            Caso = caso, 
            Repeticao = as.integer(rep),
            Threads = as.integer(threads),
            ##     NMatriz = Nmat,
            ##     NBloco = Nbloco,
            Tempo = as.numeric(tempo),
            Origem = x)
        }) %>% bind_rows -> dados

## # aqui eh pra calcular a media
dados %>%
     select(-Origem) %>% 
    group_by(App, Caso, Threads
           # , NMatriz, NBloco
             ) %>%
     summarize(Media = mean(Tempo), SD = sd(Tempo), N = length(unique(Repeticao))) %>% write.csv("media.csv")

## # aqui eh o grafico (se quiser procura por ggsave)
ggplot(dados, aes(y = Tempo, x = Threads, color = Caso)) +
    geom_point(alpha = .5) + 
    # facet_wrap(~NMatriz+NBloco, scales = "free") + 
    ylim(c(0, NA)) +
    theme_bw()
