import sys


def string_to_decimals(data: str) -> list:
    """
    Convert string of hex data to list of decimals.
    """
    return [int(data[i:i + 2], 16) for i in range(0, len(data), 2)]


def decimals_to_chars(data: list) -> str:
    """
    Convert list of decimals to string of chars.
    """
    return ''.join([chr(i) for i in data])


if __name__ == '__main__':
    data = sys.argv[1]
    decimals = string_to_decimals(data)
    print(decimals)
    print(decimals_to_chars(decimals))
