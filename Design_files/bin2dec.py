# Python3 program to demonstrate above steps
# of binary fractional to decimal conversion

# Function to convert binary fractional
# to decimal

# Python3 program to print 1's and 2's
# complement of a binary number

# Returns '0' for '1' and '1' for '0'
def flip(c):
	return '1' if (c == '0') else '0'

# Print 1's and 2's complement of
# binary number represented by "bin"

def TwosComplement(bin):

	n = len(bin)
	ones = ""
	twos = ""
	
	# for ones complement flip every bit
	for i in range(n):
		ones += flip(bin[i])

	# for two's complement go from right
	# to left in ones complement and if
	# we get 1 make, we make them 0 and
	# keep going left when we get first
	# 0, make that 1 and go out of loop
	ones = list(ones.strip(""))
	twos = list(ones)
	for i in range(n - 1, -1, -1):
	
		if (ones[i] == '1'):
			twos[i] = '0'
		else:		
			twos[i] = '1'
			break

	i -= 1	
	# If No break : all are 1 as in 111 or 11111
	# in such case, add extra 1 at beginning
	if (i == -1):
		twos.insert(0, '1')

	#print("1's complement: ", *ones, sep = "")
	#print("2's complement: ", *twos, sep = "")
	return("".join(twos[1:]))
	#return str(twos)
	
	
# This code is contributed
# by SHUBHAMSINGH10


def binaryToDecimal(binary, length) :
	
	# Fetch the radix point
	point = binary.find('.')

	# Update point if not found
	if (point == -1) :
		point = length

	intDecimal = 0
	fracDecimal = 0
	twos = 1

	# Convert integral part of binary
	# to decimal equivalent
	for i in range(point-1, -1, -1) :
		
		# Subtract '0' to convert
		# character into integer
		intDecimal += ((ord(binary[i]) -
						ord('0')) * twos)
		twos *= 2

	# Convert fractional part of binary
	# to decimal equivalent
	twos = 2
	
	for i in range(point + 1, length):
		
		fracDecimal += ((ord(binary[i]) -
						ord('0')) / twos);
		twos *= 2.0

	# Add both integral and fractional part
	ans = intDecimal + fracDecimal
	
	return ans

# Driver code :
if __name__ == "__main__" :
	n = input("Enter the binary: ")
	l = len(n)
	
	if n[0] == '1':
		dot = n.find(".")
		n = TwosComplement(n)
		#print(n)
		n = n[:dot] + '.' + n[dot:]
		#print(n)
		dec = binaryToDecimal(n,l)
		print("Decimal: ",(dec*-1))
		
	else:
		dec = binaryToDecimal(n,l)
		print("Decimal: ",dec)
			
	
# This code is contributed
# by aishwarya.27

