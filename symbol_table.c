#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

SymbolTable* create_symbol_table(){
  SymbolTable* symbol_table = (SymbolTable *) malloc(sizeof(SymbolTable)); 

  symbol_table->top = NULL; 

  return symbol_table;
}

void insert_in_symbol_table(SymbolTable* symbol_table, char* identifier, enum IdentifierCategories identifier_category, unsigned int lexical_level, void* attributes){
  SymbolTableNode* symbol_table_node = (SymbolTableNode *) malloc(sizeof(SymbolTableNode));
  symbol_table_node->identifier = (char *)malloc(strlen(identifier) + 1);

  memcpy(symbol_table_node->identifier, identifier, strlen(identifier) + 1);
  symbol_table_node->identifier_category = identifier_category; 
  symbol_table_node->lexical_level = lexical_level;
  symbol_table_node->attributes = attributes;
  symbol_table_node->next = NULL;
  symbol_table_node->previous = symbol_table->top;

  if (symbol_table->top) symbol_table->top->next = symbol_table_node;

  symbol_table->top = symbol_table_node;
}

void insert_simple_variable_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, unsigned int offset) {
  void* attributes = (void *) malloc(sizeof(SimpleVariableAttributes));
  SimpleVariableAttributes* simple_variable_attributes = (SimpleVariableAttributes *) attributes;

  simple_variable_attributes->variable_type = UNKNOWN;
  simple_variable_attributes->offset = offset;

  insert_in_symbol_table(symbol_table, identifier, SIMPLE_VARIABLE, lexical_level, attributes);
}

void update_latest_nodes_with_variable_type(SymbolTable* symbol_table, enum VariableTypes variable_type){
  SymbolTableNode* current_node = symbol_table->top;
  SimpleVariableAttributes* current_node_attributes = (SimpleVariableAttributes *) current_node->attributes;

  while (current_node && current_node_attributes->variable_type == UNKNOWN)
  {
    current_node_attributes->variable_type = variable_type; 

    current_node = current_node->previous;
    if(current_node) current_node_attributes = (SimpleVariableAttributes *) current_node->attributes;
  }
}

void remove_node_from_symbol_table(SymbolTable* symbol_table) {
  SymbolTableNode* top = symbol_table->top; 

  symbol_table->top = top->previous; 

  free(top->identifier); 
  free(top->attributes); 
  free(top);
}

void remove_n_latest_nodes_from_symbol_table(SymbolTable* symbol_table, int n) {
  for(int i = 0; i < n; i++) remove_node_from_symbol_table(symbol_table);
}

void free_symbol_table(SymbolTable* symbol_table){
  while (symbol_table->top) remove_node_from_symbol_table(symbol_table);
  free(symbol_table);
}

SymbolTableNode* find_node_from_symbol_table_by_identifier(SymbolTable* symbol_table, char* identifier){
  SymbolTableNode *current_node = symbol_table->top; 
  int found = 0;

  while (current_node && !found)
  {
    if (!strcmp(current_node->identifier, identifier))
      found = 1;
    else 
      current_node = current_node->previous;
  }

  return current_node; 
}

void insert_procedure_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, int procedure_label) {
  void* attributes = (void *) malloc(sizeof(ProcedureAttributes));
  ProcedureAttributes* procedure_attributes = (ProcedureAttributes *) attributes;

  procedure_attributes->formal_params_count = 0; 
  procedure_attributes->procedure_label = procedure_label;

  insert_in_symbol_table(symbol_table, identifier, PROCEDURE, lexical_level, attributes);
}

void insert_formal_parameter_in_symbol_table(SymbolTable* symbol_table, char* identifier, unsigned int lexical_level, enum PassByTypes pass_by_type){
  void* attributes = (void *) malloc(sizeof(FormalParameterAttributes));
  FormalParameterAttributes* formal_parameter_attributes = (FormalParameterAttributes *) attributes; 

  formal_parameter_attributes->formal_parameter_variable_type = UNKNOWN;
  formal_parameter_attributes->formal_parameter_pass_by_type = pass_by_type;

  insert_in_symbol_table(symbol_table, identifier, FORMAL_PARAMETER, lexical_level, attributes);
}
