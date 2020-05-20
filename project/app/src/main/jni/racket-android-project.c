#include <string.h>
#include <jni.h>
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdint.h>
#include <signal.h>

#include <android/log.h>
#define LOG_TAG "racket-android"
#define ALOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define ALOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)


#define MZ_PRECISE_GC
#include "racket/include/scheme.h"
#include "racket/include/schemegc2.h"
#include "racket/racket_app.c"

// Internals

void _scheme_console_output( const char *disp, intptr_t len ) {
    ALOGE("RC: %.*s\n", len, disp);
}
void _scheme_exit( int code ) {
    ALOGE("Racket tried to exit with %d\n", code);
    // XXX Really stop?
    // pthread_exit(NULL);
}

static const char *RAP_STDOUT = "stdout";
static const char *RAP_STDERR = "stderr";
intptr_t _stdio_writes_bytes(Scheme_Output_Port *port, const char *buf, intptr_t off, intptr_t size, int rarely_block, int enable_break) {
    __android_log_print(
            // XXX this doesn't work, it's always FALSE
            scheme_eq(port->name, scheme_intern_symbol(RAP_STDERR)) ? ANDROID_LOG_ERROR : ANDROID_LOG_DEBUG, LOG_TAG, "%.*s", size, buf+off);
    return size;
}

int _stdio_char_ready(Scheme_Output_Port *port) {
    return 1;
}

void _stdio_close(Scheme_Output_Port *port) {
    return;
}

void _stdio_need_wakeup(Scheme_Output_Port *port, void *fds ) {
    return;
}


#include "racket/racket-vm.3m.c"

Scheme_Object *_scheme_make_stdout() {
    return _scheme_make_stdio(RAP_STDOUT);
}
Scheme_Object *_scheme_make_stderr() {
    return _scheme_make_stdio(RAP_STDERR);
}

static struct sigaction old_sa[NSIG];

void android_sigaction(int signal, siginfo_t *info, void *reserved)
{
    //(*env)->CallVoidMethod(env, obj, nativeCrashed);
    old_sa[signal].sa_handler(signal);
}

void *rvm_thread_init(void *d) {

    scheme_console_output = _scheme_console_output;
    scheme_exit = _scheme_exit;
    scheme_make_stdout = _scheme_make_stdout;
    scheme_make_stderr = _scheme_make_stdout;

    //scheme_set_logging(SCHEME_LOG_DEBUG, SCHEME_LOG_DEBUG);

    scheme_main_stack_setup(1, vm_init, d);

    return NULL;
}

JavaVM* the_JVM;
pthread_t main_t;
int main_t_fd[2];
struct rvm_api_t {
    uint32_t call;
    union {
        int32_t i;
        float f;
    } args[3];
};
void send_to_racket( struct rvm_api_t rpc ) {
    write(main_t_fd[1], (void *)&rpc, sizeof(rpc));
    fsync(main_t_fd[1]);
}

int main(int argc, char *argv[])
{
    rvm_thread_init(NULL);
}

void Java_org_racketlang_android_project_RLib_onCreate(JNIEnv* env, jobject thiz) {
    (*env)->GetJavaVM(env, &the_JVM);
    pthread_create(&main_t, NULL, rvm_thread_init, NULL);
    return;
}