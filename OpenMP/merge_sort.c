#include<stdlib.h>
#include<stdio.h>
#include <sys/time.h>

#define TEMPO_DESDE_INICIO ((double)( (fim.tv_sec - inicio.tv_sec) + (fim.tv_usec - inicio.tv_usec)*1e-6 ))
#define MIN_PAR 1000

int esta_ordenado(int* vec, int s){
  for(int i = 0; i < s - 1; i++)
    if(vec[i] > vec[i+1]) 
      return 0;
  return 1;
}

void merge(int* v, int n) {
  //printf("merge tam: %d --  thread %d\n", n, omp_get_thread_num());
    int m;
    int i, j, k;
    int* tmp;
    tmp = (int*) malloc(n * sizeof (int));
    if (tmp == NULL) {
        exit(1);
    }
    j = m = n / 2;
    k = i = 0;
    while (i < m && j < n) {
        if (v[i] < v[j]) {
            tmp[k++] = v[i++];
        } else {
            tmp[k++] = v[j++];
        }
    }
    if (i == m) {
        while (j < n) {
            tmp[k++] = v[j++];
        }
    } else {
        while (i < m) {
            tmp[k++] = v[i++];
        }
    }
    for (i = 0; i < n; ++i) {
        v[i] = tmp[i];
    }
    free(tmp);
}

void merge_sort(int vetor[], int tam) {
  int metade = tam / 2;            
  if (tam > 1) {        
    #pragma omp task if(metade > MIN_PAR) untied
    merge_sort(vetor, metade);
    #pragma omp task if(metade > MIN_PAR) untied
    merge_sort(vetor + metade, tam - metade);
    #pragma omp taskwait
    merge(vetor, tam);
  }
  return;
}


int main(int argc, char *argv[]) {
  struct timeval inicio, fim;
  if(argc != 2){
    printf("Erro, use: %s <tamanho do vetor>\n", argv[0]);
    exit(1);
  }
  int tamanho = atoi(argv[1]);  
  int * vetor = (int*) malloc(tamanho * sizeof (int));
  for ( int i = 0; i < tamanho; i++)
    vetor[i] = rand();

  printf("Ordernando...\n");

  gettimeofday(&inicio, 0);
  #pragma omp parallel
  #pragma omp single  
  merge_sort(vetor, tamanho);
  gettimeofday(&fim, 0);

  if(esta_ordenado(vetor, tamanho)){
    printf("\tEsta ordenado!\n");
    printf("tempo: %lf\n", TEMPO_DESDE_INICIO);    
  } else
    printf("\tNao esta ordenado!\n");
  
  free(vetor);
  return 0;
}

