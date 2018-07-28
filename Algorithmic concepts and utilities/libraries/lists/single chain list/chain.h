#include <stdio.h>
#include <stdlib.h>

typedef struct node{
    int key;
    /*add more key values*/
    struct node *next;
} chain;

typedef struct{
    int key;
} content;

chain *search (chain *head, int givenKey);
int is_empty (chain *head);
chain *create_element (int givenKey);
void insert_first(chain **head, chain **tail, int givenKey);
void insert_last(chain **head, chain **tail, int givenKey);
void insert_after_key(chain** head, chain** tail, int afterKey, int givenKey); //stupid
void insert_address (chain** head, chain** tail, chain* address, int givenKey);
void insert_order (chain** head, chain** tail, int givenKey, int (*rule)(int, int));

void delete_first(chain** head, chain** tail);
void delete_last(chain** head, chain** tail);
void delete_key(chain** head, chain** tail, int givenKey);

void invert (chain **head, chain **tail);
void sort (chain* first);
void print_chain(chain *head);
