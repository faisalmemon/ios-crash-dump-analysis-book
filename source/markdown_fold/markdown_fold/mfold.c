#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#define TAB_LENGTH 4
#define WIDTH 66
#define BUFFER_SIZE 2048
#define MF_DEBUG 0

void
usage() {
    fprintf(stdout, "Usage: mfold filename\n");
    return;
}

size_t
strlen_with_tabs(char *source, int tab_length) {
    int n_tabs = 0;
    char *letter = source;
    while (*letter) {
        if (*letter == '\t') {
            n_tabs++;
        }
        letter++;
    }
    size_t length = strlen(source);
    
    // extra contribution from tabs
    if (tab_length > 1) {
        length += n_tabs * (tab_length - 1);
    }
    
    // don't count trailing newline
    length -= 1;
    
    return length;
}

void
fold_string(char *string, int width, int tab_length) {
    int col_pos = 0;
    char *current_char = string;
    int ws_pos = 0;
    
    while (*current_char) {
        if (*current_char == '\n') {
            break;
        } else if (col_pos > width) {
            break;
        } else if (*current_char == '\t') {
            ws_pos = col_pos;
            col_pos += tab_length;
        } else if (*current_char == ' ') {
            ws_pos = col_pos;
            col_pos++;
        } else {
            col_pos++;
        }
        current_char++;
    }
    if (MF_DEBUG) fprintf(stderr,
                          "fold_string loop escaped with col_pos %ld ws_pos %ld *current_char %c ptrdiff %ld\n",
                          (long)col_pos, (long)ws_pos, *current_char, current_char - string);
    
    if (col_pos <= width) {
        fprintf(stdout, "%s", string);
        // no more work needed; exit the recursion
        return;
    } else if (ws_pos > 0) {
        current_char = string + ws_pos;
    } else {
        current_char = string + width;
    }
    
    char *dup = strndup(string, current_char - string);
    assert(dup);
    fprintf(stdout, "%s\n", dup);
    fold_string(current_char, width, tab_length);
    free(dup);
}

int
parse(FILE *fin, int width, int tab_length) {
    bool inside_verbose_block = false;
    char buffer[BUFFER_SIZE];
    char *current_string = NULL;
    size_t line_length = 0;
    
    if (MF_DEBUG) fprintf(stderr, "Read line buffer is %zu\n", sizeof(buffer));
    
    while ((current_string = fgets(buffer, sizeof(buffer), fin)) != NULL) {
        if (strncmp(current_string, "```", 3) == 0) {
            if (MF_DEBUG) fprintf(stderr, "Found verbose backticks\n");
            inside_verbose_block = !inside_verbose_block;
        }
        if (inside_verbose_block) {
            line_length = strlen_with_tabs(current_string, tab_length);
            if (line_length <= width) {
                fprintf(stdout, "%s", current_string);
            } else {
                fold_string(current_string, width, tab_length);
            }
        } else {
            fprintf(stdout, "%s", current_string);
        }
    }
    return EXIT_SUCCESS;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        usage();
        return EXIT_SUCCESS;
    }
    char *filename = argv[1];
    FILE *fin = fopen(filename, "r");
    if (fin == NULL) {
        perror(filename);
        return EXIT_FAILURE;
    }
    int result = parse(fin, WIDTH, TAB_LENGTH);
    return result;
}
