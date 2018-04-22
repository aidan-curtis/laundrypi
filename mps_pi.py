import spidev
import time

spi = spidev.SpiDev()
spi.open(0,0)

spi.max_speed_hz = 5000
spi.mode = 0b00

while True:
	rcv = spi.readbytes(10)
	print rcv
	time.sleep(2)