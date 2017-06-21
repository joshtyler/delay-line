// Program to handle talking to test harness

#include <iostream>
#include "serial.hpp"

using namespace std;

int main(int argc, char **argv)
{
	Serial serial(0x0403, 0x6010);
	serial.listDevices();
//	cout << serial.isOpen() << ", " << serial.getError() << endl;

	return 0;
}
