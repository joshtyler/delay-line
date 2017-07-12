//Manages a single number of memory

#ifndef MEMORY_MANAGER_HPP
#define MEMORY_MANAGER_HPP


#include <uart_msg.hpp>
#include <generic_classes.hpp>

//Exception classes
class MemoryManagerException : public GenericException
{
    public:
        MemoryManagerException(std::string str) :GenericException("Memory manager exception: ", str) {};
};


class MemoryManager : public MessageCreator
{
    public:
        MemoryManager(ParamType addrIn) :addr(addrIn), curVal(0) {};
        void processMessage(UartMessage msg);
        ParamType getCurVal() const {return curVal; };
        void setVal(ParamType newVal);
        void clear(void) {curVal = 0; update.expected = false;}; //Clear current memory (used when stopped)

    private:
        ParamType addr; //The address that this class manages - this doesn't change
        ParamType curVal; //The current value of the memory
        struct UpdateType
        {
            ParamType val;
            bool expected;
            UpdateType() :expected(false) {};
        };
        UpdateType update;
};


#endif //MEM_GUI_MEMORY_MANAGER_HPP
