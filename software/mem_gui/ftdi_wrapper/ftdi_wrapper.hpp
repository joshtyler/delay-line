// C++ wrapper for libftdi
// Initialise serial port and read data

#ifndef FTDI_WRAPPER_H
#define FTDI_WRAPPER_H

#include <generic_classes.hpp>
#include "ftdi.h"

//Exception classes
class FtdiLibException : public GenericException
{
	public:
		FtdiLibException(std::string str) :GenericException("FTDI library exception: ", str) {};
		FtdiLibException(struct ftdi_context *context) :GenericException("FTDI library exception: ",ftdi_get_error_string(context)) {};
};

class FtdiWrapperException : public GenericException
{
	public:
		FtdiWrapperException(std::string str) :GenericException("FTDI wrapper exception: ",str) {};

};

//Main class
class FtdiWrapper
{
	public:
		FtdiWrapper(int vidIn, int pidIn);
		~FtdiWrapper();
		int getNoDevs(void) { refresh(); return noDevs; }; //Get number of devices available
		void listDevs(void); //List available devices
		void open(unsigned int idx, int baud); //Open the device of index chosen from listDevs()
		int getBaud(void) {return context->baudrate;}; //Get the actual baud rate of the device
		void writeBlocking(unsigned char *data, int size); //Perform blocking r/w
		void readBlocking(unsigned char *data, int size);
		void writeRequest(unsigned char *data, int size) {setupTransferReq(data, size, writeProgress);}; //Request for non blocking r/w
		void readRequest(unsigned char *data, int size) {setupTransferReq(data, size, readProgress);};
		bool writeDone(void) {return progressTransfer(writeProgress);}; //Status of previously requested r/w
		bool readDone(void) {return progressTransfer(readProgress);};
		void close(void);

	private:
		int vid, pid; //Vendor VID and PID
		int noDevs; //Number of devices found
		bool state; //True if port is open
		struct ftdi_context *context; //FTDI context (used by driver)
		struct ftdi_device_list *devList; //FTDI device list of devices found
		void refresh(void); //Refresh list of available devices

		struct rwProgress
		{
			unsigned char * data;
			int size;
			enum modeT {READ, WRITE};
			const modeT mode;
			rwProgress(modeT modeIn) :size(0), mode(modeIn) {}; //Initialise to the 'done' state
		};
		rwProgress readProgress, writeProgress;


		void setupTransferReq(unsigned char *data, int size, rwProgress &structure); //Sets up transfer
		bool progressTransfer(rwProgress &structure); //Make progress on transfer
		void checkState(bool stateIn); //Checks the device state is what is required, throws an exception if it is not
		void checkRet(int ret); //Checks the return value of the FTDI library functions

};

#endif
