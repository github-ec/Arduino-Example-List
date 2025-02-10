This project aims to support listing and finding the appropriate example *.ino file of the Arduino IDE. It has been coded in Free Pascal using the Lazarus IDE Version 3.6 and was tested with

* Windows 11 (tm) by Microsoft and Arduino IDE 2.3.4
* Kubuntu Linux (Ubuntu 24.10 Codename: oracular) with KDE Plasma and Arduino IDE 1.8.19

**How to create an executable**
* Install Lazarus IDE (see https://www.lazarus-ide.org/)
* Download the repository files to a directory on your computer
* Start Lazarus IDE and open the project ("ArduinoExamples.lpr" or "ArduinoExamples.lpi")
* Compile the project
* Run the executable

**How to use the ArduinoExamples program**

The program provides two pages of a tabbed notebook:

* Treeview
* Parameter

After the first start the paths to the libraries and to the Arduino IDE have to be set and stored to an IniFile.
It is possible to set names and paths for several (up to 8) directory paths:

![image](https://github.com/user-attachments/assets/d12c7d40-64ab-48a6-a2e6-561f5dccff48)

When that has been done switch back to Treeview and press "Read Directories":

![image](https://github.com/user-attachments/assets/4b97769b-3f0d-42f9-91e0-35fd0bcb737a)

If all went well the Treeview should show a number of nodes that can be opened further by clicking on the arrow symbols:

![image](https://github.com/user-attachments/assets/45c0955f-1b39-48db-bbe5-9a368f450aaf)

The final examples can be easily identified by the missing arrow in front. A right click on an example entry opens a popup menu that allows to open the appropriate file (provided that the path to the Arduino IDE is correct):

![image](https://github.com/user-attachments/assets/d6669d18-f4d9-4eec-9e80-8294674e863d)

![image](https://github.com/user-attachments/assets/1783c0f8-ff39-4dd5-8a31-ba4596875eea)

The TreeFilterEdit field enables to filter (case insensitive) the tree:

![image](https://github.com/user-attachments/assets/5072317f-1845-4a66-a7ee-0145cda4d999)

The Search button allows to search the Treeview (case insensitive):

![image](https://github.com/user-attachments/assets/b7d0f253-e8e5-4f7c-9aa1-61c5e825006e)

**Additional Information**
* Linux: The Arduino IDE 1.8.19 uses different places to store libraries. This may be specific to the Linux version  ...
* Windows: Arduino IDE 2.3.4 stores libraries (except the delivered standard libs) in the Sketchbook directory.

  
