/*--------------------------------------------------------
 *      A N A L I S A D O R   S I N T A T I C O           
 *                                                        
 *     Por Luiz Eduardo da Silva      JANEIRO-2013          
 *--------------------------------------------------------*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#include "utils.c"
#include "lexico.c"
%}

// Simbolo de partida
%start programa

// Simbolos terminais
%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_ABRECOLCHETES
%token T_FECHACOLCHETES
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO

// Precedencia e associatividade
%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

// Regras de producao
programa
      : cabecalho
           { printf ("\tINPP\n"); }  
        variaveis
        T_INICIO 
        {if(CONTA_ULT > 0) printf ("\tAMEM\t%d\n", CONTA_ULT); }

          lista_comandos 
        T_FIM
           { 
              printf ("\tDMEM\n");
              printf ("\tFIMP\n"); 

          }
      ;

cabecalho
      : T_PROGRAMA T_IDENTIF 
      ;

variaveis
      :  /* vazio */
      |  declaracao_variaveis 
      ;

declaracao_variaveis
      : declaracao_variaveis
        tipo 
          { CONTA_VARS = 0; }
        lista_variaveis 
         // { printf ("\tAMEM\t%d\n", CONTA_VARS); }
      | tipo 
          { CONTA_VARS = 0; }
        lista_variaveis
        //  { printf ("\tAMEM\t%d\n", CONTA_VARS); }
      ;

tipo
      : T_LOGICO {TIPO = 1;}
      | T_INTEIRO{TIPO = 0;}
      ;

lista_variaveis
      : lista_variaveis 
        T_IDENTIF 
          
          { strcpy(SALVAIDENTIFICADOR, atomo); }
            encontra_vetor

      | T_IDENTIF
          { strcpy(SALVAIDENTIFICADOR, atomo); }
            encontra_vetor
      ;


encontra_vetor
      : { insere_variavel (SALVAIDENTIFICADOR, 1, TIPO); CONTA_VARS++; CONTA_ULT++; }
      | T_ABRECOLCHETES
          T_NUMERO
              { int tam = atoi(atomo); int d = CONTA_ULT; 
                char nome_ident[50];
               
                CONTA_VARS+=tam;d+=tam;
               
                strcpy(nome_ident, SALVAIDENTIFICADOR);
                
                
                
                insere_variavel (nome_ident, tam, TIPO  ); 
                CONTA_ULT = d;
              }
        T_FECHACOLCHETES
      ;




lista_comandos
      : /* vazio */
      | comando lista_comandos
      ;

comando
      : entrada_saida
      | repeticao
      | selecao
      | atribuicao
      ;

entrada_saida
      : leitura
      | escrita
      ;

leitura
      : T_LEIA  
        T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
                ERRO ("Variavel [%s] nao declarada!",
                           atomo);
	    else {
                printf ("\tLEIA\n");
                printf ("\tARZG\t%d\n", 
                        TSIMB[POS_SIMB].desloca); 
            }
          }
      ;

escrita
      : T_ESCREVA expressao
          { printf ("\tESCR\n"); }
      ;

repeticao
      : T_ENQTO
           { 
             printf ("L%d\tNADA\n", ++ROTULO);
             empilha (ROTULO);
           } 
        expressao 
        T_FACA 
           {
             printf ("\tDSVF\tL%d\n",++ROTULO);
             empilha (ROTULO);
           }
        lista_comandos 
        T_FIMENQTO
           {
             aux = desempilha();
             printf ("\tDSVS\tL%d\n", desempilha()); 
             printf ("L%d\tNADA\n", aux);           
           }
      ;

selecao
      : T_SE 
        expressao 
           {
             printf ("\tDSVF\tL%d\n", ++ROTULO); 
             empilha (ROTULO);
           }  
        T_ENTAO 
        lista_comandos 
        T_SENAO 
           {
             printf ("\tDSVS\tL%d\n", ++ROTULO);
             printf ("L%d\tNADA\n", desempilha()); 
             empilha (ROTULO);
           }
        lista_comandos 
        T_FIMSE
           { 
             printf ("L%d\tNADA\n", desempilha());    
           }
      ;

atribuicao
      
      : T_IDENTIF 
       { POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
                ERRO ("Variavel [%s] nao declarada!", atomo);
            else{
              //empilha (TSIMB[POS_SIMB].desloca);
              empilha(TSIMB[POS_SIMB].tipo);
              VETORES[++i_vetores] = POS_SIMB;
           }
        }
       T_ABRECOLCHETES expressao_vetor
       {
        if (desempilha())
          ERRO("Indice inválido");
        }
        T_FECHACOLCHETES

       T_ATRIB 
        expressao
          { 
      
            printf ("\tARZV\t%d\n", (TSIMB[VETORES[i_vetores--]].desloca));

             if(desempilha() != desempilha())
            ERRO("Tipos diferentes na atribuicao.");  
         }
      


      | T_IDENTIF 
          { 
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
                ERRO ("Variavel [%s] nao declarada!",
                      atomo);
	    else
                VETORES[++i_vetores] = POS_SIMB;
                empilha (TSIMB[POS_SIMB].tipo); 
          }
        T_ATRIB 
        expressao
          { 
            if(desempilha() != desempilha())
            ERRO("Tipos diferentes na atribuicao.");
            printf ("\tARZG\t%d\n", TSIMB[VETORES[i_vetores--]].desloca); 

          }
      ;

expressao
      
      : expressao T_VEZES expressao 
          { printf ("\tMULT\n");compatibilidade(ARI); }
      | expressao T_DIV expressao
          { printf ("\tDIVI\n");compatibilidade(ARI); }
      | expressao T_MAIS expressao
          { printf ("\tSOMA\n");compatibilidade(ARI); }
      | expressao T_MENOS expressao
          { printf ("\tSUBT\n");compatibilidade(ARI); }
      | expressao T_MAIOR expressao
          { printf ("\tCMMA\n"); compatibilidade(RE);}
      | expressao T_MENOR expressao
          { printf ("\tCMME\n"); compatibilidade(RE);}
      | expressao T_IGUAL expressao
          { printf ("\tCMIG\n");compatibilidade(RE); }
      | expressao T_E expressao
          { printf ("\tCONJ\n"); compatibilidade(LOGICA);}
      | expressao T_OU expressao
          { printf ("\tDISJ\n"); compatibilidade(LOGICA);}
      
      | termo


      ;

termo
      :  T_IDENTIF
            {strcpy(SALVAVETOR, atomo);
              empilha (TSIMB[busca_simbolo (SALVAVETOR)].tipo); 
            }
               T_ABRECOLCHETES
               {VETORES[++i_vetores] = busca_simbolo (SALVAVETOR);}
              expressao_vetor

          {
            
              printf ("\tCRVV\t%d\n", 
             TSIMB[VETORES[i_vetores--]].desloca );
               
          }

          T_FECHACOLCHETES

        
      

      | T_NUMERO
          { printf ("\tCRCT\t%s\n", atomo);
            empilha(INT);
          } 
      | T_V
          { printf ("\tCRCT\t1\n");
            empilha(LOG);
          } 
      | T_F
          { printf ("\tCRCT\t0\n");
            empilha(LOG);
          } 
      | T_NAO termo
          { printf ("\tNEGA\n");
            empilha(LOG);
          }
      | T_ABRE expressao T_FECHA

      
             
          |  T_IDENTIF
          {
            POS_SIMB = busca_simbolo (atomo);
            if (POS_SIMB == -1)
               ERRO ("Variavel [%s] nao declarada!",
                         atomo);
      else {

               printf ("\tCRVG\t%d\n", 
                       TSIMB[POS_SIMB].desloca); 
                      empilha (TSIMB[POS_SIMB].tipo);


            }   
          }  
      ;

expressao_vetor
      : termo
      | expressao_vetor T_VEZES expressao_vetor 
          { printf ("\tMULT\n"); compatibilidade(ARI);}
      | expressao_vetor T_DIV expressao_vetor
          { printf ("\tDIVI\n"); compatibilidade(ARI); }
      | expressao_vetor T_MAIS expressao_vetor
          { printf ("\tSOMA\n"); compatibilidade(ARI);}
      | expressao_vetor T_MENOS expressao_vetor
          { printf ("\tSUBT\n"); compatibilidade(ARI);}
 
      
      
      ;
%%
/*+--------------------------------------------------------+
  |          Corpo principal do programa COMPILADOR        |
  +--------------------------------------------------------+*/

yywrap () {
}

yyerror (char *s)
{
  ERRO ("ERRO SINTATICO");
}

main ()
{
  yyparse ();
}
