// UART manager
// Handles sending and receiving messages, waiting for ACKs etc.

#include <iostream>
#include "ftdi_wrapper.hpp"

UartManager::UartManager(FtdiWrapper& uartIn, double timeoutIn, std::ostream& log)
:uart(uartIn), timeout(timeoutIn), log(logIn), readLogged(false), writeLogged(false)
{
		
}

void send(UartMessage msg)
{
	sendQueue.push(msg);
}


UartMessage receive(void)
{
	UartMessage tmp;

	if(receiveQueueSize() > 0)
	{
		tmp = receiveQueue.front();
		receiveQueue.pop();
	} else {
		throw UartManagerException("Tried to read from empty receive queue");
	}

	return tmp;
}

void update(void)
{
	
}
