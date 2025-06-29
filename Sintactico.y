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
#include "assembler.h"
int yystopparser=0;
FILE  *yyin;
extern int yylineno;

  int yyerror(const char *msg);
  int yylex();

void inicializar_codigo_intermedio();

// Variables globales
t_tabla tabla_simbolos;
t_cola c_polaca;
Pila *pila_saltos, *pila_id, *pila_comparadores, *pila_while, *pila_tipos;

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
char comparador[4];
int f_op_not = 0;
int cant_aux = 1;
int nro_celda;
char dato_celda[MAX_CADENA];
int celda_or;
char comparador_or[4];


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

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

programa: instrucciones{
  guardar_tabla_simbolos(&tabla_simbolos);
  guardar_codigo_intermedio(&c_polaca);
  //generar_aux();
  printf("COMPILACION COMPLETADA - Codigo intermedio generado\n");
  generar_assembler(&c_polaca,&tabla_simbolos);
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

si : 
    IF PA condicion PC LA instrucciones LC { 
        printf("ES CONDICION SI\n");
        
        nro_celda = atoi(desapilar(pila_saltos)); 
        sprintf(dato_celda, "etiq_endif%d:", c_polaca.final ->nro+1);
        actualizar_celda(&c_polaca, nro_celda,dato_celda);
        if (!es_pila_vacia(pila_saltos)){
          nro_celda = atoi(desapilar(pila_saltos)); 
          actualizar_celda(&c_polaca, nro_celda,dato_celda);
        }
        insertar_en_polaca(&c_polaca, dato_celda);
      }
    | IF PA condicion PC LA instrucciones LC ELSE {
          insertar_en_polaca(&c_polaca, "BI");
          avanzar_celda(&c_polaca);

          nro_celda = atoi(desapilar(pila_saltos)); 
          sprintf(dato_celda, "etiq_else%d:", c_polaca.final ->nro+1);
          actualizar_celda(&c_polaca, nro_celda,dato_celda);
          if (!es_pila_vacia(pila_saltos)){
            nro_celda = atoi(desapilar(pila_saltos)); 
            actualizar_celda(&c_polaca, nro_celda,dato_celda);
          }

          apilar_celda(&c_polaca, pila_saltos);
          insertar_en_polaca(&c_polaca, dato_celda);
        } 
        LA instrucciones LC { 
          printf("ES CONDICION SINO\n");

          nro_celda = atoi(desapilar(pila_saltos)); 
          sprintf(dato_celda, "etiq_endif%d:", c_polaca.final ->nro+1);
          actualizar_celda(&c_polaca, nro_celda,dato_celda);
          insertar_en_polaca(&c_polaca, dato_celda);
        };

bloque_asig : INIT LA lista_asignacion LC { printf("BLOQUE ASIGNACION\n"); };

lista_asignacion : lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    if (buscar_simbolo(&tabla_simbolos, t_ids[i].cadena) == EXISTE_SIMBOLO){
      char mensaje[200];
      sprintf(mensaje, " El ID %s ya fue declarado ", t_ids[i].cadena); 
      yyerror(mensaje);
    }
    insertar_tabla_simbolos(&tabla_simbolos, t_ids[i].cadena, tipo_dato, "", 0, 0);
  }
  cant_id = 0;
}
| lista_asignacion lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    if (buscar_simbolo(&tabla_simbolos, t_ids[i].cadena) == EXISTE_SIMBOLO){
      char mensaje[200];
      sprintf(mensaje, " El ID %s ya fue declarado ", t_ids[i].cadena); 
      yyerror(mensaje);
    }
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
    id {
      apilar(pila_id, nombre_id);

      if (buscar_simbolo(&tabla_simbolos, nombre_id) == NO_EXISTE_SIMBOLO){
          char mensaje[200];
          sprintf(mensaje, " El ID %s no fue declarado ", nombre_id); 
          yyerror(mensaje);
        }
    } 
      OP_AS expresion 
    {
        printf("    ID = Expresison es ASIGNACION %s\n",nombre_id);
        char *nombre = desapilar(pila_id);

        char *tipo_id = buscar_tipo_simbolo(&tabla_simbolos,nombre);
        apilar(pila_tipos,tipo_id);
        insertar_en_polaca(&c_polaca, nombre);
        insertar_en_polaca(&c_polaca, ":=");
        
        if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
          vaciar_pila(pila_tipos);
          yyerror(" Error en asignacion de datos de distinto tipo ");
        }
    }
;

id:
  ID
  {
    strcpy(nombre_id,$1);
  }
;

expresion:
   termino {
        printf("Termino es Expresion\n");
   }
   | expresion OP_SUM termino {
        printf("Expresion+Termino es Expresion\n");
        insertar_en_polaca(&c_polaca, "+");
        insertar_aux_TS(&tabla_simbolos, &cant_aux);
        
        if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
          vaciar_pila(pila_tipos);
          yyerror(" Tipo de operandos incompatibles para el operador + ");
        }
   }
   | expresion OP_RES termino {
        printf("Expresion-Termino es Expresion\n");
        insertar_en_polaca(&c_polaca, "-");
        insertar_aux_TS(&tabla_simbolos, &cant_aux);
        
        if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
          vaciar_pila(pila_tipos);
          yyerror(" Tipo de operandos incompatibles para el operador - ");
        }
   }
   | negativeCalc
   | sumFirst
;
   
mientras:
  WHILE PA {
    sprintf(dato_celda, "etiq_while%d:", c_polaca.final ->nro+1);
    insertar_en_polaca(&c_polaca, dato_celda);
    apilar_celda(&c_polaca, pila_while);
  } 
  condicion PC LA instrucciones LC 
  {
    printf("ES UN MIENTRAS\n");
    insertar_en_polaca(&c_polaca, "BI");
    sprintf(dato_celda, "etiq_while%s:", desapilar(pila_while));
    insertar_en_polaca(&c_polaca, dato_celda);

    nro_celda = atoi(desapilar(pila_saltos)); 
    sprintf(dato_celda, "etiq_wend%d:", c_polaca.final ->nro+1);
    actualizar_celda(&c_polaca, nro_celda,dato_celda);
    if (!es_pila_vacia(pila_saltos)){
      nro_celda = atoi(desapilar(pila_saltos)); 
      actualizar_celda(&c_polaca, nro_celda,dato_celda);
    }

    insertar_en_polaca(&c_polaca, dato_celda);
  }
;

condicion:
  OP_NOT {f_op_not = 1;} comparacion
  | condicion OP_OR {
      celda_or = atoi(desapilar(pila_saltos)); 
      strcpy(comparador_or,comparador);
  } comparacion {
      sprintf(dato_celda, "etiq_true%d:", c_polaca.final ->nro+1);
      actualizar_celda(&c_polaca, celda_or,dato_celda);
      insertar_en_polaca(&c_polaca, dato_celda);

      complemento_op(comparador_or,comparador);
      actualizar_celda(&c_polaca, celda_or-1,comparador);
    }
  | condicion OP_AND comparacion 
  | comparacion
;

comparacion: 
    expresion operador_comparacion expresion {
      //Verificar tipos de expresion
      insertar_en_polaca(&c_polaca, "CMP");
      insertar_en_polaca(&c_polaca, comparador);
      avanzar_celda(&c_polaca);
      apilar_celda(&c_polaca, pila_saltos);

      if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
        vaciar_pila(pila_tipos);
        yyerror(" Tipo de expresiones incompatibles para una comparacion ");
      }

    }
    | PA condicion PC
;

operador_comparacion:
   OP_MAYOR    {
    if (f_op_not == 1) {
      strcpy(comparador, "BGT");
      f_op_not = 0;
    } else {
      strcpy(comparador, "BLE");
    }
  }
  | OP_MAYORI {
    if (f_op_not == 1) {
      strcpy(comparador, "BGE");
      f_op_not = 0;
    } else {
      strcpy(comparador, "BLT");
    }
  }
  | OP_MEN    {
    if (f_op_not == 1) {
      strcpy(comparador, "BLT");
      f_op_not = 0;
    } else {
      strcpy(comparador, "BGE");
    }
  }
  | OP_MENI   {
    if (f_op_not == 1) {
      strcpy(comparador, "BLE");
      f_op_not = 0;
    } else {
      strcpy(comparador,"BGT");
    }
  }
  | OP_IGUAL  {
    if (f_op_not == 1) {
      strcpy(comparador, "BEQ");
      f_op_not = 0;
    } else {
      strcpy(comparador, "BNE");
    }
  }
  | OP_NOT_IGUAL {
    if (f_op_not == 1) {
      strcpy(comparador, "BNE");
      f_op_not = 0;
    } else {
      strcpy(comparador, "BEQ");
    }
  }
;

termino: 
       factor {printf("Factor es Termino\n");}
       |termino OP_MUL factor {
           printf("Termino*Factor es Termino\n");
           insertar_en_polaca(&c_polaca, "*");
           insertar_aux_TS(&tabla_simbolos, &cant_aux);
           
           if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
              vaciar_pila(pila_tipos);
              yyerror(" Tipo de operandos incompatibles para el operador * ");
            }
       }
       |termino OP_DIV factor {
           printf("Termino/Factor es Termino\n");
           insertar_en_polaca(&c_polaca, "/");
           insertar_aux_TS(&tabla_simbolos, &cant_aux);

           if (valida_tipos_datos(pila_tipos) == OP_NO_COMPATIBLES) {
              vaciar_pila(pila_tipos);
              yyerror(" Tipo de operandos incompatibles para el operador / ");
            }
       }
;

factor: 
      ID 
      {
        printf("ID es Factor \n");
        insertar_en_polaca(&c_polaca, $1);

        if (buscar_simbolo(&tabla_simbolos, $1) == NO_EXISTE_SIMBOLO){
          char mensaje[200];
          sprintf(mensaje, " El ID %s no fue declarado ", $1); 
          yyerror(mensaje);
        }

        char *tipo_id = buscar_tipo_simbolo(&tabla_simbolos,$1);
        apilar(pila_tipos,tipo_id);
      }
      | CTE_STRING 
      {
        printf("ES CONSTANTE STRING\n");
        strcpy(constante_aux_string,$1);
        insertar_tabla_simbolos(&tabla_simbolos, $1, "CTE_STR", $1, 0, 0.0);
        char nombreCte[100] = "_";
        strcat(nombreCte, $1);
        insertar_en_polaca(&c_polaca, nombreCte);
        apilar(pila_tipos,"STRING");
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
        apilar(pila_tipos,"FLOAT");
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
        apilar(pila_tipos,"FLOAT");

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
        apilar(pila_tipos,"FLOAT");
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
        apilar(pila_tipos,"FLOAT");
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
        inicializar_codigo_intermedio();
        yyparse();
    }
  fclose(yyin);
  return 0;
}

int yyerror(const char *msg)
{
  printf("********* Error en linea %d: %s *********\n", yylineno, msg);
  exit (1);
}


void inicializar_codigo_intermedio(){
  inicializar_polaca(&c_polaca);
  pila_id = crear_pila();
  pila_comparadores = crear_pila();
  pila_saltos = crear_pila();
  pila_while = crear_pila();
  pila_tipos = crear_pila();
}
