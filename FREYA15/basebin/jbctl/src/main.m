#import "jailbreakd.h"

extern char **environ;

void print_usage(void) {
  printf("Usage: jbctl <command> <arguments>\n\
Available commands:\n\
	proc_set_debugged <pid>\t\tMarks the process with the given pid as being debugged, allowing invalid code pages inside of it\n\
	rebuild_trustcache\t\tRebuilds the TrustCache, clearing any previously trustcached files that no longer exists from it\n");
}

int main(int argc, char *argv[]) {
  setvbuf(stdout, NULL, _IOLBF, 0);
  if (argc < 2) {
    print_usage();
    return 1;
  }

  char *cmd = argv[1];
  if (!strcmp(cmd, "proc_set_debugged")) {
    if (argc != 3) {
      print_usage();
      return 1;
    }
    int pid = atoi(argv[2]);
    int64_t result = jbdProcSetDebugged(pid);
    if (result == 0) {
      printf("Successfully marked proc of pid %d as debugged\n", pid);
    } else {
      printf("Failed to mark proc of pid %d as debugged\n", pid);
    }
  } else if (!strcmp(cmd, "rebuild_trustcache")) {
    jbdRebuildTrustCache();
  }

  return 0;
}
