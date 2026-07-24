The idea of this program is to convert the CSV, from the readings of a ESP32, or similar micro-controller meant to manage sensors, to a excel spreadsheet 
using a easy to understand UI
------------------------------------------------------------------------------------------------------------------------------------------------------------
Short-Term Goals
- Rewrite the front-end, possibly on a different language or using a different library, for better compatibility on multiple Operational Systems
- Ditch the necessity for a interpreter or to bundle said interpreter in the application
- Make a front facing executable
- Modify the length parameter of the spreadsheet to not need to load every vertical cell just in case
- Convert the milliseconds from the micro-controller to a meaningfull unit of measure
------------------------------------------------------------------------------------------------------------------------------------------------------------
Long-Term Goals
- More Detailed stats nad graphs (Possibly when more info is passed from the micro-controller)
