
//=======================================================================================================================  

class guiOverlayMenu
{
  int ObjID;
  int xpos;
  int ypos;
  int Height;
  int Width;

  int autoPosition; //0 = use xpos & ypos, 1 = center X & Y, 2 = center Y alight right, 3 = center Y align left
  int forceOverride; //0 = only menu elements can be clicked, 1 = any exposed elements can be clicked

  int xOffset, yOffset;

  //constructor
  guiOverlayMenu(int iObjID, int ixpos, int iypos, int ibWidth, int ibHeight)
  {
    ObjID = iObjID;
    xpos = ixpos;
    ypos = iypos;  
    Width = ibWidth;
    Height = ibHeight;

    autoPosition = 1; //set as default
    forceOverride = 0;
  } //end constructor

  //-----------------------------------------------------------------------------------------------

  void display()
  {
    pushStyle();
    fill(gui.menuBackground);
    stroke(0);
    strokeWeight(4);

    //draws background of menu
    switch(autoPosition) 
    {
    case 0:
    default:
      rect(xpos, ypos, Width, Height, 20);
      break;
    case 1:
      rect(xOffset, yOffset, Width, Height, 20); //background
      textSize(24);
      fill(0);
      textAlign(LEFT);
      text("Configuration Menu:", xOffset+20, yOffset+30);
      textSize(14);
      text("Use the configuration modules to select your hardware options. Once selected, upload them to the controller.", xOffset+20, yOffset+60); 
      
      menuUploadConfigurations.display();
      menuRequestConfigurations.display();
      break;
    }//end switch

    //========================================

    switch(ObjID)
    {
    case 1: //Configurations Menu 
    //scan through all enabled configuration modules, and display them
     for (int i =0; i != InputModule.length; i++) InputModule[i].display();
      break;  
    case 2:  //Stand-Alone commands menu
    
      break;    
    } //end ObjID switch

    menuCloseButton.display();

    popStyle();
  } //end display()

  //-----------------------------------------------------------------------------------------------

  void initMenu()
  {
    //----------------------------------------------------
    
    switch(autoPosition) 
    {
    case 0:
    default:
      xOffset = xpos;
      yOffset = ypos;
      break;
    case 1: //= center X&Y
      xOffset = (1024-Width)/2;
      yOffset = (768-Height)/2;
      break;
    }//end switch   
    
    //----------------------------------------------------

    switch(ObjID)
    {
    case 1: //Configurations Menu 
    menuUploadConfigurations.xpos = xOffset+300;
    menuUploadConfigurations.ypos  = yOffset+10; 
    menuRequestConfigurations.xpos = xOffset+500;
    menuRequestConfigurations.ypos = yOffset+10; 
      break;  
    case 2:  //Stand-alone commands menu
    
    break;    
    } //end ObjID switch
    
    //----------------------------------------------------
    
    menuCloseButton.xpos = xOffset+(Width-100);
    menuCloseButton.ypos = yOffset+20;
    
  //----------------------------------------------------  
  } //end display()

  //-----------------------------------------------------------------------------------------------

  boolean over() 
  {
    if (mouseXS >= xpos && mouseXS <= xpos+Width && mouseYS >= ypos && mouseYS <= ypos+Height) 
    {      
      return true;
    } else {
      return false;
    }
  } //end over()

  //-----------------------------------------------------------------------------------------------

  boolean overEllipse() 
  {
    if (mouseXS >= xpos-(Width/2) && mouseXS <= xpos+(Width/2) && mouseYS >= ypos-(Height/2) && mouseYS <= ypos+(Height/2)) 
    {      
      return true;
    } 
    else {
      return false;
    }
  } //end over()  

  //-----------------------------------------------------------------------------------------------

  boolean mousePressed()
  {

    switch(ObjID)
    {
    case 1: //Configurations Menu    
     if (CheckModuleElements() == true) return true; 
     if(menuUploadConfigurations.over()) { SetConfirmBox(1); return true; }
     if(menuRequestConfigurations.over()) { println("NO FUNCTION"); return true; }
      break;  
    case 2: //Stand-alone commands menu
    
    break;    
    } //end switch
    return false;
  } //end mouse pressed
} //end overlayMenu class
