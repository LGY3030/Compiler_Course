/*	Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
enum T {ITN,FP,VOI,ERR};
struct STORE{
    char *id;	
    enum T type;
    union{
        int intnum;
        double float32num;
    }material;
};
struct STORE *string=NULL;
char *change;
int sys_num=0;
extern int yylineno;
extern int yylex();

/* Symbol table function - you can add new function if need. */

void yyerror(char *);
void yywarning(char *s) ;
void create_symbol();
void insert_symbol(char* id, enum T type, double material);
int lookup_symbol(char* sym);
void dump_symbol();
void symbol_assign(char* id, double material);

char *serach(int n,char *s,...);
int creatdeter=0;
int deter=0;
int error=0;
int errornum=0;
int labelnum=0;
int elseifflag=0;
int ifnum=-1;
FILE *file;





%}

/* Using union to define nonterminal and token type */
%token ADD SUB MUL DIV MOD INCREMENT DECREMENT
%token GREATER_THAN LESS_THAN GREATER_EQUAL LESS_EQUAL EQUAL NOTEQUAL
%token ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token AND OR NOT
%token LB RB LCB RCB
%token PRINT PRINTLN
%token IF ELSE FOR
%token VAR VOID INT_TYPE FLOAT32_TYPE
%token STRING
%token INTEGER FLOAT32
%token ID
%token NEWLINE

%union
{
	struct
	{
		enum T type;
		union 
		{
			int i_num;
			double f_num;
		};
	} n_num;
	char *s_num;
}


%type<s_num>VAR
%type<n_num.type>VOID
%type<n_num.type>INT_TYPE
%type<n_num.type>FLOAT32_TYPE
%type<s_num>STRING
%type<s_num>ID
%type<n_num>INTEGER
%type<n_num>FLOAT32


/* Nonterminal with return, which need to sepcify type */

%type <n_num> declaration
%type <n_num> arith_stat
%type <n_num> assign_stat
%type <n_num> another_stat
%type <n_num> print_func
%type <n_num.type> type
%type <n_num> term
%type <n_num> factor
%type <n_num> crement
%type <n_num> group
%type <n_num> compare
%type <n_num> morecompare



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
    | ifpart
    | NEWLINE{;}
;

declaration
    : VAR ID type NEWLINE
     { 
	int i=lookup_symbol($2);
	if(-1==i)
	{
		insert_symbol($2,$3,0);
		if($3==FP)
		{
			fprintf(file, "ldc 0.0\nfstore %d\n",lookup_symbol($2));
		}
		else if($3==ITN)
		{
			fprintf(file, "ldc 0\nistore %d\n",lookup_symbol($2));
		}
	}
	else
	{
		change=serach(2,"re-declaration for variable ",$2);
		yyerror(change);
		free(change);
	}
	free($2);

     }

    | VAR ID type ASSIGN arith_stat NEWLINE 
     {
	int i=lookup_symbol($2);
	if(-1==i)
	{
		if($3==FP)
		{
			insert_symbol($2,$3,$5.f_num);
			fprintf(file, "fstore %d\n",lookup_symbol($2));
		}
		else if($3==ITN)
		{
			insert_symbol($2,$3,(double)$5.i_num);
			fprintf(file, "istore %d\n",lookup_symbol($2));
		}
	}
	else
		{
			change=serach(2,"re-declaration for variable ",$2);
			yyerror(change);
			free(change);
		}
		free($2);
     }
;

arith_stat 
    : term { $$ = $1; } 
    | arith_stat ADD term
     { 
	printf("Add \n"); 
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"iadd \n");
		deter=0;	
		$$.type=ITN;
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fadd \n");
		deter=1;
		$$.type=FP;
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fadd \n");
		deter=1;
		$$.type=FP;
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fadd \n");	
		deter=1;
		$$.type=FP;	
	}
	
    }

    | arith_stat SUB term
     { 
	printf("Sub\n"); 
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		deter=0;
		$$.type=ITN;	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		deter=1;
		$$.type=FP;
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		deter=1;
		$$.type=FP;
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");	
		deter=1;
		$$.type=FP;	
	}
      }
;

term
    :factor { $$ = $1; } 
    | term MUL factor
     { 
	printf("Mul\n"); 
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"imul \n");
		deter=0;
		$$.type=ITN;	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fmul \n");
		deter=1;
		$$.type=FP;
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fmul \n");
		deter=1;
		$$.type=FP;
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fmul \n");	
		deter=1;
		$$.type=FP;	
	}
     }

    | term DIV factor
     { 
	printf("Div\n"); 
	if(($3.type==ITN && $3.i_num==0)||($3.type==FP && $3.f_num==0.0))
	{
		printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno+1); 
	}
	else
	{
		if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"idiv \n");
		deter=0;
		$$.type=ITN;	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fdiv \n");
		deter=1;
		$$.type=FP;
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fdiv \n");
		deter=1;
		$$.type=FP;
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fdiv \n");	
		deter=1;
		$$.type=FP;	
	}
	}
     }
    | term MOD factor
     {
	printf("Mod\n");
	if(($3.type==ITN && $3.i_num==0)||($3.type==FP && $3.f_num==0.0))
	{
		printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno+1);
	}
	else
	{
		if($1.type==ITN && $3.type==ITN)
		{
			fprintf(file,"irem \n");
			deter=0;
			$$.type=ITN;
		}
		else if($1.type==ITN && $3.type==FP)
		{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno+1);
			$$.type=ERR;
		}
		else if($1.type==FP && $3.type==ITN)
		{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno+1);
			$$.type=ERR;
		}			
		else if($1.type==FP && $3.type==FP)
		{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno+1);
			$$.type=ERR;
		}
	}
     }
;

factor
    :group {  $$ =$1; } 
    | INTEGER {  deter=0;$$.type=ITN; $$.i_num=$1.i_num; fprintf(file,"ldc %d\n",$1.i_num); }
    | FLOAT32 {  deter=1;$$.type=FP; $$.f_num=$1.f_num; fprintf(file,"ldc %lf\n",$1.f_num); }
    | ID
     {
	int i=lookup_symbol($1); 
	if(i==-1)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno+1);
		$$.type=ERR;
		$$.f_num=0;
	}
 	else
	{
		$$.type=string[i].type;
		if( $$.type==ITN ){
			deter=0;
			$$.i_num=string[i].material.intnum;
			fprintf(file, "iload %d\n",lookup_symbol($1));
		}
		else if( $$.type==FP ){
			deter=1;
			$$.f_num=string[i].material.float32num;	
			fprintf(file, "fload %d\n",lookup_symbol($1));
		}

	}
     }
;

group
    :LB arith_stat RB { $$ = $2; }
;

assign_stat
    : ID ASSIGN arith_stat NEWLINE
     { 
	printf("ASSIGN\n"); 
	int i=lookup_symbol($1); 
	if(i>=0 && $3.type!=ERR)
	{ 
		if(string[i].type==FP /*&& $3.type==ITN*/)
		{
			//symbol_assign($1,(double)$3.i_num);
			//deter=1;
			if(deter==0){
				fprintf(file, "i2f \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
		}
		else if(string[i].type==ITN /*&& $3.type==FP*/)
		{
			/*$3.i_num=(int)$3.f_num;
			symbol_assign($1,$3.f_num);*/
			//deter=0;

			if(deter==0){
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "f2i \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
		}
		/*else
		{
			symbol_assign($1,$3.f_num);
		}*/
	}
	else if(i<0)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
		change=serach(2,"cannot find variable ",$1);
		yyerror(change);
		free(change);
	}
	$$=$3;
	free($1);
     }

    | ID ADD_ASSIGN arith_stat NEWLINE 
	{ 
		printf("ADD_ASSIGN\n");
		int i=lookup_symbol($1); 
		if(i>=0 && $3.type!=ERR)
		{ 
			if(string[i].type==FP /*&& $3.type==ITN*/)
			{
				if(deter==0){
					fprintf(file, "i2f \n");
					fprintf(file, "fload %d\n",lookup_symbol($1));
					fprintf(file, "fadd \n");
					fprintf(file, "fstore %d\n",lookup_symbol($1));
				}
				else if(deter==1){
					fprintf(file, "fload %d\n",lookup_symbol($1));
					fprintf(file, "fadd \n");
					fprintf(file, "fstore %d\n",lookup_symbol($1));
				}

				//string[i].material.float32num+=(double)$3.i_num;
			}
			else if(string[i].type==ITN /*&& $3.type==FP*/)
			{
				if(deter==0){
					fprintf(file, "iload %d\n",lookup_symbol($1));
					fprintf(file, "iadd \n");
					fprintf(file, "istore %d\n",lookup_symbol($1));
				}
				else if(deter==1){
					fprintf(file, "f2i \n");
					fprintf(file, "iload %d\n",lookup_symbol($1));
					fprintf(file, "iadd \n");
					fprintf(file, "istore %d\n",lookup_symbol($1));
				}
				//string[i].material.intnum+=(int)$3.f_num;
			}
			/*else if(string[i].type==ITN && $3.type==ITN)
			{
				string[i].material.intnum+=$3.i_num;
			}
			else{
				string[i].material.float32num+=$3.f_num;
			}*/

	    	    }
		else if(i<0)
		{
			printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
			change=serach(2,"cannot find variable ",$1);
			yyerror(change);
			free(change);
		}
		$$=$3;
		free($1);
     }

    | ID SUB_ASSIGN arith_stat NEWLINE 
     { 
	printf("SUB_ASSIGN\n");
	int i=lookup_symbol($1); 
	if(i>=0 && $3.type!=ERR)
	{ 
		if(string[i].type==FP /*&& $3.type==ITN*/)
		{
			if(deter==0){
				fprintf(file, "i2f \n");
				fprintf(file, "fstore %d\n",sys_num);
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fload %d\n",sys_num);
				fprintf(file, "fsub \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "fstore %d\n",sys_num);
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fload %d\n",sys_num);
				fprintf(file, "fsub \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			//string[i].material.float32num-=(double)$3.i_num;
		}
		else if(string[i].type==ITN /*&& $3.type==FP*/)
		{
			if(deter==0){
				fprintf(file, "istore %d\n",sys_num);
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "iload %d\n",sys_num);
				fprintf(file, "isub \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "f2i \n");
				fprintf(file, "istore %d\n",sys_num);
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "iload %d\n",sys_num);
				fprintf(file, "isub \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			//string[i].material.intnum-=(int)$3.f_num;
		}
		/*else if(string[i].type==ITN && $3.type==ITN)
		{
			string[i].material.intnum-=$3.i_num;
		}
		else{
			string[i].material.float32num-=$3.f_num;
		}*/

	   }
	else if(i<0)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
		change=serach(2,"cannot find variable ",$1);
		yyerror(change);
		free(change);
	}
	$$=$3;
	free($1);
     } 

    | ID MUL_ASSIGN arith_stat NEWLINE
     {
	printf("MUL_ASSIGN\n");
	int i=lookup_symbol($1); 
	if(i>=0 && $3.type!=ERR)
	{ 
		if(string[i].type==FP/* && $3.type==ITN*/)
		{
			if(deter==0){
				fprintf(file, "i2f \n");
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fmul \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fmul \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			//string[i].material.float32num*=(double)$3.i_num;
		}
		else if(string[i].type==ITN /*&& $3.type==FP*/)
		{
			if(deter==0){
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "imul \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "f2i \n");
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "imul \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			//string[i].material.intnum*=(int)$3.f_num;
		}
		/*else if(string[i].type==ITN && $3.type==ITN)
		{
			string[i].material.intnum*=$3.i_num;
		}
		else{
			string[i].material.float32num*=$3.f_num;
		}*/

	    }
	else if(i<0)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
		change=serach(2,"cannot find variable ",$1);
		yyerror(change);
		free(change);
	}
	$$=$3;
	free($1);
     } 

    | ID DIV_ASSIGN arith_stat NEWLINE
     {
	printf("DIV_ASSIGN\n");
	int i=lookup_symbol($1); 
	if(i>=0 && $3.type!=ERR)
	{ 
		if(string[i].type==FP /*&& $3.type==ITN*/)
		{
			if(deter==0){
				fprintf(file, "i2f \n");
				fprintf(file, "fstore %d\n",sys_num);
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fload %d\n",sys_num);
				fprintf(file, "fdiv \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "fstore %d\n",sys_num);
				fprintf(file, "fload %d\n",lookup_symbol($1));
				fprintf(file, "fload %d\n",sys_num);
				fprintf(file, "fdiv \n");
				fprintf(file, "fstore %d\n",lookup_symbol($1));
			}
			//string[i].material.float32num/=(double)$3.i_num;
		}
		else if(string[i].type==ITN /*&& $3.type==FP*/)
		{
			if(deter==0){
				fprintf(file, "istore %d\n",sys_num);
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "iload %d\n",sys_num);
				fprintf(file, "idiv \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			else if(deter==1){
				fprintf(file, "f2i \n");
				fprintf(file, "istore %d\n",sys_num);
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "iload %d\n",sys_num);
				fprintf(file, "idiv \n");
				fprintf(file, "istore %d\n",lookup_symbol($1));
			}
			//string[i].material.intnum/=(int)$3.f_num;
		}
		/*else if(string[i].type==ITN && $3.type==ITN)
		{
			string[i].material.intnum/=$3.i_num;
		}
		else{
			string[i].material.float32num/=$3.f_num;
		}*/
	  }
	else if(i<0)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
		change=serach(2,"cannot find variable ",$1);
		yyerror(change);
		free(change);
	}
	$$=$3;
	free($1);

     } 

    | ID MOD_ASSIGN arith_stat NEWLINE
     {
	printf("MOD_ASSIGN\n");
	int i=lookup_symbol($1); 
	if(i>=0 && $3.type!=ERR)
	{ 
		if(string[i].type==FP /*&& $3.type==ITN*/)
		{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno);
		}
		/*else if(string[i].type==ITN && $3.type==FP)
		{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno);
		}*/
		else if(string[i].type==ITN /*&& $3.type==ITN*/)
		{
				fprintf(file, "istore %d\n",sys_num);
				fprintf(file, "iload %d\n",lookup_symbol($1));
				fprintf(file, "iload %d\n",sys_num);
			fprintf(file, "irem \n");
			fprintf(file, "istore %d\n",lookup_symbol($1));
			//string[i].material.intnum%=$3.i_num;
		}
		/*else{
			printf("<ERROR> MOD can't involve any floating point variables (line %d)\n",yylineno);
		}*/
	    }
	else if(i<0)
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
		change=serach(2,"cannot find variable ",$1);
		yyerror(change);
		free(change);
	}
	$$=$3;
	free($1);

     }
;
another_stat
    : compare NEWLINE    
    | morecompare NEWLINE
;

crement
    : ID INCREMENT NEWLINE
     {
	printf("INCREMENT \n");
	int i=lookup_symbol($1);
	if(i==-1) 
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
	}
	else
	{
		if(string[i].type==ITN)
		{
			fprintf(file, "iload %d\n",lookup_symbol($1));
			fprintf(file, "ldc 1\niadd \nistore %d\n",lookup_symbol($1));
		}
		else
		{
			fprintf(file, "fload %d\n",lookup_symbol($1));
			fprintf(file, "ldc 1.0\nfadd \nfstore %d\n",lookup_symbol($1));
		}
	}
     }
    | ID DECREMENT
     {
	printf("INCREMENT \n");
	int i=lookup_symbol($1);
	if(i==-1) 
	{
		printf("<ERROR> can't find variable %s (line %d)\n",$1,yylineno);
	}
	else
	{
		if(string[i].type==ITN)
		{
			fprintf(file, "iload %d\n",lookup_symbol($1));
			fprintf(file, "ldc 1\nisub \nistore %d\n",lookup_symbol($1));
		}
		else
		{
			fprintf(file, "fload %d\n",lookup_symbol($1));
			fprintf(file, "ldc 1.0\nfadd \nfstore %d\n",lookup_symbol($1));
		}
	}
     }

;

print_func
    : PRINT group NEWLINE
     {
	if(deter==0)
	{
		printf("PRINT : %d\n",$2.i_num);
		fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
			"swap\n"
                            	 "invokevirtual java/io/PrintStream/println(I)V\n" );
	}
	else if(deter==1)
	{
		printf("PRINT : %f\n",$2.f_num);
            		fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                            	"swap\n"
                            	"invokevirtual java/io/PrintStream/println(F)V\n" );
	}
     }

    | PRINT LB STRING RB NEWLINE
     {
	printf("PRINT : %s\n",$3); 
	fprintf(file, "ldc %s\n",$3);
	fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n"
		"swap\n"
                        "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
     }
     | PRINTLN group
     {
	if(deter==0)
	{
		printf("PRINTLN : %d\n",$2.i_num);
		fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
			"swap\n"
                            	 "invokevirtual java/io/PrintStream/println(I)V\n" );
	}
	else if(deter==1)
	{
		printf("PRINTLN : %f\n",$2.f_num);
            		fprintf(file, "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                            	"swap\n"
                            	"invokevirtual java/io/PrintStream/println(F)V\n" );
	}
     }

    | PRINTLN LB STRING RB
     {
	printf("PRINTLN : %s\n",$3); 
	fprintf(file, "ldc %s\n",$3);
	fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n"
		"swap\n"
                        "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
     }

;

compare
    : arith_stat GREATER_THAN arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"ifle Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"ifle Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"ifle Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"ifle Label_%d_%d \n",ifnum,labelnum);		
	}
     }
    | arith_stat LESS_THAN arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"ifge Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"ifge Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"ifge Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"ifge Label_%d_%d \n",ifnum,labelnum);		
	}
     }
    | arith_stat GREATER_EQUAL arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"iflt Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"iflt Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"iflt Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"iflt Label_%d_%d \n",ifnum,labelnum);		
	}
     }
    | arith_stat LESS_EQUAL arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"ifgt Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"ifgt Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"ifgt Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"ifgt Label_%d_%d \n",ifnum,labelnum);		
	}
     }
    | arith_stat EQUAL arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"ifne Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"ifne Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"ifne Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"ifne Label_%d_%d \n",ifnum,labelnum);		
	}
     }
    | arith_stat NOTEQUAL arith_stat
     {
	if($1.type==ITN && $3.type==ITN)
	{
		fprintf(file,"isub \n");
		fprintf(file,"ifeq Label_%d_%d \n",ifnum,labelnum);	
	}
	else if($1.type==ITN && $3.type==FP)
	{

		fprintf(file,"fstore %d\n",sys_num);
		fprintf(file,"i2f \n");	
		fprintf(file,"fload %d\n",sys_num);
		fprintf(file,"fsub \n");
		fprintf(file,"ifeq Label_%d_%d \n",ifnum,labelnum);
	}
	else if($1.type==FP && $3.type==ITN)
	{

		fprintf(file,"i2f \n");	
		fprintf(file,"fsub \n");
		fprintf(file,"ifeq Label_%d_%d \n",ifnum,labelnum);
	}		
	else if($1.type==FP && $3.type==FP)
	{

		fprintf(file,"fsub \n");
		fprintf(file,"ifeq Label_%d_%d \n",ifnum,labelnum);		
	}
     }
;

morecompare
    : compare AND compare{ printf("AND \n"); }
    | compare OR compare{ printf("OR \n"); }
    | NOT compare{ printf("NOT \n"); }
;

ifpart
    : IF {ifnum++;} LB compare RB LCB if { if(elseifflag==0)fprintf(file,"goto EXIT_%d_%d \n",ifnum,labelnum);}{ fprintf(file,"Label_%d_%d: \n",ifnum,labelnum);} { fprintf(file,"EXIT_%d_%d: \n",ifnum,labelnum);}RCB else { fprintf(file,"EXIT_%d_%d: \n",ifnum,labelnum); ifnum--;}
;

if
    : stat if
    |
;

else
    : ELSE IF {  if(elseifflag==1){ fprintf(file,"EXIT_%d_%d: \n",ifnum,labelnum);} labelnum++;} LB compare RB LCB  if { fprintf(file,"goto EXIT_%d_%d \n",ifnum,labelnum);}{ fprintf(file,"Label_%d_%d: \n",ifnum,labelnum);elseifflag=1;} RCB else
    | ELSE  LCB if RCB else 
    | NEWLINE { ; }
    |
;

type
    : INT_TYPE { $$=$1; }
    | FLOAT32_TYPE { $$=$1; }
    | VOID { $$=$1; }
;

%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

    file = fopen("Computer.j","w");

    fprintf(file,
    ".class public main\n"
    ".super java/lang/Object\n"
    ".method public static main([Ljava/lang/String;)V\n"
    ".limit stack %d\n"".limit locals %d\n",10,10);

    yyparse();

    if(errornum!=0){
        fprintf(file,"ldc \"Compile Failure!\"\n");
        fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                         "swap  ;swap the top two items on the stack  \n"
                         "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
        fprintf(file,"ldc \"Exist %d errors\"\n",errornum);
        fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                         "swap  ;swap the top two items on the stack  \n"
                         "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
    }
    else{ fprintf(file,"ldc \"Compile Success!\"\n");
        fprintf(file,"getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                         "swap  ;swap the top two items on the stack  \n"
                         "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
    }

    fprintf(file,
    "return\n"
    ".end method\n");

    fclose(file);

    printf("Generated: %s\n","Computer.j");

    printf("\nTotal lines: %d\n\n",yylineno);

    dump_symbol();

    return 0;
}

void create_symbol(){
	creatdeter=1;
	printf("Create symbol table\n");
	string=malloc(sizeof(struct STORE)*9);
}

void insert_symbol(char* id, enum T type, double material){
	int i;
	if(creatdeter==0){
		create_symbol();
	}

	if(lookup_symbol(id)==-1) 
	{		
		if(9==sys_num%10)
		{
			string=realloc(string,sizeof(struct STORE)*(sys_num+10));
		}
		string[sys_num].type=type;
		string[sys_num].id=malloc(sizeof(char)*(strlen(id)+1));
		strcpy(string[sys_num].id,id);
		if(type==ITN){
			string[sys_num].material.intnum=(int)material;	
		}
		else if(type==FP){
			string[sys_num].material.float32num=material;
		}
		
		++sys_num;
		printf("Insert symbol: %s\n",id);				
	}
	  else{
		printf("<ERROR> re-declaration for variable %s (line %d)\n",id,yylineno);
    		return;
	  }

}
int lookup_symbol(char* sym){
	int i;
	for(i=0; i<sys_num; ++i)
	{
		if(!strcmp(string[i].id,sym))
			return i;
	}
	return -1;

}

void dump_symbol(){
	int i;
	printf("The symbol table:\n\n");
	printf("ID\tType\tData\n");
	for(i=0; i<sys_num; ++i)
	{
		printf("%s\t",string[i].id);
		if(string[i].type==FP)
		{
			printf("float32\t");
			printf("%lf\n",string[i].material.float32num);
		}
		else if(string[i].type==ITN)
		{
			printf("int\t");
			printf("%d\n",string[i].material.intnum);
		}
		free(string[i].id);
	}
	free(string);
}

void symbol_assign(char* id, double material) {	
		string[lookup_symbol(id)].material.intnum=material;
	}

void yyerror(char *s) {
    fprintf(stderr,"\033[31;1m<ERR> %s (line %d)\033[0m\n", s , yylineno+1);
}
void yywarning(char *s) 
{
	fprintf(stderr,"\033[34;1m<WARNING> %s (line %d)\033[0m\n", s , yylineno+1);
}

char *serach(int n,char *s,...)
{
	char *roll,*tmp;
	int i;
	va_list list;
	roll=malloc(strlen(s)+1);
	strcpy(roll,s);
	va_start(list,s);
	for(i=1; i<n; ++i)
	{
		tmp=va_arg(list,char *);
		roll=realloc(roll,strlen(roll)+strlen(tmp)+1);
		strcat(roll,tmp);
	}
	va_end(list);
	return roll;
}



