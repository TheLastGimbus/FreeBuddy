import re
import sys
import print_hex_data
import argparse

p = argparse.ArgumentParser()
p.add_argument('--filter-service', type=int, required=False)
p.add_argument('--filter-command', type=int, required=False)
p.add_argument('--print', action='store_true', help='Print data as text')
p.add_argument('--verbose', action='store_true', help='Print all raw data')
p.add_argument('--only-print', action='store_true', help='Skip everything else and just print as text')
args = p.parse_args()

while True:
    line = sys.stdin.readline()
    # print if line matches regex r' data: '
    if re.search(r'(received length: \d+ data: )|(Send \[Len]: \d+ \[Data]: )', line):
        is_send = bool(re.search(r'Send ', line))
        is_receive = bool(re.search(r'received length: ', line))
        res = re.search(r'5a.+', line)
        data = res.group(0)
        decimals = print_hex_data.string_to_decimals(data)
        chars = print_hex_data.decimals_to_chars(decimals)

        length = decimals[2]
        service_id = decimals[4]
        command_id = decimals[5]
        empty_bytes = decimals[1], decimals[3]
        if empty_bytes != (0, 0):
            raise Exception(f'EMPTY BYTES NOT EMPTY!!!\nBytes:{empty_bytes}\n{data}')

        if (args.filter_service is not None and service_id != args.filter_service) \
                or (args.filter_command is not None and command_id != args.filter_command):
            continue

        print("---Sent---:" if is_send else ("-Received-:" if is_receive else "UNKNOWN SOURCE: "))
        if args.verbose:
            print(data)
            print(decimals)

        if args.only_print:
            print(chars)
            continue

        print('{ Length:', length, 'ServiceID:', service_id, 'CommandID:', command_id, 'Checksums:', decimals[-2:], '}')
        print(decimals[6:-2])

        if args.print:
            print('=== Printable ===')
            print(chars)
            print('=================')
        print()
