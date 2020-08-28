/* Definition section */
%{
	#define int_declare      100
 	#define float32_declare  200
	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>

	/* Symbol table function */
	void create_symbol();
	void insert_symbol();
	int lookup_symbol();
	void dump_symbol();
	int typedeter=0;
	int creatdeter=0;
	int determine=0;
	int commentline=0;
	int line=0;
	int table=0;
	int checkre=0;
	char* storevar;
	char* II="int";
	char* FF="float32";
	struct symbol_table{
		char *id;	
		char *type;
		int deternum;
		
	};
	typedef struct symbol_table symbol_t;
	symbol_t *s_t[60];

%}

/* Define regular expression label */

int		[iI][Nn][Tt]
float32         [fF][lL][oO][aA][tT][3][2]
print           [Pp][Rr][Ii][Nn][Tt]
println         [Pp][Rr][Ii][Nn][Tt][lL][nN]
if              [Ii][Ff]
else            [Ee][Ll][Ss][Ee]
for		[fF][oO][rR]
var		[vV][Aa][rR]
letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
int_digit {digit}+
float32_digit [0-9]+"."[0-9]+
stringstring   \"[a-zA-Z0-9 \t]+\"
whitespace " "
tab	"	"
commentoneline  ^"//".*
commentmoreline  "/""*"[^*]*[*]+([^*/][^*]*[*]+)*"/"

/* Rules section */
%%
"+" 			{ printf("%s \t Add\n",yytext); }
"-"			{ printf("%s \t Sub\n",yytext); }
"*"			{ printf("%s \t Multiply\n",yytext); }
"/"			{ printf("%s \t Divide\n",yytext); }
"%"			{ printf("%s \t Mod\n",yytext); }
"++"			{ printf("%s \t Increment\n",yytext); }
"--"			{ printf("%s \t Decrement\n",yytext); }
"<"			{ printf("%s \t Greater Than\n",yytext); }
">"			{ printf("%s \t Less Than\n",yytext); }
"<="			{ printf("%s \t Less and Equal\n",yytext); }
">="			{ printf("%s \t Greater and Equal\n",yytext); }
"=="			{ printf("%s \t Equal to\n",yytext); }
"!="			{ printf("%s \t Not Equal to\n",yytext); }
"="			{ printf("%s \t Assign\n",yytext); }
"+="			{ printf("%s \t AddAssign\n",yytext); }
"-="			{ printf("%s \t SubAssign\n",yytext); }
"*="			{ printf("%s \t MultiplyAssign\n",yytext); }
"/="			{ printf("%s \t DivideAssign\n",yytext); }
":="			{ printf("%s \t Assign\n",yytext); }
"%="			{ printf("%s \t ModAssign\n",yytext); }
"&&"			{ printf("%s \t And\n",yytext); }
"||"			{ printf("%s \t Or\n",yytext); }
"!"			{ printf("%s \t Not\n",yytext); }
"("			{ printf("%s \t LB\n",yytext); }
")"			{ printf("%s \t RB\n",yytext); }
"{"			{ printf("%s \t LCB\n",yytext); }
"}"			{ printf("%s \t RCB\n",yytext); }
{commentoneline}	{ printf("%s \t C++ Comment\n",yytext);
			  commentline=commentline+1;			
			 }
{commentmoreline}	{ 
			int i;
			printf("%s \t C Comment\n",yytext);
			commentline=commentline+1;	
			for(i=0;i<yyleng;i++)
                        if(yytext[i]=='\n')
				{
					commentline++;
					line++;
				}		
			 }
{print}			{printf("%s \t PRINT function\n",yytext);}
{println}		{printf("%s \t PRINTLN function\n",yytext);}
{if}			{printf("%s \t IF function\n",yytext);}
{else}			{printf("%s \t ELSE function\n",yytext);}
{for}			{printf("%s \t FOR function\n",yytext);}
{whitespace}		{;}
{tab}			{;}	
{var}			{determine=1;}
{int}			{
			typedeter=int_declare;
			if(determine==1){
				checkre=1;
				printf("%s \t int TYPE VAR\n",storevar);
				insert_symbol(storevar);
			}
			determine=0;
			typedeter=-1;
			}
{float32}		{
			typedeter=float32_declare;
			if(determine==1){
				checkre=1;
				printf("%s \t double TYPE VAR\n",storevar);
				insert_symbol(storevar);
			}
			determine=0;	
			typedeter=-1;	
			}
{id}			{
			if(determine==0){
				checkre=0;
				if(table==1){
				if(lookup_symbol(yytext)==-1){
					printf("%s is undeclared\n",yytext);
				}
				else{
				
				printf("%s \t ID \n",yytext);}	
			}
			else{
				printf("%s is undeclared\n",yytext);
			}
			}
			else{
				
				storevar=malloc(strlen(yytext));
				strcpy(storevar,yytext);
			}}
{digit}			{printf("%s \t Digit\n",yytext);}
{stringstring}		{
					int i;
					printf("\" \t 	QUOTATION\n");
					for(i=1;i<yyleng-1;i++) 
					{printf("%c",yytext[i]);}
				     
					printf("\tSTRING\n");
					printf("\" \t	QUOTATION\n");}

\n			{line=line+1;}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

void create_symbol() {
		creatdeter=1;
		table=1;
		printf("Create a symbol table\n");
		for(int i=0;i<60;i++){
			s_t[i]=malloc(sizeof(symbol_t*));
		        s_t[i]->type=malloc(8*sizeof(char*));
			s_t[i]->type="";
		    	s_t[i]->id="";
		   	s_t[i]->deternum=0;
		}
}
void insert_symbol(char* s) {
	int i;

	if(creatdeter==0){
		create_symbol();
		s_t[0]->id=malloc(strlen(s));
			strcpy(s_t[0]->id,s);
			s_t[0]->deternum=1;
			printf("Insert a symbol:%s\n",s);
			if(typedeter==int_declare)
			{
				s_t[0]->type=II;
			}
		    if(typedeter==float32_declare){
				s_t[0]->type=FF;
			}		
	}
	else{
		if(lookup_symbol(s)==-1) 
	    {	
		 for(i=0;i<60;i++) 
		  if(s_t[i]->deternum==0) 
		  {	
			s_t[i]->id=malloc(strlen(s)+1);
			strcpy(s_t[i]->id,s);
			
			s_t[i]->deternum=1;
			printf("Insert a symbol:%s\n",s);
			if(typedeter==int_declare)
			{
				s_t[i]->type=II;
			}
		    else  if(typedeter==float32_declare){
				s_t[i]->type=FF;
			}
			
			return ;					
		 }	
	    }
	}
}
int lookup_symbol(char* sym) {
	int i;
	for(i=0;i<60;i++)
	{if(s_t[i]->id!=NULL) 
	{	
	 if(strcmp(s_t[i]->id,sym)==0 && s_t[i]->deternum==1) 
		{	
			 if(checkre==1){
			 printf("%s is redefined\n",sym);}
			 return i;
			
		}
	}
	}
	return -1;
}
void dump_symbol() {
	int i;
	printf("\nParse over, the line number is: %d\n",line);
	printf("\ncomment: %d lines\n",commentline);
	printf("\nThe symbol table dump:\n");	
	if(table==1){
		for(i=0;i<60;i++){			
			if(s_t[i]->deternum==1) {
				printf("%d\t%s\t%s\n",i+1,s_t[i]->id,s_t[i]->type);
			}
		}	
	}
	else{
		printf("\nThere is no symbol table\n");	
	}
}

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	dump_symbol();

	return 0;
}
