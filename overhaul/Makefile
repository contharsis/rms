run: compile
	./main $(args)

compile: main.c
	clear
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors main.c -lsqlite3 -o main

clean:
	rm main
