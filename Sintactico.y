%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
#include "tabla-simbolos.h"
#include "polaca-inversa.h"
#include "pila.h"
#include "cola.h"
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();


// Variables globales
t_tabla tabla_simbolos;
t_cola c_polaca;
t_pila aux_saltos;

// Variables existentes
int i=0;
char tipo_dato[10];
int cant_id = 0;
char nombre_id[20];
int constante_aux_int;
float constante_aux_float;
char constante_aux_string[40];
char aux_string[40];
t_nombresId t_ids[10];


%}

%union{
int tipo_int;
float tipo_float;
char *tipo_str;
}

%start programa
%token <tipo_str>ID
%token <tipo_int>CTE_INT
%token <tipo_float>CTE_FLOAT
%token <tipo_str>CTE_STRING
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token LA
%token LC
%token WHILE
%token IF
%token ELSE
%token OP_MAYOR
%token OP_MEN
%token TYPE_F
%token TYPE_I
%token TYPE_S
%token INIT
%token DP
%token READ
%token WRITE
%token OP_AND
%token OP_OR
%token OP_NOT
%token OP_IGUAL
%token OP_NOT_IGUAL
%token CA
%token CC
%token NEG_CALC
%token SUM_FIRST
%token OP_MAYORI
%token OP_MENI
%token COMA
%token PTO_COMA
%token IGUAL

%%

programa: instrucciones{
  guardar_tabla_simbolos(&tabla_simbolos);
  guardar_codigo_intermedio(&c_polaca);
  printf("COMPILACION COMPLETADA - Codigo intermedio generado\n");
}
;

instrucciones : sentencia { printf(" INSTRUCCIONES ES SENTENCIA\n"); }
| instrucciones sentencia { printf(" INSTRUCCIONES Y SENTENCIA ES PROGRAMA\n"); };

sentencia : asignacion { printf("SENTENCIA ES ASIGNACION\n"); }
| bloque_asig { printf("SENTENCIA ES BLOQUE ASIGNACIONES\n"); }
| mientras { printf("SENTENCIA ES MIENTRAS\n"); }
| si { printf("SENTENCIA ES SI\n"); }
| leer { printf("SENTENCIA ES LEER\n"); }
| escribir { printf("SENTENCIA ES ESCRIBIR\n"); };

si : IF PA condicion PC LA instrucciones LC { 
    printf("ES CONDICION SI\n");
}
| IF PA condicion PC LA instrucciones LC ELSE LA instrucciones LC { 
    printf("ES CONDICION SINO\n");
};

bloque_asig : INIT LA lista_asignacion LC { printf("BLOQUE ASIGNACION\n"); };

lista_asignacion : lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    insertar_tabla_simbolos(&tabla_simbolos, t_ids[i].cadena, tipo_dato, "", 0, 0);
  }
  cant_id = 0;
}
| lista_asignacion lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    insertar_tabla_simbolos(&tabla_simbolos, t_ids[i].cadena, tipo_dato, "", 0, 0);
  }
  cant_id = 0;
}
;

lista_variables: lista_variables COMA ID
                {
                    printf("ES UNA LISTA DE VARIABLES\n");
                    strcpy(t_ids[cant_id].cadena,$3);
                    cant_id++;
                }
                | ID
                {
                    printf("ES UNA VARIABLE\n");
                    strcpy(t_ids[cant_id].cadena,$1);
                    cant_id++;
                }

asig_tipo: 
    DP TYPE_S
    {
        strcpy(tipo_dato,"STRING");
    }
    | DP TYPE_F
    {
        strcpy(tipo_dato,"FLOAT");
    } 
    | DP TYPE_I
    {
        strcpy(tipo_dato,"INTEGER");
    }
;

asignacion: 
    id  OP_AS expresion 
    {
        printf("    ID = Expresion es ASIGNACION %s\n",nombre_id);
        insertar_en_polaca(&c_polaca, "=");
    }
;

id:
  ID
  {
    strcpy(nombre_id,$1);
    insertar_en_polaca(&c_polaca, nombre_id);
  }
;

expresion:
   termino {
        printf("Termino es Expresion\n");
   }
   | expresion OP_SUM termino {
        printf("Expresion+Termino es Expresion\n");
   }
   | expresion OP_RES termino {
        printf("Expresion-Termino es Expresion\n");
   }
   | negativeCalc
   | sumFirst
;
   
mientras:
  WHILE PA condicion PC LA instrucciones LC 
  {
    printf("ES UN MIENTRAS\n");
  }
;

condicion:
  OP_NOT comparacion 
  | condicion OP_OR comparacion 
  | condicion OP_AND comparacion
  | comparacion
;

comparacion: 
    expresion operador_comparacion expresion {
    }
    | PA condicion PC
;

operador_comparacion:
  OP_MAYOR 
  | OP_MAYORI 
  | OP_MEN 
  | OP_MENI 
  | OP_IGUAL 
  | OP_NOT_IGUAL
;

termino: 
       factor {printf("Factor es Termino\n");}
       |termino OP_MUL factor {
           printf("Termino*Factor es Termino\n");
       }
       |termino OP_DIV factor {
           printf("Termino/Factor es Termino\n");
       }
;

factor: 
      ID 
      {
        printf("ID es Factor \n");
        insertar_en_polaca(&c_polaca, $1);
      }
      | CTE_STRING 
      {
        printf("ES CONSTANTE STRING\n");
        strcpy(constante_aux_string,$1);
        insertar_tabla_simbolos(&tabla_simbolos, $1, "CTE_STR", $1, 0, 0.0);
        char nombreCte[100] = "_";
        strcat(nombreCte, $1);
        insertar_en_polaca(&c_polaca, nombreCte);
      }
      | CTE_INT 
      {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;
        itoa(constante_aux_int, nombre_id, 10);
        insertar_tabla_simbolos(&tabla_simbolos, nombre_id, "CTE_INT", "", $1, 0.0);
        char nombreCte[100] = "_";
        strcat(nombreCte, nombre_id);
        insertar_en_polaca(&c_polaca, nombreCte);
      }
      | OP_RES CTE_INT
      {
        constante_aux_int=$2;
        int cteneg = constante_aux_int * (-1);
        itoa(cteneg, nombre_id, 10);
        printf("ES CONSTANTE int NEG %d\n", cteneg);
        insertar_tabla_simbolos(&tabla_simbolos, nombre_id, "CTE_INT", "", cteneg, 0.0);
        char nombreCte[100] = "_";
        strcat(nombreCte, nombre_id);
        insertar_en_polaca(&c_polaca, nombreCte);

      }
      | OP_RES CTE_FLOAT
      {
        constante_aux_float=$2;
        float cteneg = constante_aux_float * (-1);
        sprintf(nombre_id, "%f", cteneg);  
        printf("ES CONSTANTE float NEG %f\n", cteneg);
        insertar_tabla_simbolos(&tabla_simbolos, nombre_id, "CTE_FLOAT", "", 0, cteneg);
        char nombreCte[100] = "_";
        strcat(nombreCte, nombre_id);
        insertar_en_polaca(&c_polaca, nombreCte);
      }
      | CTE_FLOAT 
      {
        printf("ES CONSTANTE FLOAT\n");
        constante_aux_float=$1;
        sprintf(nombre_id, "%f", $1); 
        insertar_tabla_simbolos(&tabla_simbolos, nombre_id, "CTE_FLOAT", "", 0, $1);
        char nombreCte[100] = "_";
        strcat(nombreCte, nombre_id);
        insertar_en_polaca(&c_polaca, nombreCte);
      }
      | PA expresion PC {printf("Expresion entre parentesis es Factor\n");}
;

leer : 
     READ PA ID PC {
         printf("ES READ\n");
     }
;

escribir:
    WRITE PA CTE_STRING PC   {
        printf("ES WRITE CONSTANTE\n");
    }
    | WRITE PA ID PC         {
        printf("ES WRITE ID\n");
    }

sumFirst:
  SUM_FIRST PA CTE_INT PC
;

negativeCalc:
 NEG_CALC
  {printf("es negaaaaaaaaaaaative");}
  PA lista_num PC 
;

lista_num: 
  lista_num COMA num 
  | lista_num COMA ID 
  | num
  | ID
;

num: 
  CTE_INT 
  | CTE_FLOAT 
  | OP_RES CTE_INT 
  | OP_RES CTE_FLOAT 
;

%%

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        crear_tabla_simbolos(&tabla_simbolos);
        inicializar_codigo_intermedio(&c_polaca);
        yyparse();
    }
  fclose(yyin);
  return 0;
}

int yyerror(void)
{
  printf("\n ********* Error Sintactico ********* \n");
  exit (1);
}
