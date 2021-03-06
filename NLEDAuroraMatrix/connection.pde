
//===================================================================================================

void OpenCOMPort(String NameID)
{
  println("OpenCOMPort() with "+NameID+" at baud: "+ProgramBaudRate);

  if (NameID.equals("TCP/IP"))
  {
    thread("OpenTCP");
    return;
  }

  try {
    serialPort.stop();
    serialPort.dispose();
  }
  catch(Exception e) {
  }

  int x = 0; //so can be used in catch

  try 
  {
    
    
    for (x =0; x != Serial.list().length; x++) 
    {
      if (NameID.equals(Serial.list()[x]))
      {  
        portName = Serial.list()[x];      
        serialPort = new Serial(this, portName, ProgramBaudRate);

        ShowNotification(2);
        println("Connected to "+portName);

        OpenConnection(); //Aurora device selected, attempt connection command
        break;
      } else
      {
        //println(Serial.list()[x]+" is not a Match for COM port in software.ini");
      }
    }
  }
  catch(Exception e)
  {
    println("Could Not Open COM Port "+Serial.list()[x]);
    devConnected = false;    
    portName = "None";
    ShowNotification(3);
  }
} //end func()

//===================================================================================================

void CloseCOMPort()
{
  println("CloseCOMPort() - Closing Port");    
  devConnected = false;    
  UploadInProgress = false; //incase it was uploading and connection was lost

  try   
  {  
    //close COM port
    serialPort.stop();
    serialPort.dispose();
    devConnected = false;
  }
  catch(Exception e)
  {
    println("No Port To Close");
  }  

  portName = "None";
  println("COM Port Closed");
}

//===================================================================================================

void CloseCommunicationPort()
{
  if (CommunicationMode == 0) CloseCOMPort();  
  //  else if(CommunicationMode == 1) CloseTCP();
} //end CloseCommunicationPort()


//===================================================================================================

//separate so one can pass characters, for exchange, other for data/numbers
void SendSingleDataChar(char passedValue)
{
  try {
    if (CommunicationMode == 0) serialPort.write(passedValue);
    //  else if(CommunicationMode == 1) TCPClient.write(passedValue);
  }
  catch(Exception e) {
  }
}

void SendSingleDataByte(int passedValue)
{
  println("Sent 1 byte: "+passedValue);

  try {
    if (CommunicationMode == 0) serialPort.write(passedValue);
    // else if(CommunicationMode == 1) TCPClient.write(passedValue);
  }
  catch(Exception e) {
  }
}

void SendAckedCommand() //threaded
{
  println("Cmd Request Acknowledged, Sending - CmdByte: "+cmdByte+" : "+cmdData[0]+" : "+cmdData[1]+" : "+cmdData[2]+" : "+cmdData[3]);
  RecievedOpenAck = false;
  SendSingleDataByte(cmdByte);
  SendSingleDataByte(cmdData[0]);  
  SendSingleDataByte(cmdData[1]);   
  SendSingleDataByte(cmdData[2]);  
  SendSingleDataByte(cmdData[3]); 

  CmdIssued = true; //set flag to wait for authentication
}

//===================================================================================================  

void serialEvent(Serial serialPort) 
{
  RXByte5 = RXByte4;
  RXByte4 = RXByte3;
  RXByte3 = RXByte2;
  RXByte2 = RXByte1;
  RXByte1 = serialPort.read();
  DataRecieved(); //run common function
}  //end serialEvent()

//===================================================================================================  

void DataRecieved()  
{
 // println("Received: "+RXByte1+"  Char: "+char(RXByte1)); //DISABLED TO PREVENT PRINTLN FROM RUNNING OUT OF SPACE
  
  //START TIMER METHOD
  /*
   int tempTime = (millis() - HoldMiliSec);
   println("Received: "+RXByte1+"/"+char(RXByte1)+" Time: "+tempTime);
   HoldMiliSec=millis();  
   */
  //END TIMER METHOD

  if (SentCmdRequest == true && RXByte2 == 'a' && RXByte1 == '9')
  {
    RecievedOpenAck = true;
    SentCmdRequest = false;
    EnableTransmissionTimeOut();
    //myPort.write("nled99"); 
    SendSingleDataChar('n'); 
    SendSingleDataChar('l');  
    SendSingleDataChar('e');
    SendSingleDataChar('d');  
    SendSingleDataChar('9');   
    SendSingleDataChar('9');

    println("Sent Acknowledge");
  } 
  else if (RecievedOpenAck == true  && RXByte2 == 'f' && RXByte1 == '0')
  {
    thread("SendAckedCommand");
  } 
  else if (SentConfigRequest == true)
  {
    switch(ReceiveCounter)
    {
    case 0: //MSB
      RecievedDeviceConfigsMSB = RXByte1;
      break;      
    case 1: //LSB
      RecievedDeviceConfigsLSB = RXByte1;    
      SentConfigRequest = false;
      println("Requested and Recieved Configurations "+binary(RecievedDeviceConfigsMSB, 8)+" "+binary(RecievedDeviceConfigsLSB, 8));
      break;
    } //end switch
    ReceiveCounter++;
  } 
  else if (SentOpenRequest == true)
  {
    println("Counter: "+ReceiveCounter);
    switch(ReceiveCounter)
    {
    case 0: //hardware ID
      holdHardwareID = device.HardwareID; //holds current or old HardwareID
      device.HardwareID = RXByte1;
      break;      
    case 1: //hardware version ID, not really used
      device.HardwareVersion = RXByte1;
      break;
    case 2: //Firmware Version
      device.FirmwareVersion = RXByte1;
      break;
    case 3: //Firmware Revision
      device.FirmwareRevision = RXByte1;
      break;
    case 4:  //Bootloader Target HardwareID

      break;      
    case 5:  //Bootloader Version Number
      device.BootloaderVersion = RXByte1;
      break;      
    case 6:  //UserID Number Configuration
      device.UserConfiguredIDNum = RXByte1;

      //All Device Connection bytes received, now load device file and continue
      SentOpenRequest = false;
      devConnected = true;

      try {
        LoadDeviceFile();
        //String temp = cRevisionIDstr[device.FirmwareRevision]; //to test and catch if valid firmware revision number
      }
      catch(Exception e) { 
        ShowNotification(0);
      }
      break;
    }  
    ReceiveCounter++;
  } 
  else if (UploadInProgress == true || ConfigUploadSent == true) //added the cmdUploadConfigurations check so it would ack config upload
  {
    if (RXByte4 == 'z' && RXByte3 == 'A' && RXByte2 == 'c' && RXByte1 == 'k')  
    {
      WaitForAckFlag = true;
      println("ACK RECEIVED FOR PACKET# "+USBpacketCount);
      //also send CRC byte and packet# to maintain continuity
      if (ConfigUploadSent == true) ShowNotification(12);
      ConfigUploadSent = false;
    } 
  } 
  else if (CmdIssued == true)
  {
    if (RXByte5 == 'c' && RXByte4 == 'm' && RXByte3 == 'd' && RXByte2 == 0)  
    {
      CmdIssued = false;  
      println("COMMAND #"+RXByte1+" AUTHENTICATED");
      //run common init
      SendCounter = 0;
      SendCounterB = 0;
      USBpacketCount = 0; //reset counter  
      PacketPointer = 0; //would also get set to 0, since it always sends 64 bytes then clears it.

      //this executes the actual command software side once ACKed
      switch(cmdByte)
      {     
      case 4: //Request Connection
        SentOpenRequest = true;
        ReceiveCounter = 0;
        break;
       case 100: //Full Upload
        UploadInProgress = true;        
        thread("FullIndexUpload");
        break;       
      case 101:  //Upload Configurations
        UploadInProgress = true;  
        ConfigUploadSent = true;
        SendConfigurations();  
        UploadInProgress = false; 
        break;
      case 120: //Request Configurations
        SentConfigRequest = true;
        ReceiveCounter = 0;
        break;
      }  //end switch
    } //end byte check
    //else if(devConnected == false && cmdByte == 4)
    else if (RXByte4 > 0 && RXByte3 == 1 && RXByte2 == 1 && RXByte1 < 26)  
    {
      //Detects if version 1, rather than acking the cmd
      //hardwareID,hardwarev, firmwareV, firmwareRev
      println(RXByte1+"   "+RXByte2+"   "+RXByte3+"   "+RXByte4+"   "+RXByte5);

      //RXByte4 = ID numnber
      //RXByte3 = hardware v
      //RXByte2 = firmware v
      //RXByte1 = firmware rev

      device.HardwareID = RXByte4;
      device.HardwareVersion = RXByte3;
      device.FirmwareVersion = RXByte2;
      device.FirmwareRevision = RXByte1;    

      SentOpenRequest = false;
      devConnected = true;

      try {
        LoadDeviceFile();
        //String temp = cRevisionIDstr[device.FirmwareRevision]; //to test and catch if valid firmware revision number
      }
      catch(Exception e) { 
        ShowNotification(0);
      }
    }
  } //end CmdIssued if()
} //end func

//=====================================================================================================

void RequestCommand()
{
  //reset all command authentication flags
  TerminateUpload = false; //reset flag
  WaitForAckFlag = false; 
  UploadInProgress = false;
  RecievedOpenAck = false;  
  SentCmdRequest = false;    

  try {
    // SendSingleDataByte("NLED11"); 
    SendSingleDataChar('N'); 
    SendSingleDataChar('L');  
    SendSingleDataChar('E');   
    SendSingleDataChar('D');  
    SendSingleDataChar('1');   
    SendSingleDataChar('1');
    SentCmdRequest = true; 
    EnableTransmissionTimeOut();
  }
  catch(Exception e)
  {
    println("Port Not Open, Or Unable to Send"); 
    SentCmdRequest = false;

    CloseCommunicationPort();
    ShowNotification(0);
  }
} //end func()

//===================================================================================================  

void OpenConnection()
{
  println("Attempting Connection");

  cmdByte = cmdOpen; //connect to device
  cmdData[0] = 0;
  cmdData[1] = 0; 
  cmdData[2] = 0;  
  cmdData[3] = 0;  
  devConnected = false;

  RequestCommand();
}//end func()

//===================================================================================================  

void RequestDeviceConfigurations()
{
  println("RequestDeviceConfigurations()");

  cmdByte = cmdRequestConfigurations; 
  cmdData[0] = 0;
  cmdData[1] = 0; 
  cmdData[2] = 0;  
  cmdData[3] = 0;  

  RequestCommand();
}//end func()

//===================================================================================================  

void RequestConfigurationUpload()
{
  println("RequestConfigurationUpload()");

  cmdByte = cmdUploadConfigurations; //Upload Configurations
  cmdData[0] = 0; //MSB
  cmdData[1] = 0; //LSB
  cmdData[2] = 0;  
  cmdData[3] = 0;  
  RequestCommand();
} //end RequestConfigurationUpload

//===================================================================================================  

void RequestNextSequenceCommand()
{
    try {
    serialPort.write("NLED11");
    delay(20);
    serialPort.write("nled99");
    delay(20);
    serialPort.write(92);
    serialPort.write(0);
    serialPort.write(0);
    serialPort.write(0);
    serialPort.write(0);
    }
    catch(Exception e)
    {
      println("Can not send command");
    }
}
  
 //=================================================================================================== 
 
void TransmissionTimerThread()
{
  int myStart = millis();

  while ((millis() - myStart) < CMDTimeOutVal)
  {
    delay(1);  //Required or would only work a few times, then stops working
    if (SentCmdRequest == false && RecievedOpenAck == false) { 
      return;
    } //force out by mouse click after min time
  }

  CloseCommunicationPort();

  ShowNotification(6); //display notification

  WaitForAckFlag = false;
  UploadInProgress = false;
  RecievedOpenAck = false;  
  SentCmdRequest = false;    

  println("Command Timed Out "+(millis() - myStart));
  redraw();
} //end NotificationTimerThread()

void EnableTransmissionTimeOut()
{
  println("EnableTransmissionTimeOut()");
  thread("TransmissionTimerThread");
} //end func

//============================================================================================
