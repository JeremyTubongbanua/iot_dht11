from at_client import AtClient
from at_client.common import AtSign
from at_client.common.keys import AtKey, Metadata
from at_client.util import EncryptionUtil

import RPi.GPIO as GPIO
import dht11

at_sign = "@smoothalligator"
shared_with = "@jeremy_0"
PIN=21 # GPIO=21 == PIN=40

def main():
	at_client = AtClient(AtSign(at_sign), verbose=True)
	iv_nonce = EncryptionUtil.generate_iv_nonce()
	metadata = Metadata(
		ttl=10000,
		ttr=-1,
		iv_nonce=iv_nonce
	)
	at_key = AtKey("ht", at_sign)
	at_key.shared_with = AtSign(shared_with)
	at_key.metadata = metadata
	at_key.set_namespace('dht11')
	GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BCM)
	GPIO.cleanup()

	instance = dht11.DHT11(pin=PIN)

	while True:
	
		result=instance.read()

		print(result.temperature, result.humidity)
	

		if result is None or result.temperature == 0 or result.humidity == 0:
			continue

		to_send=str(result.temperature) +  ',' + str(result.humidity)
		at_client.notify(at_key, to_send)
	

main()
