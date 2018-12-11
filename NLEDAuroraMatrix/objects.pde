
//============================================================================================

public class DeviceObj
{
  int HardwareID; //unique hardware ID number
  String Name;  //Stores the readable name for the controller as string
  int HardwareVersion;
  int FirmwareVersion;
  int FirmwareRevision;
  int BootloaderVersion;

  //Sequence defines
  int Channels; //maximum amount of channels
  int MaxSpeed;  
  int MaxIndexedSequences;
  int IndexMemoryModel;
  int MaxFrames;
  int MaxFramesGlobal;

  //Memory defines
  int DataSpace;
  int HWPVSpace;
  int HPVBlockSize;
  int SeqMemoryBlockSize; 
  int IndexBlockSize; 
  int CurrentBlockSize;
  int EraseBlockSize;

  boolean LockChannelAmt; //disallow per sequence data size, only device.channels
  int GammaCorrection;
  boolean LinkedSupport;  
  boolean Bit16Mode;  //flag to set 16-bit data mode
  boolean FillUpperData;
  boolean Bit16Processor;
  boolean Bit16LiveMode;

  int BasicVersion;
  int BasicMaxSequences; 
  int BasicSeqLength;
  int AccelerometerMode;

  int ArrayCastSize; //can't always use device channels, because of double duty for linked variables

  //How are these loaded differently???????????????  
  int DMXModeAmt;
  String[] DMXModeLabels;
  int ListedChipsets;

  //Not loaded from Device Files
  int UserConfiguredIDNum; //set by user saved in firwmare  
  int UserIdleSequence;  //Held is save file, sent with index

  //scratch
  String ConfigFlagsStr;
  String ConfigBytesStr;

  String WebpageURL;
  String MemorySpaceString; //stores byte to kb/mb conversion string

  DeviceObj(String iName)
  {
    HardwareID = 0;
    Name = iName;
    HardwareVersion = 0;
    FirmwareVersion = 0;
    FirmwareRevision = 0;  
    Channels = 0;
    DataSpace = 0;
    BootloaderVersion = 0;
    UserConfiguredIDNum = 0;
    UserIdleSequence = 0;

    MaxFrames = 0;
    MaxFramesGlobal = 0;

    MaxIndexedSequences = 8; //default, will get set when device file is loaded

    EraseBlockSize = 0;
    HWPVSpace = 0;
    DMXModeAmt = 0;
    GammaCorrection = 0;
    LinkedSupport = false;
    Bit16Mode = false;
    DMXModeLabels = new String[1];
  }
} //end object

//============================================================================

public class SoftwareObj
{
  int frameRate;

  int GUIWidth;
  int GUIHeight;

  boolean mouseOverEnabled;

  //--------------------------------------------------------------------------

  SoftwareObj()
  {
    mouseOverEnabled = true;
  }
  //--------------------------------------------------------------------------
} //end object

//=================================================================================

public class GUIObj
{
  color windowBackground;
  color windowStroke;
  color layerBackground;
  color textColor;
  color textMenuColor;

  color buttonColor;
  color buttonHighlightColor;
  color menuBackground;

  color textFieldHighlight;
  color textFieldBG;


  //--------------------------------------------------------------------------

  GUIObj()
  {
    windowBackground = color(65, 65, 65);
    windowStroke  = color(255);
    layerBackground = color(100, 100, 100);
    textColor = color(255);
    buttonColor = color(0, 0, 100);
    buttonHighlightColor = color(100, 0, 100);

    menuBackground  = color(200);
    textMenuColor = color(0);

    textFieldBG = color(255); //white
    textFieldHighlight = color(200, 40, 40);
  }
} //end gui class

//======================================================================================

public class MatrixObj
{
  int width;
  int height;
  String patchFileName; //actual file name and location
  String patchFileShort; //for GUI display

  int patchedPixels;  //base 1
  int patchedChannels; //base 1

  //---------------------------------------------------------------------------------------

  MatrixObj()
  {
    patchFileName = "";
  }

  //--------------------------------------------------------------------------

  public void setPatchFile(String passedStr)
  {
    patchFileName = passedStr;

    if (patchFileName.length() > 35) patchFileShort = "..."+patchFileName.substring(patchFileName.length()-35, patchFileName.length());
    else patchFileShort = passedStr;

    loadPatchFile();
  }
  //--------------------------------------------------------------------------

  private void loadPatchFile()
  {
    //loads a coordinate patch file, find min and mix point in both directions and scales the overall size to fit within the preview areas
    // creates the Pixel objects to display during draw and fills the Coordinate Arrays for Pixel Patching
    println("BuildCustom()");

    int Xdifference = 0;
    int Ydifference = 0;

    String[] lines = loadStrings(matrix.patchFileName); //divides the lines
    String[] WorkString = new String[3]; //used to divide the lines into tab

    WorkString = split(lines[0], '\t');
    matrix.patchedPixels = int(WorkString[0]);

    //---------------------------------------------------------------------------------------------------------

    patchedChannels = matrix.patchedPixels * 3;

    println("PatchedChannels: "+matrix.patchedChannels);
    println("TotalPixels: "+matrix.patchedPixels); 

    int MinX = 10000; //set to a large value
    int MinY = 10000;
    int MaxX = 0;
    int MaxY = 0;

    for (int i=1; i != lines.length; i++)
    {
      WorkString = split(lines[i], '\t');
      if (int(WorkString[0]) > MaxX) MaxX = int(WorkString[0]);
      if (int(WorkString[0]) < MinX) MinX = int(WorkString[0]);

      if (int(WorkString[1]) > MaxY) MaxY = int(WorkString[1]);
      if (int(WorkString[1]) < MinY) MinY = int(WorkString[1]);
    }
    //println("X: "+MinX+" : "+MaxX);
    //println("Y: "+MinY+" : "+MaxY);

    Xdifference = MaxX - MinX;
    Ydifference = MaxY - MinY;
    //println(Xdifference+" : "+Ydifference);

    PatchCoordX = new short[patchedPixels]; //resize the patch arrays
    PatchCoordY = new short[patchedPixels];

    //file created was incremented method channel numbers
    for (int i=0; i != matrix.patchedPixels; i++)
    {
      WorkString = split(lines[i+1], '\t');      
      PatchCoordX[i] = (short)(int(WorkString[0]) - MinX);
      PatchCoordY[i] = (short)(int(WorkString[1]) - MinY);
    }

    //set final matrix size
    matrix.width = Xdifference+1;//not base 0
    matrix.height = Ydifference+1;// not base 0
    //println("maxX: "+MaxX+"   maxY: "+MaxY);

    //set pixSize that draw() uses to draw the matrix preview
    if (MaxX > MaxY)
    {
      displayPixSize = ((cPreviewContentWidth-20) / MaxX);
    } else
    {
      displayPixSize = ((cPreviewContentHeight-20)  / MaxY);
    }
  }//end method
} //end object

//============================================================================

public class SequenceObj
{
  int idNum;
  String fileName;
  int totalFrames; //stored as base 1
  int speed;
  float memorySize; //in bytes

  int playMode;
  int transition;

  //GUI variables
  boolean selected;

  //Color Data
  int[][] dataFrames; //Data Storage array

  //Non-Saved Function Only - For Index Building
  int mappedROMAdr;

  //--------------------------------------------------------------------------

  SequenceObj(int pidNum)
  {
    idNum = pidNum;
    fileName = "";
    totalFrames = 0;
    speed = cDefaultSeqSpeed;
  }

  //--------------------------------------------------------------------------

  public void display(int yOffset)
  {
    if (idNum >= IndexedSequences)
    {
      //sequence not defined, it should show the add sequence button
      stroke(0, 0, 255); //blue
      fill(100);
      rect(cSeqModuleXOffset, cSeqModuleYOffset+((yOffset)*cSeqModuleHeight)+10, cSeqModuleWidth-10, cSeqModuleHeight);
      fill(255); //white
      textAlign(CENTER);
      text("Click to\nAdd Sequence to slot "+(idNum+1)+":", cSeqModuleXOffset+(cSeqModuleWidth/2), cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+60);
      textAlign(LEFT);
    } 
    else
    {
      //display normally
      fill(255); //white
      text("Slot "+(idNum+1)+":", cSeqModuleXOffset, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+20);

      if (fileName.length() > 28) text("File: "+"..."+fileName.substring(fileName.length()-28, fileName.length()), cSeqModuleXOffset, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+55);
      else text("File: "+fileName, cSeqModuleXOffset, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+55);

      text("Frames: "+totalFrames, cSeqModuleXOffset, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+75);
      text("Memory: "+((float)memorySize)+"Kb", cSeqModuleXOffset+105, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+75); 
      text("Speed(mSec): ", cSeqModuleXOffset, cSeqModuleYOffset+(yOffset*cSeqModuleHeight)+105);

      strokeWeight(2);
      stroke(gui.windowStroke);
      line(cSeqModuleXOffset, cSeqModuleYOffset+((yOffset+1)*cSeqModuleHeight), 274, cSeqModuleYOffset+((yOffset+1)*cSeqModuleHeight));
    }

    if (selected == true)
    {
      stroke(255, 0, 0); //red
      noFill();
      rect(cSeqModuleXOffset-5, cSeqModuleYOffset+((yOffset)*cSeqModuleHeight), cSeqModuleWidth, cSeqModuleHeight);
    }
  }

  //--------------------------------------------------------------------------

  public void loadSequence(String passedFilePath)
  {
    //Speed is not available, manually
    speed = cDefaultSeqSpeed; //default 30 FPS
    fileName = passedFilePath;

    //SelectedSlot = idNum;
    LoadFilePlayModeFile(passedFilePath, idNum);
    //totalFrames is updated in file load
    memorySize = (totalFrames*matrix.patchedChannels)+cHeaderByteLen; //answer in bytes
    UpdateIndexMemoryUsage();
  }

  //--------------------------------------------------------------------------

  public void removeSequence()
  {
    //have to move all other ones down and adjust ID number 
    for (int i = SelectedSlot; i < IndexedSequences; i++) 
    {
      try 
      {
        //move down the sequences
        //sequence[i] = sequence[i+1]; //don't think it works like that
        sequence[i].idNum = sequence[i+1].idNum-1;
        sequence[i].fileName = sequence[i+1].fileName;
        sequence[i].totalFrames = sequence[i+1].totalFrames;
        sequence[i].speed = sequence[i+1].speed;
        sequence[i].memorySize = sequence[i+1].memorySize;
        //mappedROMAdr only updated at upload
        sequence[i].selected  = false;   
        //sequence[i].dataFrames = sequence[i+1].dataFrames; 

        for (int x= 0; x < sequence[i].dataFrames.length; x++)
          for (int j=0; j < sequence[i].dataFrames[x].length; j++)
            sequence[i].dataFrames[x][j]= sequence[i+1].dataFrames[x][j];
      }
      catch(Exception e) {
        println("Exception attempting to shift sequence objects down");
      }
    } //end q for() 

    //update variabels and elements
    IndexedSequences--; 

    UpdateIndexMemoryUsage();
    
    sequence[SelectedSlot].selected  = false;
    SelectedSlot = 0;
    sequence[SelectedSlot].selected  = true;
  } //end removeSequence()

  //--------------------------------------------------------------------------

  String getSaveString()
  {
    String[] qpath = splitTokens(fileName, System.getProperty("file.separator"));

    return  qpath[qpath.length-1]+"\t"+speed+"\t"+playMode+"\t"+transition;
  }

  //--------------------------------------------------------------------------

  void setLoadString(String passedStr)
  {
    String[] WorkString = new String[5]; //more than required, not sure how many are listed yet

    WorkString = split(passedStr, '\t');

    fileName = WorkString[0];
    loadSequence(FileZipper.localTempFolder+fileName);
    speed = int(WorkString[1]);   
    playMode = int(WorkString[2]);   
    transition = int(WorkString[3]);
  }

} //end class


//========================================================================================================

//Sample code taken from the Processing forums and probably another website. Credit is owed to someone.
public class zipper
{
  String localTempFolder =""; //static for now

  //----------------------------------------------------------------------------------------------------

  public void clearTempFolder()
  {
    try {
      File fp = new File(localTempFolder); 
      String[] fileNames = fp.list(); //can't use .list() directly since it updates as items are deleted
      printArray(fileNames);

      for (int i = 0; i <= fileNames.length+1; i++)
      {
        File x = new File(localTempFolder+fileNames[i]); 
        x.delete(); // It is supposed to be still there...
        println("Deleted "+i+"  "+x);
      }
    }
    catch(Exception e) { 
      println("Error clearing temp folder");
    }
  } //end method

  //----------------------------------------------------------------------------------------------------

  public void unzipToTemp(String passedZipLoc)
  {
    println("Starting unzipToTemp("+passedZipLoc+")");

    byte[] buff = new byte[cBufferByteSize];

    try {
      FileInputStream fis = new FileInputStream(passedZipLoc);

      // this is where you start, with an InputStream containing the bytes from the zip file
      ZipInputStream zis = new ZipInputStream(fis);
      ZipEntry entry;

      // while there are entries I process them
      while ((entry = zis.getNextEntry()) != null)
      {
        System.out.println("entry: " + entry.getName() + ", " + entry.getSize());
        // consume all the data from this entry
        while (zis.available() > 0)
        try {
          FileOutputStream fos = new FileOutputStream(localTempFolder+entry.getName());
          int l=0;
          // write buffer to file
          while ((l=zis.read(buff))>0) {
            fos.write(buff, 0, l);
          }
          fos.close(); //crucial for it to work or won't release the files so they can not be deleted
        } 
        catch (Exception e) {
          println("Exception writing files to disk");
          break;
        }
      }
      zis.close();
      fis.close();
    }
    catch (Exception e) {
      println("Exception caught within Unzip Class");
    }
  } //end method

  //----------------------------------------------------------------------------------------------------

  public void zipFiles(String[] srcFiles, String zipDirStr) 
  {
    println("Saving "+zipDirStr);
    printArray(srcFiles);

    try {
      // create byte buffer
      byte[] buffer = new byte[1024];

      FileOutputStream fos = new FileOutputStream(zipDirStr);
      ZipOutputStream zos = new ZipOutputStream(fos);

      for (int i=0; i < srcFiles.length; i++) 
      {
        //println("Running with "+srcFiles[i]);
        File srcFile = new File(srcFiles[i]);

        FileInputStream fis = new FileInputStream(srcFile);

        // begin writing a new ZIP entry, positions the stream to the start of the entry data
        zos.putNextEntry(new ZipEntry(srcFile.getName()));

        int length;

        while ((length = fis.read(buffer)) > 0) {
          zos.write(buffer, 0, length);
        }

        zos.closeEntry();
        fis.close();           // close the InputStream
      }

      zos.close();         // close the ZipOutputStream
    }
    catch (IOException ioe) {
      System.out.println("Error creating zip file: " + ioe);
    }
  }//end method
} //end class

//========================================================================================================
