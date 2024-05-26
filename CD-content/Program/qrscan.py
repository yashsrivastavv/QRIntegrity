import cv2
import numpy as np
from pyzbar.pyzbar import decode
'''TESTING CODE...NOT IN USE'''
cap = cv2.VideoCapture(0)
# cap = cv2.VideoCapture(0)
cap.set(3, 640)
cap.set(4, 480)

myDataList = [
	"111111"
]

while True:
	success, img = cap.read()
	if not success:
		break
	for barcode in decode(img):
		myData = barcode.data.decode("utf-8")
		print(myData)
	cv2.imshow("Result", img)
	cv2.waitKey(1)