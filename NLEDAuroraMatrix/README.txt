MIT License

Copyright (c) 2018 Northern Lights Electronic Design, LLC
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 Original Author: Jeffrey Nygaard
 Company: Northern Lights Electronic Design, LLC
 Contact: JNygaard@NLEDShop.com
 Date Updated: December 11, 2018
 Software Version:  1a
 Webpage: www.NLEDShop.com/nledauroramatrix
 Written in Processing v3.4  - www.Processing.org
 
 //============================================================================================================
 
 Supported Devices: 
 
 NLED Pixel Controller Ion
   Max Pixels: 512 for all synchronous chipsets(CLK & DAT), or for asynch(DAT) 469 or 312 pixels, depends on chipset - will try to update in the future
	   WS2813 = 469 pixels,
	   WS2812/B = 312 pixels or use WS2813 protocol for 469 pixels,
	   APA106, PD9823, UCS2903,UCS2904,UCS1903 =  369 pixels
	   WS2801, APA102, AP107, LPD8806 = 512(max) pixels
   No hardware color reordering, use software side color order
   
 NLED Pixel Controller Electron
   Max Pixels: 1024 pixels with all chipsets
   Hardware color ordering for most chipsets, otherwise use software side
   
 Hotkeys:
   Spacebar - Play/pause toggle sequence software preview
   ,(<) is Sequence software preview previous frame
   .(>) is Sequence software preview next frame
   = is aurora command, commands hardware to play the next sequence
  
  
//============================================================================================================
 
 File Notes:
  .aurm is the sequence definition files. They store the file names for the sequences and the sequence variables(speed, playmodes, transitions) - never see these they are contained in the .auroramatrix
  .auroramatrix files are standard ZIP files. They store all the individual sequence files, patch file, and sequence definition file
  .txt(or .fileplay) files are used for both patches(which define the pixel physical layout and order) and the Aurora FilePlay sequence files(which store the actual color data)
  
  File Saving: 
  The application collects the patch file, the Aurora sequence files, creates a sequence definition file and saves it all into a ZIP folder with the extension .auroramatrix
  Once the save file is created the original patch and sequence files can be moved or deleted. All of that is stored together.
  
  File Loading: 
  The app unzips the files to the 'temp' folder in the sketch folder, patch file, sequence definition file, the sequence data files. The temp folder can not
   
//============================================================================================================
 
 Instructions: Videos and additional documentation will be posted as some point
	1. Start software, either through Processing IDE or with the exported applicaiton for your operating system.
	2. Plug in your controller.
	3. Use the drop down in the upper left and select your controller's COM/serial port. Assigned by the operating system. 
	4. Press the connect button. If it successfully connects the status message will update and the button will change to "Disconnect"
	5. Adjust configurations if required - controller's require their settings such as pixel chipset to be set before use.
		5a. Click the "Configurations" button.
		5b. Use the configuration modules to select your required settings.
		5c. Once all the configuration modules are set, press the "Upload Configurations" button to save them to the hardware controller.
		5d. Close the configurations menu.
	6. Add color sequence files or load a aurora matrix save file that contains color sequences and index settings
	
		Loading a Aurora Matrix save file. Extension .auroramatrix - is a ZIP file, rename to ZIP to extract or edit
		a. Press the "Load File" button, navigate to your .auroramatrix save file and open
		b. The softare will fill in the patch file, index, and color sequences.
		c. Adjust the color sequence and index
		
		Adding Color Sequence Files. Extension .txt or .fileplay - created from NLED AllPixMatrix or other software
		a. Start with defining a patch file. Click the "Load Patch" button and select a patch file(.txt). Patch files are created in a separate program.
		b. On the left side is the index, click the "Load" button for slot#1 and select a FilePlay file
		c. Adjust the speed, in miliseconds. IE 33mS is 30FPS. Adjust playmode and transition if applicable.
		d. Continue clicking the "Add sequence" tile in the index and loading FilePlay files.
		
	7. Once all the patch and color sequence files are defined in the index. Press the "Save File" button to save your changes.
	8. The sequences are ready for upload to the controller. Uploading saves everything to the controllers memory. And are available without any computer or data connection.
	9. If applicable set the Global Intensity as a percentage. This pre-calculates new color data values in software before uploading. Otherwise leave at 100%
	10. Press the "Upload Configurations" button to upload and save the color sequences and index to the hardware controller.
	11. Wait several seconds while the upload is in progress. A progress bar will indicate its progress.
	12. If your controller's configurations are correct the color sequence in slot#1 will start playing as soon as the upload completes.
	13. If the pixels are flickering or white, or just random, your chipset may not be correcty selected.
	14. The color sequences are now loaded and ready to use, the controller can be powered off and removed, the software connection is no longer required.
 
 