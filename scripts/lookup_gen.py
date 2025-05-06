"""
CORDIC Lookup Table and Gain Generator, with Qm.n fixed-point output.

Generates:
  - angles = [atan(2**-i) for i in range(n_iter)]
  - K = product_{i=0..n_iter-1} (1/sqrt(1 + 2**(-2*i)))

Optionally quantizes angles into signed Qm.n format within 32 bits.
"""
import math
import argparse
import sys

def generate_cordic_lut(n_iter):
    """
    Generate CORDIC arctan LUT and gain constant K.
    Returns angles in floating‑point and K.
    """
    angles = []
    K = 1.0
    for i in range(n_iter):
        a = math.atan(2.0 ** -i)
        angles.append(a)
        K *= 1.0 / math.sqrt(1.0 + 2.0 ** (-2.0 * i))
    return angles, K

def format_qmn(angles, m, n):
    """
    Convert list of radians into signed Qm.n fixed-point, 32 bits total.

    Layout (bit indices): [31: sign] [30..30-m+1: integer] [30-m..30-m-n+1: fraction]
    Any remaining LSBs (to fill 32 bits) are zeros.
    """
    total_used = 1 + m + n
    if total_used > 32:
        sys.exit(f"Error: 1 (sign) + m ({m}) + n ({n}) = {total_used} bits exceeds 32.")

    shift_left = 32 - total_used
    max_pos = (1 << (m + n)) - 1
    half_range = (1 << (m + n))  # for sign

    result = []
    for a in angles:
        # scale to integer value
        scaled = int(round(a * (1 << n)))
        # clamp to representable range
        if scaled > max_pos:
            scaled = max_pos
        if scaled < -half_range:
            scaled = -half_range
        # two's complement in (m+n+1) bits
        mask = (1 << total_used) - 1
        twos = scaled & mask
        # shift up to fill MSBs with zeros
        word = twos << shift_left
        result.append(word)
    # format as 0xDEADBEEF
    return [f"0x{w:08X}" for w in result]

def main():
    parser = argparse.ArgumentParser(description="Generate CORDIC LUT and gain K.")
    parser.add_argument("-N", "--niter", type=int, default=16,
                        help="Number of CORDIC iterations (default: 16)")
    parser.add_argument("--m",            type=int,
                        help="Number of integer bits in Qm.n (excluding sign)")
    parser.add_argument("--n",            type=int,
                        help="Number of fractional bits in Qm.n")
    args = parser.parse_args()

    angles, K = generate_cordic_lut(args.niter)

    print("# CORDIC Arctan LUT")
    if args.m is None or args.n is None:
        # just print floats
        for i, ang in enumerate(angles):
            print(f"iter {i:2d}: atan(2^-{i}) = {ang:.12f} rad")
    else:
        hex_vals = format_qmn(angles, args.m, args.n)
        for i, h in enumerate(hex_vals):
            print(f"iter {i:2d}: {h}")

    print(f"\n# CORDIC Gain K = {K:.12f}")

if __name__ == "__main__":
    main()
