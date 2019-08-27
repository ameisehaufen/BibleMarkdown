#!/bin/bash

biblia='acf2007-original.txt'
# read -p "Digite o arquivo da bibia: " biblia
i=''
j=''
k=''
livros_nomes=( Gênesis Êxodo Levítico Números Deuteronomio Josué Juízes Rute 1Samuel "2 Samuel" "1 Reis" "2 Reis" "1 Crônicas" "2 Crônicas" Esdras Neemias Ester "Jó" Salmos Provérbios Eclesiastes "Cantares de Salomão" Isaías Jeremías Lamentações Ezequiel Daniel Oséias Joel Amós Obadias Jonas Miquéias Naum Habacuque Sofonias Ageu Zacarias Malaquias Mateus Marcos Lucas João "Atos dos Apóstolos" Romanos "1 Coríntios" "2 Coríntios" Gálatas Efésios Filipenses Colossenses "1 Tessalonisences" "2 Tessalonisences" "1 Timóteo" "2 Timóteo" "Tito" Filemon Hebreus Tiago "1 Pedro" "2 Pedro" "1 João" "2 João" "3 João" Judas Apocalipse )
livros_abrev=( Gn Ex Lv Nm Dt Js Jz Rt 1Sm 2Sm 1Rs 2Rs 1Cr 2Cr Es Ne Et Jo Sl Pv Ec Ct Is Jr Lm Ez Dn Os Jl Am Ob Jn Mq Na Hc Sf Ag Zc Ml Mt Mc Lc Jo At Rm 1Co 2Co Gl Ef Fp Cl 1Ts 2Ts 1Tm 2Tm Tt Fm Hb Tg 1Pe 2Pe 1Jo 2Jo 3Jo Jd Ap )
livros_abrev_en=( Ge Ex Le Nu De Jo Ju Ru 1Sa 2Sa 1Ki 2Ki 1Ch 2Ch Ezr Ne Es Jb Ps Pr Ec So Is Jer La Eze Da Os Jl Am Ob Jon Mc Na Hb Zp Hg Zc Ml Mt Mk Lk Jn Ac Rm 1Co 2Co Ga Eph Pp Co 1Th 2Th 1Ti 2Ti Tit Pm Heb Ja 1Pe 2Pe 1Jn 2Jn 3Jn Jd Re )
contador_livros=0
readarray livros < <(cat "$biblia" | cut -f1 | grep -E "^[0-9]" | uniq)
for i in ${livros[@]}; do
    mkdir "${livros_abrev[$contador_livros]}"
    readarray capitulos < <(cat "$biblia" | grep -E "^$i"$'\t' | cut -f2 | uniq)
    nr_livro=$(printf '%02d' $(( $contador_livros + 1 )) )
    contador_cap=1
    for j in ${capitulos[@]}; do
        echo "$i, ${livros_abrev[$contador_livros]}, $j"
        nr_cap=$(printf '%02d' $contador_cap)
        readarray versiculos < <(cat "$biblia" | grep -P "^$i\t$j\t" | cut -f6)
        # ESCRITA NO INICIO DO CAPITULO
        echo -e "# "${livros_nomes[$contador_livros]}" Capítulo $j\n" >> "${livros_abrev[$contador_livros]}"/$j.md
        count=1
        for k in "${versiculos[@]}"; do
            [ ! -d ".img" ] && mkdir .img
            [ ! -d ".img/"${livros_abrev[$contador_livros]}"" ] && mkdir .img/"${livros_abrev[$contador_livros]}"
            [ ! -d ".img/"${livros_abrev[$contador_livros]}"/$nr_cap" ] && mkdir .img/"${livros_abrev[$contador_livros]}"/$nr_cap
            # ESCRITA NO INICIO DO VERSICULO
            echo -e '##' $count"\n${k%%$'\n'*}\n" >> "${livros_abrev[$contador_livros]}"/$j.md
            arquivo_imagem="Images/$nr_livro/610px/${nr_livro}_${livros_abrev_en[$contador_livros]}_${nr_cap}_$(printf '%02d' $count)_RG.jpg"
            echo "Imagem: $arquivo_imagem"
            if [ -f $arquivo_imagem ]; then
                # proximo_nr=$(( $(ls ".img/"${livros_abrev[$contador_livros]}"/$nr_cap/$count*" | wc -l) + 1 ))
                # [ ! "$proximo_nr" >= 0 ] && proximo_nr=0
                novo_arquivo=".img/"${livros_abrev[$contador_livros]}"/$nr_cap/$count-0.jpg"
                echo "Novo: $novo_arquivo"
                convert "$arquivo_imagem" -quality 40% -resize x180 "$novo_arquivo"
                echo -e '![]('../$novo_arquivo")\n" >> "${livros_abrev[$contador_livros]}"/$j.md
            fi
            (( count++ ))
        done
        (( contador_cap++ ))
    done
    (( contador_livros++ ))
done

#
