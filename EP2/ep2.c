#include <stdio.h>
#include<omp.h>
#include <time.h>

int checaarray (int * vetor,int tam) {
    int i;
    for (i = 1; i <= tam - 1; i++) {
        if (vetor[i-1] > vetor[i]) {
                printf("NÃO ORDENADO! \n");
                return i;
        }
    }
    printf("ORDENADO \n");
    return -1;
}
void printarray(int * p,int tam) {
    int i = 0;
    printf("{");
    while (i < tam) {
        printf("%i, ",p[i]);
        i++;
    }
    printf("}\n");
}



void selectionSort (int tam, int *vetor){
	int i, j, m, aux;
	i = 0;
	j = 0;
	m = 0;
	for (i = 0; i < tam; i++) {
	    m = i;
        #pragma omp for
        for (j = i; j < tam; j++){
            if (vetor[j] < vetor[m])m = j;
        }
        aux = vetor[i];
        vetor[i] = vetor[m];
        vetor[m] = aux;
	}

	/*for (i =0; i < tam; i++){
		int m = i;
		for (j =i+1; j < tam-1; j++) if (vetor [m] > vetor [j]) m= j;

		int aux = vetor [m];
		vetor [m] = vetor [j];
		vetor [j] = aux;
	}*/
}

int divide(int * vetor, int inicio, int fim) { //faz parte do quickSort
    int pivo, aux;
    int i = inicio;
    int j = fim;
    pivo = vetor[inicio];
    while (i < j) {
        while(vetor[i] <= pivo) {
            i++;
        }
        //printf("i = %d ",i);
        while(vetor[j] > pivo) {
            j--;
        }
        //printf("j = %d \n",j);
        #pragma omp critical
        {
            if(i < j) { //if (i >= j)
                //printf("i = %d ",i);
                //printf("j = %d \n",j);
                aux = vetor[i];
                vetor[i] = vetor[j];
                vetor[j] = aux;
            }
        }
    }
    vetor[inicio] = vetor[j];
    vetor[j] = pivo;
    return j;
}
void quickSort(int * vetor, int inicio, int fim) {
    int pivo;
    if (fim > inicio){
        pivo = divide(vetor,inicio,fim);
        //printf("pivo: %d",pivo);
        #pragma omp parallel sections
        {
            #pragma omp section
            quickSort(vetor, inicio, pivo - 1);
            #pragma omp section
            quickSort(vetor, pivo + 1, fim);
        }
    }
}
int ordena (int tam, int tipo, int *vetor){

	if (tipo == 0) selectionSort(tam, vetor);//faz selectionSort
	else  quickSort (vetor, 0, tam - 1);//faz quickSort

	return tam;
}

int main(){
    FILE * arq = fopen("arq25000.txt","r"); //"arquivo".txt deve estar na raiz do projeto
    int tam = 1;
    if (arq == NULL) printf("TA ERRADO");
    int i = 0;
    char ch;
    while(!feof(arq)) {
        fscanf(arq, "%d",&i);
        tam++;
    }
    tam = tam - 2;
    i = 0;
    printf("tam = %d\n", tam);
    int * A;
    A = malloc(tam*sizeof(int));
    fseek(arq, 0, SEEK_SET);
    while (i < tam) {
        fscanf(arq, "%d",&A[i]);
        //printf("numero %d \n",A[i]);
        i++;
    }
    //printarray(A, tam);
    checaarray(A,tam);
    double starttime = omp_get_wtime();
    ordena(tam, 0, A);
    double endtime = omp_get_wtime();
    double tt = (double) (endtime - starttime);
    //printarray(A, tam);
    int aa = checaarray(A,tam);
    if (aa != -1) printf("ÍNDICE DO ERRO: %d",aa);
    printf("tempo: %f",tt);
    return 1;
}
