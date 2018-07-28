#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
typedef struct list
{
    char key;
    struct list *point;
} XOR;

XOR *xor(XOR *a, XOR *b)
{
    return (XOR*) ((uintptr_t) a ^ (uintptr_t) b);
}

XOR *create (int givenKey)
{
    XOR *element = (XOR*) malloc(sizeof(XOR));
    element->key = givenKey;
    element->point = NULL;
    return element;
}

void insert (XOR **head, XOR **tail, int givenKey)//if head and tail are flipped, function will insert last
{
    XOR *element = create(givenKey);

    if (!(*head))
        *head = *tail = element;
    else
    {
        element->point = *head;
        (*head)->point = xor(element, (*head)->point);
        *head = element;
    }
}

XOR *search (XOR **node, int givenKey)//function return previous node thorugh node
{
    XOR *curr = *node, *prev = NULL, *next;
    while(curr)
    {
        if(curr->key == givenKey)
        {
            *node = prev;
            return curr;
        }
        next = xor(prev, curr->point);
        prev = curr;
        curr = next;
    }
    return NULL;
}

void delete_end (XOR **head, XOR  **tail)//flipping the two nodes will swith between delete_first and delete_last
{
    if(!(*head))
        return;
    if(*head == *tail)
    {
        *head = *tail = NULL;
        return;
    }
    (*head)->point->point = xor(*head, (*head)->point->point);
    *head = (*head)->point;
}

void delete_node (XOR **head, XOR **tail, int givenKey)
{
    XOR *prev = *head, *next;
    XOR *element = search(&prev, givenKey);;

    if(!element)
        return;
    if(!(*head))
        return;
    if((*head)->key == givenKey)
    {
        delete_end(head, tail);
        return;
    }

    if((*tail)->key == givenKey)
    {
        delete_end(tail, head);
        return;
    }
    next = xor(prev, element->point);
    next->point = xor(xor(next->point, element), prev);
    prev->point = xor(xor(prev->point, element), xor(prev, element->point));
}

void print_list(XOR *node)//choosing node as either head or tail will change printing direction
{
    XOR *curr = node, *prev = NULL, *next;
    while(curr)
    {
        printf("%d ",curr->key);
        next = xor(prev, curr->point);
        prev = curr;
        curr = next;
    }
    printf("\n");
}

void populate_random (XOR **head, XOR **tail, int nr_elements)
{
    srand(time(NULL));
    for(int i = 0; i < nr_elements; i++)
        insert(head, tail, rand()%100);
}

int main()
{
    srand(time(NULL));
    XOR *head = calloc(1,sizeof(XOR));
    XOR *tail = calloc(1,sizeof(XOR));
    head = tail = NULL;
    populate_random(&head, &tail, 10);

    print_list(head);//print forward

    print_list(tail);//print backwards

    insert(&head, &tail, 23);//insert first
    insert(&tail, &head, 15);//insert last
    populate_random(&tail, &head, 10);

    print_list(head);

    delete_end(&head, &tail);//delete first
    delete_end(&tail, &head);//delete last
    delete_node(&head, &tail, 15);//delete node

    print_list(head);

}
