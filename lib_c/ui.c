#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ncurses.h>

#define MAX_FAV 256

typedef struct {
    char name[256];
    char url[512];
} Favorite;

Favorite favs[MAX_FAV];
int fav_count = 0;

void load_favorites(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return;

    char line[1024];
    while (fgets(line, sizeof(line), f)) {
        char *sep = strchr(line, '|');
        if (!sep) continue;

        *sep = '\0';

        // Copiar nombre de forma segura
        size_t len = strlen(line);
        if (len >= sizeof(favs[fav_count].name))
            len = sizeof(favs[fav_count].name) - 1;

        memcpy(favs[fav_count].name, line, len);
        favs[fav_count].name[len] = '\0';

        // Copiar URL de forma segura
        const char *url = sep + 1;
        len = strlen(url);
        if (len >= sizeof(favs[fav_count].url))
            len = sizeof(favs[fav_count].url) - 1;

        memcpy(favs[fav_count].url, url, len);
        favs[fav_count].url[len] = '\0';

        fav_count++;
        if (fav_count >= MAX_FAV) break;
    }

    fclose(f);
}

void draw_ui(int selected) {
    clear();
    mvprintw(0, 0, "KEILA Radio Player (UI en C)");
    mvprintw(1, 0, "----------------------------------------");
    mvprintw(3, 0, "[W/S o ↑/↓] Mover  [ENTER] Reproducir  [q] Salir");
    mvprintw(5, 0, "EMISORAS FAVORITAS");
    mvprintw(6, 0, "------------------");

    for (int i = 0; i < fav_count; i++) {
        if (i == selected)
            mvprintw(8 + i, 0, "> %2d) %s", i + 1, favs[i].name);
        else
            mvprintw(8 + i, 0, "  %2d) %s", i + 1, favs[i].name);
    }

    refresh();
}

int main() {
    const char *fav_path = getenv("KEILA_FAVORITAS");

    // Fallback si no viene desde radio.sh
    if (!fav_path || fav_path[0] == '\0') {
        const char *base = getenv("BASE_DIR");
        if (base && base[0] != '\0') {
            static char path[512];
            snprintf(path, sizeof(path), "%s/emisorasFavoritas.txt", base);
            fav_path = path;
        } else {
            fav_path = "./emisorasFavoritas.txt";
        }
    }

    load_favorites(fav_path);

    initscr();
    noecho();
    cbreak();
    keypad(stdscr, TRUE);
    curs_set(0);

    int selected = 0;
    int ch;

    while (1) {
        draw_ui(selected);
        ch = getch();

        switch (ch) {
            case 'q':
                endwin();
                printf("EXIT|\n");
                return 0;

            case KEY_UP:
            case 'w':
            case 'W':
                if (selected > 0) selected--;
                break;

            case KEY_DOWN:
            case 's':
            case 'S':
                if (selected < fav_count - 1) selected++;
                break;

            case '\n':
            case KEY_ENTER:
                endwin();
                printf("PLAY|%s|%s\n", favs[selected].name, favs[selected].url);
                return 0;
        }
    }

    endwin();
    return 0;
}
