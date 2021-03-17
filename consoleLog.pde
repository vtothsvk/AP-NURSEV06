#include "consoleLog.h"

void log(char* tag) {
    USB.print(tag);
}//log

void logE(char* tag) {
    USB.println(tag);
}//logE

void logRet(char* tag, int ret) {
    USB.print(tag);
    USB.print("return code: ");
    USB.println(ret);
}
