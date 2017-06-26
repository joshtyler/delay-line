//Generic classes used by the project

#ifndef GENERIC_TYPES_HPP
#define GENERIC_TYPES_HPP

#include <uart_msg.hpp>
#include <queue>

// An exception class that takes a std::string detailing the error.
// The error type is also given by string
class GenericException : public std::runtime_error
{
    public:
        GenericException(std::string source, std::string str) :std::runtime_error("") {message = source+str;};
        virtual const char* what(void) const noexcept {return message.c_str();};
    private:
        std::string message;
};

class MessageCreatorException : public GenericException
{
    public:
        MessageCreatorException(std::string str) :GenericException("Message creator exception: ", str) {};
};

//A class which produces messages and should be polled for their transmit over UART
class MessageCreator
{

    public:
        virtual void processMessage(UartMessage msg) = 0; //Process a status message from FPGA
        bool messageWaiting(void) const {return (messageQueue.size() >0);}; //Indicate if a message is waiting
        UartMessage getMessage(void); //Get a message from the message queue
        virtual ~MessageCreator() {};

    protected:
        std::queue<UartMessage> messageQueue;


};

#endif
