run: compile
	./rms $(args)

mem: compile_dbg
	valgrind -v -s --show-leak-kinds=all --leak-check=full --track-origins=yes ./rms $(args)

compile: clear main.c
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors main.c -lsqlite3 -o rms

compile_dbg: clear main.c
	gcc -Wall -Wextra -Werror -pedantic -pedantic-errors -g -Og main.c -lsqlite3 -o rms

clear:
	clear

clean:
	rm rms
