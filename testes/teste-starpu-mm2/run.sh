!/bin/bash

REPETICOES=5
versao="StarPUmm"

source ~/spack/share/spack/setup-env.sh
spack load py-pip@23.1.2%gcc@12.1.0 arch=linux-centos7-x86_64_v3

# por aqui os spack load que tu precisas
for sz in "a"; do # seria bom definirmos pelo menos dois tamanhos de entrada
    for app in "mm2"; do  # app (incluir as outras aqui)
	for nt in "1" "2" "4" "8" "16" "32" ; do # Numero de Threads
	    for rep in `seq $REPETICOES`; do  # repeticoes
		echo "Rodando $app com $nt threads repeticao $r"
		runline=" "
		runline+="STARPU_NCPU=$nt LD_LIBRARY_PATH=`spack location -i starpu`/lib ./"
		if [ $app == "fib" ]; then
		    echo "nao temos essa app ainda"
		    continue;
		elif [ $app == "mm2" ]; then
			runline+="mm2 "
		else
		    echo "erro app desconhecida"
		    continue;
		fi
		echo "runline vale $runline"
		flout="result-$app-$rep-$versao-$sz-Threads-$nt.txt"
		flerr="err-$app-$rep-$versao-$sz-Threads-$nt.txt"
		runline+="> $flout 2> $flerr"
		date
		echo "Executando << $runline >>"
		eval $runline
		cat $flout
		cat $flerr
	    done;
	done;
    done;
done;
