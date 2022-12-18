run: compile
	./rms $(args)

mem: compile_dbg
	valgrind -v -s --show-leak-kinds=all --leak-check=full --track-origins=yes ./rms $(args)

compile: main.c
	clear
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors main.c -lsqlite3 -o rms

compile_dbg: main.c
	clear
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors -g -Og main.c -lsqlite3 -o rms

clean:
	rm rms
