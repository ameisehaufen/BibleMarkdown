#!/usr/bin/env bash
source /home/${USER}/bin/libkmrgobash.sh || { echo "Error while loading source files"; exit 1; }
# Some Functions
# Help variables
help_short_description="Criador de bíblias"
help_examples[0]="$0 argument"
help_version="0.9"
help_dependencies="imagemagick"
help_notes="Instale o pandoc e imagemagick"
# Declaração de variaveis de início
bibles_dir="$PWD"
livros_nomes=( "Prefácio" Gênesis Êxodo Levítico Números Deuteronomio Josué Juízes Rute 1Samuel "2 Samuel" "1 Reis" "2 Reis" "1 Crônicas" "2 Crônicas" Esdras Neemias Ester "Jó" Salmos Provérbios Eclesiastes "Cantares de Salomão" Isaías Jeremías Lamentações Ezequiel Daniel Oséias Joel Amós Obadias Jonas Miquéias Naum Habacuque Sofonias Ageu Zacarias Malaquias Mateus Marcos Lucas João "Atos dos Apóstolos" Romanos "1 Coríntios" "2 Coríntios" Gálatas Efésios Filipenses Colossenses "1 Tessalonisences" "2 Tessalonisences" "1 Timóteo" "2 Timóteo" "Tito" Filemon Hebreus Tiago "1 Pedro" "2 Pedro" "1 João" "2 João" "3 João" Judas Apocalipse )
livros_abrev=( Pref Gn Ex Lv Nm Dt Js Jz Rt 1Sm 2Sm 1Rs 2Rs 1Cr 2Cr Es Ne Et Jo Sl Pv Ec Ct Is Jr Lm Ez Dn Os Jl Am Ob Jn Mq Na Hc Sf Ag Zc Ml Mt Mc Lc Joa At Rm 1Co 2Co Gl Ef Fp Cl 1Ts 2Ts 1Tm 2Tm Tt Fm Hb Tg 1Pe 2Pe 1Jo 2Jo 3Jo Jd Ap )
livros_prefixos=( 00- 01A- 02A- 03A- 04A- 05A- 06A- 07A- 08A- 09A- 10A- 11A- 12A- 13A- 14A- 15A- 16A- 17A- 18A- 19A- 20A- 21A- 22A- 23A- 24A- 25A- 26A- 27A- 28A- 29A- 30A- 31A- 32A- 33A- 34A- 35A- 36A- 37A- 38A- 39A- 40N- 41N- 42N- 43N- 44N- 45N- 46N- 47N- 48N- 49N- 50N- 51N- 52N- 53N- 54N- 55N- 56N- 57N- 58N- 59N- 60N- 61N- 62N- 63N- 64N- 65N- 66N- )
livros_abrev_pref=()
count=0
for i in "${livros_abrev[@]}"; do livros_abrev_pref+=( "${livros_prefixos[$count]}$i" ); ((count++)); done
livros_abrev_en=( Pref Ge Ex Le Nu De Jo Ju Ru 1Sa 2Sa 1Ki 2Ki 1Ch 2Ch Ezr Ne Es Jb Ps Pr Ec So Is Jer La Eze Da Os Jl Am Ob Jon Mc Na Hb Zp Hg Zc Ml Mt Mk Lk Jn Ac Rm 1Co 2Co Ga Eph Pp Co 1Th 2Th 1Ti 2Ti Tit Pm Heb Ja 1Pe 2Pe 1Jn 2Jn 3Jn Jd Re )
# Fim das declarações
printHeader -q
# Manage options
theargs=()
while [ $# -gt 0 ]; do
        case "$1" in
        -m|--man|-h|--help|-i|--info)
            printHelp $1
            exit 0
            ;;
        -v|--version)
            echo "Version: $version"
            exit 0
            ;;
        *) # default (normal size)
            theargs+=( "$1" )
            shift
            ;;
    esac
done

printQuestion -m "Criar Biblia" "Inserir Comentarios" "Remover Comentarios" "Copiar Imagens do SQL" "Copiar csv do SQL" "Salvar MEUS comentários" "Biblia em PDF"
case $? in
1)
	# AS bíblias sempre devem estar no formato da bible-acf2007.csv
	biblia="$(printQuestion -m -c 'ls bible-*.csv')"
	[ ! -f $biblia ] && exit 1
	printQuestion -p "Deseja continuar? Agora vai! "
	mkdir "${livros_abrev_pref[0]}" && touch "${livros_abrev_pref[0]}"/0.md
	contador_livros=1
	# Le o arquivo da bíblia
	readarray livros < <(cat "$biblia" | cut -f1 | grep -E "^[0-9]" | uniq)
	for i in "${livros[@]}"; do
		i="$(echo $i | tr -d '\n' | head -n 1 )"
		nr_livro=$(printf '%02d' $(( $contador_livros )) )
	    mkdir "${livros_abrev_pref[$contador_livros]}"
	    readarray capitulos < <(cat "$biblia" | grep -E "^$i"$'\t' | cut -f2 | uniq)
	    contador_cap=1
	    for j in "${capitulos[@]}"; do
			j="$(echo $j | grep -Eo [0-9]+ | head -n 1)"
	        echo "$i, ${livros_abrev_pref[$contador_livros]}, $j"
	        nr_cap=$(printf '%02d' $j)
	        readarray versiculos < <(cat "$biblia" | grep -E "^$i"$'\t'"$j"$'\t' | cut -f6)
	        # ESCRITA NO INICIO DO CAPITULO
	        echo -e "# ${livros_nomes[$contador_livros]} Cap ${nr_cap}\n" >> "${livros_abrev_pref[$contador_livros]}"/${nr_cap}.md
	        count=1
	        for k in "${versiculos[@]}"; do
	            # [ ! -d "${livros_abrev[$contador_livros]}/.img" ] && mkdir "${livros_abrev[$contador_livros]}/.img"
	            # ESCRITA NO INICIO DO VERSICULO
	            echo -e "**${count}** \t${k%%$'\n'*}\n" >> "${livros_abrev_pref[$contador_livros]}"/${nr_cap}.md 
	            readarray bible_pictures < <(cat images-catalog.csv | grep -E "^$contador_livros"$'\t'"${j}"$'\t'"${count}"$'\t' )
	            for l in "${bible_pictures[@]}"; do
					image_file="$(echo "$l" | cut -f 4)"
					image_folder="$(echo "$l" | cut -f 5)"
					image_leg=''
	                if [ -f "Images/$image_folder/$image_file" ]; then
	                    echo -en "![$image_leg](../Images/$image_folder/$image_file) " >> "${livros_abrev_pref[$contador_livros]}"/${nr_cap}.md
	                fi
	            done
	            [ "${#bible_pictures[@]}" -gt 0 ] && echo -e "\n" >> "${livros_abrev_pref[$contador_livros]}"/${nr_cap}.md
	            (( count++ ))
	        done
	        # Escrita no FIM do CAPÍTULO (Comentarios)
	        (( contador_cap++ ))
	    done
	    (( contador_livros++ ))
	done
	
	# Cria os arquivos de introducao
	for i in "${livros_abrev_pref[@]}"; do
	    touch $i/00.md
	done
	;;
4)
	echo "Selecione o arquivo"
	arquivo="$(printQuestion -m -c 'find '${bibles_dir:=$PWD}'/ -type f -iname "*.mybible"' )"
	nome_base="$(echo "$arquivo" | rev | cut -d '/' -f1 | rev | cut -d '.' -f1)"
	# nickname="$(echo $nome_base | cut -d '-' -f2 )"
	nickname="$(printQuestion -r "Digite um nome curto (NVI, McArthur): ")"
	
	checkVariables nome_base nickname
	mkdir $nickname
	echo "$arquivo" && \
	sqlite3 "$arquivo" "SELECT filename from data" > /tmp/id.list
	count=1; cat /tmp/id.list | while read filename; do echo SELECT writefile\(\'$nickname/$filename\', content\) FROM data WHERE rowid=$count\;; ((count++)); done | sqlite3 "$arquivo"
	prinQuestion -p "Deseja remover alguma foto? Faça isso, remova da pasta imgs e coloque em Images/$nickname as que deseja manter, e depois de enter"
	mv $nickname Images/$nickname
	# Move as imagens grande para outro dir NAO IMPLEMENTADO esse find, melhor fazer manualmente por enquanto
	echo find Images/"$nickname" -type f -size +15k -exec mv "{}" Images/$nickname/ \;

	read -p "remova os arquivos que deseja e depois veja o script novamnte"
	# cd imgs && ls > ../"${nome_base}"-out_images.txt && cd - && rm -rf imgs
	for i in Images/"$nickname"/*.*; do
		convert $i $(echo $i | rev | cut -d '.' -f2- | rev ).jpg
	done
	
	;;
5)
	# Pega a tabela dos comentarios e transforma para csv, com tabs
	echo "Selecione o arquivo"
	arquivo="$(printQuestion -m -c 'find '${bibles_dir:=$PWD}'/ -type f -iname "*.mybible"' )"
	nome_base="$(echo $arquivo | rev | cut -d '/' -f1 | rev | cut -d '.' -f1)"
	echo $nome_base
	sqlite3 -csv -separator $'\t' "$arquivo" "SELECT * FROM commentary" > "${nome_base}".csv
	;;
2)
	# Seleciona o arquivo
	echo "Selecione o arquivo"
	arquivo="$(printQuestion -m -c 'find '${bibles_dir:=$PWD}'/ -type f -iname "comment-*.csv"' )"
	nome_base="$(echo $arquivo | rev | cut -d '/' -f1 | rev | cut -d '.' -f1)"
	echo $nome_base
	
	nickname="$(echo $nome_base | cut -d '-' -f2)"
	if printQuestion -y "Recriar arquivos working?"; then
		cp "${nome_base}".csv working.csv
		[ -f "${nome_base}-out_images.txt" ] && cp "${nome_base}"-out_images.txt working-imgs.txt
	fi
	# Prepara o csv
	# Retira imagens que estao fora
	if printQuestion -y "Remover imagens inexistentes do csv (as imagens que estão presentes devem estar em um arquivo working-imgs.txt, um arquivo por linha)?"; then
		for i in `cat  working-imgs.txt`; do
			sed -i "s/<p><img src='$i'\/><\/p>//g" working.csv
		done
	fi

	if printQuestion -y "Remover caracteres estranhos do csv?"; then
		sed -i "s/ă/ã/g;s/ŕ/a/g;s/ę/ê/g;s/ő/õ/g" working.csv
	fi

	# Modifica caminho das imagens e remove ""
	if printQuestion -y "Corrigir path das imagens no csv, remove aspas duplas e mudar #b01 por #b01A-Gen, #b02 por Ex..., muda extensao das imagens para .jpg?"; then
		sed -i "s/\(img src='[0-9][0-9]*\.\)\([a-z][a-z]*\)'/\1jpg\'/g" working.csv && \
		sed -i "s/<img src='/<img src='..\/Images\/${nickname}\//g;s/\"\"/\"/g" working.csv
		# Troca 01 por Ge
		count=0; for i in "${livros_abrev_pref[@]}"; do sed -i "s/\#b$count\./\#b$i\./g" working.csv ; ((count++)); done
	fi

	# Acerta os links para as bíblias
	if printQuestion -y "Corrigir links dos versiculos no csv?"; then
		sed -i "s/<a class='bible' \(href='\)#b\([A-Za-z0-9\-]\+\).\([0-9]*\).\([0-9]*\)\(\.*[0-9-]*\)*'/<a \1..\/\2\/\3.md#\4' /g" working.csv
		sed -i "s/class='bible'//g" working.csv
		sed -i "s/\/\([0-9]\)\.md/\/0\1\.md/g" working.csv
	fi

	if printQuestion -y "Inserir comentários nos arquivos .md?"; then
		# Le todos os comentarios do bd, um comentario por linha
		readarray comentarios < <(cat working.csv)
		for i in "${comentarios[@]}"; do
			case "$nickname" in
				'NVI'|'McArthur')
				readarray com_capitulo < <(echo "${i%%$'\n'*}" | cut -f 6 | pandoc --wrap=none -s -f html -t markdown | grep -v -e '^$' | sed -z "s/\n\(\!\[\]\)/\1/g")
				;;
				'MHenry')
				readarray com_capitulo < <(echo "${i%%$'\n'*}" | cut -f 6 | pandoc --wrap=none -s -f html -t markdown | grep -v -e '^$' | sed -z "s/\n\([^\*]\)/ \1/g")
				;;
				*)
				echo "Erro, $nickname não suportado"
				;;
			esac

			capitulo=$(echo "$i" | cut -f3)
			capitulo=$(printf '%02d' $capitulo)
			livro=$(echo "$i" | cut -f2)
			for j in "${com_capitulo[@]}"; do
				# A PARTIR DAQUI TEM Q CUSTOMIZAR PARA CADA COMENTÁRIO, ESSE FUNCIONA SOMENTE PARA NVI
				case "$nickname" in
					'NVI')
						versiculo="$(echo "${j}" | cut -d ':' -f2 | grep -Eo "^[0-9]{1,3}" | sed 's/^0*//')"
						;;
					'McArthur')				
						versiculo="$(echo "${j}" | grep -Eo "^\*\*[0-9]{1,3}:[ 0-9]+" | cut -d ':' -f2 | sed 's/ *//g')"
						j="$(echo ${j} | sed "s|\*\*|\*|g")"
						;;
					'MHenry')				
						versiculo="$(echo "${j}" | grep -Eo "^\**.*\*\*" | grep -Eo "[0-9]*" | head -n 1)"
						j="$(echo ${j} | sed "s|\*\*|\*|g")"
						;;
					# 'AdamOT')				
					# 	versiculo="$(echo "${j}" | grep -Eo "^\*\*[0-9]{1,3}:[ 0-9]+" | cut -d ':' -f2 | sed 's/ *//g')"
					# 	j="$(echo ${j} | sed "s|\*\*|\*|g")"
					# 	;;
					*)
						echo "Erro, $nickname não suportado"
					exit 1
				esac
				echo "Livro $livro, Capitulo $capitulo, Versiculo $versiculo"
				# Verifica se o versículo existe (se não é 0 por exemplo)
				if [ "$versiculo" -ge 0 ]; then
					# Verifica se o versículo existe no arquivo do capítulo
					if [ -z "$(cat "${livros_abrev_pref[$livro]}"/$capitulo.md | grep "\*\*"$versiculo"\*\*")" ]; then
						if [ ! $(cat "${livros_abrev_pref[$livro]}"/$capitulo.md | grep "\*\*Cmt $nickname\*\* Intro:") ]; then
							echo -en "\n> **Cmt $nickname** Intro: $j" >> "${livros_abrev_pref[$livro]}"/$capitulo.md
						else
							echo -en "> $j" >> "${livros_abrev_pref[$livro]}"/$capitulo.md
						fi
					else
						sed -i "/\*\*$versiculo\*\*/a linha_em_branco\n> **Cmt $nickname**: $j" "${livros_abrev_pref[$livro]}"/$capitulo.md
					fi
				else
					if [ ${#j} -gt 10 ]; then
						if [ ! $(cat "${livros_abrev_pref[$livro]}"/$capitulo.md | grep "\*\*Cmt $nickname\*\* Intro:") ]; then
							echo -en "\n> **Cmt $nickname** Intro: $j" >> "${livros_abrev_pref[$livro]}"/$capitulo.md
						else
							echo -en "> $j" >> "${livros_abrev_pref[$livro]}"/$capitulo.md
						fi
					fi
				fi
			done
		done
	fi

	# remove linhas_em_branco
	if printQuestion -y "Remover linhas_em_branco dos csv?"; then
		for i in "${livros_abrev_pref[@]}"; do
			echo $i 
			for j in "$i"/*.md; do
				sed -i "s/linha_em_branco//g" "$j"
			done
		done
	fi
	;;
3)
	# Remove os comentarios
	for i in "${livros_abrev[@]}"; do
		echo "Removendo de $i"
		for j in "$i"/*.md; do
			sed -i "/\*\*Comentário $nickname\*\*/,+1 d" "$j"
		done
	done
;;
6)
	echo "Não implementado"
	exit 1
;;
7)
	[ ! -d "pdf" ] && mkdir pdf
	printQuestion -m "Um pdf por capitulo" "Um pdf por livro"
	case $? in
	1)
		for i in "${livros_abrev_pref[@]}"; do
			# cria um pdf para cada capitulo
			mkdir pdf/"$i"
			cd "$i"
			for j in *.md; do
				pandoc --latex-engine=xelatex -V urlcolor=cyan "$j" -o "$(basename $j .md)".pdf
			# junta todos os capitulos em um doc pdf apenas... tentar Colocar um header com todos os livro bem pequenos, em cada livro os seus resp capitulos, se estiver no cap, o versiculo de cada livro.
			done
			mv *.pdf ../pdf/"$i"
			cd -
		done
		;;
	2)
		for i in "${livros_abrev_pref[@]}"; do
			# cria um pdf para cada capitulo
			cd "$i"
			pandoc --latex-engine=xelatex -V urlcolor=cyan *.md -o ../pdf/"$i".pdf
			# junta todos os capitulos em um doc pdf apenas... tentar Colocar um header com todos os livro bem pequenos, em cada livro os seus resp capitulos, se estiver no cap, o versiculo de cada livro.
			cd -
		done
		;;
	esac

;;
esac
