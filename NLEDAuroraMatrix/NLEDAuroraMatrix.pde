/* //<>//
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
 Date Updated: December 7, 2018
 Software Version:  1a
 Webpage: www.NLEDShop.com/nledauroramatrix
 Written in Processing v3.4  - www.Processing.org
 
 ============================================================================================================
 
 Supported Devices:
 
 More to be added
 
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
   
 ============================================================================================================
 
Changes pre-release to v.1a
  - electron expansion header was missing a listing
  - changed accelerometer movement detection, idle sequence is always slot#1
  - Added software color reordering - RGB to GRB etc
  - optimized some variables
  - Fixed ability to have more pixels loaded in software than device supports. Uploads of larger channel sizes is cropped

============================================================================================================

 Hotkeys:
   Spacebar - Play/pause toggle sequence software preview
   ,(<) is Sequence software preview previous frame
   .(>) is Sequence software preview next frame
   = is aurora command, commands hardware to play the next sequence
   
============================================================================================================
     
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

============================================================================================================

To Do: --------------------------------------------------------------------------------------------


File Notes: --------------------------------------------------------------------------------------------

  .aurm is the sequence definition files. They store the file names for the sequences and the sequence variables(speed, playmodes, transitions) - never see these they are contained in the .auroramatrix
  .auroramatrix files are standard ZIP files. They store all the individual sequence files, patch file, and sequence definition file
  .txt files are used for both patches(which define the pixel physical layout and order) and the Aurora FilePlay sequence files(which store the actual color data) - should have used custom file extensions but a bit late now
  
  File Saving: 
  The application collects the patch file, the Aurora sequence files, creates a sequence definition file and saves it all into a ZIP folder with the extension .auroramatrix
  Once the save file is created the original patch and sequence files can be moved or deleted. All of that is stored together.
  
  File Loading: 
  The app unzips the files to the 'temp' folder in the sketch folder, patch file, sequence definition file, the sequence data files. The temp folder can not
   
 Future Upgrades: --------------------------------------------------------------------------------------------
 
 - live control transmission of matrix previews
 - live painting, draw and fill using the mouse directly to the LED matrix
 - doesn't save intensity value
 
 Done: --------------------------------------------------------------------------------------------

 
 Notes: --------------------------------------------------------------------------------------------
 
 
 Known Issues: --------------------------------------------------------------------------------------------

    java.lang.IllegalStateException: Buffers have not been created - random, when not focused?
    
    software is locking up communication, think it is awaiting a state that it should timeout or over ride if it doesn't finish
      - happens a lot when devices are being swapped around
      - hasn't happened in a while

 */

// IMPORT Libraries
import processing.serial.*;
import processing.net.*; 

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import java.util.zip.ZipInputStream;

//============ Constants ================

//Configuration Input Module constant strings
final String[] cPixelChipsetStrings = {"DEFAULT", "WS2801", "WS2811", "WS2812", "WS2812B", "WS2813", "APA102", "APA107", "APA104", "APA106", "SK6805", "PD9823", "TM1803", "TM1804", "UCS290", "UCS190"};
final String[] cPixelChipsetColorID = {"unknown", "R>G>B", "G>R>B", "G>R>B", "G>R>B", "G>R>B", "B>G>R", "B>G>R", "R>G>B", "R>G>B", "G>R>B", "R>G>B", "G>R>B", "G>R>B", "G>R>B", "G>R>B"};

final String cGlobalColSwapStrV2[] = {"R>G>B", "B>R>G", "G>B>R", "R>B>G", "B>G>R", "G>R>B"};
final String cGlobalColSwapStr[] = {"R>G>B(>W)", "B>R>G", "G>B>R", "R>B>G", "B>G>R", "G>R>B", "G>R>B>W"};
final String cDDBaudstring[] = {"9600", "19200", "38400", "57600", "115200", "230400", "250000", "460800", "500000", "1Mbit"}; //fix these, there is no 250k without custom FTDI driver, but maybe make one for 500k and 1Mb and 250k
final String cDDLEDMstring[] = {"Both", "Stand-Alone", "RX", "Disabled"};
final String cDDPOVModeString[] = {"Normal Mode", "Mode 1mS", "Mode 2mS", "Mode 3mS", "Mode 4mS", "Mode 5mS", "Mode 6mS", "Mode 8mS", "Mode 16mS"};
final String cDDAutoDetectModesT1[] = {"None/Disabled", "Auto-Detect DMX", "Auto-Detect Serial"};
final String cDDAutoDetectModesT2[] = {"None/Disabled", "Auto-Detect DMX"};
final String cDDAutoDetectModesT3[] = {"None/Disabled", "Auto-Detect"};
final String cDDMasterModes8Bit[] = {"None/Slave", "Master Full Pkts", "Master Partial Pkts"};
final String cDDMasterModesMultiBit[] = {"None/Slave", "Master Full Pkts 8-Bit", "Master Full Pkts 16-Bit", "Master Partial Pkts 8-Bit", "Master Partial Pkts 16-Bit"};
final String cDDDisplayModes[] = {"Always On", "Countdown", "Dim", "Countdown+Dim"};
final String cDDAccMeterShutOff[] = {"Disabled", "5 Sec.", "10 Sec.", "20 Sec.", "30 Sec", "40 Sec.", "60 Sec.", "80 Sec."};
final String cDDAccMeterShutOffMode[] = {"Blank", "Play Slot#1"};
final String cDDPowerTimeOut[] = {"Disabled", "5 Min.", "10 Min.", "15 Min."};
final String cDDAccMeterTapMode[] = {"Disabled", "Sensitive", "Normal", "Strong"};
final String cDDPWMFreqA[] = {"31 KHz", "7.8 KHz", "1.95 KHz", "488 Hz"};
final String cDDPWMProfileA[] = {"16-Bit, 244Hz", "12-Bit, 3.9KHz", "12-Bit, 478Hz", "8-Bit, 62.5Khz", "8-Bit, 976Hz"};
final String cDDIRRemote[] = {"Disabled", "Enabled, 19200 baud", "Enabled 250k baud"};
final String cDDStandAloneA[] = {"Hold", "Blank", "Fade Out", "Stand-Alone"};
final String cDDDMXRelstring[] = {"Disabled", "Timeout & Continue", "Timeout & Play Idle"};
final String cDDExpansionHeaderStrings[] = {"No Usage", "NLED Serial Reception", "Aurora Command Protocol", "Receive DMX", "IR Remote", "Sync Master", "Sync Master+IR Remote", "Sync Slave"};
final String cHardwareColorReOrderStrings[] = {"Disabled(RGB)", "Enable Hardware"};
final String cGlediatorOverRideStrs[] = {"Disabled", "Enable Glediator Protocol"};
final int cAccMeterShutOffVals[] = {0, 16, 32, 64, 96, 128, 192, 250};

//Software String constants
final String cNoneStr[] = {"None"};
final String cRevisionIDstr[] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
final String cDDPortBaudstring[] = {"USB/None", "9600", "19200", "38400", "57600", "115200", "230400", "250000", "460800", "500000", "1000000"};

final String cDDSeqPlayModes[] = {"Loop", "One-Shot Next", "One-Shot Start", "One-Shot End", "One-Shot Blank", "One-Shot Idle"};
final String cDDSeqTransistions[] = {"Instant", "Fast Fade In", "Slow Fade In"};

//User notification string constants
final String cConfirmBoxText[] = {"null", "Uploading Configurations will overwrite the current settings. Continue?", "Are you sure you want to remove the sequence?", "Are you sure you want to upload the index & color sequences?"};

final String cNotificationText[] = {
  "none", 
  "FilePlay did not load correctly, but may still work", 
  "Connection Success", 
  "Port Failed to Open", 
  "Define Previous Sequence" //4
};    

//============ Software Constants ================

final int cMaxSequences = 64;
final int cSoftwareMaxFrames = 0xFFFF;  
final int cSoftwareMaxChans = 768;  
final int cSoftwareMaxSequences = 256;

final int cHeaderByteLen = 16;

final int cBufferByteSize = 1024; //think it is just the filename

final int cDefaultSeqSpeed = 33; //for 30FPS

//============ GUI Constants ================

final int cInputModuleOffsetX = 100;
final int cInputModuleOffsetY = 180;
final int cInputModuleAreaWidth = 800;
//final int cModuleAreaHeight = 150;
final int cInputModuleHeight = 100;

final int cSeqModuleHeight = 150;
final int cSeqModuleWidth = 244;
final int cSeqModuleYOffset = 240;
final int cSeqModuleXOffset = 35;

final int cPreviewContentWidth = 750-20; //minus 20 is the margin
final int cPreviewContentHeight = 648-20; 

final int cPreviewXPos = 294;  //+20 for margin
final int cPreviewYPos = 120;  //+20 for margin 

final int cMaxIndexViewed = 3; //sequence index

//=============== Aurora Command ID Constants ==================

final int cmdOpen = 4;
final int cmdHWPV = 99;
final int cmdFullSeqUpload = 100;
final int cmdUploadConfigurations = 101;
final int cmdGammaTableUpload = 102;
final int cmdEnterBootloader = 140;
final int cmdRequestConfigurations = 120;

//============ Global GUI Variables ================

int mouseXS, mouseYS; //scaled mouse values for resizing
float SF = 1; //scale factor for GUI resizing

int OverlayMenuID = 0;
int ConfirmBoxIDNum = 0; //0 is no message, greater than 0 is the ID number
int ShowNotification = 0; //0 is off, 1 and up is used for string pointer

boolean GlobalDDOpen = false;
boolean GlobalDragging = false;
boolean TextFieldActive = false;
boolean NumberInputFieldActive = false;
boolean sEnableMouseOver = true;

String GlobalLabelStore = "";  //used for text fields

String DisplayMessageStr = "Starting"; 

String SelectedFilePath = "";
int FileBrowserAction = 0;

float UploadProgressVar = 0;

//============ Global Configuration & Module Variables ==============

String[] DevStrArray = new String[16];
int ConfigFlags = 0;  
int holdHardwareID = 0;

int RecievedDeviceConfigsMSB = 0;
int RecievedDeviceConfigsLSB = 0;

int modulePosX = 90;
int modulePosY = 380;
int moduleHoldX = 0;
int moduleHoldY = 0;
int moduleHoldSz = 0;

int[] PixelChipsetID  = new int[2];

//============ Global Communication Variables ==============

String portName = "None";

int RXByte1 = -1;    // Incoming serial data
int RXByte2 = 0;
int RXByte3 = 0;
int RXByte4 = 0;
int RXByte5 = 0;

int SendCounter = 0;
int SendCounterB = 0;
int USBpacketCount = 0;

byte[] USBPacket = new byte[64];
int PacketPointer = 0;

int ExpectedRecieved = 0;
int ReceiveCounter = 0;
int cmdFlags = 0;
int cmdByte = 4; //open connection default
int cmdData[] = {0, 0, 0, 0};

int CMDTimeOutVal = 3000; //time in miliseconds default

boolean CmdIssued = false;
boolean devConnected = false;
boolean RecievedOpenAck = false;
boolean SentCmdRequest = false;
boolean SentOpenRequest = false;
boolean SentConfigRequest = false;
boolean LiveControlEnabled = false;
boolean UploadInProgress = false;
boolean WaitForAckFlag = false;  
boolean TerminateUpload = false;
boolean ConfigUploadSent = false;

int CommunicationMode = 0; //0 = serial port, 1 = TCP Client
int ProgramBaudRate = 19200; 

int ColorOrderCounter = 0;

//============ Global Application Variables ==============

int displayPixSize = 10; //start at default, recalculated to new size when patch file is loaded
short[] PatchCoordX = new short[1];
short[] PatchCoordY = new short[1];

int SelectedSlot = 0;
int IndexedSequences = 1;
int IndexedMemoryUsage = 0;
String IndexedMemoryUsageStr = "";

int PlayBackFrameNum = 0; //used for matrix preview

int UtilizedChannels = 0; //number of channels to upload, either device.Channels or matrix.patchedChannels whichever is smaller

//====================================== General Objects ==============================================

//Data Objects
GUIObj gui; //gui object, holds colors and such
SoftwareObj software;
DeviceObj device;
MatrixObj matrix;
SequenceObj[] sequence;

zipper FileZipper;

//hardware objects
Serial serialPort;
Client TCPClient; 

//GUI element objects
guiDropDown DropDownPointer;
guiSliderBar SliderPointer;
guiTextField textFieldPtr;
guiNumberInputField numberInputFieldPtr;

guiOverlayMenu[] OverlayMenus;

SpecHWModules[] InputModule;  //Configuration Modules

//============ GUI Objects ================

guiButton menuCloseButton, menuUploadConfigurations, menuRequestConfigurations;
guiButton ConfirmButtonYes, ConfirmButtonNo, UploadProgressCancel;

guiButton comConnectButton, comOpenConfigurationsMenu, comDefaultConfigurations, comUploadSequences, comControlCommands;
guiButton comPlayPauseButton, comLoadPatchFile;

guiDropDown comSerialPortDD, comSerialBaudRateDD, comHardwareColorReOrderDD;
guiButton comSaveSequenceFile, comLoadSequenceFile;

guiNumberInputField comGlobalIntensityField;

guiNumberInputField[] SequenceSpeedField;

guiSliderBar indexScrollBar;

guiButton[] SequenceLoadButtons, SequenceRemoveButtons;
guiDropDown[] SequencePlayModeDD, SequenceTransitionDD;

//============ Module GUI Objects ================

guiDropDown DMXModesDD, PixelChipsetDD, AutoDetectDD, MasterModeDD, HardwareColSwapDD;
guiDropDown BaudRateDD, LEDIndicatorModeADD, LEDIndicatorModeBDD;
guiDropDown StandAloneDD, DisplayModeDD, DisplayModeBDD, ShapeOptionsDD;
guiDropDown AccMeterAutoDetectDD, AccMeterAutoDetectModeDD, AccMeterTapDD, PowerDownTimeOutDD;
guiDropDown PWMProfileADD, IRRemoteModeDD, StandAloneADD, PWMFreqADD, DMXAutoReleaseDD;
guiDropDown HardwareColorReOrderDD, GlediatorOverrideDD;

//added
guiDropDown StandardExpansionHeaderDD, AutoReleaseLegacyDD, ReceptionModeLegacyDD;

guiTextField[] TextFields;

guiButton[] HardwareButtons;
guiCheckBox[] HardwareCheckBox;

//================================== ArrayList for GUI MouseOver Elements ====================================================

ArrayList<guiButton> ButtonList; //makes list to make it easier to mouseover
guiButton PointerButton;

ArrayList<guiTextField> TextFieldList;
guiTextField TextFieldListPointer;

ArrayList<guiCheckBox> CheckBoxList;
guiCheckBox CheckBoxListPointer;

ArrayList<guiDropDown> DropDownList; //makes list to make it easier to mouseover
int DropDownMouseOverID = 0;

ArrayList<guiNumberInputField> NumberInputList; //makes list to make it easier to mouseover

//================================== Graphic Objects ====================================================

PFont font;

PImage imgSliderBarHoriz, imgMixerHandleHoriz, imgMixerHandleVert, imgSliderBarVert, imgColorSelector;

//========================= END OBJECT DECLARTION ==============================

void setup() 
{
  // Initial window size
  size(1024, 768); 
  surface.setResizable(true);   // Needed for resizing the window to the sender size
  surface.setLocation(100, 100);
  colorMode(RGB);
  frameRate(30);

  font = createFont("Arial", 48);
  textFont(font);

  PImage titlebaricon = loadImage("favicon.gif");
  surface.setIcon(titlebaricon);

  //====================== Init Images ======================

  imgMixerHandleHoriz = loadImage("mixerhandle-horiz.png");  
  imgSliderBarHoriz = loadImage("sliderbg-horiz.png");
  imgSliderBarVert = loadImage("sliderbg-vert.png");
  imgMixerHandleVert = loadImage("mixerhandle-vert.png");  

  //==================== Init ArrayList for objects ======================

  ButtonList = new ArrayList<guiButton>();  
  DropDownList = new ArrayList<guiDropDown>();  
  TextFieldList = new ArrayList<guiTextField>();  
  CheckBoxList = new ArrayList<guiCheckBox>();  
  NumberInputList = new ArrayList<guiNumberInputField>();  

  //====================== Init General Objects ==========================

  gui = new GUIObj(); //init graphic user interface from XML file
  software = new SoftwareObj();
  device = new DeviceObj("None");
  matrix = new MatrixObj();
  sequence = new SequenceObj[64];

  FileZipper = new zipper(); 
  FileZipper.localTempFolder = sketchPath()+File.separator+"temp"+File.separator; //static for now, update from function or is null
  
  BuildCOMDropDown();
  comSerialBaudRateDD = new guiDropDown(cDDPortBaudstring, 0, 10, 45, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");

  comHardwareColorReOrderDD = new guiDropDown(cGlobalColSwapStrV2, 0, 165, 165, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");

  comSaveSequenceFile = new guiButton("Save File", 920, 30, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  comLoadSequenceFile = new guiButton("Load File", 920, 65, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  ConfirmButtonYes = new guiButton("Yes", 435, 410, 60, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  ConfirmButtonNo = new guiButton("No", 525, 410, 60, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  UploadProgressCancel = new guiButton("Cancel", 340, 340, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  menuUploadConfigurations = new guiButton("Upload Configurations", 340, 340, 160, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  menuRequestConfigurations = new guiButton("Request Configurations", 340, 340, 160, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  menuCloseButton = new guiButton("Close", 325, 325, 60, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  comConnectButton = new guiButton("Connect", 140, 10, 90, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  comOpenConfigurationsMenu  = new guiButton("Configurations", 580, 5, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  comUploadSequences = new guiButton("Upload Sequences", 5, 130, 140, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  comControlCommands = new guiButton("Control Commands", 740, 5, 150, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
  comPlayPauseButton = new guiButton("Play", 850, 40, 40, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);
  comLoadPatchFile = new guiButton("Load Patch", 140, 45, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

  indexScrollBar = new guiSliderBar(0, cSeqModuleYOffset, 24, height-cSeqModuleYOffset, 0, 0, 63, color(255), gui.buttonHighlightColor, color(255), color(0), false, true, true, false, "sliderHandlerIndex");

  comGlobalIntensityField = new guiNumberInputField(155, 130 , 25, 50, 1, 100, 2, "genericNumberInputField");
  comGlobalIntensityField.setValue(100);

  sequence = new SequenceObj[cMaxSequences];
  SequenceLoadButtons = new guiButton[5];
  SequenceRemoveButtons = new guiButton[5];
  SequenceSpeedField = new guiNumberInputField[5];
  SequencePlayModeDD = new guiDropDown[5];
  SequenceTransitionDD = new guiDropDown[5];

  //sequence[1] = new SequenceObj(1);
  for (int i = 0; i < cMaxSequences; i++)
  {
    sequence[i] = new SequenceObj(i);
  }

  //use the same buttons regardless of index scroll value
  for (int i = 0; i < cMaxIndexViewed; i++) //5 is how many indexed sequences can be viewed
  {
    SequenceLoadButtons[i] = new guiButton("Load", 90, cSeqModuleYOffset+(i*cSeqModuleHeight)+10, 60, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);
    SequenceRemoveButtons[i] = new guiButton("Remove", 200, cSeqModuleYOffset+(i*cSeqModuleHeight)+10, 60, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, false, true);

    SequenceSpeedField[i] = new guiNumberInputField(130, cSeqModuleYOffset+(i*cSeqModuleHeight)+85, 25, 50, 1, 65535, 1, "SequenceSpeedField");
    SequenceSpeedField[i].setValue(cDefaultSeqSpeed); //set to default FPS in mS

    SequencePlayModeDD[i]  = new guiDropDown(cDDSeqPlayModes, 0, 35, cSeqModuleYOffset+(i*cSeqModuleHeight)+115, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "SequencePlayModeDDFunc");
    SequenceTransitionDD[i]  = new guiDropDown(cDDSeqTransistions, 0, 165, cSeqModuleYOffset+(i*cSeqModuleHeight)+115, 105, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "SequenceTransitionDDFunc");
  }

  //=====================================================================================================================================

  OverlayMenus = new guiOverlayMenu[3];
  OverlayMenus[0] = new guiOverlayMenu(0, 0, 0, 0, 0); //null Menu
  OverlayMenus[1] = new guiOverlayMenu(1, 10, 40, 900, 550); //Configurations Menu
  OverlayMenus[2] = new guiOverlayMenu(1, 10, 40, 780, 550); //Stand-alone commands menu

  //====================== Start GUI objects Definition ==========================

  AccMeterAutoDetectDD = new guiDropDown(cDDAccMeterShutOff, 0, 0, 0, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  AccMeterAutoDetectModeDD = new guiDropDown(cDDAccMeterShutOffMode, 0, 0, 0, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  
  AccMeterTapDD  = new guiDropDown(cDDAccMeterTapMode, 0, 0, 0, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  LEDIndicatorModeADD = new guiDropDown(cDDLEDMstring, 0, 420, 180, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  LEDIndicatorModeBDD = new guiDropDown(cDDLEDMstring, 0, 420, 180, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  DMXModesDD = new guiDropDown(cNoneStr, 0, 0, 0, 180, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  BaudRateDD = new guiDropDown(cDDBaudstring, 0, 0, 0, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  DisplayModeDD = new guiDropDown(cDDDisplayModes, 0, 0, 0, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");    
  DisplayModeBDD = new guiDropDown(cDDDisplayModes, 0, 0, 0, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");    
  MasterModeDD = new guiDropDown(cDDMasterModes8Bit, 0,0, 0, 140, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  AutoDetectDD = new guiDropDown(cDDAutoDetectModesT1, 0, 0, 0, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  HardwareColSwapDD = new guiDropDown(cGlobalColSwapStr, 0, 0, 0, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  PixelChipsetDD = new guiDropDown(cNoneStr, 0, 0, 0, 220, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "ChipsetDDFunc"); 
  PowerDownTimeOutDD = new guiDropDown(cDDPowerTimeOut, 0, 405, 300, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  PWMProfileADD = new guiDropDown(cDDPWMProfileA, 0, 405, 300, 140, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  IRRemoteModeDD = new guiDropDown(cDDIRRemote, 0, 405, 300, 140, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  PWMFreqADD = new guiDropDown(cDDPWMFreqA, 0, 5, 160, 100, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");   
  StandAloneADD = new guiDropDown(cDDStandAloneA, 0, 5, 160, 110, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");  
  //StandAloneDD = new guiDropDown(cColorSwapStr, cColorSwapStr.length, 0, 215, 60, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  DMXAutoReleaseDD = new guiDropDown(cDDDMXRelstring, 0, 0, 0, 150, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");

  //New Aurora Matrix Modules
  StandardExpansionHeaderDD =  new guiDropDown(cDDExpansionHeaderStrings, 0, 0, 0, 190, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  HardwareColorReOrderDD =  new guiDropDown(cHardwareColorReOrderStrings, 1, 0, 0, 150, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  
  GlediatorOverrideDD =  new guiDropDown(cGlediatorOverRideStrs, 0, 0, 0, 180, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");
  
  //=====================================================================================================================================

  TextFields = new guiTextField[15];

  //TextFields[0] = new TextField("Enter#", 35, 510, 50, 25, color(255), color(200, 40, 40), 1, 0, 255, true, false, "txtHandleSlideValue"); //Slide Value
  //don't have to do this TextFields[0].Status = 1; //start greyed out
  TextFields[1] = new guiTextField("Enter#", 225, 470, 50, 20, color(255), color(200, 40, 40), 1, 0, 100, true, false, "txtHandleGenericNumber"); //whats this for now? 
  TextFields[2] = new guiTextField("1", 120, 195, 80, 20, color(255), color(200, 40, 40), 1, 1, 512, true, false, "txtHandleGenericNumber"); //DMX Adr Config
  TextFields[3] = new guiTextField("5", 120, 195, 80, 20, color(255), color(200, 40, 40), 1, 5, 32, true, false, "txtHandleGenericNumber");  // CONVERTED - End-Of-Frame Timer
  TextFields[4] = new guiTextField("170", 120, 195, 80, 20, color(255), color(200, 40, 40), 1, 1, 170, true, false, "txtHandleGenericNumber");  // CONVERTED - Pixel Amount
  TextFields[13] = new guiTextField("1", 20, 265, 25, 25, color(255), color(200, 40, 40), 1, 1, 32, true, false, "txtHandleGenericNumber");  //Stand-Alone Module ID field

  textFieldPtr =  TextFields[1]; //default it so it doesn't NullPointerException

  //=====================================================================================================================================

  HardwareButtons = new guiButton[6];
  HardwareButtons[0] = new guiButton("Enabled", 125, 470, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);
  HardwareButtons[1] = new guiButton("Enabled", 300, 470, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);
  HardwareButtons[2] = new guiButton("Enabled", 300, 470, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);
  HardwareButtons[3] = new guiButton("Enabled", 255, 330, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);
  HardwareButtons[4] = new guiButton("Enabled", 300, 470, 80, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, true, false, true);  

  HardwareCheckBox = new guiCheckBox[4];
  HardwareCheckBox[0] = new guiCheckBox(255, 285, 20, color(255), color(0), color(0), false, "");
  HardwareCheckBox[1] = new guiCheckBox(255, 285, 20, color(255), color(0), color(0), false, "");

  //added
  HardwareCheckBox[2] = new guiCheckBox(255, 285, 20, color(255), color(0), color(0), true, ""); //enable activity LED
  HardwareCheckBox[3] = new guiCheckBox(255, 285, 20, color(255), color(0), color(0), false, ""); //enable serial color swap - pixmicro

  //====================== Start Module Definition ==========================

  InputModule = new SpecHWModules[37];
  InputModule[0] = new SpecHWModules(0, "Serial RS-485 Enable:\n(Disable for TTL Serial)", 0, 0, 140, "fRS485Enable", "BYTE", 0);
  InputModule[1] = new SpecHWModules(1, "Second Activity\nLED Mode:", 0, 0, 130,  "fLEDModeMSBb,fLEDModeLSBb", "BYTE", 0);
  InputModule[2] = new SpecHWModules(2, "Select Correct Color Order For Chipset:", 0, 0, 120,  "CONFIG", "bGlobalColorShift", 240);
  InputModule[3] = new SpecHWModules(3, "Select The Pixel Chipset:\n\n\n\nRecommended Color: varies / R>G>B", 0, 0, 240,  "CONFIG", "bPixelChipset", 250);
  InputModule[4] = new SpecHWModules(4, "Enable Serial Reception Instead of DMX reception. Auto-Detect is disabled during serial reception.", 0, 0, 200,  "CONFIG", "BYTE", 0);
  InputModule[5] = new SpecHWModules(5, "DMX Address:\n(Enter Number)\n\n\n(1-512)", 0, 0, 120,  "CONFIG", "bDMXAdrMSB,bDMXAdrLSB", 0);
  InputModule[6] = new SpecHWModules(6, "DMX Reception\nMode - ID Number: "+DMXModesDD.selStr, 0, 0, 190,  "CONFIG", "bDMXModeID", 190); 
  InputModule[7] = new SpecHWModules(7, "DMX Master Mode:\n(Not all listed options are valid)", 0, 0, 160, "fMasterEnable,fMasterFullPkts,fMaster16Bit", "BYTE", 190); 
  InputModule[8] = new SpecHWModules(8, "Serial Baud Rate:\nID Number: "+BaudRateDD.selStr, 0, 0, 120, "f8or16Bit", "bBaudRateID", 200); 
  InputModule[9] = new SpecHWModules(9, "Activity\nLED Mode:", 0, 0, 120,  "fActivtyLEDMSBa,fActivtyLEDLSBa", "BYTE", 0); 
  InputModule[10] = new SpecHWModules(10, "External\nLED Display Mode:", 0, 0, 140,  "fDisModeMSBa,fDisModeLSBa", "BYTE", 190); 
  InputModule[11] = new SpecHWModules(11, "Auto-Detect Data Control Reception:", 0, 0, 140,  "fAutoDetectID,fAutoDetect", "BYTE", 180); 
  InputModule[12] = new SpecHWModules(12, "Enable Gamma\nCorrection:\n(See Connection tab)", 0, 0, 140,  "fGammaCorrectionEnabled", "CONFIG", 0); 
  InputModule[13] = new SpecHWModules(13, "Accelerometer Movement Detection:", 0, 0, 140,  "fAccMeterAutoShutOff,fAccMeterAutoShutOffMode", "bAccmeterTimeoutVal", 210); 
  InputModule[14] = new SpecHWModules(14, "Enable Accelerometer Speed Adjustment", 0, 0, 140,  "fAccMeterMovement", "BYTE", 0); 
  InputModule[15] = new SpecHWModules(15, "Enable Accelerometer Double Tap Button Press", 0, 0, 140,  "fAccMeterDoubleTap", "bAccmeterDoubleTapVal", 200); 
  InputModule[16] = new SpecHWModules(16, "Power Down\nTime Out", 0, 0, 140,  "fTimeOutEnabledMSB,fTimeOutEnabledLSB", "BYTE", 0); 
  InputModule[17] = new SpecHWModules(17, "Pixel Data Packet Cloning:\n(0 is Disabled)", 0, 0, 120,  "DELETE", "DELETE", 0); 
  InputModule[18] = new SpecHWModules(18, "Sequence Fade Transition:\n(0 is Disabled)", 0, 0, 120,  "DELETE", "DELETE", 0); 
  InputModule[19] = new SpecHWModules(19, "Dual Communication Mode (Serial\n/WiFi/Bluetooth)", 0, 0, 120,  "fDualModeCom", "BYTE", 0); 
  InputModule[20] = new SpecHWModules(20, "PWM Frequency:", 0, 0, 120,  "BIT", "bPWMModeLegacyA", 180); 
  InputModule[21] = new SpecHWModules(21, "Stand-Alone Mode\n& Signal Loss Mode:", 0, 0, 160,  "CONFIG", "bStandaloneLegacyA", 160);
  InputModule[22] = new SpecHWModules(22, "PWM Profile\nResolution & Frequency:", 0, 0, 160,  "CONFIG", "bPWMMode", 160);
  InputModule[23] = new SpecHWModules(23, "Enable I.R. Remote Control:\n(Addon Card)", 0, 0, 160,  "fIRCardEnable,fIRCardEnableSpeed", "BYTE", 160);

  //added for configuration software  
  InputModule[24] = new SpecHWModules(24, "DMX Pixel Amount:\n(Enter Number)\n\n\n(1-170)", 0, 0, 120,  "CONFIG", "bUserPixelAmountMSB,bUserPixelAmountLSB", 0); //textfield
  InputModule[25] = new SpecHWModules(25, "Enable Activity LED:", 0, 0, 120,  "fActivityLEDEnable", "BYTE", 0); //checkbox
  InputModule[26] = new SpecHWModules(26, "DMX Decoder Mode:", 0, 0, 160,  "fDMXDecoderModeFull,fDMXDecoderModeEnable", "BYTE", 0); //Drop down
  InputModule[27] = new SpecHWModules(27, "Enable Serial Color Swap:", 0, 0, 120,  "fEnableSerialColorSwap", "BYTE", 0); //checkbox
  InputModule[28] = new SpecHWModules(28, "Select Color Order For Chipset:", 0, 0, 120,  "fColorOrderGRB,fColorOrderGRBW,fColorOrderBGR,fColorOrderBRG", "BYTE", 210); //drop down
  InputModule[29] = new SpecHWModules(29, "End-Of-Frame Timer:\n(in miliseconds):", 0, 0, 120,  "CONFIG", "bUserTimerValue", 0); //textfield
  InputModule[30] = new SpecHWModules(30, "Serial Baud Rate:\nID Number: "+BaudRateDD.selStr, 0, 0, 120,  "CONFIG", "bBaudRateIDMiniV4", 200); //Drop down

  //out of order vs NLED Aurora
  InputModule[31] = new SpecHWModules(31, "DMX Timeout\n Release:", 0, 0, 170,  "fDMXAutoRelease,fDMXReleaseIdle", "BYTE", 100);

  //new legacy modules
  InputModule[32] = new SpecHWModules(32, "Signal Loss Detection\n(Runs Signal Loss Action):", 0, 0, 140,  "AutoDetectFlag", "BYTE", 100);
  InputModule[33] = new SpecHWModules(33, "Reception Mode:", 0, 0, 120,  "SerialOrDMX", "BYTE", 100);  

  //New Aurora Matrix Modules
  InputModule[34] = new SpecHWModules(34, "Enable Hardware Color Order:\n(Disabled uses RGB)", 0, 0, 170,  "fEnableColorReOrder", "BYTE", 240);  
  InputModule[35] = new SpecHWModules(35, "Expansion Header Mode:\n(May require additional hardware)\n(See Device Datasheet For Details)", 0, 0, 210,  "BIT", "bExpansionHeaderMode", 230);  
  InputModule[36] = new SpecHWModules(36, "Glediator Protocol Override:\n(TTL serial or USB Live Control)\n(Requires power cycle)", 0, 0, 200,  "fGlediatorOverRide", "BYTE", 220);  
  

//------------------------- Final Initializations -------------------------

  SelectedSlot = 0; //reset
  sequence[SelectedSlot].selected = true;

  //Set Default Message
  DisplayMessageStr = "Software Ready"; //rather than call show notificaiton...
  
  device.MaxFramesGlobal = 0xFFFF; //set to max for aurora matrix - that is 36.4 minutes at 30FPS per sequence
  
  //------------------------- Debug setup -------------------------

  //LoadSequencesFile(sketchPath()+File.separator+"mytest.auroramatrix");

} //end setup()

//======================================================================================================

void BuildCOMDropDown()
{
  //store and reselect value, say COM 6, and COM4 is added teh selStr is wrong, find the proper value again

  if (devConnected == false) ShowNotification(0);

  comSerialPortDD = new guiDropDown(serialPort.list(), 0, 10, 10, 120, 25, gui.buttonColor, gui.buttonHighlightColor, gui.textColor, false, "genericDDCallBack");

  //shorten serial name string if too long
  for (int i=0; i != Serial.list().length; i++)
  {
    if (comSerialPortDD.labels[i].length() > 10) 
    {
      comSerialPortDD.labels[i] = comSerialPortDD.labels[i].substring(comSerialPortDD.labels[i].length()-10, comSerialPortDD.labels[i].length());
    }
  } //end for()
} //end func

//======================================================================================================
