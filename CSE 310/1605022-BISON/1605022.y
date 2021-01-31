%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<iostream>
#include<string>
#include<stdio.h>
#include<sstream>
#include<fstream>
#include<list>
#include<iterator>
#include "1605022_table.h"
using namespace std;
list<SymbolInfo*>parameters;
list<SymbolInfo*> args;
string dec_type;
//list<SymbolInfo*> dec;


extern int line_count;
extern int error_count;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;

FILE *errortext=fopen("error.txt","w");
FILE *logtext= fopen("log.txt","w");


SymbolTable symboltable;


void yyerror(char *s)
{
	//write your code
}


%}

%union
{
        SymbolInfo *si;
		
}


%token<si>ADDOP MULOP RELOP LOGICOP  ASSIGNOP CONST_FLOAT ID NOT CONST_INT 
%token IF ELSE FOR WHILE INT FLOAT DOUBLE CHAR RETURN VOID MAIN PRINTLN SEMICOLON COMMA LPAREN RPAREN LCURL RCURL  LTHIRD RTHIRD INCOP DECOP
%type<si>type_specifier start program unit func_declaration func_definition parameter_list compound_statement var_declaration

%type<si>declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression



%right NOT
%left ADDOP
%left MULOP
%nonassoc ASSIGNOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program{

		



				
	}
	;

program : program unit{
		$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName(),"","");
		fprintf(logtext,"Line %d Production: program : program unit\n\n",line_count);	
		fprintf(logtext," %s %s \n\n  ",$<si>1->getName().c_str(),$<si>2->getName().c_str());
				
	} 
	| unit{
		$<si>$=new SymbolInfo($<si>1->getName(),"","");
		fprintf(logtext,"Line %d Production: program : unit\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		
				
	}
	;
	
unit : var_declaration{
		$<si>$=new SymbolInfo($<si>1->getName(),"","");
		fprintf(logtext,"Line %d Production: unit : var_declaration\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		
	}
     | func_declaration{
		$<si>$=new SymbolInfo($<si>1->getName(),"","");
		fprintf(logtext,"Line %d Production: unit : func_declaration\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
				
	}
     | func_definition{
		$<si>$=new SymbolInfo($<si>1->getName(),"","");
		fprintf(logtext,"Line %d Production: unit : func_definition\n ",line_count);	
		fprintf(logtext," %s \n \n ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());				
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON{
	$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+"("+$<si>4->getName()+" "+")"+";\n","","");
	fprintf(logtext,"Line  %d Production: func_declaration:type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
   fprintf(logtext,"%s %s(%s);\n\n",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>4->getName().c_str()); 	
    if(symboltable.look_up($<si>2->getName())==NULL)
				  {
					  symboltable.insert($<si>2->getName(),$<si>2->getType(),"");
				  }
				  else
				  {
                     
                 fprintf(logtext,"Error at line %d :The function was previously declared\n\n ",line_count);
				fprintf(errortext,"Error at line %d :The function was previously declared\n\n ",line_count);
				error_count++;


				  } 
  

		}
		| type_specifier ID LPAREN RPAREN SEMICOLON{

			 if(symboltable.look_up($<si>2->getName())==NULL)
				  {
					  symboltable.insert($<si>2->getName(),$<si>2->getType(),"");
				  }
				  else
				  {
                     
                 fprintf(logtext,"Error at line %d :The function was previously declared\n\n ",line_count);
				fprintf(errortext,"Error at line %d :The function was previously declared\n\n ",line_count);
                 error_count++;

				  }
		$<si>$=new SymbolInfo($<si>1->getName()+" "+" "+$<si>2->getName()+" "+" "+"();\n","","");
		fprintf(logtext,"Line  %d Production: func_declaration:type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
		     fprintf(logtext,"%s %s();\n\n",$<si>1->getName().c_str(),$<si>2->getName().c_str()); 	

		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement{


			 if(symboltable.look_up($<si>2->getName())==NULL)
				  {
					  symboltable.insert($<si>2->getName(),$<si>2->getType(),"");
				  }
			$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+"("+$<si>4->getName()+" "+")"+$<si>6->getName(),"","");
fprintf(logtext,"Line  %d Production: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_count);
 fprintf(logtext,"%s %s (%s) %s \n\n",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>4->getName().c_str(),$<si>6->getName().c_str()); 	
 //$<si>$->setName($<si>1->getName()+" "+$<si>2->getName()+" "+"("+$<si>4->getName()+" "+")"+$<si>6->getName()); 




		}	
		| type_specifier ID LPAREN RPAREN compound_statement{

	$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+"()"+$<si>5->getName(),"","");
fprintf(logtext,"Line  %d Production: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
		     fprintf(logtext,"%s %s()%s \n\n",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>5->getName().c_str()); 	
		    // $<si>$->setName($<si>1->getName()+" "+$<si>2->getName()+" "+"()"+$<si>5->getName());
			
			 if(symboltable.look_up($<si>2->getName())==NULL)
				  {
					  symboltable.insert($<si>2->getName(),$<si>2->getType(),"");
				  } 


		}

 		;				


parameter_list  : parameter_list COMMA type_specifier ID{

		$<si>$=new SymbolInfo($<si>1->getName()+" "+","+$<si>3->getName()+" "+$<si>4->getName(),"","");
		     fprintf(logtext,"Line  %d Production: parameter_list:parameter_list COMMA type_specifier ID\n",line_count);
		     fprintf(logtext,"%s,%s %s \n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str(),$<si>4->getName().c_str()); 	
              parameters.push_back(new SymbolInfo($<si>4->getName(),"ID",$<si>3->getName()));
			  
			 if(symboltable.look_up($<si>4->getName())==NULL)
				  {
					  symboltable.insert($<si>4->getName(),$<si>4->getType(),"");
				  } 

		}
		| parameter_list COMMA type_specifier{
			$<si>$=new SymbolInfo($<si>1->getName()+" "+","+$<si>3->getName(),"","");
		     fprintf(logtext,"Line  %d Production: parameter_list:parameter_list COMMA type_specifier\n\n",line_count);
		     fprintf(logtext,"%s,%s \n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str()); 	
           parameters.push_back(new SymbolInfo("","ID",$<si>3->getName()));

			}
 		| type_specifier ID{
			$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" ","","");
		     fprintf(logtext,"Line  %d Production: parameter_list:type_specifier ID\n\n",line_count);
		     fprintf(logtext,"%s %s \n\n",$<si>1->getName().c_str(),$<si>2->getName().c_str()); 	
		      parameters.push_back(new SymbolInfo($<si>2->getName(),"ID",$<si>1->getName()));
			  
			 if(symboltable.look_up($<si>2->getName())==NULL)
				  {
					  symboltable.insert($<si>2->getName(),$<si>2->getType(),"");
				  } 


			}
		| type_specifier{
				$<si>$=new SymbolInfo($<si>1->getName()+" ","","");
		     fprintf(logtext,"Line  %d Production: parameter_list:type_specifier\n\n",line_count);
		     fprintf(logtext,"%s \n\n",$<si>1->getName().c_str()); 	
			  parameters.push_back(new SymbolInfo("","ID",$<si>1->getName()));
		    	

			}
 		;

 		
compound_statement : LCURL{symboltable.Enter_scope();} statements RCURL{
		 $<si>$=new SymbolInfo("{\n\n"+$<si>2->getName()+"\n\n}","",""); 
	fprintf(logtext,"Line  %d Production : compound_statement:LCURL statements RCURL\n\n",line_count);
	fprintf(logtext,"{ %s }\n\n",$<si>2->getName().c_str());
	symboltable.printAll(logtext);
	symboltable.Exit_scope();
	}
 		         | LCURL{symboltable.Enter_scope();} RCURL {
          
	        fprintf(logtext,"Line  %d Production: compound_statement:LCURL RCURL\n\n",line_count);
			fprintf(logtext,"{\n\n} \n\n");
			symboltable.printAll(logtext);
			symboltable.Exit_scope();
							
			 
                 }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
			$<si>$=new SymbolInfo($<si>1->getName()+" "+" "+$<si>2->getName()+";\n","","");
		     fprintf(logtext,"Line  %d Production: var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);
		   fprintf(logtext,"%s %s;\n",$<si>1->getName().c_str(),$<si>2->getName().c_str());
		   //$<si>$->setName($<si>1->getName()+" "+" "+$<si>2->getName()+";");







}		 

		


 ;
 		 
type_specifier	: INT {
	       dec_type="int";
			
			$<si>$=new SymbolInfo("int","","");
		     fprintf(logtext,"Line  %d Production: type_specifier:INT\n\n",line_count);
		     fprintf(logtext,"int\n\n"); 	
		    // $<si>$->setName("int"); 
	//	    cout << "in rule Type->int " << $<si>$->getName() << endl;
		
			
		    }
 		| FLOAT{
			 dec_type="float";
			  $<si>$=new SymbolInfo("float ","","");
		     fprintf(logtext,"Line  %d Production: type_specifier:FLOAT\n\n",line_count);
		     fprintf(logtext,"float "); 	
		     //$<si>$->setName("float "); 
			
		    }
 		| VOID{
			 dec_type="float";
			  $<si>$=new SymbolInfo("void ","","");
		     fprintf(logtext,"Line  %d Production: type_specifier:VOID\n\n",line_count);
		     fprintf(logtext,"void"); 	
		     //$<si>$->setName("void "); 
			
		    }
 		;
 		
declaration_list : declaration_list COMMA ID{
			$<si>$=new SymbolInfo($<si>1->getName()+" "+","+$<si>3->getName(),"",dec_type); 
			fprintf(logtext,"Line  %d Production : declaration_list:declaration_list COMMA ID\n\n",line_count);
			fprintf(logtext,"%s , %s\n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str());
			//$<si>$->setName($<si>1->getName()+" "+","+$<si>3->getName());
			
			 if(symboltable.curr->look_up($<si>3->getName())==NULL)
				  {
					  symboltable.insert($<si>3->getName(),$<si>3->getType(),dec_type);
				  } 

				  else
				  {
					   fprintf(logtext,"Error at line %d :multiple declaration\n\n",line_count);
					   fprintf(errortext,"Error at line %d :multiple declaration\n\n",line_count);
					       error_count++;
				  }

			}
 			  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			$<si>$=new SymbolInfo($<si>1->getName()+" "+","+$<si>3->getName()+" "+"["+$<si>5->getName()+"]","",dec_type); 
fprintf(logtext,"Line  %d Production : declaration_list:declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		fprintf(logtext,"%s,%s [%s]\n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str(),$<si>5->getName().c_str());
				//$<si>$->setName($<si>1->getName()+" "+","+$<si>3->getName()+" "+"["+$<si>5->getName()+"]");
				
			 if(symboltable.curr->look_up($<si>3->getName())==NULL)
				  {
					  symboltable.insert($<si>3->getName(),$<si>3->getType(),dec_type);
				  } 

			else 
			{

				 fprintf(logtext,"Error at line %d :multiple declaration\n\n",line_count);
				 fprintf(errortext,"Error at line %d :multiple declaration\n\n",line_count);
				     error_count++;
			}

			}

 		  | ID { 	
			$<si>$ = new SymbolInfo($<si>1->getName(),"",dec_type);
		     		
		     fprintf(logtext,"Line  %d Production: declaration_list:ID\n\n",line_count);
		      fprintf(logtext,"%s \n\n",$<si>1->getName().c_str()); 	
		     
			 
			if(symboltable.curr->look_up($<si>1->getName())==NULL)	{
				symboltable.insert($<si>1->getName(),$<si>1->getType(),dec_type);
			}
			else	{
               
			    fprintf(logtext,"Error at line %d :multiple declaration\n\n",line_count);
				fprintf(errortext,"Error at line %d :multiple declaration\n\n",line_count);
				    error_count++;
      
 			} 
			
			
		    }
 		  | ID LTHIRD CONST_INT RTHIRD  {
			$<si>$=new SymbolInfo($<si>1->getName()+" "+"["+$<si>3->getName()+"]","",dec_type);
			 fprintf(logtext,"Line  %d Production : declaration_list:ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
		         fprintf(logtext,"%s [%s] \n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str());
			
			 if(symboltable.curr->look_up($<si>1->getName())==NULL)
				  {
					  symboltable.insert($<si>1->getName(),$<si>1->getType(),dec_type);
				  } 

				  else 
				  {
					  fprintf(logtext,"Error at line %d :multiple declaration\n\n",line_count);
					   fprintf(errortext,"Error at line %d :multiple declaration\n\n",line_count);
					       error_count++;

				  }


                 }

 		  ;
 		  
statements : statement{
			$<si>$=new SymbolInfo($<si>1->getName(),"","");
			fprintf(logtext,"Line %d Production: statements : statement\n\n",line_count);
			fprintf(logtext,"%s \n\n",$<si>1->getName().c_str());
		//	$<si>$->setName($<si>1->getName());
			


		}
	   | statements statement{
			$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName(),"","");
			fprintf(logtext,"Line %d Production: statements :statements statement\n\n",line_count);
			fprintf(logtext," %s %s \n",$<si>1->getName().c_str(),$<si>2->getName().c_str());
			//$<si>$->setName($<si>1->getName()+" "+$<si>2->getName());
			


		}
	   ;
	   
statement : var_declaration{
			$<si>$=new SymbolInfo($<si>1->getName()+" ","","");
			fprintf(logtext,"Line %d Production: statement: var_declaration\n\n",line_count);
			fprintf(logtext," %s \n\n",$<si>1->getName().c_str());
			//$<si>$->setName($<si>1->getName()+" ");
			


		}
	  | expression_statement{
			$<si>$=new SymbolInfo($<si>1->getName()+" ","","");
			fprintf(logtext,"Line %d Production: statement : expression_statement\n\n",line_count);
			fprintf(logtext," %s \n\n",$<si>1->getName().c_str());
			//$<si>$->setName($<si>1->getName()+" ");
			


		}
	  | compound_statement{
			$<si>$=new SymbolInfo($<si>1->getName()+" ","","");
			fprintf(logtext,"Line %d Production: statement : compound_statement\n\n",line_count);
			fprintf(logtext," %s \n\n",$<si>1->getName().c_str());
			//$<si>$->setName($<si>1->getName()+" ");
			


		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement{
	$<si>$=new SymbolInfo("for("+$<si>3->getName()+" "+$<si>4->getName()+" "+$<si>5->getName()+" "+")"+$<si>7->getName(),"","");
fprintf(logtext,"Line %d Production: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
	fprintf(logtext,"for(%s %s %s) %s\n\n",$<si>3->getName().c_str(),$<si>4->getName().c_str(),$<si>5->getName().c_str(),$<si>7->getName().c_str());
	//$<si>$->setName("for("+$<si>3->getName()+" "+$<si>4->getName()+" "+$<si>5->getName()+" "+")"+$<si>7->getName());
			

		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{

		$<si>$=new SymbolInfo("if("+$<si>3->getName()+" "+")"+$<si>5->getName(),"","");
fprintf(logtext,"Line %d Production: statement : IF LPAREN expression RPAREN statement\n\n",line_count);
	fprintf(logtext,"if(%s) %s \n\n",$<si>3->getName().c_str(),$<si>5->getName().c_str());
	//$<si>$->setName("if("+$<si>3->getName()+" "+")"+$<si>5->getName());
			


		}
	  | IF LPAREN expression RPAREN statement ELSE statement{


		$<si>$=new SymbolInfo("if("+$<si>3->getName()+" "+")"+$<si>5->getName()+" "+"else"+$<si>7->getName(),"","");
fprintf(logtext,"Line %d Production: statement: IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
	fprintf(logtext,"if(%s) %s else %s \n\n",$<si>3->getName().c_str(),$<si>5->getName().c_str(),$<si>7->getName().c_str());
//	$<si>$->setName("if("+$<si>3->getName()+" "+")"+$<si>5->getName()+" "+"else"+$<si>7->getName());
			


		}
	  | WHILE LPAREN expression RPAREN statement{
   $<si>$=new SymbolInfo("while("+$<si>3->getName()+" "+")"+$<si>5->getName(),"","");
   fprintf(logtext,"Line %d Production: statement : WHILE LPAREN expression RPAREN statement\n\n",line_count);
	fprintf(logtext,"while( %s) %s \n\n",$<si>3->getName().c_str(),$<si>5->getName().c_str());
	//$<si>$->setName("while("+$<si>3->getName()+" "+")"+$<si>5->getName());
	}		

	  | PRINTLN LPAREN ID RPAREN SEMICOLON {

		$<si>$=new SymbolInfo("println("+$<si>3->getName()+");\n","","");
   fprintf(logtext,"Line %d Production: statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n",line_count);
	fprintf(logtext,"println( %s ); \n\n",$<si>3->getName().c_str());
  //	$<si>$->setName("println("+$<si>3->getName()+")");
			}
	  | RETURN expression SEMICOLON{
		$<si>$=new SymbolInfo("return "+$<si>2->getName()+" "+";\n","","");
   fprintf(logtext,"Line %d Production: statement :RETURN expression SEMICOLON  \n\n",line_count);
	fprintf(logtext,"return %s ; \n\n",$<si>2->getName().c_str());
	//$<si>$->setName("return "+$<si>2->getName()+" "+";");
			}
		
	  ;
	  
expression_statement 	: SEMICOLON{ $<si>$=new SymbolInfo(";\n","","");
		     fprintf(logtext,"Line  %d Production: expression_statement:SEMICLOLON\n\n",line_count);
		     fprintf(logtext," ;\n"); 	
		     //$<si>$->setName(";"); 
			
		    }			
			| expression SEMICOLON
			{
                           $<si>$=new SymbolInfo($<si>1->getName()+";\n\n","","");
		     fprintf(logtext,"Line  %d Production: expression_statement:expression SEMICLOLON\n\n",line_count);
		     fprintf(logtext,"%s \n\n",$<si>1->getName().c_str()); 	
		     //$<si>$->setName($<si>1->getName());
			  
			
			}		 


			
			;
	  
variable : ID {
		$<si>$=new SymbolInfo($<si>1->getName(),"","");
				//$<si>$->setName($<si>1->getName());
			cout <<"in varirable : id\n";
		fprintf(logtext,"Line %d Production: variable : ID\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
	
			 if(symboltable.look_up($<si>1->getName())==NULL)
				  {
					  symboltable.insert($<si>1->getName(),$<si>1->getType(),"");
				  } 



}	
	 | ID LTHIRD expression RTHIRD{ $<si>$=new SymbolInfo($<si>1->getName()+" "+"["+$<si>3->getName()+"]","","");
		     fprintf(logtext,"Line  %d Production: variable: ID LTHIRD expression RTHIRD\n\n",line_count);
		     fprintf(logtext,"%s [%s]\n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str()); 	
		    // $<si>$->setName($<si>1->getName()+" "+"["+$<si>3->getName()+"]");


			
			 if(symboltable.look_up($<si>1->getName())==NULL)
				  {
					  fprintf(logtext,"Error at line %d :Undeclared array\n\n",line_count);
					 fprintf(errortext,"Error at line %d :Undeclared array\n\n",line_count);
					     error_count++;


					  symboltable.insert($<si>1->getName(),$<si>1->getType(),"");
				  } 

			/*if($<si>3->dec!="int")
			{
				fprintf(logtext,"Error at line %d :Array index must be integer\n\n",line_count);
				fprintf(errortext,"Error at line %d :Array index must be integer\n\n",line_count);
				    error_count++;
			}*/

		}
	 ;
	 
 expression : logic_expression{$<si>$=new SymbolInfo($<si>1->getName()+" ","",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  expression : logic_expression\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
	//	$<si>$->setName($<si>1->getName()+" ");
		}		
	   | variable ASSIGNOP logic_expression{ $<si>$=new SymbolInfo($<si>1->getName()+" "+"="+$<si>3->getName(),"","");
		     fprintf(logtext,"Line  %d Production: expression:variable ASSIGNOP logic_expression\n\n",line_count);
		     fprintf(logtext,"%s=%s\n\n",$<si>1->getName().c_str(),$<si>3->getName().c_str()); 	
		     //$<si>$->setName($<si>1->getName()+" "+"="+$<si>3->getName());

           if($<si>1->dec=="int")
		   {
			   if($<si>3->dec=="float")
			   {
			  			 fprintf(logtext,"Line %d warning : type casting .\n\n",line_count);
			   }
			   $<si>$->dec="float";
		   }
		   if($<si>1->dec=="float")
		   {
			   if($<si>3->dec=="int")
			   {
				  			 fprintf(logtext,"Line %d warning : type casting .\n\n",line_count);
			   }
			   			   $<si>$->dec="float";

		   }


		} 	
	   ;
			
logic_expression : rel_expression{$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  logic_expression : rel_expression\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		} 	
		 | rel_expression LOGICOP rel_expression {
			 $<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  logic_expression : rel_expression LOGICOP rel_expression\n\n ",line_count);	
		fprintf(logtext," %s %s %s\n\n  ",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>3->getName().c_str());
	//	$<si>$->setName($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName());
		} 	
		 ;
			
rel_expression	: simple_expression {
		$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  rel_expression	: simple_expression\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		}
		| simple_expression RELOP simple_expression{
			$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  rel_expression :  simple_expression RELOP simple_expression\n\n ",line_count);	
	fprintf(logtext," %s %s %s\n\n  ",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>3->getName().c_str());
	//	$<si>$->setName($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName());
		}
		;
				
simple_expression : term {
	     $<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  simple_expression	: term\n\n ",line_count);	
		fprintf(logtext," %s \n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		}
		  |simple_expression ADDOP term{
			  $<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName(),"","");
		fprintf(logtext,"Line %d Production:  simple_expression :  simple_expression ADDOP term\n\n ",line_count);	
		fprintf(logtext," %s %s %s\n\n  ",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>3->getName().c_str());
		//$<si>$->setName($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName());


		 if($<si>1->dec=="int"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="int"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="int";

		  }	
        if($<si>1->dec=="float"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="float"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="float";

		  }	

		  else
		  {

			  /*	fprintf(logtext,"Error at line %d Invalid addition\n",line_count);	
				fprintf(errortext,"Error at line %d Invalid addition\n",line_count);
				    error_count++;*/

		  }


		} 
		  ;
					
term :	unary_expression{$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  term :unary_expression\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		}
     |  term MULOP unary_expression{
		 $<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName()+" "+$<si>3->getName(),"","");
		fprintf(logtext,"Line %d Production:  term :term MULOP unary_expression\n\n ",line_count);	
		fprintf(logtext," %s %s %s\n\n  ",$<si>1->getName().c_str(),$<si>2->getName().c_str(),$<si>3->getName().c_str());
		if($<si>2->getName()=="*")
		{
		  if($<si>1->dec=="int"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="int"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="int";

		  }	
        if($<si>1->dec=="float"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="float"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="float";

		  }	

		  else
		  {
           /*
			  	fprintf(logtext,"Error at line %d Invalid multiplication\n",line_count);	
				fprintf(errortext,"Error at line %d Invalid multiplication\n",line_count);
				    error_count++;*/

		  }

		  }

	      if($<si>2->getName()=="/")
		{
			 if($<si>1->dec=="int"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="int"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="int";

		  }	
        if($<si>1->dec=="float"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="float"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="float";

		  }	

		  else
		  {

			  /*	fprintf(logtext,"Error at line %d Invalid division\n\n",line_count);	
				fprintf(errortext,"Error at line %d Invalid division\n\n",line_count);
				    error_count++;*/

		  }
           

		}


		if($<si>2->getName()=="%")
		{
              if($<si>1->dec=="int"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="int"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="int";

		  }	
        if($<si>1->dec=="float"&& $<si>3->dec=="float")
		  {
			  $<si>$->dec="float";

		  }	

		if($<si>1->dec=="float"&& $<si>3->dec=="int")
		  {
			  $<si>$->dec="float";

		  }	

		  else
		  {

			  /*	fprintf(logtext,"Error at line %d Invalid mod\n\n",line_count);	
				fprintf(errortext,"Error at line %d Invalid mod\n\n",line_count);
				    error_count++;*/

		  }

		}




		}
     ;

unary_expression : ADDOP unary_expression {$<si>$=new SymbolInfo($<si>1->getName()+" "+$<si>2->getName(),"",$<si>2->dec);
		fprintf(logtext,"Line %d Production: unary_expression:ADDOP unary_expression\n \n",line_count);	
		fprintf(logtext," %s %s\n \n ",$<si>1->getName().c_str(),$<si>2->getName().c_str());
	//	$<si>$->setName($<si>1->getName()+" "+$<si>2->getName());
		}  

		 | NOT unary_expression{$<si>$=new SymbolInfo("!"+$<si>2->getName(),"",$<si>2->dec);
		fprintf(logtext,"Line %d Production: unary_expression:NOT unary_expression\n\n ",line_count);	
		fprintf(logtext," !%s \n \n ",$<si>2->getName().c_str());
		//$<si>$->setName("!"+$<si>2->getName());
		} 

		 | factor {$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d Production:  unary_expression:factor\n \n",line_count);	
		fprintf(logtext," %s \n \n ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		}
		 ;
	
factor	: variable {$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d factor: variable\n \n",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName());
		}
	| ID LPAREN argument_list RPAREN{$<si>$=new SymbolInfo($<si>1->getName()+" "+"("+$<si>3->getName()+")","",$<si>1->dec);
		fprintf(logtext,"Line %d factor: ID LPAREN argument_list RPAREN\n\n ",line_count);	
		fprintf(logtext," %s (%s)\n\n  ",$<si>1->getName().c_str(),$<si>3->getName().c_str());
		if(symboltable.look_up($<si>1->getName())==NULL)
		{
			fprintf(errortext,"Error at line %d :Undeclared function %s\n",line_count,$<si>1->getName().c_str());
    error_count++;
			fprintf(logtext,"Error at line %d :Undeclared function %s\n",line_count,$<si>1->getName().c_str());
		}


	//	$<si>$->setName($<si>1->getName()+" "+"("+$<si>3->getName()+")");
		}

	| LPAREN expression RPAREN{$<si>$=new SymbolInfo($<si>2->getName(),"",$<si>2->dec);
		fprintf(logtext,"Line %d factor:  LPAREN expression RPAREN\n\n ",line_count);	
		fprintf(logtext," (%s)\n\n  ",$<si>2->getName().c_str());
		//$<si>$->setName($<si>2->getName());
		}

	| CONST_INT { $<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		     fprintf(logtext,"Line  %d Production: factor:CONST_INT\n\n",line_count);
		     fprintf(logtext,"%s \n\n",$<si>1->getName().c_str()); 	
		    // $<si>$->setName($<si>1->getName()); 
			
		    }
	| CONST_FLOAT{ $<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		     fprintf(logtext,"Line  %d Production: factor:CONST_FLOAT\n\n",line_count);
		     fprintf(logtext,"%s \n\n",$<si>1->getName().c_str()); 	
		    // $<si>$->setName($<si>1->getName()); 
			
		    }
	| variable INCOP{$<si>$=new SymbolInfo($<si>1->getName()+"++","",$<si>1->dec);
		fprintf(logtext,"Line %d factor: variable INCOP\n \n",line_count);	
		fprintf(logtext," %s++\n\n  ",$<si>1->getName().c_str());
		//$<si>$->setName($<si>1->getName()+"++");
		} 
	| variable DECOP{
		$<si>$=new SymbolInfo($<si>1->getName()+"--","",$<si>1->dec);
		fprintf(logtext,"Line %d factor: variable DECCOP\n\n ",line_count);	
		fprintf(logtext," %s--\n \n ",$<si>1->getName().c_str());
	   
		}
	;
	
argument_list : arguments{
	      $<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d argument_list : arguments\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
	


		}
		|//for void 
		{
			
			 fprintf(logtext,"at line %d: argument_list : empty\n\n",line_count);
			 $<si>$= new SymbolInfo("","","");
		 
		}
              
 ;
	
arguments : arguments COMMA logic_expression{
	        $<si>$=new SymbolInfo($<si>1->getName()+","+$<si>3->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d arguments:  arguments COMMA logic_expression\n\n ",line_count);	
		fprintf(logtext," %s,%s\n \n ",$<si>1->getName().c_str(),$<si>3->getName().c_str());

		
	
	
}

	      | logic_expression{
		$<si>$=new SymbolInfo($<si>1->getName(),"",$<si>1->dec);
		fprintf(logtext,"Line %d arguments: logic_expression\n\n ",line_count);	
		fprintf(logtext," %s \n\n  ",$<si>1->getName().c_str());
		
		}
	      ;
 

%%
int main(int argc,char *argv[])
{
		

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n\n");
		exit(1);
	}
	
   symboltable.Enter_scope();
	
	yyin=fp;
	yyparse();
  symboltable.printAll(logtext);
        fprintf(logtext,"Total lines: %d\n\n",line_count);
	    fprintf(logtext,"Total errors: %d\n\n",error_count);
		fprintf(errortext,"Total errors: %d\n\n",error_count);
	



    return 0;




}

	

