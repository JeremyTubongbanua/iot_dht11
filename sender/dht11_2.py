import RPi.GPIO as GPIO
import dht11

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.cleanup()

# pin 40 == GPIO 21
PIN=21
instance = dht11.DHT11(pin=PIN)
result=instance.read()

print(result.temperature, result.humidity)
