// C++ wrapper for libftdi
// Initialise serial port and read data

#ifndef FTDI_H
#define FTDI_H

#include "ftdi.h"

//Exception classes
class FtdiLibException
{
	public:
		FtdiLibException(std::string str) : err(str) {};

		FtdiLibException(struct ftdi_context *context)
		{
			err = ftdi_get_error_string(context)
		};

		std::string err;
};


//Main class
class Ftdi
{
	public:
		Ftdi(int pidIn, int vidIn);
		int getNoDevs() { return noDevs; };
	private:
		int pid, vid; //Vendor VID and PID
		int noDevs; //Number of devices found
		struct ftdi_context *context; //FTDI context (used by driver)
		struct ftdi_device_list *devlist; //FTDI device list of devices found

};

#endif
