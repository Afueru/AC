.data
fin: .asciiz ""      # filename for input
msg:   .asciiz "Insira o nome do arquivo:"
tipomsg: .asciiz "\nInsira um inteiro correspondente ao tipo de algoritmo desejado (0 para quicksort e 1 para selectionsort): "
newline: .asciiz "\n"
buffer: .space 1024
bufitoa: .space 32
array: .word 0,
.text 
.globl main
main:
li $v0, 4	#imprime mensagem do pedido do nome do arquivo
la $a0, msg
syscall
  
li $v0, 8	#Le o input do usuario
la $a0, fin	#armazena o nome do arquivo em 'fin'
li $a1, 32	#tamanho limite para o nome do arquivo
syscall  	#Faz o syscall para a leitura do input do usuario

jal buscaLn	#procura o ln que fica no final do nome do arquivo passado pelo usuario

la $t0, array #carrega o array

addi $a0, $t0, 0  #salva array como argumento
addi $sp, $sp, -4
sw $a0,0($sp)

jal readfile

buscaLn:
li $t0, 0	#contador do loop
li $t1, 32	#final do loop

buscaLoop:		
beq $t0, $t1, finalizaBusca 	#caso o contador passe do limite de caracteres pra o nome do arquivo
lb $t3, fin($t0)		#carrega o caracter da posição atual do loop
bne $t3, 0x0a, acrescenta	#caso o caracter não seja ln vai para o acrescenta
sb $zero, fin($t0)		#substitui ln por 0 (tabela ascii 0 = null)
j finalizaBusca			#sai do loop
	
acrescenta:
addi $t0, $t0, 1		#incrementa o contador

j buscaLoop			#pula de volta para o inicio do loop

finalizaBusca:			#sai do loop
jr $ra

endread:
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file


li $v0, 4	#imprime mensagem do pedido do tipo de algoritmo
la $a0, tipomsg
syscall

li $v0, 5	#Le o input do usuario
syscall  	#Faz o syscall para a leitura do input do usuario

lw $a0,0($sp)   #carrega de volta o endereço do array
addi $sp, $sp, 4
move $a1, $v0 #a1 = tipo     0 = quicksort, 1 = selectionsort
add $a2, $zero, $t4 #a2 = tam

jal ordena

la $t0, array
move $a0, $t0
move $a2, $v1      #a2 = tam
addi $a2, $a2, -1  #tam = tam -1





jal writefile

END:
li   $v0, 16       # system call para fechar o arquivo
move $a0, $s6      # Fechar o file descriptor
syscall            # Fechar o arquivo

li $v0, 10
syscall

troca:
addi $sp, $sp, -12
sw $a0,0($sp)  #salva array
sw $a1,4($sp)  #salva i
sw $a2,8($sp)  #salva j

sll $t1,$a1,2
add $t1,$a0,$t1
lw $s3,0($t1)  #s3 = vetor[i]

sll $t9,$a2,2
add $t9,$a0,$t9
lw $s4,0($t9) #s4 = vetor[j]

sw $s3,0($t9)
sw $s4,0($t1)

move $t1, $zero #zera $t1
move $t9, $zero #zera $t9


addi $sp, $sp, 12
jr $ra

divide:
addi $sp, $sp, -16 #abre 4 espaços

sw $a0,0($sp)  #salva array 
sw $a1,4($sp)  #salva o inicio
sw $a2,8($sp)  #salva o ultimo
sw $ra,12($sp) #salva endereço de retorno

move $s1,$a1   #$s1 = inicio
move $s2, $a2  #$s2 = ultimo

sll $t1,$s1,2  #deslocar 2 casas para o lado de $s1 e armazenar em $t1 ou $t1 = 4*$s1
add $t1,$a0, $t1 # $t1 = $t1 + (endereço do array) que resulta no índice inicial do vetor
lw $s6, 0($t1) #pivo = vetor[inicio]

move $t1, $zero #zera $t1

move $t3,$s2     #$t3 = ultimo        j = ultimo
move $t4, $s1    #$t4 = inicio        i = inicio
addi $s7, $s6, 1 #$t5 = pivo + 1



whileloop1:
	slt $t6,$s1,$s2  #checa se s1 < s2
	beq $t6,$zero,endwhile1
	
	whilei:
	sll $t1, $s1, 2    #i*4
	add $t1, $a0, $t1  # vetor + i*4
	lw $t8,0($t1) # carrega vetor[i] em t8	
	slt $t6,$t8,$s7 #if (vetor[i] < pivo + 1) t6 = 1
	beq $t6,$zero whilej    #sai desse while
	
	beq $t3, $s1, whilej
	addi $s1, $s1, 1    #i++

	j whilei
		 
	whilej:
	
	sll $t7, $s2, 2   #j*4
	add $t7, $a0,$t7  #vetor + j*4
	lw $t8,0($t7)  #carrega vetor[j] em t8
	
	slt $t6,$s6, $t8  #if(pivo < vetor[j]) t6 = 1
	beq $t6, $zero, ifij #se t6 = 0 vai pra ifij
	beq $t4, $s2, ifij
	addi $s2,$s2,-1 #j--

	j whilej	
	
	ifij:
	slt $t6, $s1, $s2  #if (i < j) t6 = 1
	beq $t6, $zero, whileloop1   #if(t6 == 0) break;
	move $a1, $s1  #a1 = i
	move $a2, $s2  #a2 = j
	
	jal troca

	j whileloop1
endwhile1:

lw $t4, 4($sp) #carrega o inicio
sll $t1, $t4, 2
add $t1, $a0,$t1  #t1 = &Vetor[inicio]

sll $t6,$s2,2
add $t6, $a0,$t6
lw $s5,0($t6)    #s5 = vetor[j]

sw $s5,0($t1)    #vetor[inicio] = vetor[j]
sw $s6,0($t6)    #vetor[j] = pivo

move $t1, $zero #zera $t1

add $v0, $zero, $s2  #return j

lw $a0, 0($sp)    #carrega o endereço do array de volta
lw $a1, 4($sp)    #carrega o inicio de volta ao argumento
lw $a2, 8($sp)    #carrega o ultimo de volta ao argumento
lw $ra, 12($sp)      #carrega o endereço pra voltar

addi $sp, $sp, 16    #devolve o espaço tomado para o sp

jr $ra               #da jump de volta para onde veio








quicksort:
addi $sp, $sp, -16 #abre 4 espaços no stack pointer

sw $a0,0($sp)  #salva array 
sw $a1,4($sp)  #salva o inicio
sw $a2,8($sp)  #salva o ultimo
sw $ra,12($sp) #salva endereço de retorno


move $t0, $a2 #salva o ultimo indice em $t0

slt $t1, $a1, $t0      #if(inicio >= fim) $t1 = 0, else $t1 = 1
beq $t1, $zero, endif

jal divide


move $s0, $v0     #s0 = pivo

lw $a1,4($sp)     #restaura a1 para seu valor original
addi $a2,$s0,-1   #a2 = pivo - 1

jal quicksort     #quicksort(vetor, inicio, pivo - 1)

addi $a1,$s0,1
lw $a2,8($sp)
jal quicksort    #quicksort(vetor,pivo + 1, fim)
endif:

lw $a0,0($sp)     #restaura valores de a0,a1,a2 e ra
lw $a1,4($sp)
lw $a2,8($sp)
lw $ra,12($sp)    #carrega o endereço de retorno
addi $sp,$sp,16   #devolve o espaço de volta para a pilha
jr $ra

selectionsort:
addi $sp, $sp, -16
sw $a0, 0($sp) #salva array
sw $a1, 4($sp)    #salva inicio
sw $a2, 8($sp)    #salva fim
sw $ra, 12($sp)   #salva endereço de retorno

addi $s0, $zero, 0   #i = 0
addi $s1, $zero, 0   #j = 0
addi $s2, $zero, 0   #m = 0
move $s5, $a2        #s5 = fim

whileitam:
	
	slt $t4, $s5, $s0
	beq $t4, 1, endwhilei
	move $s1, $s0     #j = i
	move $s2, $s0     #m = i
	
	whilejtam:
	slt $t4, $s5, $s1
	beq $t4, 1, endwhilej   #if (j = tam) break;
	
	sll $t1, $s1,2
	add $t1, $t1, $a0   #t1 = &vetor[j]
	lw $t2, 0($t1)      #t2 = vetor[j]
	
	sll $t1, $s2,2
	add $t1, $t1, $a0   #t1 = &vetor[m]
	lw $t3, 0($t1)	    #t3 = vetor[m]
	
	slt $t4, $t2, $t3
	beq $t4, $zero, skip
	move $s2, $s1		
	
	skip:
	addi $s1, $s1, 1   #j++
	j whilejtam
	
	endwhilej:
	
	move $a1, $s0
	move $a2, $s2
	jal troca
	
	addi $s0, $s0, 1
	j whileitam
	
	

endwhilei:

lw $ra, 12($sp)
addi $sp, $sp, 16
jr $ra




ordena:
addi $sp, $sp, -16 #abre 4 espaço no stack pointer
sw $a0,0($sp)   #salva array
sw $a1,4($sp)   #salva o tipo
sw $a2,8($sp)   #salva o tamanho
sw $ra,12($sp)   #salva o endereço de retorno

move $v1, $a2

move $t0, $a1   #salva o tipo em t0
move $a1, $zero #zera a1
addi $a2, $a2, -1 #salva a2 como o valor do ultimo indice 

beq $t0,$zero,quicksort
lw $t0, 4($sp)
beq $t0,1, selectionsort


lw $ra,12($sp)   #carrega o endereço de retorno
addi $sp, $sp, 16   #adiciona de volta o espaço ocupado pela função no stackpointer
jr $ra #retorna ao main


#codigo novo abaixo
################################################ fileRead:

# Open file for reading
readfile:
li   $v0, 13       # system call for open file
la   $a0, fin      # input file name
li   $a1, 0        # flag for reading
li   $a2, 0        # mode is ignored
syscall            # open a file 
move $s0, $v0      # save the file descriptor 

li   $v0, 14       # system call for reading from file
move $a0, $s0      # file descriptor 
la   $a1, buffer   # address of buffer from which to read
li   $a2,  1024    # hardcoded buffer length
syscall            # read from file

li $v0, 16
syscall


#---------------------- encontra todos os números e printa eles ------------------------------------------------------
addi $a0, $zero, 0		#o a0 é o número que faz com que andemos no buffer, sendo assim, ele deve começar em 0, que é o começo do buffer

la $t3, array        #carrega o endereço do array
addi $t4, $zero, 0   #t4 = tam - 1

loop:
#executa o encontraNumCaracteres
subi $sp,$sp,8
sw $ra, 4($sp)
sw $fp, 0($sp)



jal encontraNumCaracteres

lw $fp, 0($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8

beq $v0, 0, endread		#se não encontrar nenhum número, pode parar e ir para o final do código.

move $t1, $v0			#salva a quantidade de caracteres que o número tem em t1

#a0 já está correto		#o a0 já possui o endereço do começo do número
move $a1, $v0			#prepara o a1 para receber o nº de caracteres que o número tem

#executa o atoi
subi $sp,$sp,8
sw $ra,4($sp)
sw $fp,0($sp)
	
jal atoi
	
lw $fp,0($sp)
lw $ra,4($sp)
addi $sp,$sp,8

sll $t5, $t4, 2				#aqui
add $t5, $t5, $t3
sw $v0,0($t5)
addi $t4, $t4, 1

move $t0, $a0			#salva o endereço do número em t0
move $t2, $v0			#salva o número em t2

#move o a0 1 casa para a frente para que ele possa encontrar o próximo número 
addi $t1, $t1, 1
add $t0, $t0, $t1
add $a0, $zero, $t0

j loop

#--------------------------------------------------------------------------------------------------------



atoi:
	subi $sp,$sp,24
	sw $s0,20($sp)		#recebe o inteiro que será retornado
	sw $s1,16($sp)		#recebe o endereço do número
	sw $s2,12($sp)		#recebe o inteiro ASCII do caractere atual
	sw $s3,8($sp)		#recebe o número de caracteres que o número tem
	sw $s4,4($sp)		#recebe o multiplicador
	sw $s5,0($sp)		#marcador de negativo
	
	or $s0, $zero, $zero	#aqui que será armazenado o número final
	la $s1, buffer($a0)		#o endereço do caractere atual estará em s1
	#move $s1, $a0
	lb $s2, 0($s1)		#o inteiro ASCII do caractere atual estará em s2
	
	move $s3, $a1		#passa o número de caracteres para s3
	beq $a1, $zero, fimAtoi #se o número tiver 0 caracteres, já pula direto para o final
	
	addi $s4, $zero, 1	#o número que possui as potências de 10 está em s4, que terá valor inicial 1
	beq $s3, 1, loopAtoi	#se o número possuir apenas 1 caractere, o multiplicador já está correto
	subi $s3, $s3, 1
	
	#se chegar até aqui, será encessário criar o multiplicador
	criaMultLoop:
	mul $s4, $s4, 10	#multiplica por 10 o multiplicador
	sub $s3, $s3, 1		#subtrai 1 do número de caracteres
	bne $s3, $zero, criaMultLoop #se não houver mais caracteres no número, podemos prosseguir
	move $s3, $a1		#passa o número de caracteres para s3 novamente para utilizá-lo no loopAtoi com o valor correto
	
	loopAtoi:
	beq $s3, $zero, fimAtoi	#se não houver mais caracteres desse número, podemos sair da função
	beq $s2, 45, negativoAtoi #se o número for negativo, teremos que realizar uma marcação dessa informação
	
	subi $s2, $s2, 48	#passa de ASCII para int
	mul $s2, $s2, $s4	#multiplica o caractere atual pelo multiplicador, resultando no valor verdadeiro daquele caractere e armazenando-o em s2
	add $s0, $s0, $s2	#adiciona o valor verdadeiro do caractere no número final que está em s0
	div $s4, $s4, 10	#divide s4 por 10, pois iremos para o próximo caractere
	subi $s3, $s3, 1	#subtrai 1 de s3 pois adicionamos 1 caractere, então temos um caractere a menos para adicionar à s0
	addi $s1, $s1, 1	#adiciona 1 em s1 para irmos para o próximo caractere do endereço de s1
	lb $s2, 0($s1)		#carrega o próximo caractere em s2
	j loopAtoi
	
	negativoAtoi:
	addi $s5, $zero, 1
	div $s4, $s4, 10	#divide s4 por 10, pois iremos para o próximo caractere
	subi $s3, $s3, 1	#subtrai 1 de s3 pois adicionamos 1 caractere, então temos um caractere a menos para adicionar à s0
	addi $s1, $s1, 1	#adiciona 1 em s1 para irmos para o próximo caractere do endereço de s1
	lb $s2, 0($s1)		#carrega o próximo caractere em s2
	j loopAtoi
	
		fimAtoi:
	bne $s5, 1, fimAtoiPt2	
	move $s5, $s0
	sub $s0, $s0, $s5
	sub $s0, $s0, $s5	#transforma o número em negativo
	
	fimAtoiPt2:
	move $v0,$s0		#retorna o valor que está em s0
	lw $s5,0($sp)
	lw $s4,4($sp)
	lw $s3,8($sp)
	lw $s2,12($sp)
	lw $s1,16($sp)
	lw $s0,20($sp)
	addi $sp,$sp,24
	jr $ra


encontraNumCaracteres:
	subi $sp,$sp,20
	sw $s0,16($sp)
	sw $s1,12($sp)
	sw $s2,8($sp)
	sw $s3,4($sp)
	sw $s4,0($sp)
	
	#codigo aqui
	la $s0, buffer($a0)	#armazena o endereço do início do número que recebe do buffer a0
	la $s1, buffer($a0)	#armazena o endereço do final do número que recebe do buffer a0
	#la $s0, ($a0)
	#la $s1, ($a0)
	or $s2, $zero, $zero	#o contador de potências de 10 é zerado
	whileEnc:
	lb $s3, 0($s1)		#carrega o valor INT do char ASCII em T3
	beq $s3, $zero, finalEnc#se o conteúdo do buffer tiver terminado, t3 irá receber 0, então podemos pular para o final do código
	beq $s3, 32, finalEnc	#se encontrarmos um espaço seguimos para o próximo pedaço do código, caso contrário, continuamos avançando para o próximo caractere

	addi $s1, $s1, 1	#adiciona 1 para irmos para o próximo caractere da string
	addi $s2, $s2, 1	#adiciona 1 ao número de caracteres que o número possui
	j whileEnc
	
	finalEnc:
	move $v0,$s2
	lw $s4,0($sp)
	lw $s3,4($sp)
	lw $s2,8($sp)
	lw $s1,12($sp)
	lw $s0,16($sp)
	addi $sp,$sp,20
	jr $ra
	
writefile:
add $sp, $sp, -12
sw $a0, 0($sp)    #salva o array 
sw $a2, 4($sp)    #salva tam - 1
sw $ra, 8($sp)    #salva endereço de retorno

move $s5, $a0     #t0 = &vetor
addi $s6, $zero, 0  #iterador i = 0
move $s7, $a2     #t2 = tam - 1
addi $s7, $s7, 1


li   $v0, 13       # system call for open file
la   $a0, fin      # input file name
li   $a1, 9        # flag for writing
li   $a2, 0        # mode is ignored
syscall            # open a file 
move $t5, $v0      # save the file descriptor	#


#escreve o pula linha
li $s0, 10
sb $s0, bufitoa

li $v0, 15
move $a0, $t5     #aqui precisa mover o file descriptor pro a0
la $a1, bufitoa
li $a2, 1
syscall
#--------------------------------------------
writeloop:

sll $t1, $s6, 2
add $t1, $s5, $t1
lw $a0,0($t1)		#coloca o inteiro que queremos adicionar ao arquivo como argumento do itoa e do encontraCasaDecimal
#executa o encontraCasaDecimal

addi $s6, $s6, 1

subi $sp,$sp,8
sw $ra,4($sp)
sw $fp,0($sp)
	
jal encontraCasaDecimal
	
lw $fp,0($sp)
lw $ra,4($sp)
addi $sp,$sp,8

move $a1, $v0		#coloca a quantidade de dígitos que teremos em a1 para o itoa
move $a2, $t5

subi $sp,$sp,8
sw $ra,4($sp)
sw $fp,0($sp)
	
jal itoa		#obs: o a2 já está com o file descriptor, ação feita na linha 96
	
lw $fp,0($sp)
lw $ra,4($sp)
addi $sp,$sp,8

beq $s6,$s7,endwrite
j writeloop

endwrite:
lw $a0,0($sp)
lw $a2,4($sp)
lw $ra,8($sp)
addi $sp, $sp, 12
jr $ra

itoa:
	subi $sp,$sp,24
	sw $s0,20($sp)
	sw $s1,16($sp)
	sw $s2,12($sp)
	sw $s3,8($sp)
	sw $s4,4($sp)
	sw $s5,0($sp)
	
	#codigo aqui
	move $s0, $a0			#passa o inteiro de a0 para s0
	move $s1, $a1			#passa o tamanho de chars do inteiro de a1 para s1
	bne $s0, 0, casoNaoZero		#se foi passado zero como inteiro, vai para a parte do print
	addi $s0, $s0, 48
	addi $a1, $zero, 1
	addi $s1, $zero, 1
	add $s2, $zero, $zero
	sb $s0, bufitoa($s2)
	j printItoa
	
	casoNaoZero:
	li $s2, 1			#inicia o divisor com o número 1
	beq $s1, 1, converteParaBuffer	#se o tamanho de chars for 1, já pode ir para a conversão
	bgt $s0, $zero, loopDivItoa	#se não for negativo, pode pular para o loopDivItoa
	sub $s1, $s1, 1
	addi $s5, $zero, 1		#marca que o número é negativo
	beq $s1, 1, converteParaBuffer	#se o tamanho de chars for 1, já pode ir para a conversão
	
	
	loopDivItoa:
	mul $s2, $s2, 10		#multiplica o divisor por 10
	sub $s1, $s1, 1			#diminui em 1 a quantidade de vezes que iremos multiplicar o divisor por 10
	beq $s1, 1, converteParaBuffer	#quando o s1 chegar em 1, significa que o divisor está com o valor correto para pegar todas as casas do inteiro
	j loopDivItoa
	
	converteParaBuffer:
	bne $s5, 1, converteParaBufferPositivo #se não for negativo, vai para converteParaBufferPositivo
	addi $s5, $zero, 45
	li $s1, 0
	sb $s5, bufitoa($s1)
	add $s1, $s1, 1
	addi $s5, $zero, 1
	mul $s0, $s0, -1		#transforma o número negativo para positivo
	j loopConverteParaBuffer
	
	converteParaBufferPositivo:
	li $s1, 0	 		#iremos utilizar o s1 para contar em qual espaço do buffer estamos (começamos em 1 pois o índice 0 tem como char o pula linha)
	loopConverteParaBuffer:
	div $s0, $s2			#divide o inteiro pelo divisor para pegar a primeira casa
	mfhi $s0			#coloca o resto da divisão em s0
	mflo $s4			#em s4 haverá o char que queremos
	addi $s4, $s4, 48		#transforma para o valor ASCII
	sb $s4, bufitoa($s1)		#armazena no buffer no campo do s1, o número que está em s4
	div $s2, $s2, 10		#divide s2 por 10 para o divisor pegar a próxima casa
	addi $s1, $s1, 1		#adiciona 1 ao índice do buffer em que estamos
	beq $s2, $zero, printItoa
	j loopConverteParaBuffer
	
	printItoa:
	li $s4, 32
	sb $s4, bufitoa($s1)
	
	move $s1, $a1
	li $s2, 32
	sub $s2, $s2, $s1
	subi $s2, $s2, 1		#prepara o s2 para dizer quais espaços são inutilizados do buffer, para que não sejam impressos
		
	li $v0, 15			#chama a função para escrita no arquivo
	move $a0, $a2
	la $a1, bufitoa
	li $a2, 32
	sub $a2, $a2, $s2		#diminui o tamanho do buffer em a2 para pegar apenas os dígitos necessários
	syscall
	
	finalItoa:
	lw $s5,0($sp)
	lw $s4,4($sp)
	lw $s3,8($sp)
	lw $s2,12($sp)
	lw $s1,16($sp)
	lw $s0,20($sp)
	addi $sp,$sp,24
	jr $ra

encontraCasaDecimal:
	subi $sp,$sp,20
	sw $s0,16($sp)
	sw $s1,12($sp)
	sw $s2,8($sp)
	sw $s3,4($sp)
	sw $s4,0($sp)
	
	#codigo aqui
	move $s0, $a0		#passa o inteiro de a0 para s0
	add $s1, $zero, $zero	#inicia o s1 como um contador
	beq $s0, 0, finalCasaDecimal #testa se recebemos 0 como inteiro
	li $s2, 10		#s2 será o que contará as casas
	bgt $s0, $zero, loopcontador #se for negativo prossegue, caso contrário, pula para o loopcontador
	addi $s1, $s1, 1
	
	loopcontador:
	div $s0, $s2		#divide o número por 10
	mflo $s0		#atribui o quociente a s0
	addi $s1, $s1, 1	#após a divisão por 10, adiciona 1 ao nº de casas
	beq $s0, $zero, finalCasaDecimal
	j loopcontador
	
	finalCasaDecimal:
	move $v0, $s1
	lw $s4,0($sp)
	lw $s3,4($sp)
	lw $s2,8($sp)
	lw $s1,12($sp)
	lw $s0,16($sp)
	addi $sp,$sp,20
	jr $ra
