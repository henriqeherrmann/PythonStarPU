!/bin/bash

REPETICOES=5
versao="cmmpuro"

source ~/spack/share/spack/setup-env.sh

# por aqui os spack load que tu precisas
for sz in "a" ; do # seria bom definirmos pelo menos dois tamanhos de entrada
    for app in "mm"; do  # app (incluir as outras aqui)
	#for nt in "1" "2" "4" "8" "16" "32" ; do # Numero de Threads
	    for rep in `seq $REPETICOES`; do  # repeticoes
		nt=1
		echo "Rodando $app com $nt threads repeticao $r"
		runline=" "
		#runline+="OMP_NUM_THREADS=$nt ./"
		runline+="./"
		if [ $app == "fib" ]; then
		    echo "nao temos essa app ainda"
		    continue;
		elif [ $app == "mm" ]; then
			runline+="mm "
		    if [ $sz == "a" ]; then
			runline+=" 1024"
		    fi
		    runline+=" "
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
	#done;
    done;
done;
