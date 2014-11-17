import processing.serial.*;

PFont font;
Serial myPort;
PrintWriter rawdata;
PrintWriter calcdata;

int y;
int d;
int mon;
int h;
int m;
int s;
int s_previous;
int triger = 0;
int mode = 0;
int mode_previous = 0;
int zrhoutput = 0;
int[] data_arduino = new int[5];
int[][] zrhvalue = new int[240][5];
int count = 0;
int[] cr = new int[5];
int[] co2conc = new int[5];
float[] photo = new float[5];
float[] trace = new float[60];
float e_integral;
String pctime = "00:00:00";
String arduinotime = "00:00:00";
String begintime = "17:45:00";	// Set time to start arduino
arduinodata arduinodata1 = new arduinodata();
calcco2conc calcco2conc1 = new calcco2conc();

void setup(){
	size(490, 210);
	frameRate(1);
	font = loadFont("Calibri-24.vlw");
	textFont(font);
	textAlign(LEFT);
	myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600);
	myPort.buffer(10);
	initialize();
	String date = nf(y, 2) + nf(mon, 2) + nf(d, 2);
	rawdata = createWriter(date + "rawdata.txt");
	calcdata = createWriter(date + "calcdata.txt");
	calcdata.print("Y,MON,D,H,MIN,S,CHAM,CR,CS,P");
	calcdata.println("");
	rawdata.print("Y,MON,D,H,MIN,S,CHAM,VALUE");
	rawdata.println("");
}

void draw(){
	int i;
	int zrh;
	y = year();
	mon = month();
	d = day();
	h = hour();
	m = minute();
	s = second();
	background(0);
	pctime = getpctime();
	if((pctime.equals(begintime)) && (triger == 0)){
		myPort.clear();
		myPort.write(h);
		myPort.write(m);
		myPort.write(s);
		triger++;
		println("Serial start");
	}
	if((s != s_previous) && (myPort.available() == 3)){
		for(i = 0; i < 3; i++){
			data_arduino[i] = myPort.read();
		}
//		arduinodata1.available(data_arduino);	
//		arduinotime = getarduinotime();
		mode = data_arduino[0];
		if(mode != mode_previous){
			count = 0;
			co2conc[mode_previous] = calcco2conc1.value(mode_previous, zrhvalue);
//			textoutput(calcdata, arduinotime, mode_previous, co2conc[mode_previous]);
			if(mode_previous == 0){
				cr[mode] = co2conc[mode_previous];
			}else{
				photo[mode_previous] = getphoto(cr[mode_previous], co2conc[mode_previous]);	// [µmol s-1]
				textoutputcalc(calcdata, mode_previous, cr[mode_previous], co2conc[mode_previous], photo[mode_previous]);
			}
			println(co2conc[mode_previous]);
		}
		zrhvalue[count][mode] = ((data_arduino[1] << 8) | (data_arduino[2]));
		zrhoutput = zrhvalue[count][mode];
//		textoutput(rawdata, arduinotime, mode, zrhvalue[count][mode]);
		textoutputraw(rawdata, mode, zrhoutput);
//		println(zrhvalue[count][mode]);
		myPort.clear();
		myPort.write(h);
		myPort.write(m);
		myPort.write(s);
		mode_previous = mode;
		count++;
	}
	s_previous = s;
//	display(pctime, arduinotime, mode, count, zrhvalue[count][mode], co2conc);
	display(pctime, mode, count, zrhoutput, cr, co2conc, photo);
}

float getphoto(int _cr, int _cs){
	float _photo;	// [µmol s-1]
	/*
	float v_chamber = 20.0;	// [L]
	float vmol_chamber = getmol(v_chamber);
	*/
	float q_gas = 2.0;	// [L min-1]
	float qmol_gas = getmol(q_gas);
	_photo = (_cr - _cs) * (qmol_gas / 60);
	return _photo;
}

float getmol(float _volume){
	float _mol;
	float _gas_constant = 8.3144621;	//
	float _temp = 293.15;	// [K]
	float _pressure = 101300;	// [Pa]
	_mol = _pressure * _volume / _gas_constant / _temp;
	return _mol;
}

void textoutputcalc(PrintWriter _textdata, int _mode, int _cr, int _cs, float _photo){
	/*
	int i;
	int residue;
	residue = 4 - _mode;
	*/
	_textdata.print(y + "," + mon + "," + d + "," + h + "," + m + "," + s + "," + _mode + "," + _cr + "," + _cs + "," + _photo);
	/*
	for(i = 0; i < _mode; i++){
		_textdata.print(",");
	}
	_textdata.print(_cs);
	for(i = 0; i < residue; i++){
		_textdata.print(",");
	}
	for(i = 0; i < _mode; i++){
		_textdata.print(",");
	}
	_textdata.print(_photo);
	for(i = 0; i < residue; i++){
		_textdata.print(",");
	}
	*/
	_textdata.println("");
}

void textoutputraw(PrintWriter _textdata, int _mode, int _value){
	/*
	int i;
	int residue;
	residue = 4 - _mode;
	*/
	_textdata.print(y + "," + mon + "," + d + "," + h + "," + m + "," + s + "," + _mode + "," + _value);
	/*
	for(i = 0; i < _mode; i++){
		_textdata.print(",");
	}
	_textdata.print(_value);
	for(i = 0; i < residue; i++){
		_textdata.print(",");
	}
	*/
	_textdata.println("");
}

void initialize(){
	int i;
	int j;
	y = year();
	mon = month();
	d = day();
	for(i = 0; i < 240; i++){
		for(j = 0; j < 5; j++){
			zrhvalue[i][j] = 0;
		}
	}
	for(i = 0; i < 5; i++){
		cr[i] = 0;
		co2conc[i] = 0;
		photo[i] = 0;
	}
	myPort.clear();
}

String getpctime(){
//	int _h_pc;
//	int _m_pc;
//	int _s_pc;
	String _pctime;
//	_h_pc = hour();
//	_m_pc = minute();
//	_s_pc = second();
	_pctime = nf(h, 2) + ":" + nf(m, 2) + ":" + nf(s, 2);
	return _pctime;
}
/*
String getarduinotime(){
	int _h_arduino;
	int _m_arduino;
	int _s_arduino;
	String _arduinotime;
	_h_arduino = arduinodata1.hour();
	_m_arduino = arduinodata1.minute();
	_s_arduino = arduinodata1.second();
	_arduinotime = nf(_h_arduino, 2) + ":" + nf(_m_arduino, 2) + ":" + nf(_s_arduino, 2);
	return _arduinotime;	
}
*/

void display(String _pctime, int _mode, int _count, int _zrhvalue, int[] _cr, int[] _cs, float[] _photo){
	int i;
	text("PC time", 10, 20);
//	text("Arduino time", 10, 40);
	text("mode", 10, 60);
	text("count", 10, 80);
	text("ZRH value", 10, 100);
	text("Cham1", 110, 140);
	text("Cham2", 210, 140);
	text("Cham3", 310, 140);
	text("Cham4", 410, 140);
	text(_pctime, 220, 20);
//	text(_time_arduino, 220, 40);
	text(_mode, 220, 60);
	text(_count, 220, 80);
	text(_zrhvalue, 220, 100);
	text("Cr", 10, 160);
	for(i = 1; i < 5; i++){
		text(_cr[i], 10 + 100 * i, 160);
	}
	text("Cs", 10, 180);
	for(i = 1; i < 5; i++){
		text(_cs[i], 10 + 100 * i, 180);
	}
	text("Photo", 10, 200);
	for(i = 1; i < 5; i++){
		text(_photo[i], 10 + 100 * i, 200);
	}
	/*
	text(co2[0], 10, 160);
	text(co2[1], 110, 160);
	text(co2[2], 210, 160);
	text(co2[3], 310, 160);
	text(co2[4], 410, 160);
	*/
}

void mousePressed(){
	myPort.clear();
	rawdata.flush();
	calcdata.flush();
	rawdata.close();
	calcdata.close();
	exit();
}
