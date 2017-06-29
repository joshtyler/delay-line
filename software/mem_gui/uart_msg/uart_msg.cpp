//
// Created by josh on 29/06/17.
//
#include "uart_msg.hpp"
#include <iostream>
#include <cassert>
#include <climits>

std::ostream& operator<<(std::ostream& os, const UartMessage& itm)
{
	itm.print(os);
	return os;
}


ParamType UartMessage::accessBits(unsigned int lower, unsigned int upper, bool set,MessageType *arr, ParamType dataIn ) const
{
	const auto wordSize = sizeof(data[0])*CHAR_BIT;
	if(lower > upper || upper > (data.size()*wordSize -1) || (upper-lower) > (sizeof(dataIn)*CHAR_BIT))
	{
		throw std::out_of_range("accessBits inputs are out of range");
	}

	const unsigned int first = lower / wordSize; //C++ will floor these, so we can use it as an index
	const unsigned int last = upper / wordSize;
	const unsigned int fixedShift = lower -first*wordSize;

	ParamType ret = 0;

	dataIn <<= fixedShift; //Fixed shift on dataIn

	//Loop over relevant words of array
	for(auto i = first; i != (last+1); i++)
	{
		//Create mask
		ParamType mask = 0; //Use param type because it will be bigger than sizeof(data[0]). We cannot decltype because we'd get a reference

		for(int j=wordSize-1; j >=0; j--)
		{
			mask <<= 1;
			if((i*wordSize + j >= lower) && (i*wordSize + j <= upper))
			{
				mask |=1;
			}
		}

		unsigned int curShift = (i-first)*wordSize;

		if(set)
		{
			//This should only ever be called with *arr==data
			//The reason for this stupid stupid call is that the print() methods MUST be const
			//And print uses getBits, which uses accessBits
			//It's all a bit of a mess, but I can't think of a cleaner way to do it!
			if(arr != &data)
			{
				throw std::out_of_range("accessBits called for write, with arr not equal to data!");
			}

			(*arr)[i] = (*arr)[i] & (~mask); //Clear relevant bits
			(*arr)[i] = (*arr)[i] |= (dataIn >> curShift);

		}

		ret |= ((data[i] & mask) << curShift);
	}

	if(set)
	{
		assert(ret == dataIn);
	}

	ret >>= fixedShift;

	return ret;
}
