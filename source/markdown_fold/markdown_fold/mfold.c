#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#include "mfold.h"

enum {
    BUFFER_SIZE = 2048
};

const int MF_DEBUG = 0;

void
usage() {
    fprintf(stdout, "Usage: mfold filename\n");
    return;
}

size_t
contribution_from_tab(size_t col, int tab_length) {
    // 0 - 8
    // 1 - 7
    // 7 - 1
    // 8 - 8
    
    if (tab_length < 1) {
        return 0;
    }
        
    size_t result = tab_length - (col % tab_length);
    return result;
}

size_t
visual_len_with_tabs(char *source, int tab_length) {
    char *letter = source;
    size_t col_pos = 0;
    
    if (!source) {
        return 0;
    }
    
    while (*letter) {
        if (*letter == '\t') {
            col_pos += contribution_from_tab(col_pos, tab_length);
        } else {
            col_pos++;
        }
        letter++;
    }
    
    // don't count trailing newline
    if (*(letter - 1) == '\n') {
        col_pos -= 1;
    }
    
    return col_pos;
}

void
fold_string(char *string, int width, int tab_length) {
    int col_pos = 0;
    char *current_char = string;
    int ws_pos = 0;
    
    if (!string) {
        return;
    }
    
    while (*current_char) {
        if (*current_char == '\n') {
            break;
        } else if (col_pos > width) {
            break;
        } else if (*current_char == '\t') {
            ws_pos = col_pos;
            col_pos += contribution_from_tab(col_pos, tab_length);
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
                          (long)col_pos,
                          (long)ws_pos,
                          *current_char, current_char - string);
    
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
    
    while ((current_string = fgets(buffer, sizeof(buffer), fin))
           != NULL) {
        if (strncmp(current_string, "```", 3) == 0) {
            if (MF_DEBUG) fprintf(stderr, "Found verbose backticks\n");
            inside_verbose_block = !inside_verbose_block;
        }
        if (inside_verbose_block) {
            line_length = visual_len_with_tabs(current_string, tab_length);
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


