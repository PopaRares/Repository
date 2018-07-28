/*Scrieti un program pentru a inversa o lista simplu inlantuita in mod eficient (timp 0(n) si spatiu aditional O(1)).
Lista este implementata folosind pointer la first.*/

void invert (NodeT **head, NodeT **tail)
{
        NodeT *climber_1 = (*head)->next;
        NodeT *climber_2 = (*head)->next;

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