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
int arg_arg_count[] = {1, 1, 0, 1, 1, 1, 1, 0, 0};
int opt_count[] = {4, 5, 0, 0, 0, 0, 0, 0, 0};

char *err_msg[] = {
	"can't open database", 
	"can't close database", 
	"not enough arguments"
};

char *arg[] = {
	"init",
	"add",
	"list",
	"show",
	"start",
	"stop",
	"remove",
	"reset",
	"help"
};

char **arg_arg[] = {
	(char *[]) {
		"<options>"
	},
	(char *[]) {
		"<options>"
	},
	(char *[]) {""},
	(char *[]) {
		"<modpack>"
	},
	(char *[]) {
		"<modpack>"
	},
	(char *[]) {
		"<modpack>"
	},
	(char *[]) {
		"<modpack>"
	},
	(char *[]) {""},
	(char *[]) {""}
};

char *arg_desc[] = {
	"initialize database, table and config",
	"add modpack to database",
	"list all modpacks",
	"show all parameters of modpack",
	"start modpack server",
	"stop running modpack",
	"remove modpack from database",
	"restore all configs to default and clear modpack database",
	"display this message",
};

char **opt_short[] = {
	(char *[]) {
		"-dd",
		"-dn",
		"-tn",
		"-md"
	},
	(char *[]) {
		"-n",
		"-d",
		"-j",
		"-p",
		"-jv"
	},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""}
};

char **opt_long[] = {
	(char *[]) {
		"--databasedirectory",
		"--databasename",
		"--tablename",
		"--modpacksdirectory"
	},
	(char *[]) {
		"--name",
		"--directory",
		"--jar",
		"--parameters",
		"--javaversion"
	},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""}
};

char **opt_arg[] = {
	(char *[]) {
		"<absolute path>",
		"<name>",
		"<name>",
		"<absolute path>"
	},
	(char *[]) {
		"<name>",
		"<absolute path>",
		"<file name>",
		"<parameters>",
		"<absolute path to /bin>"
	},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
};

char **opt_default[] = {
	(char *[]) {
		"./",
		"modpacks",
		"modpack",
		"./modpacks"
	},
	(char *[]) {
		"",
		"",
		"",
		"",
		"java from PATH"
	},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""},
	(char *[]) {""}
};

char **opt_desc[] = {
        (char *[]) {
                "edit database directory",
                "edit name of database",
                "edit name of table with modpacks",
                "edit modpacks directory"
        },
        (char *[]) {
                "set modpack name",
                "edit modpack directory",
                "set jar file",
                "set jvm parameters",
                "edit java version"
        },
        (char *[]) {""},
        (char *[]) {""},
        (char *[]) {""},
        (char *[]) {""},
        (char *[]) {""},
        (char *[]) {""},
        (char *[]) {""}
};

void print_err(int err_code) {
	fprintf(stderr, "error: %s\n", err_msg[err_code]);
}

void check_err(int err_code) {
	if(rc) {
		print_err(err_code);
		fprintf(stderr, "error: %s\n", sqlite3_errmsg(db));
		exit(1);
	}
}

void check_err_exec(char *sql_err_msg) {
	if(rc != SQLITE_OK) {
		fprintf(stderr, "error: %s\n", sql_err_msg);
		sqlite3_free(sql_err_msg);
		exit(1);
	}
}

void print_usage() {
	fprintf(stderr, "usage: rms <argument>\narguments:\n");
	
	for(int i = 0; i < arg_count; i++) {
		fprintf(stderr, "\t%s", arg[i]);

		for(int j = 0; j < arg_arg_count[i]; j++) {
			fprintf(stderr, " %s", arg_arg[i][j]);
		}

		fprintf(stderr, " - %s", arg_desc[i]);
	
		for(int j = 0; j < opt_count[i]; j++) {
			if(j == 0) {
				fprintf(stderr, "\n");
			}

			fprintf(stderr, "\t\t%s, %s %s - %s", opt_short[i][j], opt_long[i][j], opt_arg[i][j], opt_desc[i][j]);
			
			if(strcmp(opt_default[i][j], "")) {
				fprintf(stderr, " - default - %s", opt_default[i][j]);	
			}

			if(j + 1 < opt_count[i]) {
				fprintf(stderr, "\n");
			}
		}

		fprintf(stderr, "\n");
		
		if(i + 1 < arg_count) {
			fprintf(stderr, "\n");
		}
	}
}

void open_db(char *dir, char *name) {
	size_t size = strlen(dir) + strlen(name) + 1;
	char path[size];

	strcpy(path, "");
	strcat(path, dir);
	strcat(path, name);

	rc = sqlite3_open(path, &db);
	check_err(err_cod);
}

void close_db() {
	rc = sqlite3_close(db);
	check_err(err_ccd);
	exit(0);	
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
