/*	Definition section */
%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
extern int yylex();

/* Symbol table function - you can add new function if need. */
void create_symbol();
void insert_symbol(char* id, char* type);
int lookup_symbol(char* sym);
void dump_symbol();
void symbol_assignint(char* id, int data);
void symbol_assignfloat32(char* id, double data);
void symbol_intcrement(char* id);
void symbol_float32crement(char* id);
char* returntype(char* id);
void yyerror(char *);
int isinteger(int a,double b);
int creatdeter=0;
int allindex=0;
int assignstate=0;
int crementstate=0;
struct symbol_table{
    char *id;	
    char *type;
    int intnum;
    double float32num;
};
typedef struct symbol_table symbol_t;
symbol_t *s_t[100];



%}

/* Using union to define nonterminal and token type */
%token ADD SUB MUL DIV MOD INCREMENT DECREMENT
%token GREATER_THAN LESS_THAN GREATER_EQUAL LESS_EQUAL EQUAL NOTEQUAL
%token ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token AND OR NOT
%token LB RB LCB RCB
%token PRINT PRINTLN
%token IF ELSE ELSEIF FOR
%token VAR VOID INT_TYPE FLOAT32_TYPE
%token STRING
%token INTEGER FLOAT32
%token ID
%token NEWLINE

%union{
	int intvalue;
	double doublevalue;
	char stringvalue[100];
	
}

%type<stringvalue>VAR
%type<stringvalue>VOID
%type<stringvalue>INT_TYPE
%type<stringvalue>FLOAT32_TYPE
%type<stringvalue>STRING
%type<stringvalue>ID
%type<intvalue>INTEGER
%type<doublevalue>FLOAT32


/* Nonterminal with return, which need to sepcify type */
%type <doublevalue> stat
%type <doublevalue> declaration
%type <doublevalue> arith_stat
%type <doublevalue> assign_stat
%type <doublevalue> another_stat
%type <doublevalue> print_func
%type <stringvalue> type
%type <intvalue> term
%type <intvalue> factor
%type <doublevalue> crement
%type <doublevalue> group
%type <doublevalue> compare
%type <doublevalue> morecompare
%type <doublevalue> if
%type <doublevalue> elseif
%type <doublevalue> else



/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : program stat
    |
;

stat
    : declaration
    | arith_stat
    | assign_stat
    | another_stat
    | print_func
    | crement
    | compare
    | morecompare
    | if
    | elseif
    | else
    | NEWLINE{;}
;

declaration
    : VAR ID type ASSIGN arith_stat NEWLINE {insert_symbol($2,$3);   if(strcmp($3,"float32")==0)symbol_assignfloat32($2,$5); else if(strcmp($3,"int")==0)symbol_assignint($2,$5);}

    | VAR ID type NEWLINE {insert_symbol($2,$3);}
;

arith_stat 
    : term {$$ = $1; } 
    | arith_stat ADD term { printf("Add \n"); $$ = $1 + $3; }
    | arith_stat SUB term { printf("Sub\n"); $$ = $1 - $3; }  
;

term
    :factor { $$ = $1; } 
    | term MUL factor { printf("Mul \n"); $$ = $1 * $3; } 
    | term DIV factor { if($3==0) { printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno+1); }
		        else{ printf("Div \n"); $$ = $1 / $3; }
		      } 
    | term MOD factor { printf("MOD \n"); if(isinteger($1,$1)==1&&isinteger($3,$3)==1) $$ = $1 % $3;else printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno+1);}

;

factor
    :group {  $$ =$1; } 
    | INTEGER {  $$ = $1; } 
    | FLOAT32 {  $$ = $1; } 
    | ID { int i=lookup_symbol($1); 
	 if(i==-1) {printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno+1);} 
 	 else{ if(strcmp(returntype($1),"int")==0)$$=s_t[i]->intnum; else if(strcmp(returntype($1),"float32")==0)$$=s_t[i]->float32num;}
	}
;

group
    :LB arith_stat RB { $$ = $2; }
;

assign_stat
    : ID ASSIGN arith_stat NEWLINE { assignstate=0;
				     printf("ASSIGN\n");  
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0)symbol_assignint($1,$3);else if(strcmp(returntype($1),"float32")==0) symbol_assignfloat32($1,$3);}
	    	       		   }
    | ID ADD_ASSIGN arith_stat NEWLINE { assignstate=1;
				     printf("ADD_ASSIGN\n");
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0)symbol_assignint($1,$3);else if(strcmp(returntype($1),"float32")==0) symbol_assignfloat32($1,$3);}
	    	       		   } 
    | ID SUB_ASSIGN arith_stat NEWLINE { assignstate=2;
				     printf("SUB_ASSIGN\n");
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0)symbol_assignint($1,$3);else if(strcmp(returntype($1),"float32")==0) symbol_assignfloat32($1,$3);}
	    	       		   }
    | ID MUL_ASSIGN arith_stat NEWLINE { assignstate=3;
				     printf("MUL_ASSIGN\n");
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0)symbol_assignint($1,$3);else if(strcmp(returntype($1),"float32")==0) symbol_assignfloat32($1,$3);}
	    	       		   }
    | ID DIV_ASSIGN arith_stat NEWLINE { assignstate=4;
				     printf("DIV_ASSIGN\n");
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0)symbol_assignint($1,$3);else if(strcmp(returntype($1),"float32")==0) symbol_assignfloat32($1,$3);}
	    	       		   }
    | ID MOD_ASSIGN arith_stat NEWLINE { assignstate=5;
				     printf("MOD_ASSIGN\n");
				     if(lookup_symbol($1)==-1) { printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno); }
		          	     else{ if(strcmp(returntype($1),"int")==0&&isinteger($3,$3)==1) symbol_assignint($1,$3); else printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno);}
	    	       		   }
;

another_stat
    : compare NEWLINE    
    | morecompare NEWLINE
;

crement
    : ID INCREMENT NEWLINE { crementstate=0;
			     printf("INCREMENT \n");
			     if(lookup_symbol($1)==-1) printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
			     else{ if(strcmp(returntype($1),"int")==0)symbol_intcrement($1);else if(strcmp(returntype($1),"float32")==0) symbol_float32crement($1);}}
    | ID DECREMENT NEWLINE { crementstate=1;
			     printf("DECREMENT \n");
			     if(lookup_symbol($1)==-1) printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
			     else{ if(strcmp(returntype($1),"int")==0)symbol_intcrement($1);else if(strcmp(returntype($1),"float32")==0) symbol_float32crement($1);}}
;

print_func
    : PRINT group NEWLINE {printf("PRINT : %lf\n",$2);}
    | PRINT LB STRING RB NEWLINE {printf("PRINT : %s\n",$3) ;}
    | PRINTLN group NEWLINE {printf("PRINTLN : %lf\n",$2);}
    | PRINTLN LB STRING RB NEWLINE {printf("PRINTLN : %s\n",$3) ;}
;

compare
    : arith_stat GREATER_THAN arith_stat { printf("GREATER_THAN \n"); }
    | arith_stat LESS_THAN arith_stat { printf("LESS_THAN \n"); }
    | arith_stat GREATER_EQUAL arith_stat { printf("GREATER_EQUAL \n"); }
    | arith_stat LESS_EQUAL arith_stat { printf("LESS_EQUAL \n"); }
    | arith_stat EQUAL arith_stat { printf("EQUAL \n"); }
    | arith_stat NOTEQUAL arith_stat { printf("NOTEQUAL \n"); }
;

morecompare
    : compare AND compare{ printf("AND \n"); }
    | compare OR compare{ printf("OR \n"); }
    | NOT compare{ printf("NOT \n"); }
;

if
    : IF LB arith_stat GREATER_THAN arith_stat RB LCB NEWLINE { printf("IF \n");printf("GREATER_THAN \n");}
    | IF LB arith_stat LESS_THAN arith_stat RB LCB NEWLINE { printf("IF \n");printf("LESS_THAN \n");}
    | IF LB arith_stat GREATER_EQUAL arith_stat RB LCB NEWLINE { printf("IF \n");printf("GREATER_EQUAL \n");}
    | IF LB arith_stat LESS_EQUAL arith_stat RB LCB NEWLINE { printf("IF \n");printf("LESS_EQUAL \n");}
    | IF LB arith_stat EQUAL arith_stat RB LCB NEWLINE { printf("IF \n");printf("EQUAL \n");}
    | IF LB arith_stat NOTEQUAL arith_stat RB LCB NEWLINE { printf("IF \n");printf("NOTEQUAL \n");}
;

elseif
    : RCB ELSEIF LB arith_stat GREATER_THAN arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("GREATER_THAN \n");}
    | RCB ELSEIF LB arith_stat LESS_THAN arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("LESS_THAN \n");}
    | RCB ELSEIF LB arith_stat GREATER_EQUAL arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("GREATER_EQUAL \n");}
    | RCB ELSEIF LB arith_stat LESS_EQUAL arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("LESS_EQUAL \n");}
    | RCB ELSEIF LB arith_stat EQUAL arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("EQUAL \n");}
    | RCB ELSEIF LB arith_stat NOTEQUAL arith_stat RB LCB NEWLINE { printf("ELSEIF \n");printf("NOTEQUAL \n");}
;

else
    : RCB ELSE LCB NEWLINE { printf("ELSE \n");}
    | RCB NEWLINE {;}
;

type
    : INT_TYPE { strcpy($$,$1); }
    | FLOAT32_TYPE { strcpy($$,$1); }
    | VOID { strcpy($$,$1); }
;

%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

    yyparse();

    printf("\nTotal lines: %d\n\n",yylineno);

    dump_symbol();

    return 0;
}

void create_symbol(){
	creatdeter=1;
	printf("Create symbol table\n");
	for(int i=0;i<100;i++){
		s_t[i]=malloc(sizeof(symbol_t*));
		s_t[i]->type=malloc(12*sizeof(char*));
		//s_t[i]->type="";
		//s_t[i]->id="";
		s_t[i]->intnum=0;
		s_t[i]->float32num=0.0;
	}

}

void insert_symbol(char* id, char* type){
	int i;
	if(creatdeter==0){
		create_symbol();
	}

	if(lookup_symbol(id)==-1) 
	{		
		s_t[allindex]->id=malloc(strlen(id)+1);
		strcpy(s_t[allindex]->id,id);
 		strcpy(s_t[allindex]->type,type);
		printf("Insert symbol:%s\n",id);
		allindex++;
		return ;						
	}
	  else{
		printf("<ERROR> re-declaration for variable %s (line %d)\n",id,yylineno);
    		return;
	  }

}
int lookup_symbol(char* sym){
	int i;
	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			if(strcmp(s_t[i]->id,sym)==0){	
			//printf("%d  %s and %s are the same\n",i,sym,s_t[i]->id);
			//printf("FONUND %s in %d\n",sym,i);
			return i;
			}
		}
	}
	return -1;

}

void dump_symbol(){
	int i;
	printf("The symbol table :\n\n");	
	printf("ID    Type     Data\n");
	for(i=0;i<allindex;i++){ 
		if(strcmp(s_t[i]->type,"int")==0)
			printf("%-6s%-9s%d\n",s_t[i]->id,s_t[i]->type,s_t[i]->intnum);
		else
			printf("%-6s%-9s%f\n",s_t[i]->id,s_t[i]->type,s_t[i]->float32num);
	}	
}

void symbol_assignint(char* id, int data) {
	int i;
    	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			 if(strcmp(s_t[i]->id,id)==0){	
	        		if(assignstate==0)	
	        		s_t[i]->intnum=data;
				else if(assignstate==1)
	        		s_t[i]->intnum=s_t[i]->intnum+data;
				else if(assignstate==2)
	        		s_t[i]->intnum=s_t[i]->intnum-data;
				else if(assignstate==3)
	        		s_t[i]->intnum=s_t[i]->intnum*data;
				else if(assignstate==4)
	        		s_t[i]->intnum=s_t[i]->intnum/data;
				else if(assignstate==5)
	        			s_t[i]->intnum=s_t[i]->intnum%data;
			}
		}
	}
	
}

void symbol_assignfloat32(char* id, double data) {
	int i;
    	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			 if(strcmp(s_t[i]->id,id)==0){
				if(assignstate==0)	
	        		s_t[i]->float32num=data;
				else if(assignstate==1)
	        		s_t[i]->float32num=s_t[i]->float32num+data;
				else if(assignstate==2)
	        		s_t[i]->float32num=s_t[i]->float32num-data;
				else if(assignstate==3)
	        		s_t[i]->float32num=s_t[i]->float32num*data;
				else if(assignstate==4)
	        		s_t[i]->float32num=s_t[i]->float32num/data;
				/*else if(assignstate==5)
	        		s_t[i]->float32num=s_t[i]->float32num%data;*/
			}
		}
	}
	
}

void symbol_intcrement(char* id){
	int i;
    	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			 if(strcmp(s_t[i]->id,id)==0){
				if(crementstate==0)	
	        		s_t[i]->intnum=s_t[i]->intnum+1;
				else if(assignstate==1)
	        		s_t[i]->intnum=s_t[i]->intnum-1;
			 }	
		}
	}
}

void symbol_float32crement(char* id){
	int i;
    	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			 if(strcmp(s_t[i]->id,id)==0){
				if(crementstate==0)	
	        		s_t[i]->float32num=s_t[i]->float32num+1;
				else if(assignstate==1)
	        		s_t[i]->float32num=s_t[i]->float32num-1;
			 }	
		}
	}
}


char* returntype(char* id){
	int i;
    	for(i=0;i<allindex;i++){
		if(s_t[i]->id!=NULL){	
			 if(strcmp(s_t[i]->id,id)==0){	
					return s_t[i]->type;
			}
		}
	}
	
}

int isinteger(int a,double b){
	if(a==b)
		return 1;
	else
		return -1;

}

void yyerror(char *s) {
    printf("%s (line %d)\n", s , yylineno+1);
}


