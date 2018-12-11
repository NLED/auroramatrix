 //<>//
//===================================================================================================  

void draw() {
  //update in case of slider or other gui features
  mouseXS = round((float)mouseX / SF);
  mouseYS = round((float)mouseY / SF);

  background(gui.windowBackground);

  fill(100);
  noStroke();
  rect(274, 100, 750, 680);

  strokeWeight(2);
  stroke(gui.windowStroke);
  line(0, 100, width, 100);
  line(274, 100, 274, height);
  line(0, 210, 274, 210);
  line(0, cSeqModuleYOffset-5, 274, cSeqModuleYOffset-5);
  line(570, 0, 570, 100);
  line(905, 0, 905, 100);
  line(725, 0, 725, 100);

  fill(gui.textColor);
  textSize(14);
  textAlign(LEFT);
  //Device Status: Not Connected\n
  text("Device: "+device.Name+"\nVersion: "+(device.FirmwareVersion)+(char(device.FirmwareRevision+97))+"\nPatch: "+matrix.patchFileShort, 255, 20);
  text("Slot#: "+(SelectedSlot+1)+"\nFrame: "+(PlayBackFrameNum+1)+"/"+sequence[SelectedSlot].totalFrames, 735, 60);
  
  text("Patch Info:\nW: "+matrix.width+"   H: "+matrix.height+"\nPixels: "+matrix.patchedPixels, 580, 50);
  
  text("Matrix Save Files:", 910, 15);
  
  text("Software Color Order:\n(Reordering applied by software at upload)", 5, 185);
  text("Selected Slot#: "+(SelectedSlot+1), 10, 230);
  text("Status: "+DisplayMessageStr, 10, 90);

  if (IndexedMemoryUsage > device.DataSpace) fill(255, 0, 0); //show red text if indexed sequences are too large
  if (devConnected == true)  text("Memory Usage: "+IndexedMemoryUsageStr+"% of "+device.MemorySpaceString, 10, 120);
  else text("Memory Usage: Connect Device", 10, 120);
  //text("Memory Usage: "+IndexedMemoryUsage+" of "+device.MemorySpaceString, 10, 120); //byte size text, for debugging
  fill(gui.textColor); // go back to white text

  //---------------------------------------------------------------------------------------------------------------------

  //could be done in a better way but this is quicker and less debugging
  if (devConnected == false) 
  {
    comOpenConfigurationsMenu.status = 1;
    comUploadSequences.status = 1;
    comControlCommands.status = 1;
    comSerialBaudRateDD.status = 0;
    comConnectButton.Label = "Connect";
  } else
  {
    comOpenConfigurationsMenu.status = 0;
    if (IndexedMemoryUsage > device.DataSpace)  comUploadSequences.status = 1;
    else comUploadSequences.status = 0;

    comControlCommands.status = 0;
    comSerialBaudRateDD.status = 1;
    comConnectButton.Label = "Disconnect";
  }
  
  //NOT YET ENABLED, maybe next revision
  comControlCommands.status = 1;
  
  //---------------------------------------------------------------------------------------------------------------------

  indexScrollBar.display();
  comSaveSequenceFile.display();
  comLoadSequenceFile.display();
  comGlobalIntensityField.display();
  comConnectButton.display();   
  comPlayPauseButton.display();  
  comLoadPatchFile.display(); 
  comControlCommands.display();
  comUploadSequences.display();
  comOpenConfigurationsMenu.display();
  comSerialBaudRateDD.display();
  comSerialPortDD.display();
  comHardwareColorReOrderDD.display();

  //---------------------------------------------------------------------------------------------------------------------

  for (int i = indexScrollBar.getValue(); i < IndexedSequences+1; i++)
  {
    sequence[i].display(i-indexScrollBar.getValue());
  }

  for (int i = 0; i < cMaxIndexViewed; i++)
  {
    if (i >= (IndexedSequences-indexScrollBar.getValue())) break;
    SequenceRemoveButtons[i].display();
    SequenceLoadButtons[i].display();
    SequenceSpeedField[i].display();
    SequencePlayModeDD[i].display();
    SequenceTransitionDD[i].display();
  }

  //-------------------------------------------- Matrix Preview -------------------------------------------------------------------------

  if (comPlayPauseButton.selected == true) 
  {
    if (sequence[SelectedSlot].speed > 0) frameRate(1000/sequence[SelectedSlot].speed); //convert from miliseconds to FPS
    else frameRate(30);

    PlayBackFrameNum++;
    if (PlayBackFrameNum >= sequence[SelectedSlot].totalFrames) PlayBackFrameNum = 0;
  }

  int i = 0;

  try {
    //default style
    stroke(255); //black outline - could also do white(255)
    strokeWeight(1);

    //output preview
    for (i = 0; i < matrix.patchedPixels; i++)
    {
      color pix = color(sequence[SelectedSlot].dataFrames[PlayBackFrameNum][(i*3)], sequence[SelectedSlot].dataFrames[PlayBackFrameNum][(i*3)+1], sequence[SelectedSlot].dataFrames[PlayBackFrameNum][(i*3)+2]);
      fill(pix);
      rect(cPreviewXPos+(PatchCoordX[i]*displayPixSize), cPreviewYPos+(PatchCoordY[i]*displayPixSize), displayPixSize, displayPixSize);
    }
  }
  catch(Exception e) {
    //colors from dataframes couldn't be loaded, display a blank matrix. Not a great solution but is quick
    //continue displaying from where it errored
    for (i = i; i < matrix.patchedPixels; i++)
    {
      color pix = color(0, 0, 0);
      fill(pix);
      rect(cPreviewXPos+(PatchCoordX[i]*displayPixSize), cPreviewYPos+(PatchCoordY[i]*displayPixSize), displayPixSize, displayPixSize);
    }
  }

  if ((device.Channels/3) < matrix.patchedPixels)
  {
    stroke(255, 0, 0); 
    fill(0, 0);

    for (i = (device.Channels/3); i < matrix.patchedPixels; i++)
    {
      rect(cPreviewXPos+(PatchCoordX[i]*displayPixSize), cPreviewYPos+(PatchCoordY[i]*displayPixSize), displayPixSize, displayPixSize);
    }

    fill(255);
    text("Hardware does not support that many pixels, pixels will be cropped(red box). Or connect a device.", 295, 115);
  } //end pixel amount if

  //---------------------------------------------------------------------------------------------------------------------

  //Writes the pixel# as text over the preview grid
  if (comPlayPauseButton.selected == false) 
  {
    try {
      noStroke();
      fill(255);
      textAlign(CENTER);
      textSize(12);      

      //output preview
      for (i = 0; i < matrix.patchedPixels; i++)
      {
        text(""+(i+1), cPreviewXPos+(PatchCoordX[i]*displayPixSize), cPreviewYPos+(PatchCoordY[i]*displayPixSize)+(displayPixSize/2), displayPixSize, displayPixSize);
      }
    }
    catch(Exception e) {
    }
  } //end if()

  //------------------------------------------- Overlay Menus --------------------------------------------------------------

  if (OverlayMenuID > 0)
  {  
    fill(gui.windowBackground, 128);
    rect(0, 0, width, height);  
    OverlayMenus[OverlayMenuID].display();
  }

  //---------------------------------------------------------------------------------------------------------------------

  if (serialPort.list().length != comSerialPortDD.numStrs) BuildCOMDropDown(); //updates drop down if available serial port list has changed

  if (GlobalDDOpen == true) DropDownPointer.display(); //if a drop down is open, display() it again to ensure it overlays all other drawing

  if (GlobalDragging == true) SliderPointer.runCallBack(); //slider drags with GUI refreshes, but uses mouse location so values are un-affected

  //---------------------------------------- Upload Progress Bar ----------------------------------------------------------------

  if (UploadInProgress == true)   DisplayProgressBar(width/2, height/2);

  //------------------------------------- User Notifications ----------------------------------------------------------------

  if (ConfirmBoxIDNum > 0)
  {
    fill(gui.windowBackground, 128);
    rect(0, 0, width, height);

    fill(gui.windowStroke);
    stroke(gui.buttonHighlightColor);
    strokeWeight(3);
    rect((1024/2)-120, (768/2)-60, 240, 120, 20);
    fill(0);
    textSize(14);
    textAlign(CENTER);
    text(cConfirmBoxText[ConfirmBoxIDNum], (1024/2)-110, (768/2)-50, 220, 100);
    textAlign(LEFT);

    ConfirmButtonYes.display();
    ConfirmButtonNo.display();
  }   

  //---------------------------------------------------------------------------------------------------------------------
} //end draw()

//=============================================================================================================================

void DisplayProgressBar(int xpos, int ypos)
{
  //only call from draw, absolute positions
  //xpos and ypos are on center
  //300 wide, 120 tall

  fill(gui.windowBackground, 128);
  rect(0, 0, width, height); //grey out
  stroke(gui.buttonHighlightColor);
  strokeWeight(4);
  fill(gui.windowBackground);
  rect(xpos-150, ypos-80, 300, 120);

  stroke(255);  
  fill(0);  
  strokeWeight(2);
  rect(xpos-130, ypos, 260, 25);

  textAlign(CENTER);
  textSize(24);
  fill(255);
  text("Upload In Progress:", xpos, ypos-50);
  textAlign(LEFT);
  noStroke();

  UploadProgressCancel.xpos = xpos - (UploadProgressCancel.bWidth/2);
  UploadProgressCancel.ypos = ypos - 35;

  UploadProgressCancel.display();

  //rounds up since only full packets are expected
  UploadProgressVar = (float)SendCounterB / (float)(ceil((float)IndexedMemoryUsage/(float)device.CurrentBlockSize) * device.CurrentBlockSize);

  if (SendCounterB > 10) //fixes problem with software freeze, maybe was only on basic, but either way
  {  

    for (int v = 0; v != int(UploadProgressVar*21); v++)
    {
      colorMode(HSB, 25);
      fill(v, 25, 25);
      rect((xpos+5-130)+(v*12), ypos+5, 8, 16, 6);
    }  
    colorMode(RGB, 255);
  }
}

//=============================================================================================================================
/*
//Prevents application from exiting successfully, disabled as it is not required
void exit()
 {
 println("running exit code");
 FileZipper.clearTempFolder(); //empties the temp folder at application close
 }
 */
//===================================================================================================
