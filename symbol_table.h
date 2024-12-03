#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "identifier_categories.h"
#include "variable_types.h"
#include "pass_by_types.h"

typedef struct FormalParameterAttributes FormalParameterAttributes;
typedef struct ProcedureAttributes ProcedureAttributes;
typedef struct FunctionAttributes FunctionAttributes;
typedef struct SimpleVariableAttributes SimpleVariableAttributes;
typedef struct SymbolTableNode SymbolTableNode;
typedef struct SymbolTable SymbolTable;

struct FormalParameterAttributes {
  enum VariableTypes formal_parameter_variable_type; 
  unsigned int offset;
  enum PassByTypes formal_parameter_pass_by_type;
};

struct ProcedureAttributes {
  int procedure_label;
  unsigned int formal_params_count;
  int implemented;

  FormalParameterAttributes* parameters; 
};

struct FunctionAttributes {
  int function_label;
  unsigned int formal_params_count;
  enum VariableTypes return_type;
  int offset;
  int implemented;

  FormalParameterAttributes* parameters; 
};

struct SimpleVariableAttributes {
  enum VariableTypes variable_type;
  unsigned int offset;
};

struct SymbolTableNode {
  char* identifier;
  enum IdentifierCategories identifier_category;
  unsigned int lexical_level; 
  void* attributes;

  SymbolTableNode* next;
  SymbolTableNode* previous;
};

struct SymbolTable {
  SymbolTableNode* top;
};

SymbolTable* create_symbol_table();
void insert_in_symbol_table(SymbolTable* symbol_table, char* identifier, enum IdentifierCategories identifier_category, unsigned int lexical_level, void* attributes);
void insert_simple_variable_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, unsigned int offset);
void update_latest_nodes_with_variable_type(SymbolTable* symbol_table, enum VariableTypes variable_type); 
void remove_n_latest_nodes_from_symbol_table(SymbolTable* symbol_table, int n); 
void free_symbol_table(SymbolTable* symbol_table);
SymbolTableNode* find_node_from_symbol_table_by_identifier(SymbolTable* symbol_table, char* identifier);
SymbolTableNode* insert_function_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, int function_label);
SymbolTableNode* insert_procedure_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, int procedure_label);
void insert_formal_parameter_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, enum PassByTypes pass_by_type);
void update_function_and_formal_parameters(SymbolTable* symbol_table, SymbolTableNode* function_node, int formal_params_count, enum VariableTypes formal_parameters_variable_type, enum VariableTypes return_type);
void update_procedure_and_formal_parameters(SymbolTable* symbol_table, SymbolTableNode* procedure_node, int formal_params_count, enum VariableTypes formal_parameters_variable_type);
void remove_subroutines_from_symbol_table_in_lexical_level(SymbolTable *symbol_table, unsigned int lexical_level); 
void remove_formal_parameters_from_symbol_table(SymbolTable* symbol_table);
SymbolTableNode* pop_node_from_symbol_table(SymbolTable* symbol_table);
int check_for_subroutines_not_implemented(SymbolTable* symbol_table);

#endif