#include <unistd.h>

#if 0
int _isatty(int fd)
{
	return fd > 2;
}
#endif

int main()
{
    int x = isatty(3);
    return x;
}
