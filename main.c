#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sqlite3.h>

#define err_cod 0
#define err_ccd 1
#define err_nea 2 

sqlite3 *db;
int rc;
int arg_count = 9;
int opt_count[] = {4, 5, 0, 0, 0, 0, 0, 0, 0};

char *err_msg[] = {
	"can't open database", 
	"can't close database", 
	"not enough arguments"
};

char *arg[] = {
	"init <arguments> - initialize database, table and config",
	"add <arguments> - add modpack to database",
	"list - list all modpacks",
	"show <modpack> - show all parameters of modpack",
	"start <modpack> - start modpack server",
	"stop <modpack> - stop running modpack",
	"remove <modpack> - remove modpack from database",
	"reset - restore all configs to default and clear modpack database",
	"help - display this message"
};

char **opt[] = {
	(char *[]) {
		"-dd, --databasedirectory <absolute path> - edit database directory, default - ./", 
		"-dn, --databasename <name> - edit name of database, default - modpacks", 
		"-tn, --tablename <name> - edit name of table with modpacks, default - modpack", 
		"-md, --modpacksdirectory <absolute path> - edit modpacks directory, default - ./modpacks"
	},
	(char *[]) {
		"-n, --name <name> - set modpack name", 
		"-d, --directory <absolute path> - edit modpack directory", 
		"-j, --jar <jar, file name> - set jar file", "-p, --parameters <parameters> - set jvm parameters", 
		"-p, --parameters <parameters> - set jvm parameters",
		"-j, --javaversion <absolute path to /bin> edit java version, default - java from PATH"
	}
};

void print_err(int err_code) {
	fprintf(stderr, "error: %s\n", err_msg[err_code]);
}

void check_err(int err_code, int stop) {
	if(rc) {
		print_err(err_code);
		fprintf(stderr, "error: %s\n", sqlite3_errmsg(db));
		
		if(stop) {
			exit(1);
		}
	}
}

void check_err_exec(char *sql_err_msg) {
	if(rc != SQLITE_OK) {
		fprintf(stderr, "error: %s\n", sql_err_msg);
		sqlite3_free(sql_err_msg);
		exit(1);
	}
}

void open_db(char *dir, char *name) {
	char *path = calloc((strlen(dir) + strlen(name) + 1), sizeof(char));

	rc = sqlite3_open(path, &db);
	check_err(err_cod, 0);

	free(path);
}

void close_db() {
	rc = sqlite3_close(db);
	check_err(err_ccd, 1);
	
	exit(0);	
}

void print_usage() {
	fprintf(stderr, "usage: rms <argument>\n");
	fprintf(stderr, "arguments:\n");
	
	for(int i = 0; i < arg_count; i++) {
		fprintf(stderr, "\t%s\n", arg[i]);

		for(int j = 0; j < opt_count[i]; j++) {
			fprintf(stderr, "\t\t%s\n", opt[i][j]);
		}
		
		if(i + 1 < arg_count) {
			fprintf(stderr, "\n");
		}
	}
}

int main(int argc, char **argv) {	
	if(argc == 1) {
		fprintf(stderr, "error: %s\n", err_msg[err_nea]);
		print_usage();
		return 1;
	}

	open_db("./", "test.db");

	printf("%s\n", argv[1]);

	close_db();
	return 0;
}
