#!/usr/bin/python3

# This script generates header files for Verilog and C++ which define the paramters of the UART messages

import datetime
import os

def get_date_string():
    return datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")

word_len = 8  # We use bytes

# Message sizes (words)
ident_len = 1  # Length of identifier
payload_len = 7  # Length of payload
msg_len = ident_len + payload_len # Total message length

# Bitfield sizes (bits)
edsac_addr_len = 9  # 512 nums per coffin - 9 bits
edsac_data_len = 36  # 35 for num plus blanking bit

# Generic bit constants
ident_start_bit = 0 # Identifier is first item
ident_end_bit = ident_start_bit + ident_len*word_len -1
payload_start_bit = ident_end_bit + 1
payload_end_bit = msg_len*word_len -1

# Message types
# This is a list of tuples
# Each tuple contains the message type, then the remaining fields are message contents, and no. bits required
msg_types = [('received num', ('addr',edsac_addr_len), ('data',edsac_data_len)),  # Number has been received by controller
             ('replace num', ('addr',edsac_addr_len), ('data',edsac_data_len)),  # Request to replace a number in memory
             ('mod params',('cycles per pulse',5), ('pulse gap',8)),  # Request to update modulator parameters
             ('sys status', ('run', 1)),  # Request to update system status
             ('mem params', ('no nums', edsac_addr_len), ('test mode',1)),  # Requst to update memory manager params
             ('err fifo full', ('payload', payload_len*word_len)),  # Error - input FIFO is full
             ('err update run', ('payload', payload_len*word_len)),  # Error - attempted to update parameters whilst running
             ('err invalid msg', ('payload', payload_len*word_len)),  # Error - invalid message received
             ('ack', ('payload', payload_len*word_len)),  # Acknowledge receipt of message
]

# Turn filename to `define guard string
def to_guard(msg):
    return msg.upper().replace('.','_')

# Turn identifier to 'verilog' constant style e.g. 'received num' -> 'RECEIVED_NUM'
def to_verilog_style(msg):
    return msg.upper().replace(' ','_')

# Verilog file details
verilog_path = './verilog_out/'
verilog_filename = 'uart_msg_consts.h'
verilog_guard_name = to_guard(verilog_filename)
verilog_header = ('// UART Message Constants \n'
                  '// Automatically generated  by ' + os.path.basename(__file__) + ' at ' + get_date_string() + '\n\n'
                  '`ifndef ' + verilog_guard_name + '\n'
                  '`define ' + verilog_guard_name + '\n\n'
                  )
verilog_footer = '\n`endif\n'
verilog_prefix = 'uart '
verilog_header_prefix = 'header '
verilog_define_prefix = '`define '.capitalize()

# Construct little endian bit definition [end:start]
def verilog_construct_bits(start, end):
    return '['+str(end) + ':' + str(start)+']'

# Turn verilog const, val pair into `define statement
def verilog_define_string(const, val):
    return verilog_define_prefix + to_verilog_style(verilog_prefix+const) + ' ' + val + '\n'

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
    #Comment
    file.write('// '+ msg_type[0].capitalize() + '\n')

    # Write definition of header
    file.write(verilog_define_string(verilog_header_prefix + msg_type[0], str(ident)))

    # Write out bit definitions for each item in bit field
    start_bit = payload_start_bit # The ident is the first field
    for i in range(1, len(msg_type)):
        param = msg_type[i]
        end_bit = start_bit + param[1] -1
        file.write(verilog_construct_width_size_bits(param[0], param[1], start_bit, end_bit))
        start_bit = end_bit +1

    file.write('\n')

# Main program

# Verilog file
verilog_file = open(verilog_path+verilog_filename, 'w')
verilog_file.write(verilog_header)

# Generic constants
verilog_file.write('// Generic constants\n')
verilog_file.write(verilog_construct_width_size_bits('msg', msg_len*word_len, 0, msg_len*word_len-1))
verilog_file.write(verilog_construct_width_size_bits(verilog_header_prefix[0:-1], ident_len*word_len, ident_start_bit, ident_end_bit))
verilog_file.write(verilog_construct_width_size_bits('payload', payload_len*word_len, payload_start_bit, payload_end_bit))
verilog_file.write('\n')


msg_ident = 0
for msg_type in msg_types:
    verilog_write_msg_type(verilog_file, msg_type, msg_ident)
    msg_ident = msg_ident + 1

verilog_file.write(verilog_footer)
verilog_file.close()