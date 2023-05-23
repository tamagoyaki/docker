#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <regex.h>
#include <sys/inotify.h>


int smbreload() {
	printf("reload conf\n");
	const char *cmd = "service smbd reload";
	int res = system(cmd);

	if (-1 == res) {
		perror("couldn't reload");
		return 1;
	}

	return 0;
}

#define EVENT_SIZE (sizeof(struct inotify_event))
#define EVENT_BUF_LEN (1024 * (EVENT_SIZE + 16))

int notifywait (const char *directory) {
	int fd = inotify_init();
	if (-1 == fd) {
		return 1;
	}

	int wd = inotify_add_watch(fd, directory, IN_ALL_EVENTS);
	if (-1 == wd) {
		perror("inotify_add_watch");
		return 1;
	}

	printf("watching for events in directory: %s\n", directory);
	char buffer[EVENT_BUF_LEN];

	while (1) {
		int num_bytes = read(fd, buffer, EVENT_BUF_LEN);
		if (num_bytes <= 0) {
			perror("read");
			break;
		}

		int i = 0;
		while (i < num_bytes) {
			struct inotify_event* event =
				(struct inotify_event*)&buffer[i];
			if (event->len) {
				// msg for debug
				if (event->mask & IN_CREATE)
					printf("File created: %s/%s\n",
						directory, event->name);
				else if (event->mask & IN_DELETE)
					printf("File deleted: %s/%s\n",
						directory, event->name);
				else if (event->mask & IN_MODIFY)
					printf("File modified: %s/%s\n",
						directory, event->name);

				// reload smb.conf if modified
				if (event->mask & IN_MODIFY) {
					smbreload();
				}

			}
			i += EVENT_SIZE + event->len;
		}
	}

	return 0;
}

/*
  Do "service smbd reload" if file in specified directory is modified.

  Commandline options:

    --background
    --confdir=/someware/to/watch
 */
int main(int argc, char *argv[]) {
	int opt_background = 0;
	const char *opt_confdir = NULL;

	// commandline options
	for (int i = 0; i < argc; i++) {
		if (0 == strcmp("--background", argv[i])) {
			opt_background = 1;
		} else if (0 == strncmp("--confdir=", argv[i], 10)) {
			opt_confdir = argv[i] + 10;
			printf("%s\n", opt_confdir);
		}
	}

	if (NULL == opt_confdir) {
		printf("%s --confdir=/somewhere [ ... ]\n", argv[0]);
		return 0;
	}

	// daemon or normal process ?
	if (opt_background) {
		pid_t pid = fork();

		// If the fork was successful, the child process will continue.
		if (pid == 0) {
			// Close the stdin, stdout, and stder.
			close(0);
			close(1);
			close(2);

			// Redirect stdin, stdout, and stderr to /dev/null.
			int fd = open("/dev/null", O_RDWR);
			dup2(fd, 0);
			dup2(fd, 1);
			dup2(fd, 2);

			// Change the working directory to the root directory.
			chdir("/");

			notifywait(opt_confdir);
		} else {
			exit(0);
		}
	} else {
		notifywait(opt_confdir);
	}

	return 0;
}
