
//===================================================================================================

void UpdateIndexGUIElements()
{
  for (int i = 0; i < cMaxIndexViewed; i++) //5 is how many indexed sequences can be viewed
  {
    SequenceSpeedField[i].setValue(sequence[i+indexScrollBar.getValue()].speed);
    SequencePlayModeDD[i].selStr = (sequence[i+indexScrollBar.getValue()].playMode);
    SequenceTransitionDD[i].selStr = (sequence[i+indexScrollBar.getValue()].transition);
  }
}

//===================================================================================================

void SetOverlayMenuID(int passedVal)
{
  OverlayMenuID = passedVal;
  OverlayMenus[OverlayMenuID].initMenu();
}

//===================================================================================================

void UpdateIndexMemoryUsage()
{
    IndexedMemoryUsage = 0; //clear it
  
    //Check if the amount of patched pixels is higher than the hardware device supports
    if (matrix.patchedPixels > (device.Channels/3)) UtilizedChannels = device.Channels; //more channels are defined in the patch than hardware supports
    else UtilizedChannels = matrix.patchedPixels * 3; //same as patchedChannels, but should not change that. Use the global.

    for (int i = 0; i < IndexedSequences; i++) 
    {
    sequence[i].memorySize = (sequence[i].totalFrames*UtilizedChannels)+cHeaderByteLen;  
    IndexedMemoryUsage += sequence[i].memorySize;
    }
    
    //println(IndexedMemoryUsage);  
    IndexedMemoryUsageStr =  ""+nf((((float)IndexedMemoryUsage / device.DataSpace)*100),1,2); //update string for GUI display
    
    if(UtilizedChannels != matrix.patchedPixels)   println("UpdateIndexMemoryUsage() result: "+IndexedMemoryUsage+"  Channel Size Was Cropped");
    else println("UpdateIndexMemoryUsage() result: "+IndexedMemoryUsage);
}

//===================================================================================================  

void SetConfirmBox(int passedVal)
{
  ConfirmBoxIDNum = passedVal;
}

//============================================================================================

void ShowNotification(int passedVal)
{
  println("ShowNotification() with "+passedVal);

//ShowNotification = passedVal;

  switch(passedVal)
  {
  case 0: //null

    break;
  case 1:
    DisplayMessageStr = "Connection and Definition Loading Successful.";
    break;
  case 2:
    DisplayMessageStr = "Available Serial Ports Have Updated.";
    break;    
  case 3:
    DisplayMessageStr = "Port Opened Successfully. Attempting Connection, please wait.";
    break; 
  case 4:
    DisplayMessageStr = "Configurations uploaded, waiting for acknowledge.";
    break;    
  case 5:
    DisplayMessageStr = "Configurations Successfully Uploaded";
    break;    
  case 6:
    DisplayMessageStr = "Command timed out. Device did not respond. Disconnecting from port.";
    break; 
  case 7:
    DisplayMessageStr = "This device does not respond, and may not actually be connected. See activity LED and datasheet for details.";
    break; 
   case 8:
    DisplayMessageStr = "Define Previous Sequence Before Adding More.";
    break; 
    case 9:
    DisplayMessageStr = "Sequence Removed From Index.";
    break;  
    case 10:
    DisplayMessageStr = "Sequence Added To Index.";
    break; 
    case 11:
    DisplayMessageStr = "Attempting to Upload Indexed Color Sequences.";
    break;    
      case 12:
    DisplayMessageStr = "Configurations Upload Completion Success.";
    break;   
   case 13:
    DisplayMessageStr = "Not the correct file type.";
    break;     
   case 16:
    DisplayMessageStr = "Could not load device file, firmware may be outdated or not compatible. See www.NLEDshop.com/deviceupdates";
    break;   
  case 22:
    DisplayMessageStr = "Port Can Not Be Opened.";
    break;
    
  }//end switch
}

//============================================================================================
