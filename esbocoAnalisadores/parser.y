%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
	int    iValue; 	/* integer value */
	char   cValue; 	/* char value */
	char * sValue;  /* string value */
	};

%start lines

%token <sValue> ID
%token <iValue> NUMBER_LITERAL
%token WHILE BLOCK_ENDWHILE  BLOCK_ENDFOR  IF BLOCK_ENDIF  BLOCK_END
%token FOR DO THEN ELSE
%token SEMI ASSIGN COL DP FUNCTION PROCEDURE RETURN AP FP AC FC ACC FCC
%token DIMENSION AND OP_AD OP_DIV OP_SUB OP_MULT
%token NUMBER STRING BOOL MAP
%token TRUE FALSE

%start prog

%type <sValue> stm

%% /* Inicio da segunda seção, onde colocamos as regras BNF */

program : declaration subprograms {}
		;

subprograms : subprogram			  {}
			| subprogram subprograms  {}
			;

subprogram  : FUNCTION ID AP argumentos FP DP tipo AC stmlist FC BLOCK_END
		    | PROCEDURE ID AP argumentos FP AC  stmlist FC BLOCK_END
			;

tipo : NUMBER 
	 | STRING 
	 | BOOL 
	 | MAP
	 ;

argumentos : argumento 						{}
		   | argumentos COL argumento 			{}
		   ;

argumento : tipo_inicial ID  					{}
		 ;

tipo_inicial : tipo
		     | tipo dimensions
		     ;

//essa regra estaria certa par adimension?
dimensions : DIMENSION
           | DIMENSION dimensions
		   ;

stmlist : stm								{}
		| stmlist SEMI stm   				{}
	    ;

stm : declaration 							{}
	| while									{} 
	| if 									{}
	| block 								{}
	;

declaration : tipo_inicial ids
			;

/** op 1, 2, 3 e 4 de declaração e inicialização 
* 1. type a;
* 2. type a, b, c;
* 3. type a = 10;
* 4. type a = 1, b = 2, c = 3;
*/
ids :  id SEMI              {}
	|  id COL ids	 		{}
	;

id  : ID init_opt 	{}
	;

init_opt : 
		 | ASSIGN ID
		 ;
/***********/

/** op 1 e 3 de declaração e inicialização 
* 1. type a;
* 3. type a = 10;
*/
ids : ID init_opt SEMI	 		{}
	;

init_opt : 
		 | ASSIGN ID
		 ;
/***********/

while : WHILE condition block BLOCK_ENDWHILE{}
	  ;

for : FOR condition block BLOCK_ENDFOR{}
    ;

if : IF condition block BLOCK_ENDIF			{}
   | IF condition block BLOCK_ENDIF elseif 	{}
   ;

elseif : ELSE IF condition block BLOCK_ENDIF elseif		{}
   	   | ELSE block BLOCK_ENDIF 						{}
	   ;

block : AC stmlist FC 			{}
	  ;

condition : AP bool_exp FP		{}
		  | AP rel_exp FP		{}
		  ;

/* TODO */
bool_exp : TRUE
		 | FALSE
		 | rel_exp
		 | bool_exp AND
		 ;

/* TODO */
rel_exp : arth_exp rel_op //and, or 
		;

arth_exp : arth_exp OP_AD arth_term
		 | arth_exp OP_SUB arth_term
		 | arth_exp
		 ;
 
arth_term : arth_term OP_MULT arth_factor
	      | arth_term OP_DIV arth_factor
	      | arth_term
	      ;

arth_factor : AP arth_exp FP
			| ID
			;

rel_op : 



%% /* Fim da segunda seção */

int main (void) {
	return yyparse();
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}