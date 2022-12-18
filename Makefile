run: compile
	./rms $(args)

compile: main.c
	clear
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors main.c -lsqlite3 -o rms

clean:
	rm rms
