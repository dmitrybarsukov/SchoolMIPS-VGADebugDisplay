#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define LINES       32
#define COLUMNS     80
#define OUTPUTFILENAME "displayROM.hex"

char bin2ASCII(uint8_t dat);

int main(int argc, char** argv)
{
    if(argc != 2)
    {
        printf("[INFO]\tUse: conv <filename>\n");
        return 0;
    }

    int fd = open(argv[1], O_RDONLY);
    if(fd < 0)
    {
        printf("[ERROR] Can't open \"%s\"\n", argv[1]);
        return 1;
    }

    char data[4096] = {};
    read(fd, data, 4096);
    close(fd);

    FILE* fout = fopen(OUTPUTFILENAME, "w");
    if(fout == NULL)
    {
        printf("[ERROR] Internal error\n");
        return 2;
    }

    int cnt = 0;

    for(int lineCnt = 0; lineCnt < LINES; lineCnt++)
    {
        for(int columnCnt = 0; columnCnt < COLUMNS; columnCnt++)
        {
            if(data[cnt] == '\n' || data[cnt] == '\0')
            {
                fprintf(fout, "20 ");
            }
            else
            {
                fprintf(fout, "%c%c ", bin2ASCII(data[cnt] >> 4), bin2ASCII(data[cnt]));
                cnt++;
            }
        }
        fprintf(fout, "\n");

        while(!(data[cnt] == '\n' || data[cnt] == '\0'))
            cnt++;
        
        cnt++;
    }

    fclose(fout);
    printf("Convert OK\n");
    return 0;

}

char bin2ASCII(uint8_t dat)
{
    const static char* str = "0123456789ABCDEF";
    return str[dat & 0xF];
}