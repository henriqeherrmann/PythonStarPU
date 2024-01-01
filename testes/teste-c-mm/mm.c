// adaptado de http://inf.ufrgs.br/gppd/intel-modern-code/slides/workshop-29/material.zip

// compilar com: gcc mm.c -o mm -fopenmp
// executar: OMP_NUM_THREADS=4 ./mm 1024

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <malloc.h>
#include <time.h>

void matrix_mult(double *A, double *B, double *C, int N);

int main(int argc, char **argv){
  char *awnser[] = { "bad", "ok" };
  
  int i, j, n, is_ok;
  
  if(argc != 2){
    fprintf(stderr, "Usage: %s <size>\n", argv[0]);
    exit(EXIT_FAILURE);
  }
  
  n = atoi(argv[1]);
  
  n = n % 8 == 0 ? n : n + (8 - n % 8);
  
  /*printf("number of rows x cols: %i\n", n);*/
  
  double *A = malloc(n * n * sizeof(double));
  assert(A != NULL);
  
  double *B = malloc(n * n * sizeof(double));
  assert(B != NULL);
  
  double *C = malloc(n * n * sizeof(double));
  assert(C != NULL);
  
  for(i = 0; i < n; i++)
    for(j = 0; j < n; j++){
      A[i * n + j] = 1; /* Do not */
      B[i * n + j] = 1; /* change */
      C[i * n + j] = 0; /* it */
    }
  
  clock_t start = clock();
  matrix_mult(A, B, C, n);
  clock_t end = clock();
  
  double elapsed = ((double) (end - start)) / CLOCKS_PER_SEC;
  
  is_ok = 1;	
  for(i = 0; i < n; i++)
    for(j = 0; j < n; j++)
      if(C[i * n + j] != (double) n){
	is_ok = 0;
	i = n;
	j = n;
      }
  
  printf("time: %.3f seconds\n", elapsed); 
  
  free(A);
  free(B);
  free(C);
  
  return 0;
}

void matrix_mult(double *A, double *B, double *C, int N){
	int i, j, k;
	for(i = 0; i < N; i++)
	  for(j = 0; j < N; j++)
	    for(k = 0; k < N; k++)
	      C[i * N + j] += A[i * N + k] * B[k * N + j];
}
