// UART Message Decoder and Encoder Classes 
// Automatically generated  by uart_msg_const_gen.py at 09:06PM on June 23, 2017
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
			SYS_STATUS=4,
			MEM_PARAMS=5,
			ERR_FIFO_FULL=6,
			ERR_MEM_OVERRUN=7,
			ERR_UPDATE_WHILST_RUN=8,
			ERR_INVALID_MSG=9,
			ACK=10
		};
		UartMessage(MessageType dataIn) :data(dataIn) {};
		UartMessage() { data.fill(0);};
		MessageType getData() const { return data;};
		void setData(MessageType dataIn) {data = dataIn;};
		messageHeaders getHeader(void) const {return (messageHeaders) data[0];};
		void setHeader(messageHeaders header) {data[0] = (uint8_t) header;};
		std::string getHeaderStr(void) {return headerStrings[getHeader()]; };
		UartMessage& operator=(const UartMessage& in) {data = in.data; return *this;};
	protected:
		MessageType data;
		const std::string headerStrings[11]=
		{
			"received wrong num",
			"replace num",
			"replace num done",
			"mod params",
			"sys status",
			"mem params",
			"err fifo full",
			"err mem overrun",
			"err update whilst run",
			"err invalid msg",
			"ack"
		};
};

//Derived Classes
class ReceivedWrongNum : public UartMessage
{
	public:
		ReceivedWrongNum() :UartMessage() {data[0] = (uint8_t) RECEIVED_WRONG_NUM;};
		ReceivedWrongNum(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setAddr(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getData(void) const
		{
			return (((ParamType) data[2]& 11111111 )) 
			| (((ParamType) data[3]) << (8 * 1))
			| (((ParamType) data[4]) << (8 * 2))
			| (((ParamType) data[5]) << (8 * 3))
			| (((ParamType) data[6]& 00001111 )  << (8 * 4));
		};
		void setData(ParamType dataIn)
		{
			dataIn <<= 0;
			data[2] &= 11111111;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] &= 00001111;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ReceivedWrongNum& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ReceivedWrongNum& itm)
{
	os  << "addr: " << itm.getAddr() << "data: " << itm.getData();
	return os;
}

class ReplaceNum : public UartMessage
{
	public:
		ReplaceNum() :UartMessage() {data[0] = (uint8_t) REPLACE_NUM;};
		ReplaceNum(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setAddr(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getData(void) const
		{
			return (((ParamType) data[2]& 11111111 )) 
			| (((ParamType) data[3]) << (8 * 1))
			| (((ParamType) data[4]) << (8 * 2))
			| (((ParamType) data[5]) << (8 * 3))
			| (((ParamType) data[6]& 00001111 )  << (8 * 4));
		};
		void setData(ParamType dataIn)
		{
			dataIn <<= 0;
			data[2] &= 11111111;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] &= 00001111;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ReplaceNum& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ReplaceNum& itm)
{
	os  << "addr: " << itm.getAddr() << "data: " << itm.getData();
	return os;
}

class ReplaceNumDone : public UartMessage
{
	public:
		ReplaceNumDone() :UartMessage() {data[0] = (uint8_t) REPLACE_NUM_DONE;};
		ReplaceNumDone(const UartMessage& in) {data = in.getData();};
		ParamType getAddr(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setAddr(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getData(void) const
		{
			return (((ParamType) data[2]& 11111111 )) 
			| (((ParamType) data[3]) << (8 * 1))
			| (((ParamType) data[4]) << (8 * 2))
			| (((ParamType) data[5]) << (8 * 3))
			| (((ParamType) data[6]& 00001111 )  << (8 * 4));
		};
		void setData(ParamType dataIn)
		{
			dataIn <<= 0;
			data[2] &= 11111111;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] &= 00001111;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ReplaceNumDone& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ReplaceNumDone& itm)
{
	os  << "addr: " << itm.getAddr() << "data: " << itm.getData();
	return os;
}

class ModParams : public UartMessage
{
	public:
		ModParams() :UartMessage() {data[0] = (uint8_t) MOD_PARAMS;};
		ModParams(const UartMessage& in) {data = in.getData();};
		ParamType getCyclesPerHalfPeriod(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setCyclesPerHalfPeriod(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ModParams& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ModParams& itm)
{
	os  << "cycles per half period: " << itm.getCyclesPerHalfPeriod();
	return os;
}

class SysStatus : public UartMessage
{
	public:
		SysStatus() :UartMessage() {data[0] = (uint8_t) SYS_STATUS;};
		SysStatus(const UartMessage& in) {data = in.getData();};
		ParamType getRun(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setRun(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const SysStatus& itm);
};
inline std::ostream& operator<<(std::ostream& os, const SysStatus& itm)
{
	os  << "run: " << itm.getRun();
	return os;
}

class MemParams : public UartMessage
{
	public:
		MemParams() :UartMessage() {data[0] = (uint8_t) MEM_PARAMS;};
		MemParams(const UartMessage& in) {data = in.getData();};
		ParamType getNoNums(void) const
		{
			return (((ParamType) data[1]& 11111111 )) ;
		};
		void setNoNums(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getTestMode(void) const
		{
			return (((ParamType) data[2]& 11111111 )) ;
		};
		void setTestMode(ParamType dataIn)
		{
			dataIn <<= 0;
			data[2] &= 11111111;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getPulseWidth(void) const
		{
			return (((ParamType) data[2]& 11111110 )) 
			| (((ParamType) data[3]& 00000111 )  << (8 * 1));
		};
		void setPulseWidth(ParamType dataIn)
		{
			dataIn <<= 1;
			data[2] &= 11111110;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] &= 00000111;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		ParamType getPulseGap(void) const
		{
			return (((ParamType) data[3]& 11111000 )) 
			| (((ParamType) data[4]& 00011111 )  << (8 * 1));
		};
		void setPulseGap(ParamType dataIn)
		{
			dataIn <<= 3;
			data[3] &= 11111000;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] &= 00011111;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const MemParams& itm);
};
inline std::ostream& operator<<(std::ostream& os, const MemParams& itm)
{
	os  << "no nums: " << itm.getNoNums() << "test mode: " << itm.getTestMode() << "pulse width: " << itm.getPulseWidth() << "pulse gap: " << itm.getPulseGap();
	return os;
}

class ErrFifoFull : public UartMessage
{
	public:
		ErrFifoFull() :UartMessage() {data[0] = (uint8_t) ERR_FIFO_FULL;};
		ErrFifoFull(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const
		{
			return (((ParamType) data[1]& 11111111 )) 
			| (((ParamType) data[2]) << (8 * 1))
			| (((ParamType) data[3]) << (8 * 2))
			| (((ParamType) data[4]) << (8 * 3))
			| (((ParamType) data[5]) << (8 * 4))
			| (((ParamType) data[6]) << (8 * 5))
			| (((ParamType) data[7]& 11111111 )  << (8 * 6));
		};
		void setPayload(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[7] &= 11111111;
			data[7] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ErrFifoFull& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ErrFifoFull& itm)
{
	os  << "payload: " << itm.getPayload();
	return os;
}

class ErrMemOverrun : public UartMessage
{
	public:
		ErrMemOverrun() :UartMessage() {data[0] = (uint8_t) ERR_MEM_OVERRUN;};
		ErrMemOverrun(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const
		{
			return (((ParamType) data[1]& 11111111 )) 
			| (((ParamType) data[2]) << (8 * 1))
			| (((ParamType) data[3]) << (8 * 2))
			| (((ParamType) data[4]) << (8 * 3))
			| (((ParamType) data[5]) << (8 * 4))
			| (((ParamType) data[6]) << (8 * 5))
			| (((ParamType) data[7]& 11111111 )  << (8 * 6));
		};
		void setPayload(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[7] &= 11111111;
			data[7] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ErrMemOverrun& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ErrMemOverrun& itm)
{
	os  << "payload: " << itm.getPayload();
	return os;
}

class ErrUpdateWhilstRun : public UartMessage
{
	public:
		ErrUpdateWhilstRun() :UartMessage() {data[0] = (uint8_t) ERR_UPDATE_WHILST_RUN;};
		ErrUpdateWhilstRun(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const
		{
			return (((ParamType) data[1]& 11111111 )) 
			| (((ParamType) data[2]) << (8 * 1))
			| (((ParamType) data[3]) << (8 * 2))
			| (((ParamType) data[4]) << (8 * 3))
			| (((ParamType) data[5]) << (8 * 4))
			| (((ParamType) data[6]) << (8 * 5))
			| (((ParamType) data[7]& 11111111 )  << (8 * 6));
		};
		void setPayload(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[7] &= 11111111;
			data[7] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ErrUpdateWhilstRun& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ErrUpdateWhilstRun& itm)
{
	os  << "payload: " << itm.getPayload();
	return os;
}

class ErrInvalidMsg : public UartMessage
{
	public:
		ErrInvalidMsg() :UartMessage() {data[0] = (uint8_t) ERR_INVALID_MSG;};
		ErrInvalidMsg(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const
		{
			return (((ParamType) data[1]& 11111111 )) 
			| (((ParamType) data[2]) << (8 * 1))
			| (((ParamType) data[3]) << (8 * 2))
			| (((ParamType) data[4]) << (8 * 3))
			| (((ParamType) data[5]) << (8 * 4))
			| (((ParamType) data[6]) << (8 * 5))
			| (((ParamType) data[7]& 11111111 )  << (8 * 6));
		};
		void setPayload(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[7] &= 11111111;
			data[7] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		friend std::ostream& operator<<(std::ostream& os, const ErrInvalidMsg& itm);
};
inline std::ostream& operator<<(std::ostream& os, const ErrInvalidMsg& itm)
{
	os  << "payload: " << itm.getPayload();
	return os;
}

class Ack : public UartMessage
{
	public:
		Ack() :UartMessage() {data[0] = (uint8_t) ACK;};
		Ack(const UartMessage& in) {data = in.getData();};
		ParamType getPayload(void) const
		{
			return (((ParamType) data[1]& 11111111 )) 
			| (((ParamType) data[2]) << (8 * 1))
			| (((ParamType) data[3]) << (8 * 2))
			| (((ParamType) data[4]) << (8 * 3))
			| (((ParamType) data[5]) << (8 * 4))
			| (((ParamType) data[6]) << (8 * 5))
			| (((ParamType) data[7]& 11111111 )  << (8 * 6));
		};
		void setPayload(ParamType dataIn)
		{
			dataIn <<= 0;
			data[1] &= 11111111;
			data[1] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[2] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[3] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[4] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[5] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[6] |= (dataIn & 0xFF);
			dataIn >>= 8;
			data[7] &= 11111111;
			data[7] |= (dataIn & 0xFF);
			dataIn >>= 8;
		};
		UartMessage getUnderlyingMsg(void) const
		{
			MessageType data = getData();
			for(unsigned int i=0; i<(data.size()-1);i++)
				data[i] = data[i+1];
			data[data.size()-1]=0;
			return UartMessage(data);
		};
		friend std::ostream& operator<<(std::ostream& os, const Ack& itm);
};
inline std::ostream& operator<<(std::ostream& os, const Ack& itm)
{
	os  << "payload: " << itm.getPayload();
	return os;
}


#endif
