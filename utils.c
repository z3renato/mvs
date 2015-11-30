/*---------------------------------------------------------
 *  Estruturas e Rotinas Utilitarias do Compilador
 *
 *  Por Luiz Eduardo da Silva
 *--------------------------------------------------------*/

/*---------------------------------------------------------
 *  Limites das estruturas
 *--------------------------------------------------------*/
#define TAM_TSIMB 100  /* Tamanho da tabela de simbolos */
#define TAM_PSEMA 100  /* Tamanho da pilha semantica    */


/*---------------------------------------------------------
 *  Variaveis globais
 *--------------------------------------------------------*/
int TOPO_TSIMB     = 0;  /* TOPO da tabela de simbolos */
int TOPO_PSEMA     = 0;  /* TOPO da pilha semantica */
int ROTULO         = 0;  /* Proximo numero de rotulo */
int CONTA_VARS     = 0;  /* Numero de variaveis */
int CONTA_ULT       = 0;  /* Guarda último id de variável*/
int POS_SIMB;            /* Pos. na tabela de simbolos */
int aux;                 /* variavel auxiliar */
int numLinha = 1; /* numero da linha no programa */
char atomo[30];   /* nome de um identif. ou numero */
char SALVAIDENTIFICADOR[50], SALVAVETOR[50];
enum enum_tipo {INT, LOG};
enum enum_op {LOGICA, ARI, RE};
int TIPO, save, salva, salvou = 0;
int VETORES[200], i_vetores=0;


/*---------------------------------------------------------
 *  Rotina geral de tratamento de erro
 *--------------------------------------------------------*/
void ERRO (char *msg, ...) {
  char formato [255];
  va_list arg;
  va_start (arg, msg);
  sprintf (formato, "\n%d: ", numLinha-1);
  strcat (formato, msg);
  strcat (formato, "\n\n");
  printf ("\nERRO no programa"); 
  vprintf (formato, arg);
  va_end (arg);
  exit (1);
}

void upper_case(char *s){
  while(*s){
    *s = toupper(*s);
    s++;
  }
}

/*---------------------------------------------------------
 *  Tabela de Simbolos
 *--------------------------------------------------------*/
struct elem_tab_simbolos {
  char id[30];
  int desloca;
  int tamanho ;
  int tipo;

} TSIMB [TAM_TSIMB], elem_tab;

/*---------------------------------------------------------
 *  Pilha Semantica
 *--------------------------------------------------------*/
int PSEMA[TAM_PSEMA];

/*---------------------------------------------------------
*   Função que verifica a compatibilidade de tipos 
*--------------------------------------------------------*/





/*---------------------------------------------------------
 * Funcao que BUSCA um simbolo na tabela de simbolos.       
 *      Retorna -1 se o simbolo nao esta' na tabela        
 *      Retorna i, onde i e' o indice do simbolo na tabela
 *                 se o simbolo esta' na tabela             
 *--------------------------------------------------------*/
int busca_simbolo (char *ident)
{
  upper_case(ident);
  int i = TOPO_TSIMB-1;
  for (;strcmp (TSIMB[i].id, ident) && i >= 0; i--);
  return i;
}
void mostra_tabela_simbolos(){
  int i;
  printf("\n%3s\t%20s\t%4s\t%3s\t%3s\n", "#", "id", "tipo", "tam", "dsl");
  for (i=0; i < TOPO_TSIMB; i++)
    printf("%3d\t%20s\t%3d\t%3d\t%3d\n", i, TSIMB[i].id,TSIMB[i].tipo, TSIMB[i].tamanho, TSIMB[i].desloca);
  printf("\n\n");
}
/*---------------------------------------------------------
 * Funcao que INSERE um simbolo na tabela de simbolos.      
 *    Se ja' existe um simbolo com mesmo nome e mesmo nivel 
 *    uma mensagem de erro e' apresentada e o  programa  e' 
 *    interrompido.                                         
 *--------------------------------------------------------*/
void insere_simbolo (struct elem_tab_simbolos *elem)
{
  if (TOPO_TSIMB == TAM_TSIMB) {
     ERRO ("OVERFLOW - tabela de simbolos");
  }
  else {
     POS_SIMB = busca_simbolo (elem->id);
     if (POS_SIMB != -1) {
       ERRO ("Identificador [%s] duplicado", elem->id);
     }  
     TSIMB [TOPO_TSIMB] = *elem;
     TOPO_TSIMB++;
  }
  mostra_tabela_simbolos();
}


/*---------------------------------------------------------
 * Funcao de insercao de uma variavel na tabela de simbolos
 *---------------------------------------------------------*/
void insere_variavel (char *ident, int tam, int tipo) {
   upper_case(ident);
   strcpy (elem_tab.id, ident);
   elem_tab.desloca = CONTA_ULT;
   elem_tab.tamanho = tam;
   elem_tab.tipo = tipo;
   insere_simbolo (&elem_tab);
}

/*---------------------------------------------------------
 * Rotinas para manutencao da PILHA SEMANTICA              
 *--------------------------------------------------------*/
void empilha (int n) {
  if (TOPO_PSEMA == TAM_PSEMA) {
     ERRO ("OVERFLOW - Pilha Semantica");
  }
  PSEMA[TOPO_PSEMA++] = n;
}

int desempilha () {
  if (TOPO_PSEMA == 0) {
     ERRO ("UNDERFLOW - Pilha Semantica");
  }
  return PSEMA[--TOPO_PSEMA];
}

void compatibilidade(enum enum_op t_operacao){
  int t1 = desempilha();
  int t2 = desempilha();
  if(t1 != t2)
    ERRO("Tipos imcompatíveis");
  if(t_operacao == LOGICA){
    if(t1 != LOG || t2!= LOG)
      ERRO("Operadores inválidos");
    else
      empilha(t2);
      empilha(t1);
  }

  if(t_operacao == RE){
    if(t1 != t2)
      ERRO("Operadores inválidos");
    else{
      empilha(t2);
      empilha(t1);
    }
  }
   if(t_operacao == ARI){
    if(t1 != INT || t2 != INT)
      ERRO("Operadores inválidos");
    else{
      empilha(t2);
      empilha(t1);
   } 

 }

  

}