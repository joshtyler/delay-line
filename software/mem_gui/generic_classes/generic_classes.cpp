//Generic classes used by the project

#include <uart_msg.hpp>
#include "generic_classes.hpp"

UartMessage MessageCreator::getMessage(void)
{
    if(messageQueue.size() == 0)
    {
        throw MessageCreatorException("Attempt to get message when queue is empty.");
    }
    UartMessage msg(messageQueue.front());
    messageQueue.pop();
    return msg;
}
