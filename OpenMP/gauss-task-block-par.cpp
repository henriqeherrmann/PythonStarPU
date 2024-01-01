#include <iostream>
#include <chrono>
#include <omp.h>
using namespace std::chrono;

// Instructions:
// Compile: g++ -o gs Gauss-Seidel.cpp -O3 -fopenmp
// Run ./gs < input
// or use make-run with the makefile
// The input file content:
// 3600 (Size N of the matrix)
// 100 (Numer of GS iterations Niter)
// 720 (Task tile size)
// 8 (Internal Task tile size)

/* given a system of equations Ax = b:
 * A is the input matrix
 * b is the solution vector
 * N is the size of A[n][n] and length of b[n]
 */
void sequential_gauss_seidel_relaxation(double **A, double* b, int N, int Niter)
{
	int i, j, k;
	double  h, h2;

	h = 1.0/(N-2-1);
	h2 = h*h;

	for(k=0; k<Niter; ++k) {
		for (i=1; i<N-1; ++i) {
			for (j=1; j<N-1; ++j) {
				// The Gauss-Seidel smoothing formula for two dimensions
				A[i][j] = 0.25 * (	A[i+1][j] +  	// down
									A[i-1][j] +  	// up
									A[i][j+1] +  	// right
									A[i][j-1] -  	// left
								 	h2*b[i]
								 ); 
			}
		}
	}
}


/* given a system of equations Ax = b:
 * A is the input matrix
 * b is the solution vector
 * N is the size of A[n][n] and length of b[n]
 * Niter is the number of repetitions of the Gauss-Seidel algorithm over the matrix
 * TS is the tile size
 */
void gauss_seidel_relaxation_tasks_block(double **A, double* b, int N, int Niter, int TS)
{
	int ii, jj, i, j, k;
	int NB = N / TS; // Number of blocks

	double  h, h2;
	h = 1.0/(N-3);
	h2 = h*h;

	#pragma omp parallel
	{
		#pragma omp single
		{
			for(k=0; k<Niter; ++k) {
				// loop over blocks
				for (ii=1; ii<N-TS; ii+=TS) {
					for (jj=1; jj<N-TS; jj+=TS) {
						#pragma omp task \
						depend(in: \
						A[ii+TS:1][jj:TS], \
						A[ii-1:TS][jj:TS], \
						A[ii:TS][jj-1:TS], \
						A[ii:TS][jj+TS:1]) \
						depend(out: A[ii:TS][jj:TS]) \
						firstprivate(ii, jj)
						{
							// printf("blk_i_start = %d, blk_j_start = %d\n", blk_i_start, blk_j_start);
							// loop inside a block
							for(int i=ii; i<ii+TS; ++i) {
								for(int j=jj; j<jj+TS; ++j) {
									// printf("%d %d\n", i, j);
									// The Gauss-Seidel smoothing formula for two dimensions
									A[i][j] = 0.25 * (	A[i+1][j] +  	// down
														A[i-1][j] +  	// up
														A[i][j+1] +  	// right
														A[i][j-1] -  	// left
													 	h2*b[i]
													 ); 
								}
							}
						}
					}
				}
			}
		}
	}
}


void print_mat(double **A, int N) 
{
	printf("Print matrix A:\n");
	for (int i = 0; i < N; ++i)
	{
		for (int j = 0; j < N; ++j)
		{
			printf("%lf ", A[i][j]);
		}
		printf("\n");
	}
	printf("\n");
}

// Init matrix a with 1 or 10 and vector b with 1
void init_A_b(double **A, double* b, int N) 
{
	for (int i = 0; i < N; ++i) {
		for (int j = 0; j < N; ++j) {
			A[i][j] = (j+i) % 2 == 0 ? 1.0 : 10.0;
		}
		b[i] = 1.0;
	}
}

// Check if the matrix produced by a parallel version identical to the sequential version
void test_mat_result(double **A_sequential, double ** A_parallel, int N)
{
	for (int i = 0; i < N; ++i)
	{
		for (int j = 0; j < N; ++j)
		{
			if(A_sequential[i][j] != A_parallel[i][j]){

 				printf("\033[1;31m[test] FAILED!\033[0m Matrices different at = [%d][%d] -> %lf != %lf\n", i, j, A_sequential[i][j], A_parallel[i][j]);
				return;
			}
		}
	}
	printf("\033[1;32m[test] PASSED!\033[0m Matrices are identical!\n");
}

void parameters_check(int N, int Niter, int BS, int IBS) {
	if(N%BS != 0){
		printf("[Parameter Error] BS and N must be multiples!\n");
		exit(1);
	} else if(Niter < 0) {
		printf("[Parameter Error] Niter must be positive!\n");
		exit(1);
	} else if(IBS > BS || BS%IBS != 0) {
		printf("[Parameter Error] IBS and BS must be multiples & IBS <= BS!\n");
		exit(1);
	}
}

int main(int argc, char const *argv[])
{
	// omp_set_num_threads(4);
	int N, Niter, BS, IBS;

	printf("\nEnter the matrix dimension N: ");
	std::cin >> N;
	printf("Enter the number of iterations Niter: ");
	std::cin >> Niter;
	printf("Enter the block size: ");
	std::cin >> BS;
	printf("Enter the inner block size: ");
	std::cin >> IBS;
	printf("Matrix size = %d+2, iterations = %d, Block size = %d, Inner block size = %d\n", N, Niter, BS, IBS);
	parameters_check(N, Niter, BS, IBS);
	N=N+2; // Add +2 to make the matrix borders (something like ghost cells)

	// initialize matrix A and rhs b
	double** A_seq, **A1;
	double* b;

	A_seq = (double**) malloc((N)*sizeof(double*));
	A1 = (double**) malloc((N)*sizeof(double*));
	b = (double*) malloc((N)*sizeof(double));
	
	for(int i=0; i<N; ++i) {
		A_seq[i] = (double*) malloc((N)*sizeof(double));
		A1[i] = (double*) malloc((N)*sizeof(double));
	}

	init_A_b(A_seq, b, N);
	auto start = high_resolution_clock::now(); 
	sequential_gauss_seidel_relaxation(A_seq, b, N, Niter);
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<microseconds>(stop - start); 
	printf("Duration SEQUENTIAL = %ldms\n", duration.count()/1000); 
	// print_mat(A_seq, N);

	init_A_b(A1, b, N);
	start = high_resolution_clock::now(); 
	gauss_seidel_relaxation_tasks_block(A1, b, N, Niter, BS);
	stop = high_resolution_clock::now();
	duration = duration_cast<microseconds>(stop - start); 
	test_mat_result(A_seq, A1, N);
	printf("Duration TASK BLOCK PARALLEL = %ldms\n", duration.count()/1000); 
	// print_mat(A1, N);

	return 0;
}
