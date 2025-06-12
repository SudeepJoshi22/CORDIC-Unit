from typing import Tuple

def to_q_format(value: float, m: int, n: int) -> Tuple[str, int]:
    """
    Convert a number to Qm.n fixed-point representation with implicit sign bit,
    and return a 32-bit integer with value packed in the LSBs and formatted bit string.

    Args:
        value: Floating-point input.
        m: Number of integer bits (excluding sign).
        n: Number of fractional bits.

    Returns:
        (bit_string, 32_bit_packed_int):
            bit_string with '.' after integer bits,
            32-bit int with bits packed in LSBs.

    Raises:
        ValueError if the input exceeds 32-bit representation.
    """
    total_q_bits = 1 + m + n
    if total_q_bits > 32:
        raise ValueError(f"Q{m}.{n} exceeds 32-bit width: 1 (sign) + {m} + {n} = {total_q_bits}")

    scale = 1 << n
    max_int = (1 << (m + n)) - 1
    min_int = - (1 << (m + n))
    scaled = int(round(value * scale))

    if not (min_int <= scaled <= max_int):
        raise ValueError(f"Value {value} out of range for Q{m}.{n} (allowed: [{min_int/scale}, {max_int/scale}])")

    # Convert to two's complement
    raw = scaled & ((1 << total_q_bits) - 1)

    # Shift to LSB of 32-bit word
    packed_32bit = raw << (32 - total_q_bits)

    # Format binary string with dot after integer bits
    bit_string_raw = format(raw, f'0{total_q_bits}b')
    split = 1 + m
    bit_string = bit_string_raw[:split] + '.' + bit_string_raw[split:]

    return bit_string, packed_32bit


def from_q_format(bit_string: str, m: int, n: int) -> float:
    """
    Convert a Qm.n fixed-point bit string (with '.') to float.

    Args:
        bit_string: Binary string with '.' after integer bits.
        m: Number of integer bits (excluding sign).
        n: Number of fractional bits.

    Returns:
        Floating-point representation.
    """
    total_bits = 1 + m + n
    raw_bits = bit_string.replace('.', '')

    if len(raw_bits) != total_bits:
        raise ValueError(f"Bit string must be {total_bits} bits (excluding dot), got {len(raw_bits)}")

    val = int(raw_bits, 2)
    if raw_bits[0] == '1':  # negative
        val -= (1 << total_bits)

    return val / (1 << n)

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

