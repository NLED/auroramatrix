
//======================================================================================================================

void deselectTextField()
{
  if (TextFieldActive == true)
  {
    if (textFieldPtr.selected == true) 
    {
      textFieldPtr.selected = false; 
      textFieldPtr.label = GlobalLabelStore; //restore
    }
    TextFieldActive = false;
  }

  //---------------------------------------------------------

  if (NumberInputFieldActive == true)
  {
    if (numberInputFieldPtr.selected > 0) 
    {
      numberInputFieldPtr.selected = 0; 
      numberInputFieldPtr.label = GlobalLabelStore; //restore
    }

    NumberInputFieldActive = false;
  }
} //end mousePressedHandleTextFields

//======================================================================================================================

void mousePressed() 
{
  mouseXS = round((float)mouseX / SF);
  mouseYS = round((float)mouseY / SF);

  if (mouseButton == RIGHT) 

  {
    println("X: "+mouseX+"   Y: "+mouseY);

    //---------------------------------------------------------

    //---------------------------------------------------------
  } //end right click
  else     
  {
    //regular left click
    //------------------------------------------------------------------------------------------------------------------

    if (ConfirmBoxIDNum > 0)
    {
      if (ConfirmButtonYes.over())
      {
        switch(ConfirmBoxIDNum)
        {
        case 0: //null
          break;
        case 1: //Upload Configurations      
          RequestConfigurationUpload(); //send configurations normally for all other devices.
          ShowNotification(4);
          break;
        case 2: //Remove Sequence from Index
          sequence[SelectedSlot].removeSequence();
          ShowNotification(9);
          break;        
        case 3: //Upload Indexed Sequences to Controller 
          StartSequenceUpload();
          break;
        } //end switch

        ConfirmBoxIDNum = 0; //close
      } //end confirm yes

      if (ConfirmButtonNo.over()) ConfirmBoxIDNum = 0; //close

      return;
    } //end confirm box if

    //------------------------------------------------------------------------------------------------------------------

    //If a drop down is open handle first, to prevent click-throughs to other elements
    if (GlobalDDOpen == true)   
    {
      //handle before anything
      if (DropDownPointer.overOpen())
      {
        println("Pressed Open DropDown "+DropDownPointer.selStr);
        method(DropDownPointer.callBack);
      } 
      else
      {
        //else a click was detected that wasn't on the open drop down, close it and leave
        DropDownPointer.selected = false;  
        GlobalDDOpen = false;
      }
      return; //whether it was a click on the open drop down, or somewhere not on the drop down, leave now, no other clicks should be detected
    }

    //------------------------------------------------------------------------------------------------------------------

    if (OverlayMenuID > 0)
    {
      if (OverlayMenus[OverlayMenuID].mousePressed()) return; //no need to check over()

      if (menuCloseButton.over()) OverlayMenuID = 0; //closes menu

      deselectTextField(); //handle deselecting previous field if applicable();

      if (OverlayMenus[OverlayMenuID].forceOverride == 0) return;
    }

    //------------------------------------------------------------------------------------------------------------------

    //only scans the buttons for the selected index slot
    try {
      //will catch if SelectedSlot with scrollbar offset is out of bounds, easy and quick. Fix later.
      if (SequenceSpeedField[SelectedSlot-indexScrollBar.getValue()].over()) return;

      if (SequenceRemoveButtons[SelectedSlot-indexScrollBar.getValue()].over())
      {
        if (IndexedSequences > 1)
        {
          //removed a sequence, move higher ones down into place 
          SetConfirmBox(2); //confirm remove sequence
        } 
        return;
      }

      if (SequenceLoadButtons[SelectedSlot-indexScrollBar.getValue()].over()) 
      {
        FileBrowserAction = 3;
        selectInput("Select a FilePlay data file for slot#"+(SelectedSlot+1), "fileSelected");  
        return;
      }

      if (SequencePlayModeDD[SelectedSlot-indexScrollBar.getValue()].over()) return;
      if (SequenceTransitionDD[SelectedSlot-indexScrollBar.getValue()].over()) return;

    }
    catch(Exception e) {
    }

    for (int i = 0; i < cMaxIndexViewed+1; i++)
    {
      if (mouseXS >= cSeqModuleXOffset && mouseXS <= cSeqModuleXOffset+cSeqModuleWidth && mouseYS >= (cSeqModuleYOffset+(i*cSeqModuleHeight)) && mouseYS <= (cSeqModuleYOffset+(i*cSeqModuleHeight))+cSeqModuleHeight)
      {
        int temp = i+indexScrollBar.getValue();

        println("Clicked sequence module "+sequence[temp].idNum+"   with "+i);
        //unselect all others first. For both selecting and adding sequences
        for (int x = 0; x < sequence.length; x++) sequence[x].selected = false;

        if (temp >= IndexedSequences)
        {
          //Its the add sequence button 
          println("Add Sequence To Index");

          if (sequence[temp-1].fileName.equals(""))
          {
            println("Previous sequence not defined");
            ShowNotification(8);
            return;
          }
          ShowNotification(10);
          IndexedSequences++; //increase index counter
          UpdateIndexMemoryUsage();
          return;
        }

        //select current sequence, and reset variables
        sequence[temp].selected = true;
        SelectedSlot = temp;
        comPlayPauseButton.selected = false;
        PlayBackFrameNum = 0;
        UpdateIndexGUIElements();
        return;
      } //end mouse locaiton if
    } //end for()

    //------------------------------------------------------------------------------------------------------------------

    if (comPlayPauseButton.over()) return; //only toggles state to indicate play or stop

      if (comGlobalIntensityField.over()) return;

    if (comLoadPatchFile.over()) 
    {
      FileBrowserAction = 4;
      selectInput("Select a FilePlay data file:", "fileSelected");  
      return;
    }


    if (comSaveSequenceFile.over())
    {
      FileBrowserAction = 2;
      selectOutput("Select a file to save the sequences to:", "fileSelected");  
      return;
    }

    if (comLoadSequenceFile.over())
    {
      FileBrowserAction = 1;
      selectInput("Select a Aurora Matrix sequence file to load(.auroramatrix)", "fileSelected");  
      return;
    }

    if (comUploadSequences.over())
    {
      SetConfirmBox(3); //confirm remove sequence
      println("Attempting Sequence Upload");
      return;
    }

    if (indexScrollBar.over()) return;

    if (comSerialPortDD.over()) return;

    if (comSerialBaudRateDD.over()) return;

    if(comHardwareColorReOrderDD.over()) return;

    if (comControlCommands.over())
    {
      println("Not Yet added");
      return;
    }

    if (UploadProgressCancel.over() && UploadInProgress == true)
    {
      UploadInProgress = false;
      return;
    }

    if (comConnectButton.over()) 
    {
      //setup baud rate based on user selections

      if (comSerialBaudRateDD.selStr == 0) ProgramBaudRate = 0;//USB/None selected, use any baud rate, doesn't matter
      else 
      {
        //A baud rate is selected
        ProgramBaudRate = int(comSerialBaudRateDD.labels[comSerialBaudRateDD.selStr]);
      }

      if (devConnected == false) OpenCOMPort(serialPort.list()[comSerialPortDD.selStr]); 
      else CloseCOMPort();
      return;
    }

    if (comOpenConfigurationsMenu.over())
    {
      SetOverlayMenuID(1); //Configurations Overlay
    }
  } //end left click else

  deselectTextField(); //no click on a gui object,  if a text field is selected, de-select
} //end mousePressed

//======================================================================================================================

void mouseReleased()
{
  //Update scaled mouse everytime before the values are used
  mouseXS = round((float)mouseX / SF);
  mouseYS = round((float)mouseY / SF);

  GlobalDragging = false; //incase a slider is being dragged
} //end mouseReleased

//======================================================================================================================

void mouseDragged()
{
  //The mouseDragged() function is called once every time the mouse moves while a mouse button is pressed. (If a button is not being pressed, mouseMoved() is called instead.) 
  //println("MouseDragging");
  //if(GlobalDragging == true) redraw();
}

//======================================================================================================================

void mouseMoved()
{
  mouseXS = round((float)mouseX / SF);
  mouseYS = round((float)mouseY / SF);

  //---------------------------------------------------------

  if (software.mouseOverEnabled == true)
  {
    //Mouse Over Functions
    // Fairly ineffiecent, it will detect any object, even those not shown, so it will always redraw on mouse moved
    for (int i = 0; i != DropDownList.size(); i++) 
    { 
      if (DropDownList.get(i).mouseOver()) return; //no other way to highlight, have to redraw
      if (DropDownList.get(i).mouseOverOpen()) return; //no other way to highlight, have to redraw
    } //end for

    //---------------------------------------------------------

    if (GlobalDDOpen == true)   return; //if a drop down is open, don't bother mousing over any other elements, just leave

    //---------------------------------------------------------

    for (int i = 0; i != ButtonList.size(); i++) 
    { 
      // An ArrayList doesn't know what it is storing so we have to cast the object coming out
      PointerButton = ButtonList.get(i);  
      if (PointerButton.mouseOver()) return;
    } //end for

    //---------------------------------------------------------
    
   for (int i = 0; i != NumberInputList.size(); i++) 
    { 
      // An ArrayList doesn't know what it is storing so we have to cast the object coming out
     // numberInputFieldPtr = NumberInputList.get(i);  
      if (NumberInputList.get(i).mouseOver() > 0) return;
    } //end for   
    
    
        //---------------------------------------------------------
  } //end sEnableMouseOver if()
} //end mouseMoved

//======================================================================================================================

void mouseWheel(MouseEvent event) 
{
  println("mouseWheel()");
  mouseXS = round((float)mouseX / SF);
  mouseYS = round((float)mouseY / SF);

  float e = event.getCount();
  if (mouseXS > 0 && mouseXS < 274 && mouseYS > 165)
  {
    indexScrollBar.setValue(int(indexScrollBar.value+e));
  }
}

//======================================================================================================================
