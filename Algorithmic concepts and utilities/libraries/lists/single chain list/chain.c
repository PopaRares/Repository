#include "chain.h"

chain *search(chain *head, int givenKey)
{
    while(head)
    {
        if(head->key == givenKey)
            return head;
        head = head->next;
    }
    return NULL;
}

int is_empty (chain *head)
{
    return !head;
}

chain *create_element (int givenKey)
{
    chain *element = (chain*)malloc(sizeof(chain));
    element->key = givenKey;
    element->next = NULL;
    return element;
}

void insert_first(chain **head, chain **tail, int givenKey) {
    chain *element = create_element(givenKey);

    if(is_empty(*head))
        *head = *tail = element;
    else
    {
        element->next = *head;
        *head = element;
    }
}

void insert_last(chain **head, chain **tail, int givenKey) {

    chain *element = create_element(givenKey);

    if(is_empty(*head))
        *head = *tail = element;
    else
    {
        (*tail)->next = element;
        *tail = element;
    }
}

void insert_after_key(chain** head, chain** tail, int afterKey, int givenKey){
    chain *element = create_element(givenKey);
    chain *afterElement = search(*head, afterKey);
    if(!afterElement)
    {
        if(is_empty(*head))
            insert_first(head, tail, afterKey);
        else
        {
            printf("The key %d does not exist.\n", afterKey, afterElement->key);
            return;
        }
    }
    element->next = afterElement->next;
    afterElement->next = element;
}

void insert_address (chain** head, chain** tail, chain* address, int givenKey)
{
    if(address == *tail)
    {
        insert_last(head, tail, givenKey);
        return;
    }

    chain* element = create_element(givenKey);
    element->next = address->next;
    address->next = element;
}

void insert_order (chain** head, chain** tail, int givenKey, int (*rule)(int, int))
{
    chain *element = create_element(givenKey);
    element->next = *head;

    while(element->next && !rule(givenKey, element->next->key))
        element = element->next;

    if(element->next == *head)
        insert_first(head, tail, givenKey);
    else
        insert_address(head, tail, element, givenKey);

}

void delete_first(chain** head, chain** tail){
    if(*head == *tail)
    {
        *head = *tail = NULL;
        return;
    }

    chain *p = *head;
    (*head)= (*head)->next;
    free(p);
}

void delete_last(chain** head, chain** tail){
    if(*head == *tail)
    {
        free(*head);
        *head = *tail = NULL;
        return;
    }
    chain *element = *head;
    while(element->next->next)
        element = element->next;
    element->next = NULL;
    *tail = element;
}

void delete_key(chain** head, chain** tail, int givenKey){
    if((*tail)->key == givenKey)
    {
        delete_last(head, tail);
        return;
    }

    chain *element = search(*head, givenKey);
    if(element)
    {
        element->key = element->next->key;
        element->next = element->next->next;
    }
}

void sort (chain* first)
{
    chain *i, *j;
    i = first;
    int temp;
    while(i->next)
    {
        j = i->next;
        while(j)
        {
            if(i->key > j->key)
            {
                temp = i->key;
                i->key = j->key;
                j->key = temp;
            }
            j = j->next;
        }
        i = i->next;
    }
}

void invert (chain **head, chain **tail)
{
        chain *climber_1 = (*head)->next;
        chain *climber_2 = (*head)->next;

        *tail = *head;
        (*head)->next = NULL;

        while(climber_1)
            {
                climber_1 = climber_1->next;
                climber_2->next = *head;
                *head = climber_2;
                climber_2 = climber_1;
            }
}

void print_chain(chain *head){
    while(head)
    {
        printf("%d ",head->key);
        head = head->next;
    }
    printf("\n");
}
