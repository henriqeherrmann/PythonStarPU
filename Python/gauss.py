import time

def sequential_gauss_seidel_relaxation(a, b, n, niter):
    h = 1.0/(n-3)
    h2 = h*h
    for k in range(niter):
        for i in range(1, n-1):
            for j in range(1, n-1):
                a[i][j] = 0.25*(a[i+1][j]+a[i-1][j]+a[i][j+1]+a[i][j-1]-h2*b[i])

def gauss_seidel_relaxation_tasks_block(a: list, b, n, niter, ts):
    h = 1.0/(n-3)
    h2 = h*h
    for k in range(niter):
        for ii in range(1, n-ts, ts):
            for jj in range(1, n-ts, ts):
                gauss(ii, jj, ts, a, b, h2)

def gauss(ii, jj, ts, a, b, h2):
    for i in range(ii, ii+ts):
        for j in range(jj, jj+ts):
            a[i][j] = 0.25*(a[i+1][j]+a[i-1][j]+a[i][j+1]+a[i][j-1]-h2*b[i])

def init_A_b(a: list, b: list, n):
    print(n)
    for i in range(n):
        linha = []
        for j in range(n):
            if (j+i) % 2 == 0:
                linha.append(1.0)
            else:
                linha.append(10.0)
        a.append(linha)
        b.append(1.0)

def parameters_check(n, niter, bs, ibs):
    if n % bs != 0:
        print("Parameter ERROR")
    elif niter < 0:
        print("Parameter ERROR")
    elif ibs > 0 and bs % ibs != 0:
        print("Parameter ERROR")

def test_mat_result(asequential, aparallel, n):
    for i in range(n):
        for j in range(n):
            if asequential[i][j] != aparallel[i][j]:
                print("FAILED")
                return
    print("PASSED")

def main():
    n = 3600
    niter = 100
    bs = 720
    ibs = 8
    parameters_check(n, niter, bs, ibs)
    n = n+2
    aseq = [] * n
    a1 = [] * n
    b = [] * n
    init_A_b(aseq, b, n)
    init_A_b(a1, b, n)
    inicio: float = time.time()
    sequential_gauss_seidel_relaxation(aseq, b, n, niter)
    gauss_seidel_relaxation_tasks_block(a1, b, n, niter, bs)
    final: float = time.time()
    test_mat_result(aseq, a1, n)
    tempo: float = final - inicio
    print("Tempo: ", tempo)

main()