import time 

def func_cpu(block_width, a, b, c):
    for i in range(block_width):
        for j in range(block_width):
            for k in range(block_width):
                c[j*block_width+i] +=a[j*block_width+k]*b[k*block_width+i]

def main():
    matrix_width = 100
    block_width = 20
    block_total_size = block_width*block_width
    number_blocks_width = matrix_width//block_width
    number_blocks = number_blocks_width*number_blocks_width
    matrix_a: float = []
    matrix_b: float = []
    matrix_c: float = []

    for i in range(number_blocks):
        matrix_a.append([0] * block_width*block_width)
        matrix_b.append([0] * block_width*block_width)
        matrix_c.append([0] * block_width*block_width)
    bi: int = 0
    by: int = 0
    ci: int = 0
    cy: int = 0
    for i in range(matrix_width):
        for y in range(matrix_width):
            bi: int = i//block_width
            by: int = y//block_width
            ci: int = i%block_width
            cy: int = y%block_width
            matrix_a[by*number_blocks_width+bi][cy*block_width+ci] = 1
            matrix_b[by*number_blocks_width+bi][cy*block_width+ci] = 2
            matrix_c[by*number_blocks_width+bi][cy*block_width+ci] = 0
    inicio: float = time.time()
    for i in range(number_blocks_width):
        for j in range(number_blocks_width):
            for k in range(number_blocks_width):
                func_cpu(block_width, matrix_a[j*number_blocks_width+k], matrix_b[k*number_blocks_width+i], matrix_c[j*number_blocks_width+i])
    final: float = time.time()
    tempo: float = final - inicio
    print("Tempo: ", tempo)

    for i in range(matrix_width):
        for y in range(matrix_width):
            bi = i//block_width
            by = y//block_width
            ci = i%block_width
            cy = y%block_width
            #print(matrix_c[by * number_blocks_width + bi][cy * block_width + ci])


main()