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
