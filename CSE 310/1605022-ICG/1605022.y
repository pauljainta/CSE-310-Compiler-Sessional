%{
#include <iostream>
#include <cstdlib>
#include<stdlib.h>
#include <cstring>
#include<string>
#include <cmath>
#include <vector>
#include <limits>
#include<algorithm>
#include <sstream>
#include "1605022_table.h"


using namespace std;

extern int yylex();
void yyerror(const char *s);
extern FILE *yyin;
extern int line_count;
extern int error_count;


int label_count=0;
int tempCount=0;
bool isF=false;

string variable_type;
SymbolTable table(10);
int IDargs = 0;
vector<string> args; 
vector<SymbolInfo> params;

vector<string> variables;
vector<string> arrays;
vector<int> arraySizes;

FILE *logtext,*asmCode;


string newLabel()
{
	
	string lb="L"+to_string(label_count);
	label_count++;
	return lb;

}

string newTemp()
{
	
	string t="t"+to_string(tempCount);

	cout<<t<<endl;
	tempCount++;
	return t;
}



void yyerror(const char *s){
}


%}

%error-verbose

%union{
SymbolInfo* si;
}

%token  IF ELSE FOR WHILE DO INT FLOAT VOID RETURN INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA  NOT PRINTLN
%token <si>ID 
%token <si>CONST_INT 
%token <si>CONST_FLOAT 
%token <si>ADDOP
%token <si>MULOP
%token <si>LOGICOP
%token <si>RELOP

%type <si>type_specifier expression logic_expression rel_expression simple_expression term unary_expression factor variable program unit var_declaration func_declaration func_definition parameter_list compound_statement declaration_list statements statement expression_statement argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%


start : program
	{
	
	$1->code+="\n\n Decimal_out proc \n \n push  ax \n\t push bx \n\t push cx  \n\t push dx  \n\tcmp  ax,0 \n\ jge begin \n\t  push ax\n\t mov  dl,'-' \n\tmov ah,2 \n\ int  21h \n\pop ax \n\t neg ax \n\t  begin: \n\t  xor cx,cx \n\t mov bx,10 \n\t\n\t  REPEAT: \n\t xor dx,dx \n\tdiv bx \n\t push dx \n\tinc cx \n\t or ax,ax \n\tjne repeat \n\tmov ah,2 \n\t print_loop: \n\t  pop dx \n\t add dl,30h \n\t int 21h \n\t LOOP print_loop \n \n mov ah,2\n mov dl,10\nint 21h\n\n mov dl,13\nint  21h\n pop dx \n  pop cx \n  pop bx \n  pop ax \n\t ret \n ";			
			fprintf(asmCode,".model small\n.stack 100h\n\n.data\n");
			for(int i = 0; i<variables.size() ; i++){
				fprintf(asmCode,"%s dw ?\n",variables[i].c_str());			
		}

			for(int i = 0 ; i< arrays.size() ; i++){
			   	fprintf(asmCode,"%s dw %d dup(?) \n",arrays[i].c_str(),arraySizes[i]);			

			}
			fprintf(asmCode,"\n.code \n");
			fprintf(asmCode,"%s\n",$1->code.c_str());
			fprintf(asmCode,"\n\t end main\n");
		
		
	}
	;

program : program unit
	{
		$$ = $1;
		$$->code += $2->code;
	} 
	| 
	unit
	{
		$$ = $1;
	}
	;
	
unit : var_declaration
	{
		$$ = $1;
	}
     	| 
     	func_declaration
     	{
			$$ = $1;
     	}
     	| 
     	func_definition
     	{
			$$ = $1;
     	}
     	;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				
				SymbolInfo *temp = table.lookUp($2->Name, "FUNC");
				if(temp != NULL){

				}
				else {
					SymbolInfo* temp2 = table.InsertandGet($2->Name, "ID");
					temp2->IDType="FUNC";
					temp2->FuncRet=$1->VarType;
					for(int i = 0; i<args.size(); i++){
						temp2->ParamList.push_back(args[i]);					
					}
					args.clear();
				} 
			}
		 	|type_specifier ID LPAREN parameter_list RPAREN error
			{
			
			}
		 	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN 
				{

				
				SymbolInfo *temp = table.lookUp($2->Name, "FUNC");
				if(args.size() != IDargs){


			    	args.clear(); 
					IDargs = 0;
				}												
				if(temp != NULL){
					
					if(temp->FuncDefined== true){


						args.clear();
						IDargs = 0;
					}
					else if(temp->FuncRet != $1->VarType){
	
						args.clear();
						IDargs = 0; 
					} 
					else if(temp->ParamList.size() != args.size()){
						args.clear();
						IDargs = 0;
											
					}
					else{
						for(int i = 0; i<temp->ParamList.size(); i++){
							if(temp->ParamList[i] != args[i]){
								args.clear();
								IDargs = 0;
							}
						}				
					}
				}
				else{
					SymbolInfo* temp = new SymbolInfo();
					temp = table.InsertandGet($2->Name, "ID");
					temp->IDType="FUNC";
					temp->FuncRet=$1->VarType;
					
					for(int i = 0; i<args.size(); i++){
						temp->ParamList.push_back(args[i]);					
					}
					temp->FuncDefined=true;
				}
				
				
	
				}
			compound_statement
			{
			     
				SymbolInfo * func = new SymbolInfo();				
				$$ = func;
				$$->code += $2->Name + " PROC \n\n";
				$$->code += $7->code;
				if($2->Name!="main"){
					$$->code+="return_label:\n";
				}
				if(args.size()!=0){
					$$->code+="\tpop bp\n";
				}
				if($2->Name!="main"){
					$$->code+="\tret ";
				}
		
				int p=args.size()*2;
				if(p){
					string Result;       

					ostringstream convert;  
	
					convert << p;    

					Result = convert.str(); 
					$$->code+=Result+"\n";
				}
				$$->code+="\n";
				if($2->Name=="main"){
					$$->code+="return_label:\n";
					$$->code+="\tmov ah,4ch\n\tint 21h\n";
				}
				$$->code += "\n" + $2->Name + " ENDP\n\n";
				args.clear();
				IDargs = 0;
				
			}
 		 	;
 		 
parameter_list  : parameter_list COMMA type_specifier ID
				{
					
					args.push_back(variable_type);
					IDargs++;
					$4->IDType="VAR";
					$4->setVarType(variable_type);
					SymbolInfo* temp = new SymbolInfo($4->Name, $4->Type);
					temp->IDType="VAR";
					
					params.push_back(*temp);
				
				}
		| parameter_list COMMA type_specifier
		{
			args.push_back($3->VarType);
		}	 
 		| type_specifier ID
		{
		
			args.push_back(variable_type);
			IDargs++;
			$2->IDType="VAR";
			$2->setVarType(variable_type);
			params.push_back(*$2);
				

		}
 		| type_specifier
		{
			args.push_back(variable_type);
		}
 		|{}
 		;

compound_statement	: LCURL
					{
						table.enterScope(); 
						for(int i = 0; i<params.size(); i++) table.Insert(params[i]);
						params.clear();					
					}statements RCURL
					{	
						table.exitScope();
						$$=$3;
					}
					| LCURL RCURL
					{
						$$=new SymbolInfo("compound_statement","dummy");
					}
					;

var_declaration : type_specifier declaration_list SEMICOLON
				{
				}
				|type_specifier declaration_list error
				{
	
				} 		 		
				;
 		 
type_specifier	: INT
				{
					SymbolInfo* s= new SymbolInfo("INT");
					variable_type = "INT" ;
					$$ = s;
				}
 				| FLOAT
				{	
					SymbolInfo* s= new SymbolInfo("FLOAT");
					variable_type = "FLOAT" ;
					$$ = s;
				}
 				| VOID
				{
					SymbolInfo* s= new SymbolInfo("VOID");
					variable_type = "VOID" ;
					$$ = s;
				}
 				;
 		
declaration_list : 	declaration_list COMMA ID
					{
						
						if(variable_type == "VOID"){
		
						}
						else{
							SymbolInfo* temp = table.lookUp($3->Name, "VAR");
							if(temp != NULL){
			
							}
							else{
							
								SymbolInfo* temp2 = new SymbolInfo($3->Name, $3->Type);
								temp2->setVarType(variable_type);
								temp2->IDType="VAR";
								table.Insert(*temp2);
								
							}
						}
					}
 					| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
					{
						
						if(variable_type == "VOID"){
				
						}
						else{
							SymbolInfo* temp = table.lookUp($3->Name, "ARA");
							if(temp!= NULL){
									
							}
							else{
								SymbolInfo* temp2 = new SymbolInfo($3->Name, $3->Type);
								temp2->setVarType(variable_type);
								temp2->IDType="ARA";
								int araSize = atoi(($5->Name).c_str());
								cout<<"arraya"<<$5->Name<<endl;

								temp2->AraSize=araSize;
								$3->AraSize=araSize;
								cout<<"size"<<temp2->AraSize<<endl;
								if(variable_type == "INT"){								
									for(int i = temp2->ints.size(); i<araSize; i++){
										temp2->ints.push_back(0);
									}							
								}
								else if(variable_type == "FLOAT"){								
									for(int i = temp2->floats.size(); i<araSize; i++){
										temp2->floats.push_back(0);
									}							
								}
							
								table.Insert(*temp2);	
									


								
							}
						}

					}
 					| ID
					{
						if(variable_type == "VOID"){
					
						}
						else{
							SymbolInfo* temp = table.lookUp($1->Name, "ARA");
							if(temp!= NULL){
							
							}
							else{
								SymbolInfo* temp2 = new SymbolInfo($1->Name, $1->Type);
								temp2->setVarType(variable_type);
								temp2->IDType="VAR";
								table.Insert(*temp2);
										
							}
						}
					}
					| ID LTHIRD CONST_INT RTHIRD
					{
						
						if(variable_type == "VOID"){
	
						}
						else{
							SymbolInfo* temp = table.lookUp($1->Name, "ARA");
							if(temp!= NULL){
					
							}
							else{
								SymbolInfo* temp2 = new SymbolInfo($1->Name, $1->Type);
								temp2->setVarType(variable_type);
								temp2->IDType="ARA";
								int araSize = atoi(($3->Name).c_str());
								temp2->AraSize=araSize;
								$1->AraSize=araSize;
								cout<<"arraya2"<<endl;
								table.Insert(*temp2);
								

											
							}
						}
					}						
					;


statements : statement {
				$$=$1;
			}
	       | statements statement {
				$$=$1;
				$$->code += $2->code;
			}
	       ;


statement 	: 	var_declaration
			{
			}
	  		|	expression_statement {
					$$=$1;
				}
			| 	compound_statement {
					$$=$1;
				}
			|	FOR LPAREN expression_statement expression_statement expression RPAREN statement {			
					
					$$ = $3;
					string label1 = newLabel();
					string label2 = newLabel();
					$$->code += label1 + ":\n";
					$$->code+=$4->code;
					$$->code+="\tmov ax , "+$4->Name+"\n";
					$$->code+="\tcmp ax , 0\n";
					$$->code+="\tje "+label2+"\n";
					$$->code+=$7->code;
					$$->code+=$5->code;
					$$->code+="\tjmp "+label1+"\n";
					cout<<label1<<endl;
					$$->code+=label2+":\n";
		
				}
			|	IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
					$$=$3;					
					string label=newLabel();
					$$->code+="\tmov ax, "+$3->Name+"\n";
					$$->code+="\tcmp ax, 0\n";
					$$->code+="\tje "+label+"\n";
					$$->code+=$5->code;
					$$->code+=label+":\n";
					
				}
			|	IF LPAREN expression RPAREN statement ELSE statement {
					$$=$3;
					
					string elselabel=newLabel();
					string exitlabel=newLabel();
					$$->code+="\tmov ax,"+$3->Name+"\n";
					$$->code+="\tcmp ax,0\n";
					$$->code+="\tje "+elselabel+"\n";
					$$->code+=$5->code;
					$$->code+="\tjmp "+exitlabel+"\n";
					cout<<exitlabel<<endl;
					$$->code+=elselabel+":\n";
					$$->code+=$7->code;
					$$->code+=exitlabel+":\n";
				}
			|	WHILE LPAREN expression RPAREN statement {
					$$ = new SymbolInfo();
					string label = newLabel();
					string exit = newLabel();
					$$->code = label + ":\n"; 
					$$->code+=$3->code;
					$$->code+="\tmov ax , "+$3->Name+"\n";
					$$->code+="\tcmp ax , 0\n";
					$$->code+="\tje "+exit+"\n";
					$$->code+=$5->code;
					$$->code+="\tjmp "+label+"\n";
					cout<<label<<endl;
					$$->code+=exit+":\n";
			
				}
			|	PRINTLN LPAREN ID RPAREN SEMICOLON {
					$$=new SymbolInfo("println","nonterminal");
					$$->code += "\tmov ax, " + $3->Name +"\n";
					$$->code += "\tcall Decimal_out\n";
				}
			| PRINTLN LPAREN ID RPAREN error
			{
			}
			| 	RETURN expression SEMICOLON {
					$$=$2;
					$$->code+="\tmov dx,"+$2->Name+"\n";
					$$->code+="\tjmp return_label\n";

		
				}
			| RETURN expression error
			{
			}
			;
		
expression_statement	: SEMICOLON	{
							$$=new SymbolInfo(";","SEMICOLON");
							$$->code="";
						}			
					| expression SEMICOLON {
							$$=$1;
						}		
					| expression error
						{
		
						} 		 		
						;
						
variable	: ID {
				SymbolInfo* temp = table.lookUp($1->Name,"VAR");
				if(temp == NULL){
				
				}
				else{
					$$= $1;
					$$->code="";
					$$->Name=$$->Name+to_string(table.scopeNum);
					bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==$$->Name)
						b=true;


					}
					if(b==false)
					{
					  variables.push_back($$->Name);
					   $$->Type="notarray";
					}
					
				}
		}		
		| ID LTHIRD expression RTHIRD {
				SymbolInfo* temp = table.lookUp($1->Name,"ARA");
				if(temp == NULL){
								
				}
				else{
					
					$$= $1;
					$$->AraSize=temp->AraSize;
					$$->Type="array";
					$$->Name=$$->Name+to_string(table.scopeNum);
						bool b=false;
					for(int i=0;i<arrays.size();i++)
					{
						if(arrays[i]==$$->Name)
						b=true;

					}
					if(b==false)
					{
					  arrays.push_back($$->Name);
					  arraySizes.push_back(temp->AraSize);

					}
					$$->code=$3->code ;
					$$->code += "\tmov bx, " +$3->Name +"\n";
					
			}
		}	
		;
			
expression : logic_expression {
			$$= $1;
		}	
		| variable ASSIGNOP logic_expression {
				$$=$1;
				$$->code=$3->code+$1->code;
				if($3->IDType!="FUNC")
				   $$->code+="\t mov ax, "+$3->Name+"\n";

				
				if($$->Type=="notarray"){ 
					$$->code+= "\tmov "+$1->Name+", ax\n";
				}
				
				else{
					$$->code+= "\tmov  "+$1->Name+"[bx], ax\n";
				}
			}	
		;
			
logic_expression : rel_expression {
					$$= $1;		
				}	
		| rel_expression LOGICOP rel_expression {
					$$=$1;
					$$->code+=$3->code;
					string label1 = newLabel();
					string label2 = newLabel();
					string temp = newTemp();
					bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;

					}
					cout<<"b"<<b<<endl;
					if(b==false)
					{
								cout<<"dd"<<endl;

					 variables.push_back(temp);
					}
					if($2->Name=="&&"){
						
						$$->code += "\tmov ax , " + $1->Name +"\n";
						$$->code += "\tcmp ax , 0\n";
				 		$$->code += "\tje " + label1 +"\n";
						$$->code += "\tmov ax , " + $3->Name +"\n";
						$$->code += "\tcmp ax , 0\n";
						$$->code += "\tje " + label1 +"\n";
						$$->code += "\tmov " + string(temp) + " , 1\n";
						$$->code += "\tjmp " + label2 + "\n";

						$$->code += label1 + ":\n" ;
						$$->code += "\tmov " + string(temp) + ", 0\n";
						$$->code += label2 + ":\n";
						$$->Name=temp;
						
					}
					else if($2->Name=="||"){
						$$->code += "\tmov ax , " + $1->Name +"\n";
						$$->code += "\tcmp ax , 0\n";
				 		$$->code += "\tjne " + string(label1) +"\n";
						$$->code += "\tmov ax , " + $3->Name +"\n";
						$$->code += "\tcmp ax , 0\n";
						$$->code += "\tjne " + string(label1) +"\n";
						$$->code += "\tmov " + string(temp) + " , 0\n";
						$$->code += "\tjmp " + string(label2) + "\n";
							cout<<label2<<endl;

						$$->code += string(label1) + ":\n" ;
						$$->code += "\tmov " + string(temp) + ", 1\n";
						$$->code += string(label2) + ":\n";
						$$->Name=temp;
						
					}
				}	
			;
			
rel_expression	: simple_expression {
				$$= $1;
			}	
		| simple_expression RELOP simple_expression {
				$$=$1;
				$$->code+=$3->code;
				$$->code+="\tmov ax, " + $1->Name+"\n";
				$$->code+="\tcmp ax, " + $3->Name+"\n";
				string temp=newTemp();

				bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
										cout<<"b"<<b<<endl;

					if(b==false)
					{
															cout<<"dd"<<endl;

					 variables.push_back(temp);
					}
				string label1=newLabel();
				string label2=newLabel();
				if($2->Name=="<"){
					$$->code+="\tjl " + string(label1)+"\n";
				}
				else if($2->Name=="<="){
					$$->code+="\tjle " + string(label1)+"\n";
				}
				else if($2->Name==">"){
					$$->code+="\tjg " + string(label1)+"\n";
				}
				else if($2->Name==">="){
					$$->code+="\tjge " + string(label1)+"\n";
				}
				else if($2->Name=="=="){
					$$->code+="\tje " + string(label1)+"\n";
				}
				else if($2->Name=="!="){
					$$->code+="\tjne " + string(label1)+"\n";
				}
				
				$$->code+="\tmov "+string(temp) +", 0\n";
				$$->code+="\tjmp "+string(label2) +"\n";
				cout<<label2<<endl;

				$$->code+=string(label1)+":\n";
				$$->code+= "\tmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->Name=temp;
			}	
		;
				
simple_expression : term {
				$$= $1;
			}
		| simple_expression ADDOP term {
				$$=$1;
				$$->code+=$3->code;
				
				
				if($2->Name=="+"){
					string temp = newTemp();
						bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
					if(b==false)
					{
					 variables.push_back(temp);
					}
					
					$$->code += "\tmov ax, " + $1->Name + "\n";
					$$->code += "\tadd ax, " + $3->Name + "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->Name=string(temp);
				}
				else if($2->Name == "-"){
					string temp = newTemp();
					bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
					if(b==false)
					{
					 variables.push_back(temp);
					}
					$$->code += "\tmov ax, " + $1->Name + "\n";
					$$->code += "\tsub ax, " + $3->Name + "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->Name=string(temp);
				}
			
			}
				;
				
term :	unary_expression 
		{
			$$= $1;
		}
	 	|term MULOP unary_expression 
		{
			$$=$1;
			$$->code += $3->code;
			$$->code += "\tmov ax, "+ $1->Name+"\n";
			$$->code += "\tmov bx, "+ $3->Name +"\n";
			string temp=newTemp();
			bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
					if(b==false)
					{
					 variables.push_back(temp);
					}

			if($2->Name=="*"){
				$$->code += "\tmul bx\n";
				$$->code += "\tmov "+ string(temp) + ", ax\n";
			}
			else if($2->Name=="/"){
				$$->code += "\txor dx , dx\n";
				$$->code += "\tdiv bx\n";
				$$->code += "\tmov " + string(temp) + " , ax\n";
			}
			else{
				$$->code += "\txor dx , dx\n";
				$$->code += "\tdiv bx\n";
				$$->code += "\tmov " + string(temp) + " , dx\n";
				
			}
			$$->Name=temp;
		
		}
	 	;

unary_expression 	:	ADDOP unary_expression  
					{
						
						if($1->Name == "+"){
							$$=$2;
						}
						else if($1->Name == "-")
						{
							$$ = $2;
							$$->code += "\tmov ax, " + $2->Name + "\n";
							$$->code += "\tneg ax\n";
							$$->code += "\tmov " + $2->Name + " , ax\n";
						}
					}
					|	NOT unary_expression 
					{
						$$=$2;
						string temp=newTemp();
						bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
					if(b==false)
					{
					 variables.push_back(temp);
					}

						$$->code="\tmov ax, " + $2->Name + "\n";
						$$->code+="\tnot ax\n";
						$$->code+="\tmov "+string(temp)+", ax";
					}
					|	factor 
					{
						$$=$1;
					}
					;
	
factor	: variable {
			SymbolInfo * newVar = new SymbolInfo(*$1);
			
			if($$->Type=="notarray"){
				
			}
			
			else{
				string temp= newTemp();
							bool b=false;
					for(int i=0;i<variables.size();i++)
					{
						if(variables[i]==temp)
						b=true;


					}
					if(b==false)
					{
					 variables.push_back(temp);
					}

				$$->code+="\tmov ax, " + $1->Name + "[bx]\n";
				$$->code+= "\tmov " + string(temp) + ", ax\n";
				$$->Name=temp;



				
			}
			}
	| ID LPAREN argument_list RPAREN
	{
		SymbolInfo *temp=new SymbolInfo();
			temp = table.lookUp($1->Name, "FUNC");
			if(temp == NULL){
			}

			for(int i=0;i<args.size();i++) 
			{
				cout<<args[i]<<endl<<endl;




			}
			$$->code+="\tcall "+$1->Name+"\n\t mov ax,dx\n";
			isF=true;



			

	}
	| LPAREN expression RPAREN 
	{
		$$= $2;
	}
	| CONST_INT 
	{
		
		$$= $1;
	}
	| CONST_FLOAT 
	{
		
		$$= $1;
	}
	| variable INCOP 
	{
		$$=$1;
		$$->code += "\tmov ax , " + $$->Name+ "\n";
		$$->code += "\tadd ax , 1\n";
		$$->code += "\tmov " + $$->Name + " , ax\n";
		
	}
	| variable DECOP
	{
		$$ = $1;
		
		$$->code += "\tmov ax , " + $$->Name+ "\n";
		$$->code += "\tsub ax , 1\n";
		$$->code += "\tmov " + $$->Name + " , ax\n";
	}
	;

argument_list	: arguments
				{
				}
				|{}
				;

arguments	:arguments COMMA logic_expression 
			{

				cout<<"arg "<<$3->Name<<endl;
				 

			}
			|logic_expression
			{
				cout<<"arg "<<$1->Name<<endl;
			}
			;
		
%%



  








int main(int argc, char * argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	asmCode=fopen("code.asm","w");

	logtext=fopen("log.txt","w");

	yyin= fin;
	yyparse();
	
	
	fprintf(logtext,"Total Lines %d\n",line_count);
	fprintf(logtext,"Total errors %d",error_count);






	fclose(logtext);
     fclose(asmCode);


	
	return 0;
}
