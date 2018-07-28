#include <stdlib.h>
#include <windows.h>
#include <time.h>

#define MAX 500000

LARGE_INTEGER frequency;        // ticks per second
LARGE_INTEGER t1, t2;           // ticks
double elapsedTime;
time_t process_start; /* calendar time */
int bar = 50;

void hidecursor()
{
   HANDLE consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
   CONSOLE_CURSOR_INFO info;
   info.dwSize = 100;
   info.bVisible = FALSE;
   SetConsoleCursorInfo(consoleHandle, &info);
}

void loading (int i, int max)
{
    static int current_box = 0;
    static int current_proc = -1;
    int proc = 100*i/max;
    int box = bar*i/max;
    //printf("%d %d %d %d\n", i, max, proc, box);
    //getch();
    if(box > current_box)
    {
        current_box = box;
        printf("#");
    }
    if(proc > current_proc)
    {
        current_proc = proc;
        printf("[%2d%%]",proc);
        for(int i = 0; i < 5; i++)
            printf("\b");
    }
    if(proc == 100)
    {
        printf("\n");
        current_box = current_proc = 0;
    }
}

int *generate()
{
    int *vector = malloc(MAX * sizeof(int));
    srand(time(NULL));
    int r;
    for(int i = 0; i < MAX; i++)
    {
        r = rand();
        r = r % (MAX*10);
        vector[i] = r;
    }
    return vector;
}

void print_array (int *vector)
{
    for(int i = 0; i < MAX; i++)
        printf("%d, ",vector[i]);
    printf("\b\b \n--------------------------------------------\n\n");
}

void reset (int *v, int *u)
{
    for(int i = 0; i < MAX; i++)
        u[i] = v[i];
}

void swap (int *x, int *y)
{
    int temp = *x;
    *x = *y;
    *y = temp;
}

void bubblesort (int *vector)
{
    int swaps, scramble_level=0, edge = 1;
    do
    {
        swaps=0;
        for(int  i = 0; i < MAX - edge; i++)
            if(vector[i] > vector[i+1])
            {
                swap(vector+i, vector+i+1);
                swaps++;
            }
        if(!scramble_level)
            scramble_level = swaps;
        else
            loading(scramble_level - swaps, scramble_level);
        edge++;
    }while(swaps > 0);
}

void insert_sort (int *vector)
{
    for(int i = 1; i < MAX; i++)
    {
        for(int j = i-1; j >= 0 && vector[j] > vector[j+1]; j--)
            swap(vector+j, vector+j+1);
        loading(i, MAX-1);
    }
}

void selection_sort (int *vector)
{
    int min;
    for(int i = 0; i < MAX - 1; i++)
    {
        min = i;
        for(int j = i+1; j < MAX; j++)
            if(vector[j] < vector[min])
                min = j;
        swap(vector+min, vector+i);
        loading(i, MAX - 2);
    }
}

void call_merge_sort (int *vector)
{
    merge_sort(vector, 0, MAX - 1);
}

void merge(int* vector, int low, int mid, int high)
{
    int *temp = malloc( (high - low+1) * sizeof(int) );
    int i = low, j = mid + 1, k = 0;
    while(i <= mid && j <= high)
        if(vector[i] <= vector[j])
            temp[k++] = vector[i++];
        else
            temp[k++] = vector[j++];

    while(i <= mid)
        temp[k++] = vector[i++];
    while(j <= high)
        temp[k++] = vector[j++];
    k--;
    for(int x = high; x >= low; x--)
        vector[x] = temp[k--];
}

void merge_sort (int *vector, int low, int high)
{
    if(low >= high)
        return;
    int mid = (low + high) / 2;
    merge_sort(vector, low, mid);
    merge_sort(vector, mid + 1, high);
    merge(vector, low, mid, high);
}

void call_quick_sort(int *vector)
{
    quick_sort(vector, 0, MAX - 1);
}

void quick_sort(int *vector, int low, int high)
{
    if(low >= high)
        return;
    int pivot = partition(vector, low, high);
    quick_sort(vector, low, pivot-1);
    quick_sort(vector, pivot+1, high);
}

int partition(int* vector, int low, int high)
{
    int pivot = vector[high];
    int i = low - 1;
    for(int j = low; j < high; j++)
        if(vector[j] <= pivot)
        {
            i++;
            swap(vector+i, vector+j);
        }
    swap(vector+i+1, vector+high);
    i++;
    return i;
}

void sort (int *v, void (*func)(int*), char *message)
{
    printf("%s\n",message);
    QueryPerformanceCounter(&t1);
    func(v);
    QueryPerformanceCounter(&t2);
    elapsedTime = (t2.QuadPart - t1.QuadPart) * 1000.0 / frequency.QuadPart;
    process_start=time(NULL);
    printf("%f ms. Sort ended at %s--------------------------------------------\n", elapsedTime, asctime(localtime(&process_start)));
    //print_array(v);
}

int main()
{
    hidecursor();
    // get ticks per second
    QueryPerformanceFrequency(&frequency);
    int *v = generate();
    int *u = malloc(MAX * sizeof(int));
    reset(v,u);

    process_start=time(NULL); /* get current cal time */
    printf("Process started at: %s\n",asctime( localtime(&process_start) ) );

    printf("Original array of %d elements:\n--------------------------------------------\n",MAX);
    //print_array(v);

    sort(u, bubblesort, "Bubblesort O(n^2)");
    reset(v,u);

    sort(u, insert_sort, "Insert sort O(n^2)");
    reset(v,u);

    sort(u, selection_sort, "Select sort O(n^2)");
    reset(v,u);

    sort(u, call_merge_sort, "Merge sort O(nlogn)");
    reset(v,u);

    sort(u, call_quick_sort, "Quick sort O(nlogn)");
    reset(v,u);

    return 0;
}
