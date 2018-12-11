
//===================================================================================================  

void fileSelected(File selection) 
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    SelectedFilePath = selection.getAbsolutePath();  

    switch(FileBrowserAction)  
    {
    case 0: //null

      break;
    case 1: //load sequence file
      if (SelectedFilePath.indexOf(".auroramatrix") > 0)
      {
        LoadSequencesFile(SelectedFilePath);
      } else
      {
        ShowNotification(13);
        println("Not a correct aurora matrix sequences file");
      }
      break;
    case 2: //save sequence file
      //If overwriting a save file, need to strip off the extension so it can be added back on without duplication
      if (SelectedFilePath.contains("."))
      {
        //println("RAN "+SelectedFilePath.substring(0, SelectedFilePath.lastIndexOf('.')));
        SelectedFilePath = SelectedFilePath.substring(0, SelectedFilePath.lastIndexOf('.'));
      }
      SaveSequencesFile(SelectedFilePath); //now save with the edited file path
      break;
    case 3: //load File Play
      //reset GUI and preview variables
      comPlayPauseButton.selected = false;
      PlayBackFrameNum = 0;
      //now load sequence into object
      sequence[SelectedSlot].loadSequence(SelectedFilePath);
      DisplayMessageStr = "Loaded FilePlay file";
      break; 
    case 4: //load patch file
      //reset a variables
      comPlayPauseButton.selected = false;
      PlayBackFrameNum = 0;

      DisplayMessageStr = "Loaded Patch File";
      matrix.setPatchFile(SelectedFilePath);
      break;
    }//end switch
  }//end else
}//end func

//===================================================================================================  

void LoadFilePlayModeFile(String passedFileName, int passedSlot)
{
  println("LoadFilePlayModeFile() with "+passedFileName);  

  int i = 0;
  int q = 0;
  //Loads text file with lines as frames, comma delimiated entries
  try
  {  
    String[] lines = loadStrings(passedFileName); 
    String[] WorkString = new String[cSoftwareMaxChans];  
    //println(lines.length+"    "+lines[0]);
    WorkString = split(lines[0], ',');  //updates WorkString.length to move to DataSize

    if (lines.length > device.MaxFramesGlobal) println("FilePlay file too large");
    else {  
      //This latches the new File Play channel amount to the sequence

      //Update Sequence Frame Amount
      sequence[passedSlot].totalFrames = (lines.length);
      sequence[passedSlot].dataFrames = new int[sequence[passedSlot].totalFrames][matrix.patchedChannels];

      println("Loading file play, length: "+lines.length+" using Datasize: "+matrix.patchedChannels);  

      for (q = 0; q < lines.length; q++)  
      {    
        WorkString = split(lines[q], ',');

        for (i = 0; i < matrix.patchedChannels; i++)  //already calced Datasize, prevents over runs
        {  
          WorkString[i] = trim(WorkString[i]);//removes any whitespace

          if (WorkString[i].equals("") == false)
          {
            sequence[passedSlot].dataFrames[q][i] = int(WorkString[i]);
          }
        } //end i for()
      } //end q for()
    } //end else
  }
  catch(Exception e)
  {
    ShowNotification(1); 
    println(i+"   "+q);
    println("File Play file failed to load");
    return;
  }   

  println("File Play file loaded correctly");
} //end func

//===================================================================================================

void LoadDeviceFile()
{
  //Called when device responds to a Connection Request
  //Loads a TXT file with the device specific defines and variables, loads into the device object

  if (device.HardwareID == 0)
  {
    //Null
    device.Name = "No Device";
    return;
  }

  String BuildString = "devices"+File.separator+""+device.HardwareID+"-nled-contr-revs.txt";   //loads file with current firmware rev info

  String[] lines = loadStrings(BuildString); 
  String[] WorkString = new String[30]; //may need to up this  

  BuildString = "";  

  for (int i = 0; i != lines.length; i++)
  {
    WorkString = split(lines[i], '\t');
    println(int(WorkString[0])+" : "+int(WorkString[1]));    

    if (int(WorkString[0]) == device.FirmwareVersion)//version
    {

      if (int(WorkString[1]) < device.FirmwareRevision && i == 0)//version
      {
        println("Revison higher than local "+device.FirmwareRevision);
        BuildString = "devices"+File.separator+""+device.HardwareID+"-"+int(WorkString[0])+"-"+int(WorkString[1])+"-nled-contr.txt";
        break;
      } //end [1] if

      if (int(WorkString[1]) == device.FirmwareRevision)//version
      {
        println("REVISION FOUND with "+i);
        BuildString = "devices"+File.separator+""+device.HardwareID+"-"+int(WorkString[0])+"-"+int(WorkString[1])+"-nled-contr.txt";
        break;
      } //end [1] if
    } //end [0] if
  }//end for()

  //detects if a revID is lower than what is found, use the highest
  if (BuildString.equals(""))
  {
    println("Device File For V. & Rev. Not Found - Using Most Recent Version");  
    lines = loadStrings("devices"+File.separator+""+device.HardwareID+"-nled-contr-revs.txt"); 
    WorkString = split(lines[0], '\t');
    BuildString = "devices"+File.separator+""+device.HardwareID+"-"+int(WorkString[0])+"-"+int(WorkString[1])+"-nled-contr.txt";
  }

  println("LoadDeviceFile() - "+BuildString);  

  lines = loadStrings(BuildString); 
  int LinePointer = 1;

  //WorkString[0] is HardwareID, already checked....
  WorkString = split(lines[LinePointer++], '\t');
  device.Name = WorkString[1]; //String Name

  WorkString = split(lines[LinePointer++], '\t');
  device.WebpageURL = WorkString[1];    //String URL


  WorkString = split(lines[LinePointer++], '\t');
  if (device.FirmwareVersion < int(WorkString[1]))
  {
    println("FIRMWARE OUTDATED "+int(WorkString[1])+" vs "+device.FirmwareVersion);
    if (devConnected == true) //if no device is connected don't show the message
    {  
      //  ConfirmBoxIDNum = 8;
    }
  }

  WorkString = split(lines[LinePointer++], '\t');
  if (device.FirmwareRevision < int(WorkString[1]))
  {
    println("FIRMWARE REVISION OUTDATED "+int(WorkString[1])+" vs "+device.FirmwareRevision);
    if (devConnected == true) //if no device is connected don't show the message
    {
      // ConfirmBoxIDNum = 8;
    }
  }  

  //device.HardwareVersion = int(WorkString[1]);
  LinePointer++;  //for hardwareversion which is not read

  WorkString = split(lines[LinePointer++], '\t');
  device.Channels = int(WorkString[1]);   

  WorkString = split(lines[LinePointer++], '\t');
  device.LockChannelAmt = boolean(WorkString[1]);   

  WorkString = split(lines[LinePointer++], '\t');
  device.DataSpace = int(WorkString[1]);   

  WorkString = split(lines[LinePointer++], '\t');
  device.IndexBlockSize = int(WorkString[1]);
  try {   
    device.HPVBlockSize = int(WorkString[2]);   
    device.SeqMemoryBlockSize = int(WorkString[3]);
  }
  catch(Exception e) 
  {
    println("Error loading block sizes, using single value");
    device.CurrentBlockSize  = device.IndexBlockSize;
    device.HPVBlockSize = device.CurrentBlockSize;   
    device.SeqMemoryBlockSize = device.CurrentBlockSize;
  }

  WorkString = split(lines[LinePointer++], '\t');
  device.EraseBlockSize = int(WorkString[1]);  

  WorkString = split(lines[LinePointer++], '\t');
  device.HWPVSpace = int(WorkString[1]);    

  WorkString = split(lines[LinePointer++], '\t');
  device.MaxIndexedSequences = int(WorkString[1]);  

  WorkString = split(lines[LinePointer++], '\t');
  device.IndexMemoryModel = int(WorkString[1]);      

  WorkString = split(lines[LinePointer++], '\t');
  device.FillUpperData = boolean(WorkString[1]); 

  WorkString = split(lines[LinePointer++], '\t');
  device.Bit16Processor = boolean(WorkString[1]);    

  WorkString = split(lines[LinePointer++], '\t');
  device.Bit16Mode = boolean(WorkString[1]);    

  WorkString = split(lines[LinePointer++], '\t');
  device.BasicVersion = int(WorkString[1]);      

  WorkString = split(lines[LinePointer++], '\t');
  device.LinkedSupport = boolean(WorkString[1]);   

  WorkString = split(lines[LinePointer++], '\t');
  device.GammaCorrection = int(WorkString[1]);  //0=none, 1=8-bit gamma table, 2=16-bit calculation

  WorkString = split(lines[LinePointer++], '\t');
  device.AccelerometerMode = int(WorkString[1]);

  WorkString = split(lines[LinePointer++], '\t');
  device.MaxSpeed = int(WorkString[1]);    

  WorkString = split(lines[LinePointer++], '\t');
  device.MaxFrames = int(WorkString[1]);     //Max Frames for sequences that use DataFrameVar[] on device
  device.MaxFramesGlobal = int(WorkString[2]);  //max frames for POVs currently and anything that uses GlobalFrameVar

  WorkString = split(lines[LinePointer++], '\t');
  device.ConfigFlagsStr = WorkString[1];    

  WorkString = split(lines[LinePointer++], '\t');
  device.ConfigBytesStr = WorkString[1];    

  WorkString = split(lines[LinePointer++], '\t');
  device.DMXModeLabels = new String[16];
  device.DMXModeLabels = split(WorkString[1], ',');

  device.DMXModeAmt = device.DMXModeLabels.length;     

  //Init GUI Elements
  DMXModesDD.labels = device.DMXModeLabels;   //drop down
  DMXModesDD.numStrs = device.DMXModeAmt;   //drop down

  //Pixel Type Modes if applicable
  WorkString = split(lines[LinePointer++], '\t');
  device.ListedChipsets = int( WorkString[1]);   

  if (device.ListedChipsets > 0)
  {  
    String[] tempPixLables = new String[16];

    tempPixLables = new String[device.ListedChipsets]; //use same array as DMX  
    PixelChipsetID = new int[device.ListedChipsets];

    //pixel Type Compatibility
    for (int i = LinePointer; i != (LinePointer+device.ListedChipsets); i++)
    {
      WorkString = split(lines[i], '\t');
      tempPixLables[i-LinePointer] = WorkString[1];
      PixelChipsetID[i-LinePointer] = int(WorkString[2]);
    }

    PixelChipsetDD.labels = tempPixLables;
    PixelChipsetDD.numStrs = device.ListedChipsets;
  }  //end if()

  // =================   END DATA LOAD  =========================================================

  //set Memory/DataSpace label
  if (device.DataSpace > 1000000) device.MemorySpaceString = nf((((float)device.DataSpace/1048576)), 1, 2)+"MB";
  else device.MemorySpaceString = nf((((float)device.DataSpace/1024)), 1, 2)+"KB";  

  println("Device File Successfully Loaded - Starting Configuration Modules");

  //================  init Hardware Usage Modules  ============================================

  modulePosX = cInputModuleOffsetX; //constants
  modulePosY = cInputModuleOffsetY;

  moduleHoldX = 0;
  moduleHoldY = 0;
  moduleHoldSz = 0;

  for (int i = 0; i != InputModule.length; i++) InputModule[i].Enabled = false; //reset all modules to disabled

  ConfigFlags = 0; //reset flags here.....
  DevStrArray = split(device.ConfigFlagsStr, ',');
  String[] ModuleString = new String[16];  //reset
  String[] ByteStrArray = new String[16];
  ByteStrArray = split(device.ConfigBytesStr, ',');  
  //Now single delimenated string is an array, the pointer is the bit number in ConfigFlags  

  //First handle prioritized tiles ====================================================================================

  //z counts from high to low, and checks for tiles that are not yet placed and are above that number
  for (int z = 260; z > 0; z-=10)
  {  
    for (int y = 0; y != InputModule.length; y++)
    {  
      if (InputModule[y].Enabled == false && InputModule[y].Priority >= z)
      {
        ModuleString = split(InputModule[y].ModuleFlagStr, ','); //fill with bit string

        for (int q = 0; q != ModuleString.length; q++)
        {  
          for (int i = 0; i != DevStrArray.length; i++)
          {  
            if (DevStrArray[i].equals(ModuleString[q]) == true) //if string matches
            {
              if (InputModule[y].Enabled == false) 
              {
                //println("Bit tile placed priority "+z);
                //println("Module Priority: "+InputModule[y].Priority);              
                InputModule[y].PlaceTile();
              }
            }
          } //end i for()
        } //end q for()  

        //==============================================================

        ModuleString = split(InputModule[y].ModuleByteStr, ','); //refill with byte string

        for (int q = 0; q != ModuleString.length; q++)
        {  
          for (int i = 0; i != ByteStrArray.length; i++)
          {  
            if (ByteStrArray[i].equals(ModuleString[q]) == true) //if string matches
            {
              if (InputModule[y].Enabled == false) 
              {
                //println("Byte tile placed priority "+z);
                //println(InputModule[y].Priority);              
                InputModule[y].PlaceTile();
              }
            }
          } //end i for()
        } //end q for()
      }
    } //end y for()
  }  //end z for()


  ///Now place all unprioritized not yet enabled tiles
  for (int y = 0; y != InputModule.length; y++)
  {  
    if (InputModule[y].Enabled == false)
    {
      ModuleString = split(InputModule[y].ModuleFlagStr, ',');

      for (int q = 0; q != ModuleString.length; q++)
      {  
        for (int i = 0; i != DevStrArray.length; i++)
        {  
          if (DevStrArray[i].equals(ModuleString[q]) == true) //if string matches
          {
            if (InputModule[y].Enabled == false) 
            {            
              InputModule[y].PlaceTile();
            }
          }
        } //end i for()
      } //end q for()  

      //==============================================================

      ModuleString = split(InputModule[y].ModuleByteStr, ',');

      for (int q = 0; q != ModuleString.length; q++)
      {  
        for (int i = 0; i != ByteStrArray.length; i++)
        {  
          if (ByteStrArray[i].equals(ModuleString[q]) == true) //if string matches
          {
            if (InputModule[y].Enabled == false) 
            {          
              InputModule[y].PlaceTile();
            }
          }
        } //end i for()
      } //end q for()
    }
  } //end y for()
  //Modules placed and prioritized

  // ================   Set additional define flags that require configurations to be loaded ==============

  //if 16-bit data mode or has 16-bit pack function for serial, live control would also be 16-bit capable
  if (device.Bit16Mode == true || IsOnConfigFlags("f8or16Bit"))   device.Bit16LiveMode = true;

  // ================   grey out unavailable GUI elements ==============

  UpdateIndexMemoryUsage(); //update memory usage

  ShowNotification(1);
  println("Configuration Modules Successfully Loaded - end LoadDeviceFile()");
}//end func()

//===================================================================================================  

void SaveSequencesFile(String passedFileLoc)
{
  println("SaveSequencesFile() to "+passedFileLoc);

  //Use user selected file name and directory
  //create string array containing file names and directories
  //Build aurora matrix seuquence file
  //ZIP aurm file and all the sequences into a folder

  passedFileLoc = passedFileLoc+".auroramatrix"; //add file extension, it is still a regular ZIP

  //checks to see if there is an undefined sequence on the index, that is one with no defined file
  for (int i = 0; i < IndexedSequences; i++) 
  {
    if (sequence[i].fileName.equals(""))
    {
      //sequence fileName is not defined
      //println(i+"   vs   "+IndexedSequences);
      IndexedSequences = i;
      break; //leave for()
    }
  } //end for()


  String[] filesToZipList = new String[IndexedSequences+2];

  for (int i = 0; i < IndexedSequences; i++) 
  {
    filesToZipList[i] = sequence[i].fileName;
  } //end for()

  //-------------------- Save Aurora Matrix Sequenc File ------------------------------

  String[] WorkString = new String[IndexedSequences+2]; //may need to up this

  WorkString[0] = "//NLED Aurora Matrix sequence save file - see readme for details";
  if (matrix.patchFileName.length() > 0) //incase patch is not defined, would error otherwise
  {
    String[] qpath = splitTokens(matrix.patchFileName, System.getProperty("file.separator"));
    WorkString[1] = qpath[qpath.length-1];
  }


  for (int i = 0; i < IndexedSequences; i++) 
  {
    try {
      WorkString[2+i] = sequence[i].getSaveString();
    }
    catch(Exception e)
    {
      println("getSaveString() with sequence#: "+i+" failed");
    }
  }

  //saves it to the temp folder
  saveStrings(sketchPath()+File.separator+"temp"+File.separator+"sequenceFile.aurm", WorkString);

  filesToZipList[IndexedSequences] = sketchPath()+File.separator+"temp"+File.separator+"sequenceFile.aurm";

  filesToZipList[IndexedSequences+1] = matrix.patchFileName;

  //------------------------------------ ZIP Up The Files -----------------------------------------

  FileZipper.zipFiles(filesToZipList, passedFileLoc);

  println("SaveSequencesFile() completed");
} //end func

//===================================================================================================  

void LoadSequencesFile(String passedFileLoc)
{
  println("LoadSequencesFile() with "+passedFileLoc);
  //unzip to temp, find the .aurm file, define sequence object

  FileZipper.clearTempFolder(); //clear temp folder first to prevent issues
  FileZipper.unzipToTemp(passedFileLoc); //unzip files to local temp folder

  String[] lines = loadStrings(FileZipper.localTempFolder+"sequenceFile.aurm"); //always same name
  printArray(lines);

  matrix.setPatchFile(FileZipper.localTempFolder+lines[1]); //load patch

  IndexedSequences = lines.length-2;

  //loads the sequence parameters from the .aurm file
  for (int i = 0; i < IndexedSequences; i++) 
  {
    sequence[i].selected = false;
    sequence[i].setLoadString(lines[i+2]);
  }
  
  //update index and scrollbar
  SelectedSlot = 0;
  sequence[SelectedSlot].selected = true;
  indexScrollBar.setValue(0);
}

//===================================================================================================
