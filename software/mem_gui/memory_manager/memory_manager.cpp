//Manages a single number of memory

#include "memory_manager.hpp"

void MemoryManager::setVal(ParamType newVal)
{
    //Check that we're not already updating the memory!
    if(update.expected)
    {
        throw("Attempted to update memory, whilst already waiting for an update");
    }

    //Set the update flag and value
    update.expected = true;
    update.val = newVal;

    //Construct message and put it on queue
    ReplaceNum msg;
    msg.setAddr(addr);
    msg.setData(newVal);
    messageQueue.push(msg);
}

void MemoryManager::processMessage(UartMessage msg)
{
    if(msg.getHeader() == UartMessage::REPLACE_NUM_DONE)
    {
        ReplaceNumDone repMsg(msg);
        if(repMsg.getAddr() == addr)
        {
            curVal = repMsg.getData(); //Always update, even if not expected
            if(!update.expected) //If not expected throw exception
            {
                throw MemoryManagerException("Updated when not expecting update.");
            }

            update.expected = false;

            if(update.val != repMsg.getData())
            {
                throw MemoryManagerException("Expected update, but data was not the same as expected");
            }

        } else {
            throw MemoryManagerException("Passed message for incorrect address.");
        }
    } else {
        throw MemoryManagerException("Passed incorrect message type.");
    }
}
