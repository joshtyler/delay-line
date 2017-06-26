// C++ wrapper for libftdi
// Initialise serial port and read data

#ifndef FTDI_WRAPPER_H
#define FTDI_WRAPPER_H

#include "ftdi.h"

//Exception classes
class FtdiLibException : public std::runtime_error
{
	public:
		FtdiLibException(std::string str) :std::runtime_error(explanation+str) {};
		FtdiLibException(struct ftdi_context *context) :std::runtime_error(explanation+ftdi_get_error_string(context)) {};

	private:
		const std::string explanation = "FTDI library exception: ";
};

class FtdiWrapperException : public std::runtime_error
{
	public:
		FtdiWrapperException(std::string str) :std::runtime_error(explanation+str) {};

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
		int getBaud(void) {return context->baudrate;}; //Get the actual baud rate of the device
		void writeBlocking(const unsigned char *data, int size) {checkRet(ftdi_write_data(context, data, size));}; //Perform blocking r/w
		void readBlocking(unsigned char *data, int size) {checkRet(ftdi_read_data(context, data, size));};
		void writeRequest(unsigned char *data, int size); //Request for non blocking r/w
		void readRequest(unsigned char *data, int size);
		bool writeDone(void); //Status of previously requested r/w
		bool readDone(void);
		void close(void);

	private:
		int vid, pid; //Vendor VID and PID
		int noDevs; //Number of devices found
		bool state; //True if port is open
		struct ftdi_context *context; //FTDI context (used by driver)
		struct ftdi_device_list *devList; //FTDI device list of devices found
		void refresh(void); //Refresh list of available devices

		struct ftdi_transfer_control *read_tc, *write_tc; //Transfer control structures to monitor status of tx/rx requests
		bool readDoneFlag, writeDoneFlag;

		void checkState(bool stateIn); //Checks the device state is what is required, throws an exception if it is not
		void checkRet(int ret); //Checks the return value of the FTDI library functions

};

#endif
