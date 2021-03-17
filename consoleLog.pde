#include "consoleLog.h"

void log(const char* message) {
    USB.print(message);
}//log

void logE(const char* message) {
    USB.println(message);
}//logE

void logA(const char* format, ...) {
    va_list args;
    char buffer[200];

    va_start(args, format);
    vsprintf(buffer, format, args);
    va_end(args);

    log(buffer);
}//logA
