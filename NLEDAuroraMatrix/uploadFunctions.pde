
//================================================================================================

final int mStall = 0;
final int mFade = 1;
final int mGradient = 2;
final int mInstant = 3;
final int mTech = 4;
final int mPOV = 5;
final int mFilePlay = 6; //only sequence mode supported
final int mLinked = 7;

//================================================================================================

void BuildUSBPacket(int dataValue)
{
  //THIS DO ANYTHING? ALL DEVICES ERASE AT FIRST PACKET....  
  SendCounter++; //used for 
  SendCounterB++; //counts all bytes
  if (SendCounter >= device.EraseBlockSize)
  {
    delay(5); //delay to allow the device to erase the next block
    SendCounter = 0;
  }
  //end this  

  USBPacket[PacketPointer] =  byte(dataValue);
  PacketPointer++;

  if (PacketPointer == 64) //always sends in blocks of 64, that is built into 64/128/192/256 byte sized packets
  {  
    //packet full, send it  
    PacketPointer = 0;
    try {    

      if (CommunicationMode == 0) serialPort.write(USBPacket); //send a full 64 byte packet all at once
      else if (CommunicationMode == 1) TCPClient.write(USBPacket);    

      USBpacketCount++;

      //this runs the routine for waiting for "zAck"
      if (SendCounter == device.CurrentBlockSize)
      {
        println("Waiting for ACK, USBPacket: "+USBpacketCount+"    SendCounter: "+SendCounter);
        SendCounter = 0;
        while (WaitForAckFlag == false) 
        {
          delay(1); //runs infinitly til ack flag is set, needs delay to not error, but not locking
          if (TerminateUpload == true) { 
            break;
          } //once set will force the function to finish and thread to end
        }
        WaitForAckFlag = false; //set back to false
        redraw();
      }
    }
    catch(Exception e)
    {
      println("Unable to Send Packet");  
      redraw();
    }
  }  //end if()
}  //end BuildUSBPacket()

//===================================================================================================

void BreakValueForUSBPacket(int passedValue, int passedType)
{
  //breaks address value into properly sized bytes, either 16-bit or 32-bit  
  //println("Passed:" +passedValue);
  switch(passedType)
  {
  case 0: //16-bit 
    BuildUSBPacket((passedValue>>8)); //MSB  
    BuildUSBPacket(passedValue); //LSB, correct order?
    break;

  case 1: //32-bit
    BuildUSBPacket((passedValue>>24));
    //println((passedValue>>24));    
    BuildUSBPacket((passedValue>>16)); //MSB   
    //println((passedValue>>16)); //MSB   
    BuildUSBPacket((passedValue>>8)); //MSB      
    //println((passedValue>>8)); //MSB      
    BuildUSBPacket(passedValue); 
    //println(passedValue& 0xFF); 
    break;
  } //end switch
} //end BreakUSBValue()  

//=====================================================================================================

void BreakUSBValue(int passedValue)
{
  //breaks address value into properly sized bytes, either 16-bit or 32-bit    
  switch(device.IndexMemoryModel)
  {
  case 0: //standard 16-bit     
    BuildUSBPacket(passedValue); //LSB, correct order?
    BuildUSBPacket((passedValue>>8)); //MSB  
    if (device.FillUpperData == true)  BuildUSBPacket(0); //fill upper with 0   
    break;

  case 1: //32-bit  
    BuildUSBPacket(passedValue); 
    BuildUSBPacket((passedValue>>8)); //MSB  
    if (device.FillUpperData == true)  BuildUSBPacket(0); //fill upper with 0     
    BuildUSBPacket((passedValue>>16)); //MSB 
    BuildUSBPacket((passedValue>>24));  
    if (device.FillUpperData == true)  BuildUSBPacket(0); //fill upper with 0     
    break;
  } //end switch
} //end BreakUSBValue()  

//================================================================================================

void StartSequenceUpload()
{
  println("StartSequenceUpload()    IndexedMemoryUsage: "+IndexedMemoryUsage);
  ShowNotification(11);

  UpdateIndexMemoryUsage();
  if (IndexedMemoryUsage > device.DataSpace) return; //SHOULD NEVER GET HERE BUT LEAVE IF IT DOES

  int adrCount = 0;
  int i = 0; //declare it here so the result can be used outside 

  sequence[0].mappedROMAdr = adrCount; 

  for (i = 1; i < IndexedSequences; i++) //was not equals to
  {
    adrCount += sequence[i-1].memorySize;
    sequence[i].mappedROMAdr = adrCount; //store for the sequence header
  } //end for()

  println("Total Sequences Length in Bytes: "+IndexedMemoryUsage);

  //--------------------------------------------------------------------------------------------------------------

  int tempExpectedPacketsIndex = 0;
  //IndexMemoryModel: 0 = 16-bit, 1 = 32-bit
  if (device.IndexMemoryModel == 0)
  {
    tempExpectedPacketsIndex +=  device.MaxIndexedSequences * 2;//length of Index Map
    if (device.FillUpperData == true) tempExpectedPacketsIndex +=  device.MaxIndexedSequences;
  } else if (device.IndexMemoryModel == 1)
  {
    tempExpectedPacketsIndex +=  device.MaxIndexedSequences * 4;//length of Index Map
    if (device.FillUpperData == true) tempExpectedPacketsIndex +=  device.MaxIndexedSequences * 2;
  }

  tempExpectedPacketsIndex =  ceil((float)tempExpectedPacketsIndex/device.IndexBlockSize);    
  int tempExpectedPacketsSequence = ceil((float)IndexedMemoryUsage/device.SeqMemoryBlockSize); 

  println("Index Space Length, in packets: "+tempExpectedPacketsIndex);
  int totalExpectedPackets = tempExpectedPacketsIndex + tempExpectedPacketsSequence;

  device.CurrentBlockSize = device.IndexBlockSize;  //start with IndexBlockSize since that is first

  println("Index Pkts("+device.IndexBlockSize+"): "+tempExpectedPacketsIndex+"     Seq Pkts("+device.SeqMemoryBlockSize+"): "+tempExpectedPacketsSequence);
  println("Total Pkts(variable size): "+totalExpectedPackets);

  println("RequestFullUpload()   Sequence Bytes: "+(IndexedMemoryUsage)+" : IndexedSequences: "+IndexedSequences+"    CurrentBlockSize: "+device.CurrentBlockSize);
  cmdByte = cmdFullSeqUpload; //Upload Sequences
  cmdData[0] = ((totalExpectedPackets) >> 8) & 0xFF; //MSB
  cmdData[1] = (totalExpectedPackets) & 0xFF; //LSB
  cmdData[2] = IndexedSequences-1;  //Max Sequences
  cmdData[3] = 0;   //send idle sequence ID number
  RequestCommand();
} //end func

//===================================================================================================

void SendSequence(int passedSeqID)
{
  println("SendSequence() "+(passedSeqID)+"    Start SendCounterB="+SendCounterB+"    Total Bytes to Send: "+(sequence[passedSeqID].memorySize));

  //Set Default Message
  DisplayMessageStr = "Attempting to Upload Sequence Data. Slot# "+(passedSeqID+1);

  //----------------------------------------- Pack & Send Header  -----------------------------------------

  SendSequenceHeader(passedSeqID); //send header using passedSeqID

  //----------------------------------------- Header Packed  --------------------------------------------

  float GlobalIntensity = (float)int(comGlobalIntensityField.value) / 100;  
  println("GlobalIntensity: "+GlobalIntensity);
  println(sequence[passedSeqID].totalFrames+"   "+matrix.patchedChannels);

  ColorOrderCounter = 0; //reset variable

  for (int q = 0; q < sequence[passedSeqID].totalFrames; q++)
  {
    //for (int i = 0; i != matrix.patchedChannels; i++)  BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));

    for (int i = 0; i < UtilizedChannels; i+=3)
    {  
      switch(comHardwareColorReOrderDD.selStr)
      {
      case 0://RGB
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        break;
      case 1: //BRG
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));          
        break;
      case 2: //GBR
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));         
        break;
      case 3: //RBG
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));  
        break;
      case 4: //BGR
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));
        break;
      case 5: //GRB - WS2812B
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+1] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i] * GlobalIntensity));
        BuildUSBPacket(int(sequence[passedSeqID].dataFrames[q][i+2] * GlobalIntensity));
        break;
      } //end switch
    } //end for()
  }//end for()
} //end func

//================================================================================================

void SendSequenceHeader(int passedSeqID)
{
  /*
  32-bit(?) First bytes should be length/or address, and that should be double checked against the Index address, make sure they match or bad data
   8-bit Mode, the mode alters the header and data storing methods - Stall - Fade - Gradient - Instant - Technical(Combo)- POV - Video - Linked
   16-bit Max Frames - SeqFrameAmount
   32-bit speed - for long instants
   16-bit Sequence Channels - MSB - LSB - SeqDataSize
   8-bit Sequence Flags (T2-T1-T0-P2-P1-P0-D1-D0)
   - (3-bits) Transistion In/Start: Fade Up/Down, Instant, 6 spots for others
   - (3-bits) One shot and stop at end values, one shot and stop at start values, one shot and blank, one shot and go to next sequence, standard loop  
   - (2-bits) Data Type Single/RGB/RGBW/EXTRA
   8-bit POV Flags OR Seqeunce Transition Speed Value
   - (4-Bits) POV Flag bits 
   - (4-Bits) Enable accmeter option
   8-bit Packet Clone value or hardware specific?
   = 16 bytes   
   */

  BreakValueForUSBPacket(sequence[passedSeqID].mappedROMAdr, 1);//break 32-bit number into 4 bytes
  //BuildUSBPacket(0); //Index ID MSB3
  //BuildUSBPacket(0); //MSB2
  //BuildUSBPacket(0); //LSB1
  //BuildUSBPacket(0); //LSB0

  BuildUSBPacket(mFilePlay); //no other sequence modes available on the Aurora Matrix Firmware

  BreakValueForUSBPacket((sequence[passedSeqID].totalFrames-1), 0); //break into 16-bit number

  BreakValueForUSBPacket(sequence[passedSeqID].speed, 1); //break into 32-bit number

  //BreakValueForUSBPacket(matrix.patchedChannels, 0);   //break into 16-bit number
  BreakValueForUSBPacket(UtilizedChannels, 0);   //break into 16-bit number

  //(TF2-TF1-TF0-PM2-PM1-PM0-DT1-DT0)
  int tempStorage = 0; //start with all 0s
  tempStorage = 1; //RGB - only color data type available - No RGBW or single color
  tempStorage = (sequence[passedSeqID].playMode << 2) | tempStorage;
  tempStorage = (sequence[passedSeqID].transition << 5) | tempStorage;
  BuildUSBPacket(tempStorage); //Send packed SeqFlags

  BuildUSBPacket(0); 
  BuildUSBPacket(0); //if true send 0 for now...  //Packet Cloning or Hardware Specific, seems to work on hardware
} //end SendSequenceHeader()

//================================================================================================

void FullIndexUpload()
{
  println("FullUpload()");

  for (int q = 0; q < IndexedSequences; q++) BreakUSBValue(sequence[q].mappedROMAdr);//IndexMapArray[q]);    

  //Finish off index slots with 0000s
  for (int i = IndexedSequences; i != device.MaxIndexedSequences; i++)   BreakUSBValue(0);  

  println("Sent "+SendCounterB+" index bytes");

  //--------------------------------------- End Map Built --------------------------------------------------

  //Switch from IndexBlockSize to Seqblocksize
  device.CurrentBlockSize = device.SeqMemoryBlockSize;

  for (int i = 0; i < IndexedSequences; i++)
  {
    println("Running with "+i);
    SendSequence(i);
  }  //end for()

  println("TotalSent: "+SendCounterB);     
  println("Left to Send: "+(device.CurrentBlockSize - (SendCounter%device.CurrentBlockSize)));

  while ((float)(SendCounterB%device.CurrentBlockSize) != 0)
  {  
    BuildUSBPacket(33); //send dummy
  } 

  println("Indexed & Sequences Sent");
  UploadInProgress = false;  //do it here not from switch()  
  redraw();
}//end FullUpload()

//===================================================================================================  

void SendConfigurations()
{
  println("SendConfigurations()"); 

  String[] ModuleString = new String[16];  
  int[] TransmitByteArray = new int[16];  
  DevStrArray = split(device.ConfigFlagsStr, ',');
  //Now single delimenated string is an array, the pointer is the bit number in ConfigFlags  

  //Module0 with matching string ex:   "fDisModeMSBa,fDisModeLSBa"
  //Module1 with matching string ex:   "fAutoDetectID,fAutoDetect"
  //Loop goes through enabled modules, checks the string to the DevStr array  
  //  If a module string matches the list build ConfigFlags

  ConfigFlags = 0; //reset flags here.....

  for (int y = 0; y != InputModule.length; y++)
  {  
    if (InputModule[y].Enabled == true)
    {
      ModuleString = split(InputModule[y].ModuleFlagStr, ',');

      for (int q = 0; q != ModuleString.length; q++)
      {  
        for (int i = 0; i != DevStrArray.length; i++)
        {  
          if (DevStrArray[i].equals(ModuleString[q]) == true) //if string matches
          {
            //println("String Matches "+ModuleString[q]+" on Bit ID# "+i+"   StrID: "+q);

            if (InputModule[y].GetBitValues(q) == 1) bitSet(i); //this pretty much does it gotta setup modules
          }
        } //end i for()
      } //end q for()
    } //end if
  } //end y for()

  println("ConfigFlags: "+binary(ConfigFlags, 16));

  for (int i = 0; i != TransmitByteArray.length; i++) TransmitByteArray[i] = 0; //clear array first
  TransmitByteArray[0] = (ConfigFlags >> 8); //MSB first
  TransmitByteArray[1] = ConfigFlags & 0xFF;  //LSB second
  ///NOW RUN CONFIGURATION BYTES  

  DevStrArray = split(device.ConfigBytesStr, ',');  //load device config byte string

  for (int y = 0; y != InputModule.length; y++)
  {    
    if (InputModule[y].Enabled == true)
    {
      ModuleString = split(InputModule[y].ModuleByteStr, ',');

      for (int q = 0; q != ModuleString.length; q++)
      {  
        for (int i = 0; i != DevStrArray.length; i++)
        {  
          if (DevStrArray[i].equals(ModuleString[q]) == true) //if string matches
          {
            //println("Set Byte - String Matches "+ModuleString[q]+" on BYTE# "+(i+2));
            TransmitByteArray[i+2] = InputModule[y].GetByteValues(q);
          }
        } //end i for()
      } //end q for()
    } //end if
  } //end y for()

  printArray(TransmitByteArray);

  if (device.BasicVersion == 0)
  {
    //Now Send TransmitByteArray
    for (int i = 0; i != (DevStrArray.length+2); i++)  SendSingleDataByte(TransmitByteArray[i]); //+2 for 2x config bytes
  } 
  println("SendConfigurations() finished");
} //end SendConfigurations()  

//=====================================================================================================
