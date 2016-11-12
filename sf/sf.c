#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

// 쓰레드 함수
void *t_function(void *data)
{
    int id;
    int i = 0;
    id = *((int *)data);

     char s[300];
     sprintf(s, "/bin/bash -c \"java net.tinyos.sf.SerialForwarder -port %d -comm sf@indriya.comp.nus.edu.sg:%d\"", 10000+id, 40000+id);
     //sprintf(s, "/bin/bash -c \"java net.tinyos.sf.SerialForwarder -port %d -comm serial@/dev/ttyUSB%d:telosb\"", 10000+id, id-1);
     system(s);
}

int main()
{
    pthread_t p_thread[150];
    int thr_id;
    int status;
    int i;
    int arg[150] = {

// all
/*
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 
35, 36, 37, 38, 39, 45, 46, 47, 48, 51, 
53, 54, 55, 56, 57, 58, 59, 60, 63, 64, 
65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 
75, 76, 77, 78, 79, 80, 82, 83, 84, 117, 
118, 119, 120, 122, 123, 124, 126, 128, 130, 131, 
132, 133, 135, 136, 137, 138, 139
*/

128, 130, 126, 120, 118, 65, 132, 73, 123, 24,  // 0
34, 58, 119, 135, 27, 45, 47, 137, 131, 54,  // 10
71, 139, 56, 72, 138, 51, 57, 70, 79, 53,  // 20
78, 75, 68, 17, 76, 60, 39, 69, 66, 38,  // 30
80, 19, 16, 37, 2, 25, 7, 3, 5, 20,  // 40
35, 18, 11, 64, 14, 9, 1, 

};

    int cnt = 30;
    int index = 0;

    //for(i=0; i<150; ++i)
    //  arg[i] = i+1;

    for(i=0; i<cnt; ++i)
      thr_id = pthread_create(&p_thread[i], NULL, t_function, (void *)&arg[index+i]);

    // 쓰레드 종료를 기다린다. 
    for(i=0; i<cnt; ++i)
        pthread_join(p_thread[i], (void **)&status);

    return 0;
}
