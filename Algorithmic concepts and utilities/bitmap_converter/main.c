#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <string.h>

FILE *image;
FILE *output;
int bytesPerLine;
int padding;

typedef struct dim
{
    int width, height;
}dim;

typedef struct pixel
{
    unsigned char b,g,r;
}pixel;

enum colors
{VERDE, NEGRU, ALB, GRI, MARO, GALBEN, PORTOCALIU, ALBASTRU, ROZ};

void skip_bytes (int n)
{
    char skip;
    for(int i = 0; i < n; i++)
        fscanf(image,"%c",&skip);
}

int round4 (int x)
{
    if (x & 0x0003)
    {
        x |= 0x0003;
        x++;
    }
    return x;
}

char *color_name (int x)
{
    switch (x)
    {
    case 0:
        return "VERDE";
    case 1:
        return "NEGRU";
    case 2:
        return "ALB";
    case 3:
        return "GRI";
    case 4:
        return "MARO";
    case 5:
        return "GALBEN";
    case 6:
        return "PORTOCALIU";
    case 7:
        return "ALBASTRU";
    case 8:
        return "ROZ";
    default:
        return "ERROR";
    }
}

int color_code(char *color)
{
    if(strcmp(color,"009000") == 0)
        return VERDE;

    if(strcmp(color,"000000") == 0)
        return NEGRU;

    if(strcmp(color,"FFFFFF") == 0)
        return ALB;

    if(strcmp(color,"ACACAC") == 0)
        return GRI;

    if(strcmp(color,"804000") == 0)
        return MARO;

    if(strcmp(color,"FFFF00") == 0)
        return GALBEN;

    if(strcmp(color,"FF8000") == 0)
        return PORTOCALIU;

    if(strcmp(color,"0077C0") == 0)
        return ALBASTRU;

    if(strcmp(color,"EC008C") == 0)
        return ROZ;

    return -13;///error #
}

void test (pixel color, int x, int y)
{
    char s[6];
    sprintf(s, "%02X%02X%02X",color.r, color.g, color.b);
    printf("#%02X%02X%02X %s [%d][%d]\n",color.r, color.g, color.b, color_name(color_code(s)),x,y),getch();
}

void decode (char *filePath)
{
    image = fopen (filePath, "rb");
    dim *img = malloc(sizeof(dim));

    skip_bytes(18);
    fread(img,sizeof(dim),1,image);

    bytesPerLine = round4((img->width));
    padding = bytesPerLine - img->width;

    skip_bytes(28);
    pixel color[img->height+10][img->width+10];//ar trebui sa mearga si fara +5 acolo da face figuri la alocarea memoriei

    for(int i = 0; i < img->height; i++)
    {
        fread(color[i],sizeof(pixel),img->width,image);
        skip_bytes(padding);
    }
    fclose(image);

    char s[6];
    for(int i = img->height - 1; i > -1; i--)
    {
        fprintf(output, "\t\tDB ");
        for(int j = 0; j < img->width/2; j++)
            {
                sprintf(s, "%02X%02X%02X",color[i][j].r, color[i][j].g, color[i][j].b);
                if(j == img->width/2 - 1)
                    fprintf(output, "%c\n", color_code(s) + '0');
                else
                    fprintf(output, "%c, ", color_code(s) + '0');
                //test(color[i][j], img->height - i - 1, j);
            }
        fprintf(output, "\t\tDB ");
        for(int j = img->width/2; j < img->width; j++)
            {
                sprintf(s, "%02X%02X%02X",color[i][j].r, color[i][j].g, color[i][j].b);
                if(j == img->width - 1)
                    fprintf(output, "%c\n", color_code(s) + '0');
                else
                    fprintf(output, "%c, ", color_code(s) + '0');
                //test(color[i][j], img->height - i - 1, j);
            }
    }
    fprintf(output, "\n\n\n\n\n");
}

int main()
{
    int nrFiles = 0;
    char path[500], outFile[20], name[20];
    printf("Select folder path:\n");
    gets(path);
    printf("Name of output file:\n");
    gets(outFile);

    strncpy(name, outFile, strlen(outFile) - 4);
    name[strlen(outFile) - 4] = '\0';

    struct dirent *de;  // Pointer for directory entry

    // opendir() returns a pointer of DIR type.
    DIR *dr = opendir(path);
    printf("Decoding bitmaps in %s:\n\n", path);
    if (dr == NULL)  // opendir returns NULL if couldn't open directory
    {
        printf("Could not open current directory" );
        return 0;
    }

    output = fopen(outFile, "w");
    fprintf(output, "%s\n", name);

    while ((de = readdir(dr)) != NULL)
        if(strstr(de->d_name, ".bmp"))
        {
            char temp[100];
            strcpy(temp, path);
            strcat(temp, "\\");
            strcat(temp, de->d_name);
            printf("%s\n",temp);
            decode(temp);
            nrFiles++;
        }
    if(nrFiles)
        printf("\n%d files successfully decoded.", nrFiles);
    else
        printf("\nNo bitmaps detected");
    printf("\nPress any key to continue...");
    getch();
    closedir(dr);
    fclose(output);
}
