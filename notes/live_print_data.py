import argparse
import json
import re
from datetime import datetime

import sys

import print_hex_data

p = argparse.ArgumentParser()
p.add_argument('--filter-service', type=int, required=False)
p.add_argument('--filter-command', type=int, required=False)
p.add_argument('--filter-length-max', type=int, required=False, help='Only print stuff below this length')
p.add_argument('--print', action='store_true', help='Print data as text')
p.add_argument('--verbose', action='store_true', help='Print all raw data')
p.add_argument('--very-verbose', action='store_true', help='Print even raw lines from stdin')
p.add_argument('--only-print', action='store_true', help='Skip everything else and just print as text')
p.add_argument('--search-for-bytes', type=str, required=False,
               help='Search for these bytes anywhere in data (in decimal)')
p.add_argument('--print-time', action='store_true')
p.add_argument('--only-sent', action='store_true', help='Only print sent data')
p.add_argument('--only-received', action='store_true', help='Only print received data')
p.add_argument('--smart-divide', type=bool, default=True, help='Divide payloads into two if length byte says so.'
                                                               'Also detects if they are duplicates and skips them.')
p.add_argument('--filter-rules-file', type=str, help='Path to file with filter rules. Look at filter-rules.json '
                                                     'for an example :)')
args = p.parse_args()

file_filter_rules = None
if args.filter_rules_file is not None:
    with open(args.filter_rules_file) as f:
        file_filter_rules = json.load(f)


def is_sublist(big_list, sublist):
    for idx in range(len(big_list) - len(sublist) + 1):
        if big_list[idx: idx + len(sublist)] == sublist:
            return True
    return False


def matches_rules(filter_rules: dict, decimals: list[int], is_send: bool, is_receive: bool):
    matches_any = False
    for rule in filter_rules["rules"]:
        matches_all = True
        for key in rule:
            if any([
                key == "source" and \
                ((rule[key] == "send" and not is_send) or (rule[key] == "receive" and not is_receive)),
                key == "serviceId" and decimals[4] != rule[key],
                key == "commandId" and decimals[5] != rule[key],
                key == "minLength" and len(decimals) - 3 - 1 - 2 - 2 < rule[key],
                key == "maxLength" and len(decimals) - 3 - 1 - 2 - 2 > rule[key],
                key == "includesBytesInOrder" and not is_sublist(decimals[6:-2], rule[key]),
                key == "includesBytesAnyOrder" and not all(i in decimals[6:-2] for i in rule[key]),
            ]):
                matches_all = False
                break
        if matches_all:
            matches_any = True
            break
    if filter_rules["filterType"] == "only":
        return matches_any
    elif filter_rules["filterType"] == "not":
        return not matches_any
    else:
        raise Exception("Invalid filter type in rules: ", filter_rules)


def handle_payload(raw_line: str, payload: str, is_send: bool, is_receive: bool, smart_divided: bool):
    decimals = print_hex_data.string_to_decimals(payload)
    chars = print_hex_data.decimals_to_chars(decimals)

    length = decimals[2]
    service_id = decimals[4]
    command_id = decimals[5]
    magic_bytes = decimals[0], decimals[1], decimals[3]
    if magic_bytes != (90, 0, 0):
        raise Exception(f'MAGIC BYTES NOT MAGIC!!!\nBytes:{magic_bytes}\n{payload}')

    if (args.filter_service is not None and service_id != args.filter_service) \
            or (args.filter_command is not None and command_id != args.filter_command) \
            or (args.search_for_bytes is not None and not is_sublist(decimals[6:-2], eval(args.search_for_bytes))) \
            or (args.only_sent and not is_send) \
            or (args.only_received and not is_receive) \
            or (args.filter_length_max is not None and length > args.filter_length_max) \
            or (file_filter_rules is not None and not matches_rules(file_filter_rules, decimals, is_send, is_receive)):
        return

    # print unix epoch
    if args.print_time:
        print(datetime.now().timestamp(), end=' ')
    print("---Sent---:" if is_send else ("-Received-:" if is_receive else "UNKNOWN SOURCE: "))
    if args.very_verbose:
        print(raw_line, end=' ')
        if smart_divided:
            print('(Psst: Actually parsed bytes were smartly divided/ignored thanks to --smart-divide option)')
    if args.verbose:
        print(payload)
        print(decimals)

    if args.only_print:
        print(chars)
        return

    print('{ ServiceID:', service_id, 'CommandID:', command_id, '}')
    print('Data:', decimals[6:-2])

    if args.print:
        print('=== Printable ===')
        print(chars)
        print('=================')
    print()


while True:
    line = sys.stdin.readline()
    # print if line matches regex r' data: '
    if re.search(r'(received length: \d+ data: )|(Send \[Len]: \d+ \[Data]: )', line):
        _is_send = bool(re.search(r'Send ', line))
        _is_receive = bool(re.search(r'received length: ', line))
        res = re.search(r'5a\w+', line)
        data = res.group(0)
        if not args.smart_divide:
            handle_payload(line, data, _is_send, _is_receive, False)
            continue

        # Psst: while testing this, i was shaking my head why it wasn't showing me some commands
        # Then i realized, i filtered them out with filters :D So it actually works great!!
        last_payload = ""
        _smart_divided = False
        while len(data) >= 14:
            decimals = print_hex_data.string_to_decimals(data)
            length = decimals[2] + 5  # get length byte and add 5 for rest of bytes that it doesn't include
            if length < len(decimals):
                _smart_divided = True  # length shows to be smaller than what we have - we will smart divide
            hex_str_length = length * 2  # every byte is two hex chars
            actual_payload = data[:hex_str_length]
            data = data[hex_str_length:]  # Shorten data by what we have already parsed
            if actual_payload == last_payload:
                continue  # Skip if it's same as last (they often repeat)
            last_payload = actual_payload
            handle_payload(line, actual_payload, _is_send, _is_receive, _smart_divided)
