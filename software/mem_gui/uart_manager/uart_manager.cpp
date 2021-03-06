// UART manager
// Handles sending and receiving messages, waiting for ACKs etc.

#include <iostream>
#include <thread>
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
		uart.readRequest(currentRead.getDataRef(),UartMsgLen);
        readLogged = true;
	}

	//Handle a currently logged write
	if(writeLogged)
	{
		if(uart.writeDone())
		{
            static int i = 0;
            if(i == 1) //Stupid delay
            {
                writeLogged = false;
                i=0;
            } else {
                i++;
            }
		}
	}

    //Setup a new write if the resource is available, and we have data to write
    if(!writeLogged && (sendQueue.size()>0))
    {
        currentWrite = sendQueue.front();
        sendQueue.pop();
        uart.writeRequest(currentWrite.getDataRef(),UartMsgLen);
        log << "Sent:" << std::hex << currentWrite << std::dec;
        ackQueue.push({currentWrite, (clock() + timeout)}); //We expect the packet to be ACKed. Log this in the ACK queue
        writeLogged = true;
    }

    //Check if the FPGA has taken too long to ack
    if(ackQueue.size()>0)
    {
        if (clock() > ackQueue.front().latestTime)
        {
            throw UartManagerException("FGPA took too long to ACK");
        }
    }
}

void UartManager::processReceivedMessage(UartMessage msg)
{
//        log << "Raw received packet:" << std::hex << msg << std::dec << std::endl;
        log << "Received: ";
        switch(msg.getHeader())
        {
            case UartMessage::REPLACE_NUM:
            case UartMessage::MOD_PARAMS:
            case UartMessage::SYS_STATUS:
            case UartMessage::MEM_PARAMS:
                throw(UartManagerException("Received unexpected message type from FPGA"));

            case UartMessage::RECEIVED_WRONG_NUM:
                log << "Error: ";
                log << ReceivedWrongNum(msg);
//                throw(FpgaMessageError("FPGA received wrong number"));

            case UartMessage::REPLACE_NUM_DONE:
                log << ReplaceNumDone(msg);
                break;

            case UartMessage::ERR_FIFO_FULL:
                log << "Error: ";
                log << ErrFifoFull(msg);
                throw(FpgaMessageError("FIFO full"));
                break;
            case UartMessage::ERR_MEM_OVERRUN:
                log << "Error: ";
                log << ErrMemOverrun(msg);
                throw(FpgaMessageError("Message overrun"));
                break;
            case UartMessage::ERR_UPDATE_WHILST_RUN:
                log << "Error: ";
                log << ErrUpdateWhilstRun(msg);
                throw(FpgaMessageError("Attempt to update whilst running"));
                break;
            case UartMessage::ERR_INVALID_MSG:
                log << "Error: ";
                log << ErrInvalidMsg(msg);
                throw(FpgaMessageError("Received invalid message"));
                break;
            case UartMessage::ACK:
            {
                UartMessage underlying = Ack(msg).getUnderlyingMsg();
                if (ackQueue.size() > 0)
                {
                    ackType ackPacket = ackQueue.front();
                    ackQueue.pop();

                    //Handle case of expired packet
                    if (clock() > ackPacket.latestTime)
                    {
                        throw UartManagerException("FGPA took too long to ACK");
                    }

                    //Check that acked packet is identical to what is expected
                    if (underlying.getData() != ackPacket.msg.getData())
                    {
                        std::cerr << "Transmitted packet :" << std::hex <<ackPacket.msg << std::dec << std::endl;
                        std::cerr << "Received ack :" << std::hex << msg << std::dec << std::endl;
                        throw UartManagerException("ACK packet was not the same as transmitted packet");
                    }

                } else
                {
                    throw (UartManagerException("Recieved ACK, but no messages are waiting in ACK queue"));
                }

                //Display full message for ack
                log << "Ack: ";
                switch (underlying.getHeader())
                {
                    case UartMessage::REPLACE_NUM:
                        log << ReplaceNum(underlying);
                        break;
                    case UartMessage::MOD_PARAMS:
                        log << ModParams(underlying);
                        break;
                    case UartMessage::DEMOD_PARAMS:
                        log << DemodParams(underlying);
                        break;
                    case UartMessage::SYS_STATUS:
                        log << SysStatus(underlying);
                        break;
                    case UartMessage::MEM_PARAMS:
                        log << MemParams(underlying);
                        break;
                    default:
                        log << Ack(msg);
                        break;
                }
                break;
            }
            default:
                throw(UartManagerException("Received message of unknown header"));
        }


}
