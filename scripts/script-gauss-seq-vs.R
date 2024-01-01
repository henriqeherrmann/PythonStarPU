#!/usr/bin/Rscript 

# rodar assim:
# Rscript script-gauss-seq-vs.R teste-openmp-gauss/ teste-starpu-gauss/

args <- commandArgs(trailingOnly = TRUE)
diretorioC <- args[1]
diretorioPython <- args[2]

library(dplyr)
library(ggplot2)
options(crayon.enabled = FALSE)

                                        # diretorio = "./"
lapply(
grep("-a-", list.files(path = diretorioC, pattern = "result*", full.names=TRUE, recursive = TRUE), fixed = TRUE, value = TRUE),   # lista todos que comecam com result
    function(x){
        # print(basename(x))
        arq <- strsplit(basename(x), split="-", fixed=TRUE) %>% unlist # quebra o nome do arquivo por -
        app <- arq[2]
        rep <- arq[3]
        caso <- arq[4]
        tamanho <- arq[5]
        threads <- gsub(".txt", "", arq[7])       
        linhaTempo <- grep("SEQUENTIAL", readLines(x), value = TRUE)
        # print(">>>")
        # print(linhaTempo)
        tempo <- gsub(" ", "", gsub("ms", "", (strsplit(linhaTempo, split = "=", fixed = TRUE) %>% unlist)[2]))
        # print(tempo)
        tibble(
            App = app,
            Caso = caso, 
            Repeticao = as.integer(rep),
            Threads = as.integer(threads),
            Matriz = tamanho, 
            ##     NMatriz = Nmat,
            ##     NBloco = Nbloco,
            Tempo = as.numeric(tempo),
            Origem = x) # %>% print
        }) %>% bind_rows -> dadosC

lapply(
grep("-a-", list.files(path = diretorioPython, pattern = "result*", full.names=TRUE, recursive = TRUE), fixed = TRUE, value = TRUE),   # lista todos que comecam com result
    function(x){
        # print(basename(x))
        arq <- strsplit(basename(x), split="-", fixed=TRUE) %>% unlist # quebra o nome do arquivo por -
        app <- arq[2]
        rep <- arq[3]
        caso <- arq[4]
        tamanho <- arq[5]
        threads <- gsub(".txt", "", arq[7])
        
        linhaTempo <- grep("sequential", readLines(x), value = TRUE)
        tempo <- gsub(" ", "", (strsplit(linhaTempo, split = ":", fixed = TRUE) %>% unlist)[2]) # esse tem dois espacos
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
        }) %>% bind_rows -> dadosPython

# dividindo o tempo em C por 1000 pra passar pra segundos
bind_rows(dadosC %>% mutate(Tempo = Tempo/1000), dadosPython) %>% filter(Threads == 1) -> dados

## # aqui eh pra calcular a media
dados %>%
     select(-Origem) %>% 
    group_by(App, Caso, Threads, Matriz
           # , NMatriz, NBloco
             ) %>%
     summarize(Media = mean(Tempo), SD = sd(Tempo), N = length(unique(Repeticao))) %>% write.csv("media-gauss-c-vs-python.csv")

## # aqui eh o grafico (se quiser procura por ggsave)
grafico <- ggplot(dados, aes(y = Tempo, x = Caso, color = Caso)) +
    geom_point(alpha = .5, size = 4, position = position_jitter(width = 0.2, height = 0)) + 
    facet_wrap(~Matriz, scales = "free") + 
    ylim(c(0, NA)) +
    theme_bw(base_size = 16) + guides(color = FALSE)

ggsave("grafico-gauss-c-vs-python.pdf", plot = grafico, width = 8, height = 4, units = "in")
