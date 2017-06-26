// UART manager
// Handles sending and receiving messages, waiting for ACKs etc.

#ifndef UART_MANAGER_HPP
#define UART_MANAGER_HPP

#include "ftdi_wrapper.hpp"
#include "uart_msg.hpp"
#include <queue>
#include <ctime>
#include <generic_classes.hpp>

//Exception classes
class UartManagerException : public GenericException
{
	public:
		UartManagerException(std::string str) :GenericException("UART Manager exception: ",str) {};
};

class FpgaMessageError : public std::runtime_error
{
public:
    FpgaMessageError(std::string str) :std::runtime_error(explanation+str) {};

private:
    const std::string explanation = "FPGA reported error : ";
};

//Main class
class UartManager
{
	public:
		UartManager(FtdiWrapper& uartIn, double timeoutIn, std::ostream& logIn);
		void send(UartMessage msg); // Add a message to send queue
		UartMessage receive(void); // Remove a message from receive queue (only valid when a message is waiting in the queue)
		void update(void); // Perform admin tasks, e.g. sending and receiving messages via UART
		std::queue<UartMessage>::size_type receiveQueueSize(void) const { return receiveQueue.size(); };
		

	private:
		FtdiWrapper& uart; // This handles the actual comms
		std::clock_t timeout; // Amount of time to wait before throwing exception whilst waiting for ACK
		std::queue<UartMessage> sendQueue, receiveQueue;
		std::ostream& log; //Reference to a stream which logging info should be dumped to
		struct ackType { UartMessage msg; std::clock_t latestTime; };
		std::queue<ackType> ackQueue; //Store messages to be ACKed, as well as latest time we can receive the ACK
		bool readLogged, writeLogged; //Variables to remember if a read and write request are currently logged
        UartMessage currentRead, currentWrite; //Containers for the messages currently being read/written
        void processReceivedMessage(UartMessage msg); //Handle logging a received message, and checking that it's not an error.
};

#endif
