#!/usr/bin/python3

# This script generates header files for Verilog and C++ which define the paramters of the UART messages

import datetime
import os
import math

# MESSAGE PARAMETERS

word_len = 8  # We use bytes
cpp_size = 'uint64_t' # Size large enough to hold the contents of any individual bitfield

# Message sizes (words)
ident_len = 1  # Length of identifier
payload_len = 7  # Length of payload
msg_len = ident_len + payload_len # Total message length

# Bitfield sizes (bits)
edsac_addr_len = 8  # 256 nums per coffin - 8 bits
edsac_data_len = 36  # 35 for num plus blanking bit

# Generic bit constants
ident_start_bit = 0 # Identifier is first item
ident_end_bit = ident_start_bit + ident_len*word_len -1
payload_start_bit = ident_end_bit + 1
payload_end_bit = msg_len*word_len -1

# Message types
# This is a list of tuples
# Each tuple contains the message type, then the remaining fields are message contents, and no. bits required
msg_types = [('received wrong num', ('addr',edsac_addr_len), ('data',edsac_data_len)),  # Received a number different to what was expected
             ('replace num', ('addr',edsac_addr_len), ('data',edsac_data_len)),  # Request to replace a number in memory
             ('replace num done', ('addr',edsac_addr_len), ('data',edsac_data_len)),  # Replacement of a number is complete. Data is old data.
             ('mod params',('cycles per half period',6)),  # Request to update modulator parameters
             ('sys status', ('run', 1)),  # Request to update system status
             ('mem params', ('no nums', edsac_addr_len), ('test mode',1),('pulse width',10), ('pulse gap',10)),  # Requst to update memory manager params
             ('err fifo full', ('payload', payload_len*word_len)),  # Error - input FIFO is full
             ('err mem overrun', ('payload', payload_len*word_len)),  # Error - missed a word that came in because dealing with UART request took too long
             ('err update whilst run', ('payload', payload_len*word_len)),  # Error - attempted to update parameters whilst running
             ('err invalid msg', ('payload', payload_len*word_len)),  # Error - invalid message received
             ('ack', ('payload', payload_len*word_len)),  # Acknowledge receipt of message
]


# GENERIC FUNCTIONS

def get_date_string():
    return datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")


# Turn filename to `define guard string  e.g. 'received num.h' -> 'RECEIVED_NUM_H'
def to_guard(msg):
    return msg.upper().replace('.','_').replace(' ','_')

# VERILOG FILE PARAMETERS
verilog_path = './verilog_out/'
verilog_filename = 'uart_msg_consts.h'
verilog_guard_name = to_guard(verilog_filename)
verilog_header = ('// UART Message Constants \n'
                  '// Automatically generated  by ' + os.path.basename(__file__) + ' at ' + get_date_string() + '\n'
                  '// DO NOT MODIFY MANUALLY\n\n'
                  '`ifndef ' + verilog_guard_name + '\n'
                  '`define ' + verilog_guard_name + '\n\n'
)
verilog_footer = '\n`endif\n'
verilog_prefix = 'uart '
verilog_header_prefix = 'header '
verilog_define_prefix = '`define '.capitalize()

# CPP FILE PARAMETERS
cpp_path = './cpp_out/'
cpp_filename = 'uart_msg.hpp'
cpp_guard_name = to_guard(cpp_filename)
cpp_header = ('// UART Message Decoder and Encoder Classes \n'
              '// Automatically generated  by ' + os.path.basename(__file__) + ' at ' + get_date_string() + '\n'
              '// DO NOT MODIFY MANUALLY\n\n'
              '#ifndef ' + cpp_guard_name + '\n'
              '#define ' + cpp_guard_name + '\n\n'
              '#include <array>\n'
              '#include <iostream>\n\n'
)
cpp_footer = '\n#endif\n'
cpp_ret_type = 'param type' # A typedef'd type used to store any of the paramters
cpp_msg_var = 'message type'
cpp_base_class = 'uart_message' #Name of base class
cpp_length_const = 'uart msg len' #Constant for length of uart message in bytes
cpp_enum_name = 'message headers'
cpp_string_lookup_name = 'header strings'

# VERILOG SPECIFIC FUNCTIONS

# Turn identifier to 'verilog' constant style
def to_verilog_style(msg):
    return to_guard(msg)


# Construct little endian bit definition [end:start]
def verilog_construct_bits(start, end):
    return '['+str(end) + ':' + str(start)+']'


# Turn verilog const, val pair into `define statement
def verilog_define_string(const, val):
    return verilog_define_prefix + to_verilog_style(verilog_prefix+const) + ' ' + val + '\n'


# Create a verilog style constant e.g. 8'd5
def verilog_construct_constant(num, width):
    return str(width) + '\'d' + str(num)

# Create a statement for the bits size and width of a statement
# Width = How many bits wide is the item
# Size = Verilog size declaration of how bit the item is
# Bits = which bits of the overall message are specified by this
#
def verilog_construct_width_size_bits(ident, width, start_bit, end_bit):
    size = verilog_construct_bits(0, width-1)
    bits = verilog_construct_bits(start_bit, end_bit)
    return ( verilog_define_string(ident + ' width', str(width)) +
             verilog_define_string(ident + ' size', size) +
             verilog_define_string(ident + ' bits', bits)
    )


# Write out all that is required for a particular message type
def verilog_write_msg_type(file, msg_type, ident):
    # Comment
    msg_type_str = msg_type[0]
    file.write('// '+ msg_type_str.capitalize() + '\n')

    # Write definition of header
    file.write(verilog_define_string(verilog_header_prefix + msg_type_str, verilog_construct_constant(ident,ident_len*word_len)))

    # Write out bit definitions for each item in bit field
    start_bit = payload_start_bit # The ident is the first field

    total_payload_bits = 0
    for i in range(1, len(msg_type)):
        param = msg_type[i]
        param_str = param[0]
        param_width = param[1]
        total_payload_bits = total_payload_bits + param[1]
        end_bit = start_bit + param_width -1
        file.write(verilog_construct_width_size_bits(msg_type_str + ' ' + param_str, param_width, start_bit, end_bit))
        file.write(verilog_define_string(msg_type_str + ' ' + param_str + ' payload bits', verilog_construct_bits(start_bit-payload_start_bit, end_bit-payload_start_bit)))  # Bit define for inside payload
        start_bit = end_bit +1

    # Print an item for the total payload
    file.write(verilog_construct_width_size_bits(msg_type_str + ' total payload', total_payload_bits, payload_start_bit, payload_start_bit + total_payload_bits-1))

    file.write('\n')

# CPP functions


#Function to create a class declaration
def cpp_create_class(name, public, protected=(), extra=()):
    msg = ('class '+name+'\n'
           '{\n'
           '\tpublic:\n')
    for item in public:
        msg = msg + '\t\t'+item.replace('\n', '\n\t\t')+'\n'

    if len(protected) != 0:
        msg = msg + '\tprotected:\n'

        for item in protected:
            msg = msg + '\t\t'+item.replace('\n', '\n\t\t')+'\n'

    msg = msg + '};\n'

    for item in extra:
        msg += item + '\n'

    msg += '\n'

    return msg


#Camelcase (first letter uppercase)
def to_cpp_class_style(st): #From https://stackoverflow.com/questions/8347048/camelcase-every-string-any-standard-library
    output = ''.join(x for x in st.title() if x.isalpha())
    return output


#Camelcase (first letter lowercase)
def to_cpp_style(st): #From https://stackoverflow.com/questions/8347048/camelcase-every-string-any-standard-library
    output = ''.join(x for x in st.title() if x.isalpha())
    return output[0].lower() + output[1:]

cpp_base_class_fmtd = to_cpp_class_style(cpp_base_class)
cpp_length_const_fmtd = to_cpp_class_style(cpp_length_const)
cpp_ret_type_fmtd = to_cpp_class_style(cpp_ret_type)
cpp_msg_var_fmtd = to_cpp_class_style(cpp_msg_var) #Variable to hold uart message
cpp_enum_name_fmtd = to_cpp_style(cpp_enum_name)

# Generate bit mask to keep bits between (and including), low keep and high keep
def cpp_gen_mask(low_keep, high_keep):
    arr = ''
    for i in range(0, word_len):
        if i >= low_keep and i <= high_keep :
            val = '1'
        else:
            val = '0'
        arr = val + arr
    return arr

#Generate a getter and setter for a paramter
def cpp_gen_getter_setter_printer(name, low_bit, high_bit):
    low_word = math.floor(low_bit / word_len) # Get word containing low_bit
    high_word = math.floor(high_bit / word_len)
    low_bit = low_bit - low_word * word_len # Get position of lowest bit to keep in low word
    high_bit = high_bit - high_word * word_len
    name = to_cpp_class_style(name)

    #Getter
    get = cpp_ret_type_fmtd+ ' get'+ name +'(void) const\n{\n\treturn '
    for i in range(low_word, high_word+1):
        if i > low_word:
            get += '\n\t| '
        get += '((('+cpp_ret_type_fmtd+') data[' + str(i) + ']'
        if i == low_word:
             get += '& '+ cpp_gen_mask(low_bit, word_len-1) +' )) '
        else:
            if i == high_word:
                get += '& '+ cpp_gen_mask(0, high_bit) +' ) '
            else:
                get += ')'
            get += ' << ('+str(word_len)+' * '+str(i-low_word)+'))'
    get += ';\n};'

    #Setter
    set = 'void set'+name+'('+cpp_ret_type_fmtd+' dataIn)\n{\n'
    set += '\tdataIn <<= '+str(low_bit)+';\n' # Shift dataIn to align with words
    for i in range(low_word, high_word + 1):
        if i == low_word:
            set+= '\tdata['+str(i)+'] &= '+cpp_gen_mask(low_bit, word_len-1)+';\n' # Clear relevant bits from data
        elif i == high_word:
            set += '\tdata['+str(i)+'] &= '+cpp_gen_mask(0, high_bit)+';\n' #Clear relevant bits
        set+= '\tdata['+str(i)+'] |= (dataIn & 0xFF);\n\tdataIn >>= 8;\n' #Clear and shift ready for next bit
    set += '};'

    return [get, set]


# MAIN PROGRAM

# Open files
# Verilog
verilog_file = open(verilog_path+verilog_filename, 'w')
verilog_file.write(verilog_header)
# Cpp
cpp_file = open(cpp_path+cpp_filename,'w')
cpp_file.write(cpp_header)

# Write Generic constants
# Verilog
verilog_file.write('// Generic constants\n')
verilog_file.write(verilog_construct_width_size_bits('msg', msg_len*word_len, 0, msg_len*word_len-1))
verilog_file.write(verilog_construct_width_size_bits(verilog_header_prefix[0:-1], ident_len*word_len, ident_start_bit, ident_end_bit))
verilog_file.write(verilog_construct_width_size_bits('payload', payload_len*word_len, payload_start_bit, payload_end_bit))
verilog_file.write('\n')
#Cpp
cpp_file.write('// Generic constants\n')
cpp_file.write('const int '+cpp_length_const_fmtd+' = '+str(word_len)+'; //Length of UART message in bytes\n')
cpp_file.write('typedef ' + cpp_size + ' ' + cpp_ret_type_fmtd + '; //A type large enough to hold any of the paramters\n')
cpp_file.write('typedef std::array<uint8_t,' + cpp_length_const_fmtd + '> ' + cpp_msg_var_fmtd + '; //A type large enough to hold any of the paramters\n')
cpp_file.write('\n')

# Write main file contents
# Verilog
msg_ident = 0
for msg_type in msg_types:
    verilog_write_msg_type(verilog_file, msg_type, msg_ident)
    msg_ident = msg_ident + 1
#Cpp

name = cpp_base_class_fmtd
cpp_file.write('\n//Base Class\n')
public = [name +'(' + cpp_msg_var_fmtd + ' dataIn) :data(dataIn) {};',
          name +'() { data.fill(0);};',
          cpp_msg_var_fmtd + ' getData() const { return data;};',
          'void setData(' + cpp_msg_var_fmtd + ' dataIn) {data = dataIn;};',
          cpp_enum_name_fmtd+' getHeader(void) const {return ('+cpp_enum_name_fmtd+') data[0];};',
          'void setHeader('+cpp_enum_name_fmtd+' header) {data[0] = (uint8_t) header;};',
          'std::string getHeaderStr(void) {return '+to_cpp_style(cpp_string_lookup_name)+'[getHeader()]; };',
          cpp_base_class_fmtd + '& operator=(const '+cpp_base_class_fmtd+'& in) {data = in.data; return *this;};',
          ]

type_enum = 'enum '+cpp_enum_name_fmtd+'\n{\n'
i = 0
for param in msg_types:
    type_enum += '\t'+to_guard(param[0])+'='+str(i)+',\n'
    i+=1
type_enum = type_enum[0:-2]  #Get rid of comma
type_enum += '\n};'
public.insert(0,type_enum)

#Upgrade type function
#upgrade = 'auto upgradeType(void) const\n'
#upgrade += '{\n\tauto recd;\n\tswitch(in.getHeader())\n\t{'
#for param in msg_types:
#    upgrade += '\t case '+to_guard(param[0])+':\n'
#    upgrade += '\t\trecd = '+to_cpp_class_style(param[0])+'(*this);\n'
#    upgrade += '\t\tbreak;\n'
#upgrade += '\t}\n\treturn recd;\n}\n'
#public.append(upgrade)


protected = [cpp_msg_var_fmtd + ' data;',]
type_strings = 'const std::string '+ to_cpp_style(cpp_string_lookup_name)+'['+str(len(msg_types))+']=\n{\n'
for param in msg_types:
    type_strings += '\t'+'"'+param[0]+'",\n'
type_strings = type_strings[0:-2]  # Get rid of comma
type_strings += '\n};'
protected.append(type_strings)
cpp_file.write(cpp_create_class(name, public, protected))

cpp_file.write('//Derived Classes\n')
msg_ident = 0
for msg_type in msg_types:
    # Create class
    start_bit = payload_start_bit
    name = to_cpp_class_style(msg_type[0])
    public = [name+'() :'+cpp_base_class_fmtd+'() {data[0] = (uint8_t) '+to_guard(msg_type[0])+';};',
              name + '(const '+cpp_base_class_fmtd+'& in) {data = in.getData();};',
              ]
    for param in msg_type[1:]:
        end_bit = start_bit + param[1] -1
        public.extend(cpp_gen_getter_setter_printer(param[0], start_bit, end_bit))
        start_bit = end_bit +1;

    #Special function for ACK
    if msg_type[0] == 'ack':
        public.append(cpp_base_class_fmtd+' getUnderlyingMsg(void) const\n'
                                          '{\n'
                                           '\t'+cpp_msg_var_fmtd+' data = getData();\n'
                                          '\tfor(unsigned int i=0; i<(data.size()-1);i++)\n'
                                          '\t\tdata[i] = data[i+1];\n'
                                          '\tdata[data.size()-1]=0;\n'
                                          '\treturn '+cpp_base_class_fmtd+'(data);\n'
                                          '};')

    #Pretty printer
    printer_class = 'friend std::ostream& operator<<(std::ostream& os, const '+name+'& itm);' #Friend entry to go inside class
    public.append(printer_class)

    printer_extra = ('inline std::ostream& operator<<(std::ostream& os, const '+name+'& itm)\n' #Operator itself, inline is a dirty trick to allow multiple definition
                     '{\n'
                     '\tos '
                     )
    for param in msg_type[1:]:
        printer_extra += ' << "'+param[0]+': " << itm.get'+to_cpp_class_style(param[0])+'()'
    printer_extra += ';\n\treturn os;\n}'

    cpp_file.write(cpp_create_class(name + ' : public '+cpp_base_class_fmtd, public,(),[printer_extra,]))
    msg_ident = msg_ident + 1

# Close files
# Verilog
verilog_file.write(verilog_footer)
verilog_file.close()
#Cpp
cpp_file.write(cpp_footer)
cpp_file.close()