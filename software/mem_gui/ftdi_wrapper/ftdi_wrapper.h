// C++ wrapper for libftdi
// Initialise serial port and read data

#ifndef FTDI_WRAPPER_H
#define FTDI_WRAPPER_H

#include "ftdi.h"

//Exception classes
class FtdiLibException
{
	public:
		FtdiLibException(std::string str) {throw std::runtime_error(explanation+str);};

		FtdiLibException(struct ftdi_context *context)
		{
			std::string err = ftdi_get_error_string(context);
			throw std::runtime_error(explanation+err);
		};
	private:
		const std::string explanation = "FTDI library exception: ";
};

class FtdiWrapperException
{
	public:
		FtdiWrapperException(std::string str) {throw std::runtime_error(explanation+str);};

	private:
		const std::string explanation = "FTDI wrapper exception: ";
};

//Main class
class FtdiWrapper
{
	public:
		FtdiWrapper(int vidIn, int pidIn);
		~FtdiWrapper();
		int getNoDevs(void) { return noDevs; }; //Get number of devices available
		void listDevs(void); //List available devices
		void open(unsigned int idx, int baud); //Open the device of index chosen from listDevs()
		int getBaud(void) {return context->baudrate;};
		void close(void);

	private:
		int vid, pid; //Vendor VID and PID
		int noDevs; //Number of devices found
		bool state; //True if port is open
		struct ftdi_context *context; //FTDI context (used by driver)
		struct ftdi_device_list *devList; //FTDI device list of devices found
		void refresh(void); //Refresh list of available devices
		void checkState(bool stateIn); //Checks the device state is what is reqired, throws an exception if it is not
		void checkRet(int ret); //Checks the return value of the FTDI library functions

};

#endif
