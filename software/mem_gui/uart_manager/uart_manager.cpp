// UART manager
// Handles sending and receiving messages, waiting for ACKs etc.

#include <iostream>
#include "uart_manager.hpp"
#include "uart_msg.hpp"

UartManager::UartManager(FtdiWrapper& uartIn, double timeoutIn, std::ostream& logIn)
:uart(uartIn), log(logIn), readLogged(false), writeLogged(false)
{
		timeout = (std::clock_t) (timeoutIn * CLOCKS_PER_SEC);
}

void UartManager::send(UartMessage msg)
{
	sendQueue.push(msg);
}


UartMessage UartManager::receive(void)
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

void UartManager::update(void)
{
	//Handle a currently logged read
	if(readLogged)
	{
		if(uart.readDone())
		{
            processReceivedMessage(currentRead);
			receiveQueue.push(currentRead);
			readLogged = false;
		}
	}

	//Setup a new read if the resource is available
	if(!readLogged)
	{
		uart.readRequest(currentRead.getData().data(),UartMsgLen);
        readLogged = true;
	}

	//Handle a currently logged write
	if(writeLogged)
	{
		if(uart.writeDone())
		{
			ackQueue.push({currentWrite, (clock() + timeout)}); //We expect the packet to be ACKed. Log this in the ACK queue
			writeLogged = false;
		}
	}

    //Setup a new write if the resource is available, and we have data to write
    if(!writeLogged && (sendQueue.size()>0))
    {
        currentWrite = sendQueue.front();
        sendQueue.pop();
        uart.writeRequest(currentWrite.getData().data(),UartMsgLen);
    }
}

void UartManager::processReceivedMessage(UartMessage msg)
{

        switch(msg.getHeader())
        {
            case UartMessage::RECEIVED_WRONG_NUM:
            case UartMessage::REPLACE_NUM:
            case UartMessage::REPLACE_NUM_DONE:
            case UartMessage::MOD_PARAMS:
            case UartMessage::SYS_STATUS:
            case UartMessage::MEM_PARAMS:
                throw(UartManagerException("Received unexpected message type from FPGA"));
                break;

            case UartMessage::ERR_FIFO_FULL:
                log << ErrFifoFull(msg);
                throw(FpgaMessageError("FIFO full"));
                break;
            case UartMessage::ERR_MEM_OVERRUN:
                log << ErrMemOverrun(msg);
                throw(FpgaMessageError("Message overrun"));
                break;
            case UartMessage::ERR_UPDATE_WHILST_RUN:
                log << ErrUpdateWhilstRun(msg);
                throw(FpgaMessageError("Attempt to update whilst running"));
                break;
            case UartMessage::ERR_INVALID_MSG:
                log << ErrInvalidMsg(msg);
                throw(FpgaMessageError("Received invalid message"));
                break;
            case UartMessage::ACK:
                if(ackQueue.size() > 0)
                {
                    ackType ackPacket = ackQueue.front();
                    ackQueue.pop();

                    //Handle case of expired packet
                    if(ackPacket.latestTime > clock())
                    {
                        throw UartManagerException("FGPA took too long to ACK");
                    }

                    //Check that acked packet is identical to what is expected
                    if(Ack(msg).getUnderlyingMsg().getData() != ackPacket.msg.getData())
                    {
                        throw UartManagerException("ACK packet was not the same as transmitted packet");
                    }

                } else {
                    throw(UartManagerException("Recieved ACK, but no messages are waiting in ACK queue"));
                }

                log << Ack(msg);
                break;
            default:
                throw(UartManagerException("Received message of unknown header"));
        }


}
