# Compilador
CC = gcc

# Flags de compilación
CFLAGS = -Wall -Wextra -O2

# Librerías necesarias
LIBS = -lncursesw

# Archivos fuente y binario final
SRC = ui.c
BIN = ui_ncurses

# Regla por defecto
all: $(BIN)

# Cómo compilar ui_ncurses
$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(BIN) $(LIBS)

# Limpieza del binario
clean:
	rm -f $(BIN)

# Limpieza completa
distclean: clean
	rm -f *.o
