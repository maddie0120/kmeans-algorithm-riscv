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

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:      .word 4,2, 5,1, 5,2, 5,3, 6,2

#Input C
#n_points:    .word 23
#points:      .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
n_points:    .word 30
points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 6,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,9, 3,8, 0,10, 4,10

# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do projeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    



# Definicoes de cores a usar no projeto 
colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.
# Vermelho, verde, azul

.equ         black      0
.equ         white      0xffffff

# ------------------------------------------------------------ Codigo ------------------------------------------------------------
.text

    # Chama funcao principal da 1a parte do projeto
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
    # Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### ------------------------------------------------------------ printPoint ------------------------------------------------------------
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja e fornecida pelos docentes
# E uma funcao auxiliar que e chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -20
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw ra, 16(sp)
    
    # Printa ponto
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
    
    # Repoe valores e liberta o espaco reservado na pilha
    lw ra, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 20
    
    jr ra
    
### ------------------------------------------------------------ cleanScreen ------------------------------------------------------------
# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li a0, 0
    li t0, 31    # Dimensao max
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Percorre todos os pontos verticalmente, pintando-os de branco
    x:
        bgt a0, t0, fim_cleanScreen
        li a1, 0
        j y

    y: 
        bgt a1, t0, incrementa_x
        li a2, white
        jal printPoint
        addi a1, a1, 1
        j y
    
    incrementa_x:
        addi a0, a0, 1
        j x
    
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
    # POR IMPLEMENTAR (1a e 2a parte)

    # Percorre o array points e pintar o ponto correspondente no ecra
    la t0, points
    lw t1, n_points
    li t2, 1
    la t3, colors
    #lw t4, k
    lw a2, 0(t3)
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    coloca_ponto:
        bgt t2, t1, fim_printClusters
        lw a0, 0(t0)
        lw a1, 4(t0)
        jal printPoint
        addi t0, t0, 8
        addi t2, t2, 1
        j coloca_ponto
    
    fim_printClusters:
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra, 0(sp)
        addi sp, sp, 4
        
        jr ra
    
### ------------------------------------------------------------ 
#para 2 parte do projeto
#branch � parte, ver se k = 1: � o primeiro do vetor
#se for maior que 1, consulta clusters e ver cor :D
### ------------------------------------------------------------

### ------------------------------------------------------------ printCentroids ------------------------------------------------------------
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    la t0, centroids
    #la t3, colors
    li t1, 1
    lw t2, k
    li a2, black
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)

    percorre_vetor_centroids:
        bgt t1, t2, fim_printCentroids
        lw a0, 0(t0)
        lw a1, 4(t0)
        #lw a2, 0(t3)
        jal printPoint
        #addi t3, t3, 4
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
    # POR IMPLEMENTAR (1a e 2a parte)
    la, t0, points
    lw t1, n_points
    li t2, 1 
    li t3, 0    # Soma dos x
    li t4, 0    # Soma dos y
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)

    percorre_vetor_pontos:
        bgt t2, t1, fim_calculateCentroids
        lw a0, 0(t0)
        lw a1, 4(t0)
        add t3, t3, a0
        add t4, t4, a1
        addi t0, t0, 8
        addi t2, t2, 1
        j percorre_vetor_pontos
    
    fim_calculateCentroids:
        div t3, t3, t1
        div t4, t4, t1
        la t1, centroids
        
        # Preenche as coordenadas do centroide
        sw t3, 0(t1)
        sw t4, 4(t1)
    
        # Repoe valores e liberta o espaco reservado na pilha
        lw ra 0(sp)
        addi sp sp 4
    
        jr ra

### ------------------------------------------------------------ mainSingleCluster ------------------------------------------------------------
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:
    # Coloca k=1 (caso nao esteja a 1)
    lw t0, k
    li t1, 1
    
    # Reserva espaco na pilha e guarda a informacao a ser preservada
    addi sp, sp, -4
    sw ra, 0(sp)
    
    bne t0, t1, altera_k
    j main
    
    altera_k:
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



































### ------------------------------------------------------------ manhattanDistance ------------------------------------------------------------
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### ------------------------------------------------------------ nearestCluster ------------------------------------------------------------
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### ------------------------------------------------------------ mainKMeans ------------------------------------------------------------
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra