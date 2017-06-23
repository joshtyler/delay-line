// UART manager
// Handles sending and receiving messages, waiting for ACKs etc.

#ifndef UART_MANAGER_HPP
#define UART_MANAGER_HPP

#include "ftdi_wrapper.hpp"
#include "uart_msg.hpp"
#include <queue>

//Exception classes
class UartManagerException : public std::runtime_error
{
	public:
		UartManagerException(std::string str) :std::runtime_error(explanation+str) {};

	private:
		const std::string explanation = "UART Manager exception: ";
};

//Main class
class UartManager
{
	public:
		UartManager(FtdiWrapper uartIn, double timeoutIn, std::ostream& logIn);
		void send(UartMessage msg); // Add a message to send queue
		UartMessage receive(void); // Remove a message from receive queue (only valid when a message is waiting in the queue)
		void update(void); // Perform admin tasks, e.g. sending and receiving messages via UART
		std::size_type receiveQueueSize(void) const { return receiveQueue.size() };
		

	private:
		FtdiWrapper& uart; // This handles the actual comms
		double timeout; // Amount of time to wait before throwing exception whilst waiting for ACK
		std::queue<UartMessage> sendQueue, receiveQueue;
		std::ostream& log; //Reference to a stream which logging info should be dumped to
		struct ackType { uartMessage msg, clock_t latestTime };
		std::queue<ackType> ackQueue; //Store messages to be ACKed, as well as latest time we can receive the ACK
		bool readLogged, writeLogged; //Variables to remember if a read and write request have already been logged
};

#endif
