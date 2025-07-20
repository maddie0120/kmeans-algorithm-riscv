#
# IAC 2023/2024 k-means
# 
# Grupo: 29
# Campus: Alameda
#
# Autores:
# 109834, Ricardo Fonseca
# 110144, Leonor Azevedo
# 110206, Madalena Yang
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...

# Variaveis em memoria
.data

# ===================================================================
#                             STRINGS
# ===================================================================
str_enter:                   .string "\n"
str_dois_pontos:             .string ": "
str_virgula:                 .string ","

str_mainSingleCluster:       .string "\nMain Single Cluster\n"
str_main_KMeans:             .string "\nMain KMeans\n"
str_cleanScreen:             .string "- Clean Screen\n"
str_printClusters:           .string "- Print Clusters\n"
str_calculateCentroids:      .string "- Calculate Centroids\n"
str_printCentroids:          .string "- Print Centroids\n"
str_coordenadasCentroids:    .string "    Coordenadas do Centroide "
str_initializeCentroids:     .string "- Initialize Centroids\n"
str_updateClusters:          .string "- Update Clusters\n"
str_estado:                  .string "Estado: "
str_iteracao:                .string "ITERACAO N? "
str_max_iteracao:            .string "Atingiu o n? maximo de iteracoes"
str_fim_estado:              .string "Nao houve alteracao da posicao de nenhum centroide"

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:      .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
n_points:    .word 23
points:      .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10

# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:  .zero 256
estado:    .zero 1

# OPTIMIZATION
# Para verificar se ha alteracoes nos centroides de forma mais eficiente, recorremos a um estado que varia entre 0, valor com que eh inicializado,
# e 1, valor tomado no caso de ocorrer alguma alteracao na posicao dos centroides.
# Se no final de uma iteracao da funcao mainKMeans o estado mantiver o valor inicial de 0, sabemos que podemos terminar a sua execucao.
# Desta forma, eh utilizado apenas 1 byte de memoria.

# Definicoes de cores a usar no projeto 
colors:    .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0 (vermelho), 1 (verde), 2 (azul), etc.

.equ         black      0
.equ         white      0xffffff

# ============================================================ CODIGO ============================================================
.text
    #jal mainSingleCluster

    jal mainKMeans
    
    # Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### ------------------------------------------------------------ printPoint ------------------------------------------------------------
# Pinta o ponto (x,y) na LED matrix com a cor passada como argumento
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0
    sw a2, 0(a3)
 
    jr ra


### ------------------------------------------------------------ cleanScreen ------------------------------------------------------------
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    la a0, str_cleanScreen
    li a7, 4
    ecall    # - Clean Screen
    
    li t0, 31    # Coordenada maxima
    li t1, 0
    li a2, white
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Percorre todos os pontos verticalmente, pintando-os de branco
    loop_x:
        bgt t1, t0, fim_cleanScreen
        li t2, 0    # Renova o valor de y para comecar a proxima coluna
        j loop_y

    loop_y: 
        bgt t2, t0, incrementa_x
         
        mv a0, t1    # Copia o valor de t1 para a0
        mv a1, t2    # Copia o valor de t2 para a1
        jal printPoint
        
        addi t2, t2, 1
        j loop_y
    
    incrementa_x:
        addi t1, t1, 1
        j loop_x
    
    fim_cleanScreen:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra


### ------------------------------------------------------------ printClusters ------------------------------------------------------------
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    la a0, str_printClusters
    li a7, 4
    ecall    # - Print Clusters
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, points
    lw t1, n_points
    la t2, clusters
    la t3, colors
    lw t4, k
    li t5, 1
    li t6, 4
    
    bne t5, t4, k_maior_um    # Verifica o valor de k
    
    k_um:
        bgt t5, t1, fim_printClusters    

        # Inicializa x, y e a cor
        lw a0, 0(t0)
        lw a1, 4(t0)
        lw a2, 0(t3)

        jal printPoint

        # Avanca no vetor e incrementa o indice
        addi t0, t0, 8
        addi t5, t5, 1

        j k_um
        
    k_maior_um:
        bgt t5, t1, fim_printClusters

        # Inicializa x e y
        lw a0, 0(t0)
        lw a1, 4(t0)

        # Guarda em a2 o valor retirado de clusters
        lb a2, 0(t2)

        # Determina a cor do ponto
        mul t4, a2, t6
        add t3, t4, t3
        lw a2, 0(t3)

        jal printPoint

        # Repoe a adress de colors, avanca nos vetores e incrementa o contador
        sub t3, t3, t4
        addi t2, t2, 1
        addi t0, t0, 8
        addi t5, t5, 1
        
        j k_maior_um
    
    fim_printClusters:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra


### ------------------------------------------------------------ printCentroids ------------------------------------------------------------
# Pinta os centroides a preto na LED matrix
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    la a0, str_printCentroids
    li a7, 4
    ecall    # - Print Centroids
    
    la t0, centroids
    li t1, 1
    lw t2, k
    li a2, black
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)

    percorre_vetor_centroids:
        bgt t1, t2, fim_printCentroids
        
        la a0, str_coordenadasCentroids
        li a7, 4
        ecall
        
        mv a0, t1
        addi a0, a0, -1
        li a7, 1
        ecall
        
        la a0, str_dois_pontos
        li a7, 4
        ecall

        # Carrega as coordenadas do centroide
        lw a0, 0(t0)
        lw a1, 4(t0)
        mv t3, a0
        
        li a7, 1
        ecall
        
        la a0, str_virgula
        li a7, 4
        ecall
        
        mv a0, a1
        li a7, 1
        ecall
        
        la a0, str_enter
        li a7, 4
        ecall
    
        mv a0, t3
        jal printPoint

        # Avanca no vetor e incrementa o contador
        addi t0, t0, 8
        addi t1, t1, 1

        j percorre_vetor_centroids

    fim_printCentroids:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra
    

### ------------------------------------------------------------ calculateCentroids ------------------------------------------------------------
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:    
    la a0, str_calculateCentroids
    li a7, 4
    ecall    # - Calculate Centroids
                             
    la a2, clusters
    la a3, centroids
    la a4, estado
    lw a5, k
    la a7, points

    lw t1, n_points
    li t2, 1    # Contador para percorrer o points
    li t3, 0    # Soma dos x
    li t4, 0    # Soma dos y
    li t5, 0    # Contador para loop k
    li t6, 0    # Numero de pontos de uma determinado agrupamento
    li t0, 0    # Guarda o valor retirado do vetor clusters

    bne a5, t2, percorre_points    # Avalia o valor de k

    percorre_points_k1:
        bgt t2, t1, guarda_centroide_k1

        # Carrega as coordenadas do ponto
        lw a0, 0(a7)
        lw a1, 4(a7)

        # Incrementa as somas de x e y
        add t3, t3, a0
        add t4, t4, a1

        # Avanca no vetor points e incrementa o contador
        addi a7, a7, 8
        addi t2, t2, 1

        j percorre_points_k1
    
    guarda_centroide_k1:
        # Determina e guarda as novas coordenadas do centroide
        div t3, t3, t1
        div t4, t4, t1

        sw t3, 0(a3)
        sw t4, 4(a3)

        j fim_calculateCentroids

    percorre_points:
        bgt t2, t1, fim_percorre_points

        lb t0, 0(a2)    # Vai buscar o valor do indice pretendido no vetor clusters
        bne t0, t5, continua_percorre_points    # Verifica se o valor retirado de clusters eh o procurado

        addi t6, t6, 1    # Incrementa a contagem de pontos

        # Carrega as coordenadas do ponto
        lw a0, 0(a7)
        lw a1, 4(a7)

        # Incrementa as somas de x e y
        add t3, t3, a0
        add t4, t4, a1

    continua_percorre_points:
        # Avanca nos vetores (clusters e points) e incrementa o contador
        addi a7, a7, 8
        addi a2, a2, 1           
        addi t2, t2, 1   

        j percorre_points       

    renova_valores:
        addi t5, t5, 1

        beq t5, a5, fim_calculateCentroids
        
        # Reinicia os valores alterados e avanca no vetor centroids
        la a7, points
        la a2, clusters
        li t2, 1 
        li t3, 0 
        li t4, 0         
        li t6, 0
        addi a3, a3, 8

        j percorre_points

    fim_percorre_points:
        # Verifica se ha pontos associados ao centroide
        bnez t6, guarda_centroide
        
        # OPTIMIZATION
        # Para melhor distribuicao dos pontos em agrupamentos,
        # consideramos o caso de um dos centroides gerado pseudoaleatoriamente nao ter nenhum ponto associado.
        # Nesta situacao geramos um novo centroide e verificamos se as suas coordenadas sao diferentes do anterior.
        
        # Reserva espaco na pilha e guarda a informacao a ser preservada
        addi sp, sp, -8
        sw a7, 0(sp)
        sw a0, 4(sp)

        li t3, 32
        
        # Chama a funcao milisegundos e determina as novas coordenadas
        li a7, 30
        ecall
        remu t3, a0, t3
        ecall
        remu t4, a0, t3

        # Guarda o novo centroide
        sw t3, 0(a3)
        sw t4, 4(a3)

        # Repoe valores e liberta o espaco reservado na pilha
        lw a0, 4(sp)
        lw a7, 0(sp)
        addi sp, sp, 8
        
        # Altera o estado
        li a6, 1
        sb a6, 0(a4)
        
        j renova_valores
        
    guarda_centroide:
        # Calcula as coordenadas do novo centroide
        div t3, t3, t6
        div t4, t4, t6

        # Verifica se o x do novo centroide eh igual ao anterior
        lw a6, 0(a3)
        beq a6, t3, continua_guarda_centroide

        # Guarda o valor e altera o estado
        sw t3, 0(a3)
        li a6, 1
        sb a6, 0(a4)

    continua_guarda_centroide:
        # Verifica se o y do novo centroide eh igual ao anterior
        lw a6, 4(a3)
        beq a6, t4, renova_valores
        
        # Guarda o valor e altera o estado
        sw t4, 4(a3)
        li a6, 1
        sb a6, 0(a4)

        j renova_valores

    fim_calculateCentroids:
        jr ra


### ------------------------------------------------------------ mainSingleCluster ------------------------------------------------------------
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la a0, str_mainSingleCluster
    li a7, 4
    ecall    # - Main Single Cluster
    
    lw t0, k
    li t1, 1
    
    bne t0, t1, altera_k    # Verifica o valor de k

    j main
    
    altera_k:
        # Define k = 1 (caso nao esteja a 1)
        la t2, k
        sw t1, 0(t2)
    
    main:
        jal cleanScreen
        
        jal printClusters
        
        jal calculateCentroids
        
        jal printCentroids

        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra
        

### ------------------------------------------------------------ initializeCentroids ------------------------------------------------------------
# Inicializa os valores iniciais do vetor centroids de forma pseudoaleatoria
# Argumentos: nenhum
# Retorno: nenhum   

initializeCentroids:
    la a0, str_initializeCentroids
    li a7, 4
    ecall    # - Initialize Centroids
    
    la t0, centroids
    lw t2, k  
    add t2, t2, t2
    li t1, 1
    li t3, 32

    percorre_centroids:
        la t4, centroids    # Usado para comparar o novo valor com os ja existentes no vetor centroids

        mv t5, t2    # Contador que vai percorrer o vetor centroids
        
        bgt t1, t2, fim_initializeCentroids 
     
        # System call Time_msec
        li a7, 30
        ecall
        remu a0, a0, t3    # Coloca em a0 o novo valor para a coordenada
        
    verifica_se_existe:
        
        # OPTIMIZATION
        # Para evitar a sobreposicao de centroides, ao gerar uma nova coordenada verificamos se o seu valor ja existe no vetor centroids.
        # Se for um valor repetido, eh calculada uma nova coordenada que vai tambem ser comparada com os valores do vetor.
        # Este processo repete-se ate encontrarmos um valor diferente dos restantes, que eh entao guardado. 
        
        beqz t5, valores_diferentes

        # Recalcula a coordenada se estiver repetida
        lw a2, 0(t4)
        beq a0, a2, percorre_centroids

        # Avanca no vetor e decrementa o contador
        addi t5, t5, -1
        addi t4, t4, 4

        j verifica_se_existe
        
    valores_diferentes:
        # Guarda a nova coordenada na memoria
        sw a0, 0(t0)

        # Avanca no vetor e incrementa o contador
        addi t0, t0, 4
        addi t1, t1, 1

        # Repete o processo para determinar as restantes coordenadas
        j percorre_centroids

    fim_initializeCentroids:
        jr ra


### ------------------------------------------------------------ manhattanDistance ------------------------------------------------------------
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    li t0, -1

    sub a0, a0, a2    # Diferenca entre x
    bgez a0, x_positivo
    mul a0, a0, t0    # Faz o simetrico do resultado, caso seja negativo
 
    x_positivo:
        sub a1, a1, a3    # Diferenca entre y
        bgez a1, y_positivo
        mul a1, a1, t0    # Faz o simetrico do resultado, caso seja negativo
    
    y_positivo:
        add a0, a0, a1    # Soma das distancias
        
        jr ra


### ------------------------------------------------------------ nearestCluster ------------------------------------------------------------
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)    
    sw a1, 8(sp)

    lw t1, k
    la t2, centroids
    li t3, 100    # Distancia para referencia inicial
    li t4, 0
    li t5, 0
    
    loop_nearestCluster: 
        beq t1, t5, fim_nearestCluster
        
        # Carrega as coordenadas do centroide
        lw a2, 0(t2)   
        lw a3, 4(t2)
        
        jal manhattanDistance    
        
        bgt a0, t3, continua_nearestCluster    # Verifica se a nova distancia eh superior
        
        # Para uma distancia menor, guarda o seu valor e o indice do centroide correspondente
        mv t3, a0   
        mv t4, t5    
        
    continua_nearestCluster:
        # Avanca no vetor e incrementa o contador
        addi t2, t2, 8
        addi t5, t5, 1 

        # Recupera as coordenadas do ponto
        lw a1, 8(sp)
        lw a0, 4(sp)
        
        j loop_nearestCluster
        
    fim_nearestCluster:
        mv a0, t4

        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 12
    
        jr ra


### ------------------------------------------------------------ updateClusters ------------------------------------------------------------
# Atualiza os valores dos Clusters
# Argumentos: nenhum
# Retorno: nenhum

updateClusters:
    la a0, str_updateClusters
    li a7, 4
    ecall
    
    la t0, points
    lw t1, n_points
    la t2, clusters
    li t3, 1
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -20
    sw ra, 0(sp)
    sw t1, 4(sp)
   
    determina_centroide:
        bgt t3, t1, fim_updateClusters

        # Carrega as coordenadas do ponto
        lw a0, 0(t0)
        lw a1, 4(t0)
        
        # Guarda a informacao a ser preservada
        sw t0, 8(sp)
        sw t2, 12(sp)
        sw t3, 16(sp)
        
        jal nearestCluster
        
        # Repoe valores
        lw t3, 16(sp)
        lw t2, 12(sp)
        lw t0, 8(sp)
        lw t1, 4(sp)
        
        # Guarda no vetor clusters o indice do centroide mais proximo do ponto
        sb a0, 0(t2)

        # Avanca nos vetores (points e clusters) e incrementa o contador
        addi t2, t2, 1
        addi t0, t0, 8
        addi t3, t3, 1

        j determina_centroide
    
    fim_updateClusters:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 20
        
        jr ra
    

### ------------------------------------------------------------ mainKMeans ------------------------------------------------------------
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans: 
    la a0, str_main_KMeans
    li a7, 4
    ecall    # - Main KMeans
    
    lw t0, L
    li t1, 0

    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -12
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)

    jal initializeCentroids
    
    la a0, str_enter
    li a7, 4
    ecall    # \n
    
    iteracao:
        # Recupera, decrementa e guarda o valor do contador
        lw t1, 8(sp)
        lw t0, 4(sp)
        
        beq t0, t1, fim_iteracao
        addi t1, t1, 1
        sw t1, 8(sp)
        
        la a0, str_iteracao
        li a7, 4
        ecall    # ITERACAO N? 
        
        mv a0, t1
        li a7, 1
        ecall    # Print valor da iteracao
        
        la a0, str_enter
        li a7, 4
        ecall    # \n 

        jal updateClusters
        
        jal cleanScreen

        jal printClusters

        jal calculateCentroids

        jal printCentroids
     
        la t1, estado
        lb t2, 0(t1)
        
        la a0, str_estado
        li a7, 4
        ecall    # Estado: 
        
        mv a0, t2
        li a7, 1
        ecall    # Printa o valor do estado
        
        la a0, str_enter
        li a7, 4
        ecall    # \n
        ecall    # \n

        beqz t2, fim_estado
        sb x0, 0(t1)
        
        j iteracao
        
    fim_iteracao:
        la a0, str_max_iteracao
        li a7, 4
        ecall    # Atingiu o n? maximo de iteracoes
        
        j fim_mainKMeans
        
    fim_estado:
        la a0, str_fim_estado
        li a7, 4
        ecall    # Nao houve alteracao da posicao de
        
        j fim_mainKMeans
    
    fim_mainKMeans:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 12

        jr ra