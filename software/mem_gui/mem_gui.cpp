// Program to handle talking to test harne

#include <iostream>
#include <typeinfo>
#include "ftdi_wrapper.h"
#include "uart_msg.hpp"

using namespace std;

int main(int argc, char **argv)
{
	try{
		//Setup and search for devices
		FtdiWrapper serial(0,0); //Our device is 0x0403, 0x6010. But 0,0 searches all common FTDI devices
		cout << "Number of devices found: " << serial.getNoDevs() << endl;
		serial.listDevs();

		//Choose a device and connect
		cout << "Choose a device to connnect to: ";
		int idx;
		cin >> idx;

		cout << "Choose baud: ";
		int baud;
		cin >> baud;
		serial.open(idx, baud);
		cout << "Connected at baud " << serial.getBaud() << endl;
		
		//Data transfer
		SysStatus start;
		start.setRun(1);
		serial.write_blocking(start.getData().data(), 8);

		uint8_t received[10] = {0};
		serial.read_blocking(received,10);

		cout << "Received: ";
		for(int i=0; i<10; i++)
			cout << std::hex << static_cast<int>(received[i]) << ',';
		cout << endl;

		//Close
		serial.close();

	} catch (const std::exception& exc) {
		cerr << exc.what() << endl;
	}

	return 0;
}
