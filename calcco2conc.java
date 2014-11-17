class calcco2conc{
	private int i = 0;
	private int j = 0;
	private float[] clone = new float[180];
	private float[] smoothedclone = new float[180];
	private float[] difclone = new float[180];

	public calcco2conc(){
	}

	public int value(int _mode_previous, int[][] _zrhvalue){
		float _plateau;
		for(i = 0; i < 180; i++){
			clone[i] = _zrhvalue[i][_mode_previous];
		}
		smoothedclone = smooth(clone);
		difclone = dif(_mode_previous, smoothedclone);
		_plateau = estimateplateau(_mode_previous, smoothedclone, difclone);
		return (int)_plateau;
	}

	private float[] smooth(float[] _clone){
		float[] _smoothedclone = new float[180];
		int[] gaussianfilter = {1, 4, 6, 4, 1};
		for(i = 0; i < 180; i++){
			_smoothedclone[i] = 0;
		}
		for(i = 2; i <= 177; i++){
			for(j = 0; j < 5; j++){
				_smoothedclone[i] = _smoothedclone[i] + _clone[i + j - 2] * gaussianfilter[j] / 16;
			}
		}
		return _smoothedclone;
	}

	private float[] dif(int _mode_previous, float[] _smoothedclone){
		float[] _difclone = new float[180];
		int[] stirling = {-1, 8, 0, -8, 1};
		for(i = 0; i < 180; i++){
			_difclone[i] = 0;
		}
		for(i = 4; i <= 175; i++){
			for(j = 0; j < 5; j++){
				_difclone[i] = _difclone[i] + _smoothedclone[i + j - 2] * stirling[j] / 12 / 5;
			}
		}
		return _difclone;
	}

	private float estimateplateau(int _mode_previous, float[] _smoothedclone, float[] _difclone){
		float _plateau = 0;
		float _n;
		double er;
		switch(_mode_previous){
			case 0:
				_plateau = _smoothedclone[115];
				/*
				i = 30;
				j = 50;
				*/
				break;
			case 1:
			case 2:
			case 3:
			case 4:
				i = 115;
				j = 175;
				er = Math.pow((_difclone[i] - _difclone[j]), 2);
				_n = -(float)(Math.log(_difclone[j] / _difclone[i]) / (j - i));
				//if(er < 1){
					_plateau = _smoothedclone[j];
				//}else{
				//	_plateau = (float)((_smoothedclone[j] - _difclone[i] * Math.exp(-_n * (j - i))) / (1 - Math.exp(-_n * (j - i))));
				//}
				break;
		}
		return _plateau;
	}
}
