import random
import time 
import starpu
import asyncio

starpu.init()
def esta_ordenado(vec):
    for i in range(len(vec) - 1):
        if vec[i] > vec[i + 1]:
            return 0
    return 1

def merge(v, e, d):
    j = k = i = 0
    while i < len(e) and j < len(d):
        if e[i] < d[j]:
            v[k] = e[i]
            i += 1
        else:
            v[k] = d[j]
            j += 1
        k += 1
    while j < len(d):
        v[k] = d[j]
        k += 1
        j += 1
    while i < len(e):
        v[k] = e[i]
        k += 1
        i += 1

def merge_sort(vetor, tamanho):
    metade = tamanho // 2
    if tamanho > 1:
        e = vetor[:metade]
        d = vetor[metade:]
        starpu.task_submit()(merge_sort, e, metade)
        starpu.task_submit()(merge_sort, d, tamanho-metade)
        starpu.task_submit()(merge,vetor, e, d)


async def main(argv: int):
    tamanho = argv
    vetor = []
    for _ in range(0, tamanho):
        vetor.append(random.randint(0, 32767))
    #print("Vetor não ordenado: ", vetor)
    tamanho = len(vetor)
    print("Ordenando...\n")
    inicio = time.time()
    starpu.task_submit()(merge_sort, vetor, tamanho)
    final = time.time()
    tempo = final - inicio
    if esta_ordenado(vetor):
        print("Esta ordenando!\n")
    else:
        print("Não está ordenado\n")
    print("Tempo: ", tempo) 



#mainfunc = main(10)
#main(10)
asyncio.run(main(100000000))
#asyncio.run(mainfunc)
# loop = asyncio.get_event_loop()
# loop.create_task(main(10))
# loop.
# loop.run_in_executor(None, lambda: main(10))
# asyncio.create_task(main(10))
starpu.shutdown()