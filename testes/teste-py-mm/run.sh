!/bin/bash

REPETICOES=5
versao="pythonmmpuro"

source ~/spack/share/spack/setup-env.sh
spack load py-pip
source `spack location -i starpu@1.4.1`/bin/starpu_env

# por aqui os spack load que tu precisas
for sz in "a"  "b"; do # seria bom definirmos pelo menos dois tamanhos de entrada
    for app in "mm"; do  # app (incluir as outras aqui)
	#for nt in "1" "2" "4" "8" "16" "32" ; do # Numero de Threads
		nt=1
	    for rep in `seq $REPETICOES`; do  # repeticoes
		echo "Rodando $app com $nt threads repeticao $r"
		runline=" "
		#runline+="STARPU_NCPU=$nt python3 "
		runline+="python3 "
		if [ $app == "fib" ]; then
		    echo "nao temos essa app ainda"
		    continue;
		elif [ $app == "mm" ]; then
		    runline+="mm.py "
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
