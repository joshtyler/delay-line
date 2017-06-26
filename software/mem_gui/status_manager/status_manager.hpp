//Manages the system status
//E.g. parameters, is the system running or stopped

#ifndef STATUS_MANAGER_HPP
#define STATUS_MANAGER_HPP


#include <uart_msg.hpp>
#include <queue>
#include "generic_classes.hpp"


//Exception Classes
class StatusManagerException : private GenericException
{
    public:
        StatusManagerException(std::string str) :GenericException("Status Manager exception: ",str) {};
};

class StatusManager : public MessageCreator
{
    public:
        struct modParams
        {
            ParamType cyclesPerHalfPeriod;
            modParams() : cyclesPerHalfPeriod(0) {};
        };
        struct memParams
        {
            ParamType noNums;
            ParamType testMode;
            ParamType pulseWidth;
            ParamType pulseGap;
            memParams() : noNums(0), testMode(0), pulseWidth(0), pulseGap(0) {};
        };
        struct sysStatus
        {
            ParamType run;
            sysStatus() :run(0) {};
        };

        void processMessage(UartMessage msg); //Process a status message from FPGA
        void setModParams(modParams newParams); //Send out a request to update to these parameters
        void setMemParams(memParams newParams);
        void setSysStatus(sysStatus newStatus);
        modParams getModParams(void) const {return currModParams;};
        memParams getMemParams(void) const {return currMemParams;};
        sysStatus getSysParams(void) const {return currSysStatus;};

    private:
        modParams currModParams;
        memParams currMemParams;
        sysStatus currSysStatus;
};


#endif
