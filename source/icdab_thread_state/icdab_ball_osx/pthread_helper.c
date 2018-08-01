//
//  pthread_helper.c
//  icdab_ball_osx
//
//  Created by Faisal Memon on 01/08/2018.
//  Copyright © 2018 Faisal Memon. All rights reserved.
//


/* A task that takes some time to complete. The id identifies distinct
 tasks for printed messages. */
void *task(int id) {
    printf("Task %d started\n", id);
    int i;
    double result = 0.0;
    for (i = 0; i < 1000000; i++) {
        result = result + sin(i) * tan(i);
    }
    printf("Task %d completed with result %e\n", id, result);
    
    return NULL;
}

/* Same as 'task', but meant to be called from different threads. */
void *threaded_task(void *t) {
    long id = (long) t;
    printf("Thread %ld started\n", id);
    task(id);
    printf("Thread %ld done\n", id);
    pthread_exit(0);
}

/* Run 'task' num_tasks times serially. */
void *serial(int num_tasks) {
    int i;
    for (i = 0; i < num_tasks; i++) {
        task(i);
    }
    return NULL;
}

/* Run 'task' num_tasks times, creating a separate thread for each
 call to 'task'. */
void *parallel(int num_tasks)
{
    int num_threads = num_tasks;
    pthread_t thread[num_threads];
    int rc;
    long t;
    for (t = 0; t < num_threads; t++) {
        printf("Creating thread %ld\n", t);
        rc = pthread_create(&thread[t], NULL, threaded_task, (void *)t);
        if (rc) {
            printf("ERROR: return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    return NULL;

}

void *print_usage(int argc, char *argv[]) {
    printf("Usage: %s serial|parallel num_tasks\n", argv[0]);
    exit(1);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {print_usage(argc, argv);}
    
    int num_tasks = atoi(argv[2]);
    
    if (!strcmp(argv[1], "serial")) {
        serial(num_tasks);
    } else if (!strcmp(argv[1], "parallel")) {
        parallel(num_tasks);
    }
    else {
        print_usage(argc, argv);
    }
    
    printf("Main completed\n");
    pthread_exit(NULL);
}
