import time

def m_interno(a, b, c, n, i):
    #print("estamos no i valendo ", i)
    for j in range(n):
        for k in range(n):
            c[i*n+j] += a[i*n+k] * b[k*n+j]

def imprime(c, n):
    for i in range(n):
        for j in range(n):
            print(c[i*n+j], end = " ")
        print("\n")
         

def matrix_mult(a, b, c, n):
    for i in range(n):
        # starpu task submit
        m_interno(a, b, c, n, i)
        
                
def main(argc):
    n: int = argc
    resposta = ["bad", "ok"]
    is_ok = 1
    if n % 8 == 0:
        n = n
    else:
        n= n + (8 - n % 8)
    a: float = [0] * (n*n)
    b: float = [0] * (n*n)
    c: float = [0] * (n*n)
    for i in range(n):
        for j in range(n):
            a[i*n+j] = 1
            b[i*n+j] = 1
            c[i*n+j] = 0
    #imprime(a, n)
    #imprime(b, n)
    inicio: float = time.time()
    matrix_mult(a, b, c, n)
    final: float = time.time()
    tempo: float = final - inicio
    print("Tempo: ", tempo)
    is_ok = 1
    for i in range(n):
        for j in range(n):
            if c[i*n+j] != n:
                is_ok = 0
                i = n
                j = n
    print("Resultado: ", resposta[is_ok])
    #imprime(c, n)
if __name__ == "__main__":
    main(argc=1024)