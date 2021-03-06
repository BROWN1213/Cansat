import processing.serial.*;
import controlP5.*;


Serial myPort;
float lat,lng,alt,speed_km,course,num_sat;
boolean gps_new_messege=false;

PImage img;

boolean on=true;
float prev_lon,prev_lat,prev_course;
boolean first_map=false;
int blink_count=-1;

PShape satellite;
PShape battery0,battery1,battery2,battery3,battery4;
PShape b_level;
int bat_level;

PShape connect;
int isconneted=-1;


 
 
DropdownList menu1, menu2;
ControlP5 cp5;

void setup(){
  size(600, 600);
  satellite=loadShape("satellite.svg");
  battery0=loadShape("batt0.svg");battery0.rotate(PI/2);
  battery1=loadShape("batt1.svg");battery1.rotate(PI/2);
  battery2=loadShape("batt2.svg");battery2.rotate(PI/2);
  battery3=loadShape("batt3.svg");battery3.rotate(PI/2);
  battery4=loadShape("batt4.svg");battery4.rotate(PI/2);
  connect=loadShape("connect.svg");
  
  cp5 = new ControlP5(this);

  menu1 = cp5.addDropdownList("port")
    .setPosition(0.2*width/5, 0.7*height/5)
    .setSize(200,500);    

 customize(menu1);


  
  
  
}

void draw(){
  background(0);
  loadMap();
  satellite_info();
  drawBattery();
  if(isconneted>0)isconneted--;
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  PFont pfont = createFont("Arial",20,true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont,12);
  //ddl.setFont(font);
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(15);
  ddl.setBarHeight(17);
  //ddl.captionLabel().set("port");
  ddl.getCaptionLabel().getStyle().marginTop = 3;
  ddl.getCaptionLabel().getStyle().marginLeft = 3;
  ddl.getValueLabel().getStyle().marginTop = 3;
  
  for(int i=0;i<Serial.list().length;i++)
    ddl.addItem(Serial.list()[i], i);
  

   
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  
  
}

void controlEvent(ControlEvent theControlEvent) 
{
  
  if (theControlEvent.isFrom(menu1))
  { int list_num= (int)theControlEvent.controller().getValue();
    String port_name=Serial.list()[list_num];
    println(port_name);
    myPort = new Serial(this, port_name, 115200);
    myPort.bufferUntil('\n');   
    
    String cmd="AT\r\n";
    myPort.write(cmd); 
    delay(1000);
    cmd="ATD\r\n";
    myPort.write(cmd);     
  }

}
void drawBattery(){
  
  if(bat_level==0)shape(battery0, 250, 26, 100, 50); 
  if(bat_level==1)shape(battery1, 250, 26, 100, 50); 
  if(bat_level==2)shape(battery2, 250, 0, 100, 50); 
  if(bat_level==3)shape(battery3, 250, -26, 100, 50); 
  if(bat_level==4)shape(battery4, 250, -52, 100, 50); 

}
void satellite_info(){
  textAlign(CENTER);
  fill(0,0,0);
  text(str(int(speed_km))+"km/h", 500, 40); 
  textSize(25);

  
  //satellite.disableStyle();
  //fill(0, 102, 153);
  shape(satellite, 280, 10, 40, 40); 
  text(str(int(num_sat)), 350, 40); 
  textSize(25);
  
  
  if(isconneted>0){
    connect.disableStyle();
    fill(0, 102, 255);
    shape(connect, 140, 15, 35, 35);
  }else{
    connect.disableStyle();
    fill(200, 3, 3);
    shape(connect, 140, 15, 35, 35);  
  }
  
}

void serialEvent(Serial port) //Reading the datas by Processing.
{
   String input = port.readStringUntil('\n');
   //println(input);
   
  if(input.indexOf("%") == 0){ //header
     input=input.substring(2,input.length()-2); 
     //println(input);
     input = trim(input);
     String[] values = split(input, ",");
     //values[0]: class, values[1]: num, 

      if(int(values[0])==2){ //GPS
        lat=float(values[2]);
        lng=float(values[3]);
        alt=float(values[4]);
        num_sat=float(values[5]);
        speed_km=float(values[6]);
        course=float(values[7]);
        
        gps_new_messege=true; //
        blink_count=20;
        print(lat);print(",");
        print(lng);print(",");
        println(alt);
        
        print(num_sat);print(",");
        print(speed_km);print(",");
        println(course);         
      }
     
      if(int(values[0])==3){ //battery
        bat_level=int(values[2]);
        //print("batt=");println(bat_level);
        isconneted=70;
         
      }
  }
   
}


void loadMap(){
  
  //pushMatrix();
  //translate(2.7*width/5, 0.8*height/5);
  String token = "";
  //String longitude = "127.1144943 ";
  //String latitude = "37.384931";
  String longitude = "127.006744";
  String latitude = "037.558231";  
  
  String course_N = "0";
  if(num_sat>=3){
    longitude=nf(lng,3,7);
    latitude=nf(lat,3,7);
    //course_N=nf(-course,3,2);
    course_N=str(course);
  }

  String zoom = "15.2";
  String pitch = "0";
  //https://www.mapbox.com/api-documentation/#styles
  String style = "streets-v10"; // "streets-v10" "dark-v9" "light-v9" "satellite-streets-v10" "navigation-preview-day-v2"
  
  String url;

  
  url="https://api.mapbox.com/styles/v1/mapbox/"+style+"/static/"+longitude+","+latitude+","+zoom+","+course_N+","+pitch+"/600x600?access_token="+token;
  if(abs(prev_lon-lng)>0.0001 || (first_map==false) ||abs(prev_lat-lat)>0.0001||abs(prev_course=course)>10.0){
    img =  loadImage(url,"jpg");  
    
    first_map=true;
  }
  image(img,0,0);
  prev_lon=lng;
  prev_lat=lat;
  prev_course=course;
  
  if(blink_count>0) {
    blink_count--;
    fill(203,67,53);
    ellipse(300, 300, 20, 20);

  }
  

  
 // popMatrix();
  
}
