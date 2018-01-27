// UART Message Decoder and Encoder Classes 
// Automatically generated  by uart_msg_const_gen.py at 10:20PM on August 10, 2017
// DO NOT MODIFY MANUALLY

#ifndef UART_MSG_HPP
#define UART_MSG_HPP

#include <array>
#include <iostream>

// Generic constants
const int UartMsgLen = 8; //Length of UART message in bytes
typedef uint64_t ParamType; //A type large enough to hold any of the paramters
typedef std::array<uint8_t,UartMsgLen> MessageType; //A type large enough to hold any of the paramters


//Base Class
class UartMessage
{
	public:
		enum messageHeaders
		{
			RECEIVED_WRONG_NUM=0,
			REPLACE_NUM=1,
			REPLACE_NUM_DONE=2,
			MOD_PARAMS=3,
			DEMOD_PARAMS=4,
			SYS_STATUS=5,
			MEM_PARAMS=6,
			ERR_FIFO_FULL=7,
			ERR_MEM_OVERRUN=8,
			ERR_UPDATE_WHILST_RUN=9,
			ERR_INVALID_MSG=10,
			ACK=11
		};
		UartMessage(MessageType dataIn) :data(dataIn) {};
		UartMessage() { data.fill(0);};
		MessageType getData() const { return data;};
		uint8_t * getDataRef() {return data.data();};
		void setData(MessageType dataIn) {data = dataIn;};
		messageHeaders getHeader(void) const {return (messageHeaders) data[0];};
		void setHeader(messageHeaders header) {data[0] = (uint8_t) header;};
		std::string getHeaderStr(void) const {return headerStrings[getHeader()]; };
		virtual void print(std::ostream& os) const {os << getBits(0, 63) << std::endl;};
		UartMessage& operator=(const UartMessage& in) {data = in.data; return *this;};
	protected:
		MessageType data;
		ParamType accessBits(unsigned int lower, unsigned int upper, bool set,MessageType *arr=nullptr, ParamType dataIn=0 ) const;
		ParamType getBits(unsigned int lower, unsigned int upper) const {return accessBits(lower, upper, false);};
		void setBits(unsigned int lower, unsigned int upper,ParamType dataIn) {accessBits(lower, upper, true, &data, dataIn);};
		const std::string headerStrings[12]=
		{
			"received wrong num",
			"replace num",
			"replace num done",
			"mod params",
			"demod params",
			"sys status",
			"mem params",
			"err fifo full",
			"err mem overrun",
			"err update whilst run",
			"err invalid msg",
			"ack"
		};
};
std::ostream& operator<<(std::ostream& os, const UartMessage& itm);

//Derived Classes
class ReceivedWrongNum : public UartMessage
{
	public:
		ReceivedWrongNum() :UartMessage() {data[0] = (uint8_t) RECEIVED_WRONG_NUM;};
		ReceivedWrongNum(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const {return getBits(8, 15);};
		void setAddr(ParamType data) {setBits(8, 15, data);};
		ParamType getData(void) const {return getBits(16, 51);};
		void setData(ParamType data) {setBits(16, 51, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " addr: " << getAddr() << " data: " << getData()<< std::endl;
		}
};

class ReplaceNum : public UartMessage
{
	public:
		ReplaceNum() :UartMessage() {data[0] = (uint8_t) REPLACE_NUM;};
		ReplaceNum(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const {return getBits(8, 15);};
		void setAddr(ParamType data) {setBits(8, 15, data);};
		ParamType getData(void) const {return getBits(16, 51);};
		void setData(ParamType data) {setBits(16, 51, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " addr: " << getAddr() << " data: " << getData()<< std::endl;
		}
};

class ReplaceNumDone : public UartMessage
{
	public:
		ReplaceNumDone() :UartMessage() {data[0] = (uint8_t) REPLACE_NUM_DONE;};
		ReplaceNumDone(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const {return getBits(8, 15);};
		void setAddr(ParamType data) {setBits(8, 15, data);};
		ParamType getData(void) const {return getBits(16, 51);};
		void setData(ParamType data) {setBits(16, 51, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " addr: " << getAddr() << " data: " << getData()<< std::endl;
		}
};

class ModParams : public UartMessage
{
	public:
		ModParams() :UartMessage() {data[0] = (uint8_t) MOD_PARAMS;};
		ModParams(const UartMessage& in) {data = in.getData();};
		ParamType getCyclesPerHalfPeriod(void) const {return getBits(8, 13);};
		void setCyclesPerHalfPeriod(ParamType data) {setBits(8, 13, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " cycles per half period: " << getCyclesPerHalfPeriod()<< std::endl;
		}
};

class DemodParams : public UartMessage
{
	public:
		DemodParams() :UartMessage() {data[0] = (uint8_t) DEMOD_PARAMS;};
		DemodParams(const UartMessage& in) {data = in.getData();};
		ParamType getPulseWidth(void) const {return getBits(8, 15);};
		void setPulseWidth(ParamType data) {setBits(8, 15, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " pulse width: " << getPulseWidth()<< std::endl;
		}
};

class SysStatus : public UartMessage
{
	public:
		SysStatus() :UartMessage() {data[0] = (uint8_t) SYS_STATUS;};
		SysStatus(const UartMessage& in) {data = in.getData();};
		ParamType getRun(void) const {return getBits(8, 8);};
		void setRun(ParamType data) {setBits(8, 8, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " run: " << getRun()<< std::endl;
		}
};

class MemParams : public UartMessage
{
	public:
		MemParams() :UartMessage() {data[0] = (uint8_t) MEM_PARAMS;};
		MemParams(const UartMessage& in) {data = in.getData();};
		ParamType getNoNums(void) const {return getBits(8, 15);};
		void setNoNums(ParamType data) {setBits(8, 15, data);};
		ParamType getTestMode(void) const {return getBits(16, 16);};
		void setTestMode(ParamType data) {setBits(16, 16, data);};
		ParamType getPulseWidth(void) const {return getBits(17, 24);};
		void setPulseWidth(ParamType data) {setBits(17, 24, data);};
		ParamType getPulseGap(void) const {return getBits(25, 32);};
		void setPulseGap(ParamType data) {setBits(25, 32, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " no nums: " << getNoNums() << " test mode: " << getTestMode() << " pulse width: " << getPulseWidth() << " pulse gap: " << getPulseGap()<< std::endl;
		}
};

class ErrFifoFull : public UartMessage
{
	public:
		ErrFifoFull() :UartMessage() {data[0] = (uint8_t) ERR_FIFO_FULL;};
		ErrFifoFull(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const {return getBits(8, 63);};
		void setPayload(ParamType data) {setBits(8, 63, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " payload: " << getPayload()<< std::endl;
		}
};

class ErrMemOverrun : public UartMessage
{
	public:
		ErrMemOverrun() :UartMessage() {data[0] = (uint8_t) ERR_MEM_OVERRUN;};
		ErrMemOverrun(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const {return getBits(8, 63);};
		void setPayload(ParamType data) {setBits(8, 63, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " payload: " << getPayload()<< std::endl;
		}
};

class ErrUpdateWhilstRun : public UartMessage
{
	public:
		ErrUpdateWhilstRun() :UartMessage() {data[0] = (uint8_t) ERR_UPDATE_WHILST_RUN;};
		ErrUpdateWhilstRun(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const {return getBits(8, 63);};
		void setPayload(ParamType data) {setBits(8, 63, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " payload: " << getPayload()<< std::endl;
		}
};

class ErrInvalidMsg : public UartMessage
{
	public:
		ErrInvalidMsg() :UartMessage() {data[0] = (uint8_t) ERR_INVALID_MSG;};
		ErrInvalidMsg(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const {return getBits(8, 63);};
		void setPayload(ParamType data) {setBits(8, 63, data);};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " payload: " << getPayload()<< std::endl;
		}
};

class Ack : public UartMessage
{
	public:
		Ack() :UartMessage() {data[0] = (uint8_t) ACK;};
		Ack(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const {return getBits(8, 63);};
		void setPayload(ParamType data) {setBits(8, 63, data);};
		UartMessage getUnderlyingMsg(void) const
		{
			MessageType data = getData();
			for(unsigned int i=0; i<(data.size()-1);i++)
				data[i] = data[i+1];
			data[data.size()-1]=0;
			return UartMessage(data);
		};
		void print(std::ostream& os) const
		{
			os << getHeaderStr() << ": "  << " payload: " << getPayload()<< std::endl;
		}
};


#endif
