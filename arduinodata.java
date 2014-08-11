class arduinodata{
	private int i;
	private int[] data_arduino = new int[5];
	private int _hour;
	private int _minute;
	private int _second;
	private int _mode;

	public void available(int[] _data_arduino){
		for(i = 0; i < 5; i++){
			data_arduino[i] = _data_arduino[i];
		}
		_hour = 0;
		_minute = 0;
		_second = 0;
		_mode = 0;
	}

	public int hour(){
		_hour = data_arduino[0];
		return _hour;
	}

	public int minute(){
		_minute = data_arduino[1];
		return _minute;
	}

	public int second(){
		_second = data_arduino[2];
		return _second;
	}

	public int mode(){
		_mode = data_arduino[3];
		return _mode;
/*		switch(data_arduino[3]){
			case 0:
				mode = "reference";
				break;
			case 1:
				mode = "sample1";
				break;
			case 2:
				mode = "sample2";
				break;
			case 3:
				mode = "sample3";
				break;
			case 4:
				mode = "sample4";
				break;
			default :
				println("Miss to get data_arduino[]");
				break;
		}
*/
	}

	public float zrhvalue(){
		return data_arduino[4];
	}
}
