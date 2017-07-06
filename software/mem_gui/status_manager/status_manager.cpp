//Manages the system status
//E.g. parameters, is the system running or stopped

#include "status_manager.hpp"


void StatusManager::setModParams(StatusManager::modParams newParams)
{
    ModParams msg;
    msg.setCyclesPerHalfPeriod(newParams.cyclesPerHalfPeriod);
    messageQueue.push(msg);
}

void StatusManager::setDemodParams(StatusManager::demodParams newParams)
{
    DemodParams msg;
    msg.setPulseWidth(newParams.pulseWidth);
    messageQueue.push(msg);
}

void StatusManager::setMemParams(StatusManager::memParams newParams)
{
    MemParams msg;
    msg.setNoNums(newParams.noNums);
    msg.setTestMode(newParams.testMode);
    msg.setPulseWidth(newParams.pulseWidth);
    msg.setPulseGap(newParams.pulseGap);
    messageQueue.push(msg);
}

void StatusManager::setSysStatus(StatusManager::sysStatus newStatus)
{
    SysStatus msg;
    msg.setRun(newStatus.run);
    messageQueue.push(msg);
}

void StatusManager::processMessage(UartMessage msg)
{
    if(msg.getHeader() == UartMessage::ACK)
    {
        msg = Ack(msg).getUnderlyingMsg(); //Transform message to what was acked.
        //Each case is inside a {} block because we need to create scope for the local variables
        switch (msg.getHeader())
        {
            case UartMessage::MOD_PARAMS:
            {
                ModParams modMsg(msg);
                currModParams.cyclesPerHalfPeriod = modMsg.getCyclesPerHalfPeriod();
            }
                break;


            case UartMessage::MEM_PARAMS:
            {
                MemParams memMsg(msg);
                currMemParams.noNums = memMsg.getNoNums();
                currMemParams.testMode = memMsg.getTestMode();
                currMemParams.pulseWidth = memMsg.getPulseWidth();
                currMemParams.pulseGap = memMsg.getPulseGap();
            }
                break;

            case UartMessage::SYS_STATUS:
            {
                SysStatus sysMsg(msg);
                currSysStatus.run = sysMsg.getRun();
            }
                break;

            default:
                throw StatusManagerException("Received incorrect message type.");
        }
    } else {
        throw StatusManagerException("Asked to process non ACK message.");
    }
}



