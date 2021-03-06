//================================= START CONFIGURATION MODULES GUI ELEMENTS=================================================================

boolean CheckModuleElements()
{
  //--------------------------------------------------------------------------------------------------
  if (InputModule[2].Enabled == true && HardwareColSwapDD.over()) return true; 
  //--------------------------------------------------------------------------------------------------
  if (InputModule[3].Enabled == true && PixelChipsetDD.over())     return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[9].Enabled == true && LEDIndicatorModeADD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[1].Enabled == true && LEDIndicatorModeBDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[10].Enabled == true && DisplayModeDD.over()) return true;  
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[7].Enabled == true && MasterModeDD.over()) return true;  
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[11].Enabled == true && AutoDetectDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[22].Enabled == true && PWMProfileADD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[23].Enabled == true && IRRemoteModeDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[8].Enabled == true && BaudRateDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[6].Enabled == true && DMXModesDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[14].Enabled == true && AccMeterAutoDetectDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[14].Enabled == true && AccMeterAutoDetectModeDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if ( InputModule[15].Enabled == true && AccMeterTapDD.over()) return true;
  //--------------------------------------------------------------------------------------------------  
  if (InputModule[16].Enabled == true && PowerDownTimeOutDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[20].Enabled == true && PWMFreqADD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[21].Enabled == true && StandAloneADD.over()) return true;   
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[31].Enabled == true && DMXAutoReleaseDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[32].Enabled == true && AutoReleaseLegacyDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[33].Enabled == true && ReceptionModeLegacyDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[34].Enabled == true && HardwareColorReOrderDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[35].Enabled == true && StandardExpansionHeaderDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (InputModule[13].Enabled == true && AccMeterAutoDetectDD.over()) return true;
  if (InputModule[13].Enabled == true && AccMeterAutoDetectModeDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    
  if (HardwareCheckBox[0].over() && InputModule[8].Enabled == true) return true;//16-bit serial checkbox, not always enabled via Status
  if (HardwareCheckBox[1].over() && InputModule[19].Enabled == true) return true; //Dual Communication Mode
  //--------------------------------------------------------------------------------------------------
  if (InputModule[36].Enabled == true && GlediatorOverrideDD.over()) return true;
  //--------------------------------------------------------------------------------------------------    

  if (HardwareButtons[0].over() && InputModule[0].Enabled == true) return true;//Enable/Disable RS485

  if (HardwareButtons[1].over() && InputModule[1].Enabled == true) return true;  //16 or 8 bit DMX Transmission

  if (HardwareButtons[2].over() && InputModule[4].Enabled == true) return true;

  if (HardwareButtons[3].over() && InputModule[12].Enabled == true) return true;  //gamma   

  if (HardwareButtons[4].over() && InputModule[14].Enabled == true) return true;    

  //--------------------------------------------------------------------------------------------------  

  if (TextFields[2].over() && InputModule[5].Enabled == true) { 
    TextFields[2].selectField(); 
    return true;
  }//DMX Address
  if (TextFields[13].over() && InputModule[21].Enabled == true) { 
    TextFields[13].selectField(); 
    return true;
  }//StandAlone Field A    

  //--------------------------------------------------------------------------------------------------  

  //added for configuration software  

  if (HardwareCheckBox[2].over() && InputModule[25].Enabled == true) return true;  //enable activity LED

  if (HardwareCheckBox[3].over() && InputModule[27].Enabled == true) return true;  //Enable Serial Color Swap:

  if (TextFields[4].over() && InputModule[24].Enabled == true) { 
    TextFields[4].selectField(); 
    return true;
  }//DMX pixel amount

  if (TextFields[3].over() && InputModule[29].Enabled == true) { 
    TextFields[3].selectField(); 
    return true;
  }//End of Frame Timer

  //--------------------------------------------------------------------------------------------------  
  return false;
} //end func

//===================================================================================================

void FuncRecommendColorShift()
{  
  println("FuncRecommendColorShift()");
  InputModule[3].Label = "Select The Pixel Chipset:\n\n\n\nHardware Color Order:\n";
  try
  {
    for (int i=0; i <= (PixelChipsetDD.numStrs+1); i++)
    {
      if (PixelChipsetDD.labels[PixelChipsetDD.selStr].indexOf(cPixelChipsetStrings[i]) >= 0)
      {
         InputModule[3].Label += cPixelChipsetColorID[i]; //add to label string
        return; //return if something is found
      }
    } //end for()
  }
  catch(Exception e)
  {
    //nothing
  }
  //otherwise uses default
  InputModule[3].Label += "Not Available, uses R>G>B"; //add to label string
} //end FuncRecommendColorShift

//=================================================================================================================================================  

boolean IsOnConfigFlags(String passedStr)
{
  for (int i = 0; i != DevStrArray.length; i++)
  {  
    if (DevStrArray[i].equals(passedStr) == true) //if string matches
    {
      println("IsOnConfigFlags() found "+passedStr);
      return true;
    }
  } //end i for()
  return false;
}//end func  

//==================================================================================================================================================

void bitSet(int pointer)
{
  ConfigFlags |= (1 << pointer); 
  //println("BitSet "+pointer+"    "+ConfigFlags);
} //end func

//==================================================================================================================================================

class SpecHWModules
{
  int IDnumber;
  String Label;
  int xpos;
  int ypos;
  int bWidth;
  int bHeight;

  int Priority;

  String ModuleFlagStr;
  String ModuleByteStr;

  boolean Enabled;

  SpecHWModules(int iIDnumber, String iLabel, int ixpos, int iypos, int ibWidth,  String iModuleFlagStr, String iModuleByteStr, int iPriority)
  {
    IDnumber = iIDnumber;
    Label = iLabel;
    xpos = ixpos;
    ypos = iypos;  
    bWidth = ibWidth;
    bHeight = cInputModuleHeight; //static
    ModuleFlagStr = iModuleFlagStr;
    ModuleByteStr = iModuleByteStr;
    Priority = iPriority;
    Enabled = false;
  }

  void display()
  {
    if (Enabled == false) return;

    stroke(0);
    strokeWeight(2);
    fill(gui.windowStroke, 200);
    rect(xpos, ypos, bWidth, bHeight);
    noStroke();

    switch(IDnumber)
    {
    case 0:  //device.RS485Capable
      HardwareButtons[0].display();    
      break;    
    case 1:    //LED indicator 2
      LEDIndicatorModeBDD.display();
      //if (LEDIndicatorModeBDD.selected == true)  DropDownPointer = LEDIndicatorModeBDD;    
      break;      
    case 2:  //device.GlobalColorShift    
      HardwareColSwapDD.display();  
      //if (HardwareColSwapDD.selected == true)  DropDownPointer = HardwareColSwapDD;  
      break;      
    case 3:  //Pixel Type
      PixelChipsetDD.display();  
      //if (PixelChipsetDD.selected == true)  DropDownPointer = PixelChipsetDD;
      break;        
    case 4:  //device.HardwareID
      HardwareButtons[2].display();  
      break;      
    case 5: //DMX Adress
      TextFields[2].display(); //DMX Address
      break;      
    case 6:
      Label = "DMX Reception\nMode - ID Number: "+DMXModesDD.selStr;
      DMXModesDD.display(); //has to be last so it overlays everything else
      break;  
    case 7:
      MasterModeDD.display();
      break;
    case 8:
      HardwareCheckBox[0].display();
      fill(0);
      textAlign(LEFT);
      text("16-Bit Serial", HardwareCheckBox[0].xpos+25, HardwareCheckBox[0].ypos+15);    
      Label = "Serial Baud Rate:\nID Number: "+BaudRateDD.selStr;
      BaudRateDD.display();  
      break;
    case 9:
      LEDIndicatorModeADD.display();
      break;  
    case 10:
      DisplayModeDD.display();
      break;  
    case 11:
      AutoDetectDD.display();  
      break;      
    case 12: //fGammaCorrectionEnabled
      HardwareButtons[3].display();
      break;      
    case 13: //Automatic Shut Off/Resume Time Out Value
      AccMeterAutoDetectDD.display();  
      AccMeterAutoDetectModeDD.display();  
      break;        
    case 14: //Enable Accelerometer Speed Adjustment
      HardwareButtons[4].display();
      break;
    case 15: //Enable Double Tap Button Press
      AccMeterTapDD.display();  
      break;
    case 16: //Power Down Time Out
      PowerDownTimeOutDD.display();  
      break;    
    case 17: //Packet Clone

      break;  
    case 18: //Fade Transition

      break;
    case 19: //Dual Communication Mode
      HardwareCheckBox[1].display();  
      fill(0);
      textAlign(LEFT);
      text("Enable", HardwareCheckBox[1].xpos-45, HardwareCheckBox[1].ypos+15); 
      break;  
    case 20: //PWM Freq A
      PWMFreqADD.display();
      break;
    case 21: //Stand-Alone A
      StandAloneADD.display();
      TextFields[13].display();
      fill(0);
      textAlign(LEFT);
      textSize(12);
      text("Enter Sequence ID#:", TextFields[13].xpos-90, TextFields[13].ypos-5);
      break;
    case 22: //PWM Profile
      PWMProfileADD.display();
      break;  
    case 23: //I.R. Remote addon card
      IRRemoteModeDD.display();
      break;      
      //start added modules
    case 24: //DMX Pixel Amount:
      TextFields[4].display();
      break;
    case 25: //"Enable Activity LED:
      HardwareCheckBox[2].display();
      break;
    case 26: //DMX Decoder Mode:

      break;
    case 27: //Enable Serial Color Swap:
      HardwareCheckBox[3].display();
      break;
    case 28: //Select Color Order For Chipset:
    
      break;
    case 29: //End-Of-Frame Timer
      TextFields[3].display();
      break;
    case 30: //mini Serial Baud Rate

      break;
    case 31: //DMX Timeout auto release
      DMXAutoReleaseDD.display();
      break;   
    case 32: //Legancy Signal Loss Auto Detection

      break;   
    case 33: //Legacy Reception mode. DMX or serial

      break;  
    case 34: //Hardware color order
      HardwareColorReOrderDD.display();
      break;   
    case 35: //Expansion Header Mode
      StandardExpansionHeaderDD.display();
      break;
      case 36: //glediator protocol override
      GlediatorOverrideDD.display();
      break;
    }

    textAlign(CENTER);
    textSize(12);  
    textLeading(14);
    fill(0);
    text(Label, xpos+5, ypos+10, bWidth-10, bHeight-10);
  } //end display

  //-------------------------------------------------------------------------------------------------------

  void InitPositions()
  {

    switch(IDnumber)
    {
    case 0:  //device.RS485Capable
      HardwareButtons[0].xpos = xpos+30;
      HardwareButtons[0].ypos = ypos+55;
      break;    
    case 1:  //second LED indicator
      LEDIndicatorModeBDD.xpos = xpos+10;
      LEDIndicatorModeBDD.ypos = (ypos+(bHeight))-40;
      break;      
    case 2:  //device.GlobalColorShift  
      HardwareColSwapDD.xpos = xpos+10;            
      HardwareColSwapDD.ypos = ypos+60;      
      break;      
    case 3:  //Pixel Chipset
      PixelChipsetDD.xpos = xpos+10;    
      PixelChipsetDD.ypos = ypos+35;    
      break;        
    case 4:  //device.HardwareID
      HardwareButtons[2].xpos = xpos+60;
      HardwareButtons[2].ypos = ypos+55;  
      break;  
    case 5:  
      TextFields[2].xpos = xpos+20;
      TextFields[2].ypos = ypos+45;        
      break;        
    case 6: //DMX Reception Mode  
      DMXModesDD.xpos = xpos+5;
      DMXModesDD.ypos = ypos+45;      
      break;      
    case 7: //DMX Master Mode
      if (device.Bit16Mode == true)
      {
        MasterModeDD.labels = cDDMasterModesMultiBit;
        MasterModeDD.numStrs = cDDMasterModesMultiBit.length;
      } else
      {
        MasterModeDD.labels = cDDMasterModes8Bit;
        MasterModeDD.numStrs = cDDMasterModes8Bit.length;
      }
      MasterModeDD.xpos = xpos+10;
      MasterModeDD.ypos = (ypos+(bHeight))-35;  
      break;      
    case 8:
      BaudRateDD.xpos = xpos+10;
      BaudRateDD.ypos = ypos+45;  

      HardwareCheckBox[0].xpos = xpos+10;
      HardwareCheckBox[0].ypos = (ypos+(bHeight))-25;  

      //set checkbox grey out or not if enabled
      if (IsOnConfigFlags("f8or16Bit") == true) HardwareCheckBox[0].status = 0; //0=show, 1=grey out, 2=hide
      else HardwareCheckBox[0].status = 1; //0=show, 1=grey out, 2=hide    
      break;  
    case 9:
      LEDIndicatorModeADD.xpos = xpos+10;
      LEDIndicatorModeADD.ypos = (ypos+(bHeight))-40;
      break;  
    case 10:
      DisplayModeDD.xpos = xpos+10;
      DisplayModeDD.ypos = (ypos+(bHeight))-40;
      break;  
    case 11:
      AutoDetectDD.xpos = xpos+10;
      AutoDetectDD.ypos = (ypos+(bHeight))-40;      
      break;      
    case 12://fGammaCorrectionEnabled
      HardwareButtons[3].xpos = xpos+30;
      HardwareButtons[3].ypos = ypos+55;  
      break;  
    case 13: //Automatic Shut Off/Resume Time Out Value
      AccMeterAutoDetectModeDD.xpos = xpos+10;    
      AccMeterAutoDetectModeDD.ypos = ypos+40;
      AccMeterAutoDetectDD.xpos = xpos+10;    
      AccMeterAutoDetectDD.ypos = ypos+70;    
      break;        
    case 14: //Enable Accelerometer Speed Adjustment
      HardwareButtons[4].xpos = xpos+30;
      HardwareButtons[4].ypos = ypos+45;  
      break;
    case 15: //Enable Double Tap Button Press
      AccMeterTapDD.xpos = xpos+20;    
      AccMeterTapDD.ypos = ypos+55;  
      break;    
    case 16: //Power Down Time Out  
      PowerDownTimeOutDD.xpos = xpos+10;
      PowerDownTimeOutDD.ypos = (ypos+(bHeight))-40;  
      break;
    case 17: //empty

      break;  
    case 18: //empty

      break;  
    case 19: //Dual Communication Mode
      HardwareCheckBox[1].xpos=xpos+70;  
      HardwareCheckBox[1].ypos=ypos+65;  
      break;  
    case 20: //PWM Freq A
      PWMFreqADD.xpos=xpos+10;
      PWMFreqADD.ypos=(ypos+(bHeight))-40;  
      break;
    case 21: //Stand-Alone A
      StandAloneADD.xpos=xpos+5;  
      StandAloneADD.ypos=(ypos+(bHeight))-35;      
      TextFields[13].xpos=xpos+125;  
      TextFields[13].ypos=(ypos+(bHeight))-35;  
      break;
    case 22: //PWM Profile
      PWMProfileADD.xpos = xpos+10;
      PWMProfileADD.ypos = (ypos+(bHeight))-35;      
      break;      
    case 23: //I.R. Remote Add on
      IRRemoteModeDD.xpos = xpos+10;
      IRRemoteModeDD.ypos = (ypos+(bHeight))-35;      
      break;
    case 24: //DMX Pixel Amount:
      TextFields[4].xpos = xpos+20;
      TextFields[4].ypos = (ypos+(bHeight))-50;   
      break;
    case 25: //"Enable Activity LED:
      HardwareCheckBox[2].xpos=xpos+50;  
      HardwareCheckBox[2].ypos=ypos+40;  
      break;
    case 26: //DMX Decoder Mode:
     
      break;
    case 27: //Enable Serial Color Swap:
      HardwareCheckBox[3].xpos=xpos+50;  
      HardwareCheckBox[3].ypos=ypos+50;  
      break;
    case 28: //Select Color Order For Chipset:
   
      break;
    case 29: //End-Of-Frame Timer
      TextFields[3].xpos = xpos+20;
      TextFields[3].ypos = (ypos+(bHeight))-35;   
      break;
    case 30: //mini Serial Baud Rate
     
      break;
    case 31: //DMX Timeout auto release
      DMXAutoReleaseDD.xpos = xpos+10;
      DMXAutoReleaseDD.ypos = ypos+50;        
      break;     
    case 32: //Legancy Signal Loss Auto Detection
      AutoReleaseLegacyDD.xpos = xpos+10;
      AutoReleaseLegacyDD.ypos = (ypos+(bHeight))-35;        
      break;   
    case 33: //Legacy Reception mode. DMX or serial
      ReceptionModeLegacyDD.xpos = xpos+10;
      ReceptionModeLegacyDD.ypos = (ypos+(bHeight))-35;        
      break;
    case 34: //Native color order
      HardwareColorReOrderDD.xpos = xpos+10;
      HardwareColorReOrderDD.ypos = (ypos+(bHeight))-35;   
      break;   
    case 35: //Expansion Header Mode
      StandardExpansionHeaderDD.xpos = xpos+10;
      StandardExpansionHeaderDD.ypos = (ypos+(bHeight))-35;   
      break;
    case 36: //glediator protocol override
      GlediatorOverrideDD.xpos = xpos+10;
      GlediatorOverrideDD.ypos= (ypos+60);   
      break;     
    }
  }//end InitPositions

  //-------------------------------------------------------------------------------------------------------

  int GetBitValues(int passedID)
  {

    switch(IDnumber)
    {
    case 0:  //device.RS485Capable
      //"fRS485Enable,f8or16Bit"
      if (HardwareButtons[0].selected && passedID == 0)  return 1;//fRS485Enable
      if (HardwareCheckBox[0].selected && passedID == 1) return 1;//f8or16FBit
      break;    
    case 1: //LED Indicator Mode 2

      break;      
    case 2:  //bGlobalColorShift

      break;      
    case 3:  //Pixel Chipset

      break;        
    case 4: //Enable Serial Reception Instead of DMX

      break;  
    case 5:  //DMX Adress

      break;        
    case 6: //DMX Reception

      break;      
    case 7: //DMX Master Mode

      if (IsOnConfigFlags("fMaster16Bit") == true) 
      {
        //"fMasterEnable,fMasterFullPkts,fMaster16Bit"
        switch(MasterModeDD.selStr)
        {
        case 0: //None
          //both ID flag and Autodetect stay 0

          return 0;
        case 1: //Master Full Pkts 8-Bit
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable
          //temp2Flags = temp2Flags | 0x02; //fMasterFullPkts(1 is Full, 0 is partial)
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 1;//fMasterFullPkts(1 is Full, 0 is partial)
          if (passedID == 2)       return 0;//fMaster16Bit  stays 0            
          //fMaster16Bit stays 0  
          break;
        case 2: //Master Full Pkts 16-Bit
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable
          //temp2Flags = temp2Flags | 0x02; //fMasterFullPkts(1 is Full, 0 is partial)  
          //temp2Flags = temp2Flags | 0x04; //fMaster16Bit
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 1;//fMasterFullPkts(1 is Full, 0 is partial)
          if (passedID == 2)       return 1;//fMaster16Bit  stays 0            

          break;
        case 3:  //Master Partial Pkts 8-Bit
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable  
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 0;//fMasterFullPkts(1 is Full, 0 is partial) 
          if (passedID == 2)       return 0;//fMaster16Bit  stays 0      
          break;  
        case 4:  //Master Partial Pkts 16-Bit
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable  
          //temp2Flags = temp2Flags | 0x04; //    
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 0;//fMasterFullPkts(1 is Full, 0 is partial)
          if (passedID == 2)       return 1;//fMaster16Bit  
          break;
        }//end switch
      } else
      {
        //"fMasterEnable,fMasterFullPkts"
        switch(MasterModeDD.selStr)
        {
        case 0: //None
          //both ID flags  
          return 0;
        case 1: //Master Full Packets
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable
          //temp2Flags = temp2Flags | 0x02; //fMasterFullPkts(1 is Full, 0 is partial)
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 1; //fMasterFullPkts

          break;
        case 2: //Master Partial Packets
          //temp2Flags = temp2Flags | 0x01; //fMasterEnable        
          if (passedID == 0)       return 1;//fMasterEnable
          if (passedID == 1)       return 0;//fMasterFullPkts(1 is Full, 0 is partial) - leave it 0
          break;
        }//end switch
      }

      break;      
    case 8: //Serial Baud Rate
      if (HardwareCheckBox[0].selected == true) return 1;  
      return 0;
      //break;  
    case 9: //LED Inidicator A
      //11 "Both", 01"Stand-Alone", 10"RX", 00"Disabled"
      //"fLEDModeMSBa,fLEDModeLSBa"
      switch(LEDIndicatorModeADD.selStr) //LEDMode
      {
      case 0: //Both
        //tempFlags = tempFlags | 0x0C;
        if (passedID == 0)       return 1;
        if (passedID == 1)       return 1;
        break;
      case 1: //Stand-Alone
        //tempFlags = tempFlags | 0x04;
        if (passedID == 0)       return 0;
        if (passedID == 1)       return 1;      
        break;
      case 2: //RX only
        //tempFlags = tempFlags | 0x08;
        if (passedID == 0)       return 1;
        if (passedID == 1)       return 0;        
        break;
      case 3: //disabled
        //no change both 00
        return 0;
      }
      break;  
    case 10: //External LED Display Mode
      //"fDisModeMSBa,fDisModeLSBa"
      switch(DisplayModeDD.selStr)
      {
      case 0: //Always On
        //00 is always on
        return 0;
      case 1: //Countdown
        if (passedID == 0)       return 1;
        if (passedID == 1)       return 0;
        break;
      case 2: //Dim
        if (passedID == 0)       return 0;
        if (passedID == 1)       return 1;
        break;
      case 3: //both
        if (passedID == 0)       return 1;
        if (passedID == 1)       return 1;
        break;
      }
      break;  
    case 11: //Standard Auto-Detect
      switch(AutoDetectDD.selStr)
      {
      case 0: //None
        //both ID flag and Autodetect stay 0
        return 0;
      case 1: //Autodetect DMX
        //tempFlags = tempFlags | 0x10; //Set AutoDetectID Flag to 1
        //tempFlags = tempFlags | 0x20; //Set AutoDetectEnable Flag to 1
        if (passedID == 0)       return 1;
        if (passedID == 1)       return 1;
        break;
      case 2: //Autodetect Serial
        //AutoDetectID Flag stays 0 for serial
        //tempFlags = tempFlags | 0x20; //Set AutoDetectEnable Flag to 1
        if (passedID == 0)       return 0;
        if (passedID == 1)       return 1;
        break;
      }//end switch
      break;      
    case 12: //Gamma Correction Enabled
      if (HardwareButtons[3].selected == true) return 1;
      return 0;
    case 13: //Automatic Shut Off/Resume Time Out Value
      if (passedID == 0) if (AccMeterAutoDetectDD.selStr > 0) return 1;
      if (passedID == 1) if (AccMeterAutoDetectModeDD.selStr == 1) return 1;
      //if(AccMeterAutoDetectDD.selStr > 0)  return 1; //fAccMeterAutoShutOff
      //if(AccMeterAutoDetectModeDD.selStr > 0)  return 1; //fAccMeterAutoShutOffMode
      return 0; //break;        
    case 14: //Enable Accelerometer Speed Adjustment
      if (HardwareButtons[4].selected)  return 1;//fAccMeterMovement
      return 0; //break;
    case 15: //Enable Double Tap Button Press
      if (AccMeterTapDD.selStr > 0) return 1;//fAccMeterDoubleTap
      return 0; //break;    
    case 16: //Power Down Time Out  

      break;
    case 17:

      break;  
    case 18:

      break;  
    case 19: //Dual Communication Mode
      if (HardwareCheckBox[1].selected == true) return 1; //fDualModeCom
      return 0; //break;  
    case 20: //PWM Freq A

      break;
    case 21: //Stand-Alone A

      break;
    case 22: //PWM Profile

      break;    
    case 23: //IR Remote Addon
      switch(IRRemoteModeDD.selStr)
      {
      case 0: //None
        //both ID flags  0
        return 0;
      case 1: //Enabled, 19200, 1-0
        if (passedID == 0)   return 1;
        if (passedID == 1)   return 0;  
        break;
      case 2: //Enabled, 250k, 1-1  
        if (passedID == 0)   return 1;
        if (passedID == 1)   return 1;
        break;
      }//end switch
      break;

      //start added modules
    case 24: //DMX Pixel Amount:

      break;
    case 25: //"Enable Activity LED:
      if (HardwareCheckBox[2].selected == true) return 1; //fActivityLEDEnable
      else return 0;
      //break;
    case 26: //DMX Decoder Mode:

      break;
    case 27: //Enable Serial Color Swap:
      if (HardwareCheckBox[3].selected == true) return 1; //fEnableSerialColorSwap
      break;
    case 28: //Select Color Order For Chipset:
    
      break;
    case 29: //End-Of-Frame Timer

      break;
    case 30: //mini Serial Baud Rate

      break;
    case 31: //DMX Timeout auto release
      switch(DMXAutoReleaseDD.selStr)
      {
      case 0: //None
        //both ID flags  0
        return 0;
      case 1: //Enabled, Restore Sequence
        if (passedID == 0)   return 1;
        if (passedID == 1)   return 0;  
        break;
      case 2: //Enabled, Play Idle  
        if (passedID == 0)   return 1;
        if (passedID == 1)   return 1;
        break;
      }//end switch
      break;
    case 32: //Legancy Signal Loss Auto Detection
      if (AutoReleaseLegacyDD.selStr == 0) return 0;
      else return 1;
      //break;   
    case 33: //Legacy Reception mode. DMX or serial
      if (ReceptionModeLegacyDD.selStr == 0) return 0;
      else return 1;    
      //break;
    case 34: //Hardware color order
      if(HardwareColorReOrderDD.selStr == 0) return 0;
      else return 1;
      //break;   
    case 35: //Expansion Header Mode
      
     break;
      case 36: //glediator protocol override
      if(GlediatorOverrideDD.selStr == 0) return 0;
      else return 1;
     //break;           
    }  //end switch 

    println("Did not find InputModule[] to GetBitValues() from with ID "+IDnumber);
    return 0;
  } //end GetBitValues()

  //-------------------------------------------------------------------------------------------------------

  int GetByteValues(int passedID)
  {
    switch(IDnumber)
    {
    case 0:  //device.RS485Capable

      break;    
    case 1:

      break;      
    case 2:  //bGlobalColorShift
      return (HardwareColSwapDD.selStr); //Global Color Swap    
    case 3:  //Pixel Chipset
      return (PixelChipsetID[PixelChipsetDD.selStr]); //Pixel Type    
    case 4: //Enable Serial Reception Instead of DMX

      break;  
    case 5:  //DMX Adress
      if (passedID == 0)   return ((int(TextFields[2].label) >> 8) & 0xFF); //DMXAdr MSB
      if (passedID == 1)   return (int(TextFields[2].label) & 0xFF); //DMXAdr LSB
      break;        
    case 6: //DMX Reception Mode
      return DMXModesDD.selStr;  //DMX Mode ID    
    case 7: //DMX Master Mode

      break;      
    case 8: //Serial Baud Rate
      return BaudRateDD.selStr; //BaudRateID
    case 9: //LED Inidicator A

      break;  
    case 10: //External LED Display Mode

      break;  
    case 11: //Standard Auto-Detect

      break;      
    case 12: //Gamma Correction Enabled

      break;  
    case 13: //Automatic Shut Off/Resume Time Out Value
      return (cAccMeterShutOffVals[AccMeterAutoDetectDD.selStr]);   //Timeoutval      
    case 14: //Enable Accelerometer Speed Adjustment

      break;
    case 15: //Enable Double Tap Button Press

      return (AccMeterTapDD.selStr);  //Double Tap Mode  
    case 16: //Power Down Time Out  

      break;
    case 17:

      break;  
    case 18:

      break;  
    case 19: //Dual Communication Mode

      break; 
    case 20: //PWM Freq LegacyA
      return (PWMFreqADD.selStr+4); //4,5,6,7 are loaded into T6CON
    case 21: //Stand-Alone Legacy A
      switch(StandAloneADD.selStr) //either 10-42 for sequences, 1 for hold, 2 for blank, 3 blank with fade out
      {
      case 0: //hold
      case 1: //blank
      case 2: //fade out
        return (StandAloneADD.selStr+1); //0 is null so add 1
      case 3: //stand alone
        return ((int(TextFields[13].label)+9)); //10+ is sequences, base 0, textfield should be at least 1
      }  //end switch
      break;
    case 22: //PWM Profile
      return (PWMProfileADD.selStr);  //16-bit lamp PWM Profile  
    case 23: //IR Remote Add On

      break;
      //start added modules
    case 24: //DMX Pixel Amount:
      if (passedID == 0)   return ((int(TextFields[4].label) >> 8) & 0xFF); //DMXAdr MSB
      if (passedID == 1)   return (int(TextFields[4].label) & 0xFF); //DMXAdr LSB
      break;
    case 25: //Enable Activity LED:

      break;
    case 26: //DMX Decoder Mode:

      break;
    case 27: //Enable Serial Color Swap:

      break;
    case 28: //Select Color Order For Chipset:

      break;
    case 29: //End-Of-Frame Timer
      return int((int(TextFields[3].label) * 1000)  / 128);
      //break;
    case 30: //mini Serial Baud Rate
      //return BaudRateMiniV4DD.selStr; //BaudRateID
    case 31: //DMX Timeout auto release

      break;
    case 32: //Legancy Signal Loss Auto Detection

      break;   
    case 33: //Legacy Reception mode. DMX or serial

      break;
    case 34: //Hardware color order

        break;   
    case 35: //Expansion Header Mode
      return StandardExpansionHeaderDD.selStr;
      //break;
    case 36: //glediator protocol override

     break;         
    }  //end switch  

    println("Did not find InputModule[] to GetByteValues() from with ID "+IDnumber);
    return 0;
  } //end GetByteValues()

  //-------------------------------------------------------------------------------------------------------

  boolean over() 
  {
    if (Enabled == false) return false;  

    if (mouseXS >= xpos && mouseXS <= xpos+bWidth && mouseYS >= ypos && mouseYS <= ypos+bHeight) 
    {      
      return true;
    } 
    else {
      return false;
    }
  }

  //-------------------------------------------------------------------------------------------------------

  void PlaceTile()
  {
    if (InputModule[IDnumber].bWidth < moduleHoldSz)
    {
      //println("Module "+IDnumber+" with width of: "+InputModule[IDnumber].bWidth+" can fit at Y: "+moduleHoldY+", X: "+moduleHoldX+" with available: "+moduleHoldSz);  

      InputModule[IDnumber].xpos = moduleHoldX;    
      InputModule[IDnumber].ypos = moduleHoldY;

      moduleHoldX = 0;
      moduleHoldY = 0;
      moduleHoldSz = 0;
    } 
    else if ((modulePosX + InputModule[IDnumber].bWidth) < (cInputModuleOffsetX+cInputModuleAreaWidth))  
    {
      InputModule[IDnumber].xpos = modulePosX;    
      modulePosX += (InputModule[IDnumber].bWidth+10);
      InputModule[IDnumber].ypos = modulePosY;
    } 
    else 
    {
      //saves previous row extra space and will try to fit something in
      if (((cInputModuleOffsetX+cInputModuleAreaWidth) - modulePosX) > moduleHoldSz)
      {
        //if new row size is larger than last, use it, otherwise utilize largest space  
        moduleHoldX = modulePosX;
        moduleHoldY = modulePosY;
        moduleHoldSz = (cInputModuleOffsetX+cInputModuleAreaWidth) - modulePosX;    
        //println("remaining Module Size: "+moduleHoldSz);
      }

      modulePosY += cInputModuleHeight+10;
      InputModule[IDnumber].xpos = cInputModuleOffsetX;
      modulePosX = cInputModuleOffsetX + (InputModule[IDnumber].bWidth+10);
      InputModule[IDnumber].ypos = modulePosY;
    }

    InputModule[IDnumber].Enabled = true;
    InputModule[IDnumber].InitPositions();
  } //end func
}  //end class

//==================================================================================================================================================
