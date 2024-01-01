#!/usr/bin/Rscript 

# rodar assim:
# Rscript script-mm-starpupython.R teste-starpu-mm

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
        tamanho <- arq[5]
        threads <- gsub(".txt", "", arq[7])       
        linhaTempo <- grep("Tempo:", readLines(x), value = TRUE)
        tempo <- (strsplit(linhaTempo, split = " ", fixed = TRUE) %>% unlist)[3]
        tibble(
            App = app,
            Caso = caso, 
            Repeticao = as.integer(rep),
            Threads = as.integer(threads),
            Matriz = tamanho, 
            ##     NMatriz = Nmat,
            ##     NBloco = Nbloco,
            Tempo = as.numeric(tempo),
            Origem = x)
        }) %>% bind_rows -> dados

## # aqui eh pra calcular a media
dados %>%
     select(-Origem) %>% 
    group_by(App, Caso, Threads, Matriz
           # , NMatriz, NBloco
             ) %>%
     summarize(Media = mean(Tempo), SD = sd(Tempo), N = length(unique(Repeticao))) %>% write.csv("media-mm-starpu.csv")

## # aqui eh o grafico (se quiser procura por ggsave)
grafico <- ggplot(dados, aes(y = Tempo, x = Threads, color = Caso)) +
    geom_point(alpha = .5, size = 4, position = position_jitter(width = 0.2, height = 0)) + 
    facet_wrap(~Matriz, scales = "free") + 
    ylim(c(0, NA)) +
    theme_bw(base_size = 16) + guides(color = FALSE)

ggsave("grafico-mm-starpu.pdf", plot = grafico, width = 8, height = 4, units = "in")
