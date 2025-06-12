from typing import Tuple

def to_q_format(value: float, m: int, n: int) -> Tuple[str, int]:
    """
    Convert a number to Qm.n fixed-point representation with implicit sign bit.

    Args:
        value: The floating-point number to convert.
        m: Number of integer bits (excluding sign bit).
        n: Number of fractional bits.

    Returns:
        A tuple (bit_string, int_value) where:
          - bit_string: Binary string (length = 1+m+n+1 for the dot) with a '.' after the integer bits.
          - int_value: Integer representation packed in the LSBs (two's complement).

    Raises:
        ValueError: If the value is out of range for the given format.
    """
    total_bits = 1 + m + n
    scale = 1 << n  # 2^n

    # Determine min and max representable values
    max_int = (1 << (m + n)) - 1
    min_int = - (1 << (m + n))

    # Scale and round
    scaled = int(round(value * scale))

    # Range check
    if not (min_int <= scaled <= max_int):
        raise ValueError(
            f"Value {value} out of range for Q{m}.{n} (allowed: [{min_int/scale}, {max_int/scale}])"
        )

    # Two's complement for negatives, packed into total_bits
    if scaled < 0:
        packed = (1 << total_bits) + scaled
    else:
        packed = scaled

    raw_bits = format(packed, f'0{total_bits}b')
    # Insert decimal point after sign bit + m integer bits
    split_index = 1 + m
    bit_string = raw_bits[:split_index] + '.' + raw_bits[split_index:]
    return bit_string, packed


def from_q_format(bit_string: str, m: int, n: int) -> float:
    """
    Convert a Qm.n fixed-point binary string to a floating-point number.

    Args:
        bit_string: Binary string (two's complement) with a '.' after the integer bits.
        m: Number of integer bits (excluding sign bit).
        n: Number of fractional bits.

    Returns:
        The floating-point value.
    """
    # Remove decimal point
    split_index = 1 + m
    raw_bits = bit_string.replace('.', '')
    if len(raw_bits) != split_index + n:
        raise ValueError(
            f"Bit string length must be {split_index+n+1} (including dot) for Q{m}.{n}, got {len(bit_string)}"
        )

    packed = int(raw_bits, 2)

    # Interpret two's complement
    if raw_bits[0] == '1':
        packed -= (1 << (split_index + n))

    return packed / (1 << n)


def main() -> None:
    """
    Demonstrate conversions for sample values in various Q formats.
    """
    examples = [
        (3.75, 3, 4),    # Q3.4
        (-1.125, 2, 5),  # Q2.5
        (0.5, 1, 3),     # Q1.3
        (-0.625, 1, 4),  # Q1.4
    ]

    for value, m, n in examples:
        bits, integer_val = to_q_format(value, m, n)
        recon = from_q_format(bits, m, n)
        print(
            f"Value {value} -> Q{m}.{n} bits: {bits}, int: {hex(integer_val)} -> back to float: {recon}"
        )


if __name__ == "__main__":
    main()

