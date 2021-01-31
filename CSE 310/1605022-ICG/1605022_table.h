#include<iostream>
#include<vector>
#include<fstream>
#include<string>

using namespace std;


class SymbolInfo{
public:
    string Name;
    string Type;
	string IDType;				
	string VarType;				
	int AraSize; 				
	string FuncRet;				
	bool FuncDefined = false;	

	string code;
	vector<string> ParamList;	

	vector<int> ints; 
	vector<float> floats;



    SymbolInfo(){
    }

	SymbolInfo(const SymbolInfo *sym){
		Name = sym->Name;
		Type = sym->Type;
		code = sym->code;
	}
	
	SymbolInfo(string type){
		VarType = type;
		if(type == "INT") ints.push_back(0);
		else if(type == "FLOAT") floats.push_back(0);
    }

    SymbolInfo(string name, string type){
        Name = name;
        Type = type;
    }

	void setVarType(string type){
		VarType = type;	
		if(type == "INT") ints.push_back(0);
		else if(type == "FLOAT") floats.push_back(0);
	}
	
  
	
	

};

class ScopeTable{
private:

    vector<SymbolInfo>* symbols;
    ScopeTable* parentScope;
    int mod;
    int ID;

public:

    ScopeTable(){
        parentScope = NULL;
    }

    ScopeTable(int M,int id){
        mod = M;
        symbols = new vector<SymbolInfo>[mod];
        parentScope = new ScopeTable;
        parentScope = NULL;
        ID = id;
    }

    SymbolInfo* Insert(SymbolInfo sym){
        symbols[Hash(sym)].push_back(sym);
        return &symbols[Hash(sym)][symbols[Hash(sym)].size()-1];
    }

    int Hash(SymbolInfo sym){
        int key = 0;
        string name = sym.Name;
        for(int i = 0; i< name.size(); i++)
            key += (int)name[i];
        return(key % mod);
    }

    int Hash(string name){
        int key = 0;
        for(int i = 0 ; i< name.size(); i++)
            key += (int)name[i];
        return (key % mod);
    }

    int getID(){return ID;}

  

    SymbolInfo* lookUp(string name, string type){
        int key = Hash(name);
        for(int i = 0; i< symbols[key].size(); i++){
            if(symbols[key][i].Name == name && symbols[key][i].IDType == type){
                //loc = i;
                return &symbols[key][i];
            }
        }
        return NULL;
    }

    SymbolInfo* lookUp(SymbolInfo sym){
        int key = Hash(sym.Name);
        for(int i = 0; i< symbols[key].size(); i++){
            if(symbols[key][i].Name== sym.Name && symbols[key][i].IDType == sym.IDType){
                //loc = i;
                return &symbols[key][i];
            }
        }
        return NULL;
    }

    void Delete(string name){
        int key = Hash(name);
        int s = symbols[key].size();
        for(int i = 0; i< s; i++){
            if(symbols[key][i].Name == name){
                if( s == 1) {
                    symbols[key].clear();

                }
                else{
                    for(int j = i; j<s-1; j++){
                        symbols[key][j] = symbols[key][j+1];
                    }
                    symbols[key].erase(symbols[key].begin() +s-1);
                    symbols[key].resize(s-1);

                }

              

                return;
            }
        }
    }
};

class SymbolTable{

private:
    vector<ScopeTable> tableStack;
    int current;
    
    int mod;
	int size;

public:

	int scopeNum;
    SymbolTable(int m){
        scopeNum = 1;
        mod = m;
        ScopeTable newScope(mod, scopeNum);
        tableStack.push_back(newScope);
        current = 0;
		size = 1;

    }


	SymbolInfo* Insert(SymbolInfo sym){
		return tableStack[current].Insert(sym);
	}
	bool Insert(string name, string type){
		
        SymbolInfo* temp = new SymbolInfo;
		SymbolInfo sym(name,type);
        temp = tableStack[current].lookUp(sym);
        if(temp == NULL){
            tableStack[current].Insert(sym);
          
            return true;
        }
        else{
            
            return false;
        }
    }

	SymbolInfo* InsertandGet(string name, string type){
		SymbolInfo* temp = new SymbolInfo(name, type);
		SymbolInfo* temp2 = tableStack[current].Insert(*temp);
		return temp2;
	}

    SymbolInfo* lookUp(string name, string type){
        for(int i = current; i>=0; i--){
            SymbolInfo* temp = new SymbolInfo;
            temp = tableStack[i].lookUp(name, type);
            if(temp != NULL){
              
                return temp;
            }
        }
        return NULL;

    }

   

    bool Remove(string name){
        SymbolInfo* temp = new SymbolInfo;
        temp = tableStack[current].lookUp(name);
        if(temp == NULL){
            cout << "Not found" << endl;
            return false;
        }
        else{
            

            tableStack[current].Delete(name);
        }
    }

    void enterScope(){
        ScopeTable newScope(mod,++scopeNum);
		size++;
        current++;
        tableStack.push_back(newScope);
    }

    void exitScope(){
        tableStack.erase(tableStack.begin()+ current--);
		
        tableStack.resize(--size);
    }

};

