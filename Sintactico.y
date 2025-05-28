%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include <string.h>
#include <math.h>
int yystopparser=0;
FILE  *yyin;

  int yyerror();
  int yylex();

/* --- Estructura de la tabla de simbolos --- */

typedef struct
{
        char *nombre;
        char *tipo;
        union Valor{
                int valor_var_int;
                float valor_var_float;
                char *valor_var_str;
        }valor;
        int longitud;
}t_data;

typedef struct s_simbolo
{
        t_data data;
        struct s_simbolo *next;
}t_simbolo;

typedef struct
{
        t_simbolo *primero;
}t_tabla;

typedef struct{
  char cadena[40];
}t_nombresId;

/* --- Estructuras para código intermedio --- */

typedef struct {
    char operador[10];
    char operando1[50];
    char operando2[50]; 
    char resultado[50];
} t_cuadrupla;

typedef struct nodo_cuadrupla {
    t_cuadrupla cuadrupla;
    struct nodo_cuadrupla *siguiente;
} t_nodo_cuadrupla;

typedef struct {
    t_nodo_cuadrupla *primera;
    t_nodo_cuadrupla *ultima;
    int contador;
} t_lista_cuadruplas;

/* --- Estructura para pila de polaca inversa --- */
typedef struct nodo_pila {
    char dato[50];
    struct nodo_pila *siguiente;
} t_nodo_pila;

typedef struct {
    t_nodo_pila *tope;
} t_pila;

// Declaracion funciones tabla simbolos
void crear_tabla_simbolos();
int insertar_tabla_simbolos(const char*, const char*, const char*, int, float);
t_data* crearDatos(const char*, const char*, const char*, int, float);
void guardar_tabla_simbolos();

// Declaracion funciones codigo intermedio
void inicializar_codigo_intermedio();
void generar_cuadrupla(const char *op, const char *arg1, const char *arg2, const char *res);
char* generar_temporal();
void guardar_codigo_intermedio();
void mostrar_cuadruplas();

// Funciones para pila (polaca inversa)
void inicializar_pila(t_pila *pila);
void apilar(t_pila *pila, const char *elemento);
char* desapilar(t_pila *pila);
int pila_vacia(t_pila *pila);
void liberar_pila(t_pila *pila);

// Funciones para generar código de expresiones
char* procesar_expresion_polaca(t_pila *pila_operandos, t_pila *pila_operadores);
void agregar_operando(t_pila *pila, const char *operando);
void agregar_operador(t_pila *pila_operandos, t_pila *pila_operadores, const char *operador);
char* evaluar_polaca(t_pila *pila_operandos, t_pila *pila_operadores);

// Variables globales
t_tabla tabla_simbolos;
t_lista_cuadruplas lista_codigo;
int contador_temporal = 1;
int contador_etiqueta = 1;

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

// Variables para manejo de expresiones
t_pila pila_operandos_global;
t_pila pila_operadores_global;
char resultado_expresion[50];
char variable_asignacion[50];

%}

%union {
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
  guardar_tabla_simbolos();
  guardar_codigo_intermedio();
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
    char etiq[20];
    sprintf(etiq, "FIN_IF_%d", contador_etiqueta++);
    generar_cuadrupla("LABEL", etiq, "", "");
}
| IF PA condicion PC LA instrucciones LC ELSE LA instrucciones LC { 
    printf("ES CONDICION SINO\n");
    char etiq_else[20], etiq_fin[20];
    sprintf(etiq_else, "ELSE_%d", contador_etiqueta);
    sprintf(etiq_fin, "FIN_IF_%d", contador_etiqueta++);
    generar_cuadrupla("LABEL", etiq_else, "", "");
    generar_cuadrupla("LABEL", etiq_fin, "", "");
};

bloque_asig : INIT LA lista_asignacion LC { printf("BLOQUE ASIGNACION\n"); };

lista_asignacion : lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
    // Generar código intermedio para declaración
    generar_cuadrupla("DECL", tipo_dato, "", t_ids[i].cadena);
  }
  cant_id = 0;
}
| lista_asignacion lista_variables asig_tipo
{
  for (i = 0; i < cant_id; i++)
  {
    insertar_tabla_simbolos(t_ids[i].cadena, tipo_dato, "", 0, 0);
    generar_cuadrupla("DECL", tipo_dato, "", t_ids[i].cadena);
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
    id OP_AS { 
        strcpy(variable_asignacion, nombre_id);
        inicializar_pila(&pila_operandos_global);
        inicializar_pila(&pila_operadores_global);
    } expresion 
    {
        printf("    ID = Expresion es ASIGNACION\n");
        // Evaluar la expresión en polaca inversa
        char *temp_result = evaluar_polaca(&pila_operandos_global, &pila_operadores_global);
        if (temp_result != NULL) {
            strcpy(resultado_expresion, temp_result);
        }
        
        // Generar cuádrupla de asignación
        generar_cuadrupla("=", resultado_expresion, "", variable_asignacion);
        
        liberar_pila(&pila_operandos_global);
        liberar_pila(&pila_operadores_global);
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
        agregar_operador(&pila_operandos_global, &pila_operadores_global, "+");
   }
   | expresion OP_RES termino {
        printf("Expresion-Termino es Expresion\n");
        agregar_operador(&pila_operandos_global, &pila_operadores_global, "-");
   }
   | negativeCalc
   | sumFirst
;
   
mientras:
  WHILE { 
    char etiq_inicio[20];
    sprintf(etiq_inicio, "WHILE_INICIO_%d", contador_etiqueta);
    generar_cuadrupla("LABEL", etiq_inicio, "", "");
  } PA condicion PC LA instrucciones LC 
  {
    printf("ES UN MIENTRAS\n");
    char etiq_inicio[20], etiq_fin[20];
    sprintf(etiq_inicio, "WHILE_INICIO_%d", contador_etiqueta);
    sprintf(etiq_fin, "WHILE_FIN_%d", contador_etiqueta++);
    generar_cuadrupla("JMP", etiq_inicio, "", "");
    generar_cuadrupla("LABEL", etiq_fin, "", "");
  }
;

condicion:
  OP_NOT comparacion {
    char *temp = generar_temporal();
    generar_cuadrupla("NOT", resultado_expresion, "", temp);
    strcpy(resultado_expresion, temp);
  }
  | condicion OP_OR comparacion {
    char *temp = generar_temporal();
    generar_cuadrupla("OR", resultado_expresion, "", temp);
    strcpy(resultado_expresion, temp);
  }
  | condicion OP_AND comparacion {
    char *temp = generar_temporal();
    generar_cuadrupla("AND", resultado_expresion, "", temp);
    strcpy(resultado_expresion, temp);
  }
  | comparacion
;

comparacion: 
    expresion operador_comparacion expresion {
    }
    | PA condicion PC
;

operador_comparacion:
  OP_MAYOR { agregar_operador(&pila_operandos_global, &pila_operadores_global, ">"); }
  | OP_MAYORI { agregar_operador(&pila_operandos_global, &pila_operadores_global, ">="); }
  | OP_MEN { agregar_operador(&pila_operandos_global, &pila_operadores_global, "<"); }
  | OP_MENI { agregar_operador(&pila_operandos_global, &pila_operadores_global, "<="); }
  | OP_IGUAL { agregar_operador(&pila_operandos_global, &pila_operadores_global, "=="); }
  | OP_NOT_IGUAL { agregar_operador(&pila_operandos_global, &pila_operadores_global, "!="); }
;

termino: 
       factor {printf("Factor es Termino\n");}
       |termino OP_MUL factor {
           printf("Termino*Factor es Termino\n");
           agregar_operador(&pila_operandos_global, &pila_operadores_global, "*");
       }
       |termino OP_DIV factor {
           printf("Termino/Factor es Termino\n");
           agregar_operador(&pila_operandos_global, &pila_operadores_global, "/");
       }
;

factor: 
      ID 
      {
        printf("ID es Factor \n");
        agregar_operando(&pila_operandos_global, $1);
      }
      | CTE_STRING 
      {
        printf("ES CONSTANTE STRING\n");
        strcpy(constante_aux_string,$1);
        insertar_tabla_simbolos($1, "CTE_STR", $1, 0, 0.0);
        agregar_operando(&pila_operandos_global, $1);
      }
      | CTE_INT 
      {
        printf("ES CONSTANTE INT\n");
        constante_aux_int=$1;
        itoa(constante_aux_int, nombre_id, 10);
        insertar_tabla_simbolos(nombre_id, "CTE_INT", "", $1, 0.0);
        agregar_operando(&pila_operandos_global, nombre_id);
      }
      | OP_RES CTE_INT
      {
        constante_aux_int=$2;
        int cteneg = constante_aux_int * (-1);
        itoa(cteneg, nombre_id, 10);
        printf("ES CONSTANTE int NEG %d\n", cteneg);
        insertar_tabla_simbolos(nombre_id, "CTE_INT", "", cteneg, 0.0);
        agregar_operando(&pila_operandos_global, nombre_id);
      }
      | OP_RES CTE_FLOAT
      {
        constante_aux_float=$2;
        float cteneg = constante_aux_float * (-1);
        sprintf(nombre_id, "%f", cteneg);  
        printf("ES CONSTANTE float NEG %f\n", cteneg);
        insertar_tabla_simbolos(nombre_id, "CTE_FLOAT", "", 0, cteneg);
        agregar_operando(&pila_operandos_global, nombre_id);
      }
      | CTE_FLOAT 
      {
        printf("ES CONSTANTE FLOAT\n");
        constante_aux_float=$1;
        sprintf(nombre_id, "%f", $1); 
        insertar_tabla_simbolos(nombre_id, "CTE_FLOAT", "", 0, $1);
        agregar_operando(&pila_operandos_global, nombre_id);
      }
      | PA expresion PC {printf("Expresion entre parentesis es Factor\n");}
;

leer : 
     READ PA ID PC {
         printf("ES READ\n");
         generar_cuadrupla("READ", "", "", $3);
     }
;

escribir:
    WRITE PA CTE_STRING PC   {
        printf("ES WRITE CONSTANTE\n");
        generar_cuadrupla("write", $3, "", "");
    }
    | WRITE PA ID PC         {
        printf("ES WRITE ID\n");
        generar_cuadrupla("write", $3, "", "");
    }

sumFirst:
  SUM_FIRST PA CTE_INT PC {
    char temp_num[20];
    itoa($3, temp_num, 10);
    char *temp = generar_temporal();
    generar_cuadrupla("CALL", "sumFirstPrimes", temp_num, temp);
    strcpy(resultado_expresion, temp);
  }
;

negativeCalc:
 NEG_CALC
  {printf("es negaaaaaaaaaaaative");}
  PA lista_num PC {
    char *temp = generar_temporal();
    generar_cuadrupla("CALL", "negativeCalculation", "", temp);
    strcpy(resultado_expresion, temp);
  }
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
        crear_tabla_simbolos();
        inicializar_codigo_intermedio();
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

/* === FUNCIONES DE CODIGO INTERMEDIO === */

void inicializar_codigo_intermedio() {
    lista_codigo.primera = NULL;
    lista_codigo.ultima = NULL;
    lista_codigo.contador = 0;
}

void generar_cuadrupla(const char *op, const char *arg1, const char *arg2, const char *res) {
    t_nodo_cuadrupla *nuevo = (t_nodo_cuadrupla*)malloc(sizeof(t_nodo_cuadrupla));
    
    strcpy(nuevo->cuadrupla.operador, op);
    strcpy(nuevo->cuadrupla.operando1, arg1 ? arg1 : "");
    strcpy(nuevo->cuadrupla.operando2, arg2 ? arg2 : "");
    strcpy(nuevo->cuadrupla.resultado, res ? res : "");
    nuevo->siguiente = NULL;
    
    if (lista_codigo.primera == NULL) {
        lista_codigo.primera = nuevo;
        lista_codigo.ultima = nuevo;
    } else {
        lista_codigo.ultima->siguiente = nuevo;
        lista_codigo.ultima = nuevo;
    }
    
    lista_codigo.contador++;
}

char* generar_temporal() {
    static char temp[20];
    sprintf(temp, "T%d", contador_temporal++);
    return temp;
}

void guardar_codigo_intermedio() {
    FILE *archivo = fopen("intermediate-code.txt", "w");
    if (!archivo) {
        printf("Error: No se pudo crear el archivo intermediate-code.txt\n");
        return;
    }
    
    fprintf(archivo, "========== CODIGO INTERMEDIO ==========\n");
    fprintf(archivo, "%-5s %-10s %-15s %-15s %-15s\n", "NUM", "OP", "ARG1", "ARG2", "RESULT");
    fprintf(archivo, "=========================================\n");
    
    t_nodo_cuadrupla *actual = lista_codigo.primera;
    int num = 1;
    
    while (actual != NULL) {
        fprintf(archivo, "%-5d %-10s %-15s %-15s %-15s\n", 
                num++,
                actual->cuadrupla.operador,
                actual->cuadrupla.operando1,
                actual->cuadrupla.operando2,
                actual->cuadrupla.resultado);
        actual = actual->siguiente;
    }
    
    fprintf(archivo, "\n========== NOTACION POLACA INVERSA ==========\n");
    fprintf(archivo, "Las expresiones se evaluan usando pila:\n");
    fprintf(archivo, "Ejemplo: a + b * c se convierte en: a b c * +\n");
    
    fclose(archivo);
    printf("Codigo intermedio guardado en 'intermediate-code.txt'\n");
}

/* === FUNCIONES DE PILA PARA POLACA INVERSA === */

void inicializar_pila(t_pila *pila) {
    pila->tope = NULL;
}

void apilar(t_pila *pila, const char *elemento) {
    t_nodo_pila *nuevo = (t_nodo_pila*)malloc(sizeof(t_nodo_pila));
    strcpy(nuevo->dato, elemento);
    nuevo->siguiente = pila->tope;
    pila->tope = nuevo;
}

char* desapilar(t_pila *pila) {
    if (pila_vacia(pila)) return NULL;
    
    t_nodo_pila *temp = pila->tope;
    static char resultado[50];
    strcpy(resultado, temp->dato);
    pila->tope = temp->siguiente;
    free(temp);
    return resultado;
}

int pila_vacia(t_pila *pila) {
    return pila->tope == NULL;
}

void liberar_pila(t_pila *pila) {
    while (!pila_vacia(pila)) {
        desapilar(pila);
    }
}

void agregar_operando(t_pila *pila, const char *operando) {
    apilar(pila, operando);
}

void agregar_operador(t_pila *pila_operandos, t_pila *pila_operadores, const char *operador) {
    apilar(pila_operadores, operador);
}

char* evaluar_polaca(t_pila *pila_operandos, t_pila *pila_operadores) {
    if (pila_vacia(pila_operadores)) {
        return desapilar(pila_operandos);
    }
    
    char *operador = desapilar(pila_operadores);
    char *operando2 = desapilar(pila_operandos);
    char *operando1 = desapilar(pila_operandos);
    
    char *temp = generar_temporal();
    
    if (operando1 && operando2) {
        generar_cuadrupla(operador, operando1, operando2, temp);
    } else if (operando1) {
        generar_cuadrupla(operador, operando1, "", temp);
    }
    
    return temp;
}

/* === FUNCIONES EXISTENTES DE TABLA DE SIMBOLOS === */

int insertar_tabla_simbolos(const char *nombre, const char *tipo,
                            const char *valor_string, int valor_var_int,
                            float valor_var_float)
{
  t_simbolo *tabla = tabla_simbolos.primero;
  char nombreCTE[100] = "_";
  strcat(nombreCTE, nombre);

  while (tabla)
  {
    if (strcmp(tipo, "STRING") == 0 || strcmp(tipo, "INTEGER") == 0 || strcmp(tipo, "FLOAT") == 0)
    {
      if (strcmp(tabla->data.nombre, nombre) == 0)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_STR") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_STR") == 0 &&
          strcmp(tabla->data.valor.valor_var_str, valor_string) == 0)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_INT") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_INT") == 0 &&
          tabla->data.valor.valor_var_int == valor_var_int)
      {
        return 1;
      }
    }
    else if (strcmp(tipo, "CTE_FLOAT") == 0)
    {
      if (strcmp(tabla->data.tipo, "CTE_FLOAT") == 0 &&
          tabla->data.valor.valor_var_float == valor_var_float)
      {
        return 1;
      }
    }

    if (tabla->next == NULL)
    {
      break;
    }
    tabla = tabla->next;
  }

  t_data *data = crearDatos(nombre, tipo, valor_string, valor_var_int, valor_var_float);
  if (data == NULL)
  {
    return 1;
  }

  t_simbolo *nuevo = (t_simbolo *)malloc(sizeof(t_simbolo));
  if (nuevo == NULL)
  {
    free(data);
    return 2;
  }

  nuevo->data = *data;
  nuevo->next = NULL;

  if (tabla_simbolos.primero == NULL)
  {
    tabla_simbolos.primero = nuevo;
  }
  else
  {
    tabla->next = nuevo;
  }

  return 0;
}

t_data *crearDatos(const char *nombre, const char *tipo,
                   const char *valString, int valor_var_int,
                   float valor_var_float)
{
  t_data *data = (t_data *)calloc(1, sizeof(t_data));
  if (data == NULL)
  {
    return NULL;
  }

  data->tipo = (char *)malloc(sizeof(char) * (strlen(tipo) + 1));
  if (data->tipo == NULL)
  {
    free(data);
    return NULL;
  }
  strcpy(data->tipo, tipo);

  if (strcmp(tipo, "STRING") == 0 || strcmp(tipo, "INTEGER") == 0 || strcmp(tipo, "FLOAT") == 0)
  {
    data->nombre = (char *)malloc(sizeof(char) * (strlen(nombre) + 1));
    if (data->nombre == NULL)
    {
      free(data->tipo);
      free(data);
      return NULL;
    }
    strcpy(data->nombre, nombre);
    return data;
  }
  else
  {
    char nombreCte[100] = "_";
    strcat(nombreCte, nombre);

    data->nombre = (char *)malloc(sizeof(char) * (strlen(nombreCte) + 1));
    if (data->nombre == NULL)
    {
      free(data->tipo);
      free(data);
      return NULL;
    }
    strcpy(data->nombre, nombreCte);

    if (strcmp(tipo, "CTE_STR") == 0)
    {
      data->valor.valor_var_str = (char *)malloc(sizeof(char) * (strlen(valString) + 1));
      if (data->valor.valor_var_str == NULL)
      {
        free(data->nombre);
        free(data->tipo);
        free(data);
        return NULL;
      }
      strcpy(data->valor.valor_var_str, valString);
      data->longitud = strlen(valString) - 2;
    }
    else if (strcmp(tipo, "CTE_FLOAT") == 0)
    {
      data->valor.valor_var_float = valor_var_float;
    }
    else if (strcmp(tipo, "CTE_INT") == 0)
    {
      data->valor.valor_var_int = valor_var_int;
    }

    return data;
  }

  free(data->tipo);
  free(data);
  return NULL;
}

void guardar_tabla_simbolos()
{
  FILE *arch;
  if ((arch = fopen("symbol-table.txt", "wt")) == NULL)
  {
    printf("\nNo se pudo crear la tabla de simbolos.\n\n");
    return;
  }
  else if (tabla_simbolos.primero == NULL)
  {
    printf("\nLa tabla de simbolos está vacía.\n\n");
    fclose(arch);
    return;
  }

  fprintf(arch, "%-30s%-30s%-40s%-30s\n", "NOMBRE", "TIPODATO", "VALOR", "LONGITUD");

  t_simbolo *tabla = tabla_simbolos.primero;
  char valor[100];
  char longitud[20];

  while (tabla)
  {
    strcpy(valor, "--");
    strcpy(longitud, "--");

    if (strcmp(tabla->data.tipo, "INTEGER") == 0 ||
        strcmp(tabla->data.tipo, "FLOAT") == 0 ||
        strcmp(tabla->data.tipo, "STRING") == 0)
    {
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              tabla->data.tipo,
              "--",
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_INT") == 0)
    {
      sprintf(valor, "%d", tabla->data.valor.valor_var_int);
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              "CTE_INT",
              valor,
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_FLOAT") == 0)
    {
      sprintf(valor, "%f", tabla->data.valor.valor_var_float);
      fprintf(arch, "%-30s%-30s%-40s%-30s\n",
              tabla->data.nombre,
              "CTE_FLOAT",
              valor,
              "--");
    }
    else if (strcmp(tabla->data.tipo, "CTE_STR") == 0)
    {
      char aux_string[100];
      if (strlen(tabla->data.valor.valor_var_str) >= 2)
      {
        strncpy(aux_string, tabla->data.valor.valor_var_str + 1,
                strlen(tabla->data.valor.valor_var_str) - 2);
        aux_string[strlen(tabla->data.valor.valor_var_str) - 2] = '\0';

        sprintf(longitud, "%d", (int)strlen(aux_string));

        fprintf(arch, "%-30s%-30s%-40s%-30s\n",
                tabla->data.nombre,
                "CTE_STR",
                aux_string,
                longitud);
      }
      else
      {
        fprintf(arch, "%-30s%-30s%-40s%-30s\n",
                tabla->data.nombre,
                "CTE_STR",
                tabla->data.valor.valor_var_str,
                "0");
      }
    }

    t_simbolo *temp = tabla;
    tabla = tabla->next;
  }

  fclose(arch);
  printf("\nTabla de simbolos guardada correctamente.\n");
}

void crear_tabla_simbolos()
{
    tabla_simbolos.primero = NULL;
}