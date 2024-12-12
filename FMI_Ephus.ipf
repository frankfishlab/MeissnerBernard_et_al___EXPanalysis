#pragma rtGlobals=1		// Use modern global access method.
#include <Power Spectral Density>

Menu "Ephus"
	Submenu "ANALYSIS"
		"Low-level experiment analysis [CDF] - #1 spiking/F3",FMI_SPK_analysis_seg()
		"      --> SUMMARIZE #1 in PXP",FMI_ACTION_ALL(V_cmd=8)
		"Low-level experiment analysis [CDF] - #2 spontaneous EPSPs | EPSCs | IPSCs",FMI_vdEVT_LVL2_anl()
		"      --> SUMMARIZE #2 in PXP",FMI_ACTION_ALL(V_cmd=4)
		"Low-level experiment analysis [CDF] - #3 evoked EPSPs | EPSCs | IPSCs",FMI_EVT_analysis_seg()
		"      --> SUMMARIZE #3 in PXP",FMI_ACTION_ALL(V_cmd=5)
		"-"
		"AutoFill PVector entries",/Q,FMI_PVector_init()
		"      --> All folders [E_*]",/Q,FMI_ACTION_ALL(V_cmd=9)
		"-"
		"Reset analysis in all DFs",/Q,FMI_ACTION_ALL(V_cmd=1)
		"-"
		"AVERAGE trace in CDF [zeroed]/F12",FMI_AVGtrc()
		"AVERAGE trace in CDF",FMI_AVGtrc(V_zero=0)
		"Series amplitude in CDF/SF12",FMI_srsAMP()
		"      --> AVERAGE trace + series amplitude in PXP",FMI_ACTION_ALL(V_cmd=10,S_matchStr_DF0="VC_*") 
		"VCvd analysis in CDF",FMI_VCvd()
		"-"
		"AUC in topGrf traces - Pulse1",FMI_TRClistAREA_topGrf()
		"AUC in topGrf traces - Pulse 10",FMI_TRClistAREA_topGrf(V_start=0.75,V_end=0.799)
		"AUC in topGrf traces - all Pulses",FMI_TRClistAREA_topGrf(V_start=0.30,V_end=0.799)
		"-"
		Submenu "Single wave analysis"
			"Input resistance",FMI_Rin()
			"Membrane time constant",FMI_mTC()
			"Event detection\analysis",FMI_EventDTCT()
			"Spike detection\analysis",FMI_SpikeDTCT()
			"WAVE delta",FMI_wvDELTA()
		End
		Submenu "Spatial mapping [DMD]"
			"IMPORT W_RNDseq/F11",FMI_RNDseqimport()
			"Create XPSC template/SF11",FMI_mkXPSCtemplate()
			"-"
			"Analyse spatial mapping data [=1 series]",FMI_smDMD()
			"Analyse spatial mapping data [>1 series]",FMI_smDMD_MASTER()
		End
	End
	Submenu "DISPLAY"
		"Display - trace && raster plot [spikes] - all DFs",FMI_ACTION_ALL()
		"Display - trace && raster plot [synaptic events] - all DFs",FMI_ACTION_ALL(S_matchStr_DF0="*")
		"Display - trace && raster plot [spikes] - current EXP",FMI_ACTION_ALL(V_cmd=2,S_matchStr_DF1="*dp*",S_matchStr_DF2="*")
		"-"
		"Display - average EPSC trace - all DFs [esVC]",FMI_ACTION_ALL(V_cmd=6,S_matchStr_DF0="EXP_esVC*")
		"Display - average trace of choice - all DFs [esVC]",FMI_ACTION_ALL(V_cmd=7,S_matchStr_DF0="EXP_esVC*")
		"Display - average trace of choice - all DFs [vdVC]",FMI_ACTION_ALL(V_cmd=7,S_matchStr_DF0="EXP_vdVC*")
		"Display - average trace of choice - all DFs [msCI]",FMI_ACTION_ALL(V_cmd=7,S_matchStr_DF0="EXP_msCI*")
		"-"
		"Display && average - I-F curves - all DFs",FMI_ACTION_ALL(V_cmd=3)
	End
End

Menu "_DpIN"
	"qANL: AHP in top graph",FMI_Ephus_AHP_topGrf()
	"-" 
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_Ephus_AHP_topGrf([V_pre0,V_pre1,V_post0,V_post1])
	Variable V_pre0,V_pre1,V_post0,V_post1
	
	If(ParamIsDefault(V_pre0))
		V_pre0= 0
	Endif
	If(ParamIsDefault(V_pre1))
		V_pre1= 2
	Endif
	If(ParamIsDefault(V_post0))
		V_post0= 270
	Endif
	If(ParamIsDefault(V_post1))
		V_post1= 299
	Endif
	
	Variable i
	
	String S_TrcLst=TraceNameList("",";",1) 
		
	If(ItemsinList(	S_TrcLst)==0)
		return 0
	Endif
	
	MAKE/O/N=(ItemsinList(S_TrcLst)) W_BC_AHP 
		SetScale d,0,0,"V",W_BC_AHP
		
	For(i=0;i<ItemsinList(S_TrcLst);i+=1)
		wave w=TraceNameToWaveRef(StringfromList(0,WinList("*",";","WIN:1")),StringfromList(i,S_TrcLst))
		
		WaveStats/Q/R=[V_pre0,V_pre1] w
			Variable V_pre= V_avg
		WaveStats/Q/R=[V_post0,V_post1] w
			Variable V_post= V_avg
			
		W_BC_AHP[i]= V_post-V_pre
	Endfor
	
	WaveStats_To_Note(W_BC_AHP)
	
	FMI_permuteWave(W_BC_AHP,0)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_XPSCarea([w,V_start,V_end])
	WAVE w
	Variable V_start,V_end
	
	If(ParamIsDefault(w))
		WAVE w=FindByBrowser("select WAVE")
	Endif
	If(ParamIsDefault(V_start))
		V_start=0.3
	Endif
	If(ParamIsDefault(V_end))
		V_end=0.349
	Endif
	
	return area (w,V_start,V_end)
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_TRClistAREA_topGrf([V_start,V_end])
	Variable V_start,V_end
	
	If(ParamIsDefault(V_start))
		V_start=0.3
	Endif
	If(ParamIsDefault(V_end))
		V_end=0.349
	Endif
	
	String S_TrcLst=TraceNameList("",";",1) 
		
	If(ItemsinList(	S_TrcLst)==0)
		return 0
	Endif
	
	Variable i
	
	MAKE/O/N=(ItemsinList(S_TrcLst)) W_Area 
	For(i=0;i<ItemsinList(S_TrcLst);i+=1)
		wave w=TraceNameToWaveRef(StringfromList(0,WinList("*",";","WIN:1")),StringfromList(i,S_TrcLst))
		
		W_Area[i]=FMI_XPSCarea(w=w,V_start=V_start,V_end=V_end)
	Endfor
	
	WaveStats_to_Note(W_Area)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_smDMD_MAP_AMP([M_input]) : Graph
	WAVE M_input
	
	If(ParamIsDefault(M_input))
		WAVE M_input=FindByBrowser("Select M_grdMAP_AMP MATRIX")
	Endif
	
	FMI_LUTgeo()
	PauseUpdate; Silent 1		// building Function...
	
	Display /W=(385.5,47.75,777.75,469.25)/K=1
	AppendImage M_input
	ModifyImage $NameOfWave(M_input) ctab= {0,*,Geo,0}
	ModifyGraph margin(left)=43,margin(bottom)=85,margin(top)=43,margin(right)=14
	ModifyGraph mirror=2
	ModifyGraph nticks=3
	ModifyGraph font="Arial"
	ModifyGraph minor=1
	ModifyGraph fSize=11
	ModifyGraph standoff=0
	ModifyGraph axThick=0.5
	ModifyGraph btLen=3
	SetAxis/A/R left
	ColorScale/C/N=text0/F=0/B=1/A=MC/X=-1.34/Y=-67.35 image=$NameOfWave(M_input), vert=0, font="Arial"
	ColorScale/C/N=text0 fsize=14
	AppendText "\\Z14\\u#2<IPSC response> pA"
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_smDMD_MAP_COR([M_input]) : Graph
	WAVE M_input
	
	If(ParamIsDefault(M_input))
		WAVE M_input=FindByBrowser("Select M_grdMAP_COR MATRIX")
	Endif
	
	FMI_LUTgeo()
	PauseUpdate; Silent 1		// building Function...
	
	Display /W=(792,47.75,1184.25,469.25)/K=1
	AppendImage M_input
	ModifyImage $NameOfWave(M_input) cindex= root:Packages:pymANL:M_LUTgeo//ctab= {0,1.10,Geo,0}
	ModifyGraph margin(left)=43,margin(bottom)=85,margin(top)=43,margin(right)=14
	ModifyGraph mirror=2
	ModifyGraph nticks=3
	ModifyGraph font="Arial"
	ModifyGraph minor=1
	ModifyGraph fSize=11
	ModifyGraph standoff=0
	ModifyGraph axThick=0.5
	ModifyGraph btLen=3
	SetAxis/A/R left
	ColorScale/C/N=text0/F=0/B=1/A=MC/X=0.00/Y=-67.35 image=$NameOfWave(M_input), vert=0
	ColorScale/C/N=text0 fsize=14, axisRange={NaN,1,0}
	AppendText "\\Z14Template correlation"
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_smDMD_MASTER([W_WvLst_DATA,W_WvLst_RNDseq,W_WvLst_tmplt])
	WAVE/T W_WvLst_DATA,W_WvLst_RNDseq,W_WvLst_tmplt
	
	If(ParamIsDefault(W_WvLst_DATA))
		WAVE/T W_WvLst_DATA=FindByBrowser("Select wave - list of DATA waves",V_TEXT=1)
	Endif
		If(waveexists(W_WvLst_DATA)==0)
			return 0
		Endif
	
	If(ParamIsDefault(W_WvLst_RNDseq))
		WAVE/T W_WvLst_RNDseq=FindByBrowser("Select wave - list of RNDseq waves",V_TEXT=1)
	Endif
		If(waveexists(W_WvLst_RNDseq)==0)
			return 0
		Endif
		
	If(ParamIsDefault(W_WvLst_tmplt))
		WAVE/T W_WvLst_tmplt=FindByBrowser("Select wave - list of XPSC TEMPLATE waves",V_TEXT=1)
	Endif
		If(waveexists(W_WvLst_tmplt)==0)
			return 0
		Endif
	
	// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Variable i
	
	For(i=0;i<numpnts(W_WvLst_DATA);i+=1)
		WAVE/WAVE W_WvRef=FMI_smDMD(W_DATA=$W_WvLst_DATA[i],W_RNDseq=$W_WvLst_RNDseq[i],W_tmplt=$W_WvLst_tmplt[i])
		
		WAVE M_grdMAP_AMP=W_WvRef[0]
		WAVE M_grdMAP_COR=W_WvRef[1]
		
		If(i==0)
			MAKE/O/N=(DimSize(M_grdMAP_AMP,0),DimSize(M_grdMAP_AMP,1),numpnts(W_WvLst_DATA)) Mv_grdMAP_AMP,Mv_grdMAP_COR
		Endif
		WAVE Mv_grdMAP_AMP
		WAVE Mv_grdMAP_COR
		
		
		Mv_grdMAP_AMP[][][i]=M_grdMAP_AMP[p][q]
		Mv_grdMAP_COR[][][i]=M_grdMAP_COR[p][q]
	Endfor
	
	// ... 'PROCESSING' STACKS --> AVERAGE MAPS
	If(numpnts(W_WvLst_DATA)>2)
		ImageTransform averageImage, Mv_grdMAP_AMP; WAVE M_AveImage,M_StdvImage
			Duplicate/O M_AveImage,M_grdMAP_AMP_AVG
			Duplicate/O M_StdvImage,M_grdMAP_AMP_SD
		
		ImageTransform averageImage, Mv_grdMAP_COR; WAVE M_AveImage,M_StdvImage
			Duplicate/O M_AveImage,M_grdMAP_COR_AVG
			Duplicate/O M_StdvImage,M_grdMAP_COR_SD
	
	Else
		ImageTransform sumPlanes, Mv_grdMAP_AMP; WAVE M_SumPlanes; M_SumPlanes/=numpnts(W_WvLst_DATA)
			Duplicate/O M_SumPlanes,M_grdMAP_AMP_AVG
		
		ImageTransform sumPlanes, Mv_grdMAP_COR; WAVE M_SumPlanes; M_SumPlanes/=numpnts(W_WvLst_DATA)
			Duplicate/O M_SumPlanes,M_grdMAP_COR_AVG
	Endif
	
	Killwaves/Z M_AveImage,M_StdvImage,M_SumPlanes
	
	// ... DISPLAY MAPS
	FMI_smDMD_MAP_AMP(M_input=M_grdMAP_AMP_AVG)	
	FMI_smDMD_MAP_COR(M_input=M_grdMAP_COR_AVG)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_mkXPSCtemplate([W_input,V_start,V_end])
	WAVE W_input
	Variable V_start,V_end
	
	If(ParamIsDefault(W_input))
		WAVE W_input=FindByBrowser("Select input wave")
	Endif
	
	If(ParamIsDefault(V_start))
		V_start=0.3 // (s)
	Endif
	If(ParamIsDefault(V_end))
		V_end=0.349 // (s)
	Endif
	
	String S_WvNm=CleanupName(NameOfWave(W_input)+"_tmplt",0)
	Duplicate/O/R=(V_start,V_end) W_input,$S_WvNm; WAVE W_output=$S_WvNm
		CopyScales/P W_input, W_output
	
	Duplicate/O/FREE W_output,W_tmp
	Smooth/B 11, W_tmp
		Wavestats/Q W_tmp
			Duplicate/O W_output,$ReplaceString("_tmplt",NameOfWave(W_output),"_Ntmpl")
				WAVE W_output_N=$ReplaceString("_tmplt",NameOfWave(W_output),"_Ntmpl")
			
			//... IPSCs --> outward current
			W_output_N/=V_max
	
	return W_output_N
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_smDMD([W_DATA,W_RNDseq,W_tmplt,V_DELAY,V_segDUR])
	WAVE W_DATA,W_RNDseq,W_tmplt
	Variable V_DELAY,V_segDUR
	
	DFREF CDF=GetDataFolderDFR()
	
	If(ParamIsDefault(W_DATA))
		WAVE W_DATA=FindByBrowser("Select DATA wave")
	Endif
	
	WAVE void
	
	SetDataFolder GetWavesDataFolderDFR(W_DATA )
	
		If(ParamIsDefault(W_RNDseq))
			WAVE W_RNDseq=FMI_RNDseqimport(S_title="Match DATA wave: "+NameOfWave(W_DATA))
		Endif
		
		If(ParamIsDefault(W_tmplt))
			WAVE W_tmplt=FindByBrowser("Select XPSC template wave: ")
		Endif
		
		If(waveexists(W_DATA)==0)
			SetDataFolder CDF
			return void
		Endif
		
		If(ParamIsDefault(V_DELAY))
			V_DELAY=1.0 			// (s)
		Endif
		If(ParamIsDefault(V_segDUR))
			V_segDUR=0.2 			// (s)
		Endif
		
		Variable i
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		Variable V_grdNUM=225
		String S_ID=NameOfWave(W_DATA)
		String S_IDsh="M_grdMAP"
		
		MAKE/O/N=(sqrt(V_grdNUM),sqrt(V_grdNUM)) $S_IDsh+"_COR"=NaN,$S_IDsh+"_AMP"=NaN
			WAVE M_grdMAP_COR=$S_IDsh+"_COR"
			WAVE M_grdMAP_AMP=$S_IDsh+"_AMP"
		
		For(i=0;i<numpnts(W_RNDseq);i+=1)
			Variable V_start=V_DELAY+(i*V_segDUR)
			Variable V_end=V_DELAY+((i+1)*V_segDUR)
			
			Variable V_X=mod((W_RNDseq[i]-1), sqrt(V_grdNUM))
			Variable V_Y=floor((W_RNDseq[i]-1) / sqrt(V_grdNUM))
			
			Duplicate/O/R=(V_start,V_end) W_DATA,$S_ID+"_X"+num2str(V_X)+"_Y"+num2str(V_Y)
				WAVE W_tmp=$S_ID+"_X"+num2str(V_X)+"_Y"+num2str(V_Y)
			
			// 3ms baseline (assuming 10kHz)
			Wavestats/Q/R=[0,29] W_tmp
				Variable V_BSL=V_avg
			
			// 12ms response window (assuming 10kHz)
			Wavestats/Q/R=[30,150] W_tmp
				Variable V_RSP=V_avg
				
			Duplicate/FREE W_tmp, W_tmp_N,W_tmp_smth
			W_tmp_smth-=V_BSL
			Smooth/B 11, W_tmp_smth
				Wavestats/Q W_tmp_smth
						
			//... IPSCs --> outward current
			W_tmp_N-=V_BSL
			W_tmp_N/=V_max
			
			Redimension/N=(numpnts(W_tmplt)) W_tmp_N
			
			Duplicate/O W_tmp_N,$S_ID+"_X"+num2str(V_X)+"_Y"+num2str(V_Y)+"_N"
			
			// --> Pearson correlation coefficient with template XPSC	
			M_grdMAP_COR[V_X][V_Y]=StatsCorrelation(W_tmp_N,W_tmplt)
			
			M_grdMAP_AMP[V_X][V_Y]=V_RSP-V_BSL
		Endfor
	
	MAKE/O/N=2/WAVE W_WvRef_smDMD={M_grdMAP_AMP,M_grdMAP_COR}
	
	SetDataFolder CDF
	
	return W_WvRef_smDMD
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_RNDseqimport([S_title])
	String S_title
	
	If(ParamIsDefault(S_title))
		S_title="Load RNDseq WAVE by selecting the corresponding *.mat file "
	Endif
	
	WAVE void
	
	Open/D/R/M=S_title/MULT=0/T=".mat" V_refnum
		If(strlen(S_filename)==0)
			return void
		Endif

		String S_path=ParseFilePath(1,S_filename,":",1, 0)			// complete filepath
	
		Newpath/Q/O P_path,S_path
			
		String S_ID
		sscanf ParseFilePath(3,S_filename,":",0, 0),"%s",S_ID
		
		String S_WAVEname=ReplaceString("\r",ParseFilePath(0, S_filename, ":", 1, 0),"")
	
	MLLoadWave/R/Y=4/Q/V/S/G/P=P_path/N=$S_ID/E S_WAVEname
	
	If(strlen(S_WaveNames)==0)	// ... no wave loaded
		return void
	Else
		WAVE W_RNDseq=$StringFromList(0,S_WaveNames)
		return W_RNDseq
	Endif
		
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function DMDoff(w)
	wave w
	
	If(waveexists(w)==0)
		return 0
	Endif
	
	Print "\r#######################################################"
	Print GetWavesDataFolder(w,2)
	
//	Print "\rBaseline (0 to 3.7s) [AVG; in mV]"
		WaveStats/Q/R=(0,3.7) w
//		Print V_avg*1e3
		Variable V_BL_AVG=V_avg
	
	Print "\rResponse (3.8 to 10s) [AVG; in mV]"
		WaveStats/Q/R=(3.8,10) w
		Print (V_avg-V_BL_AVG)*1e3
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_srsAMP([V_BSLstart,V_BSLend,V_RSPstart,V_RSPend,V_DSPLY])
	Variable V_BSLstart,V_BSLend,V_RSPstart,V_RSPend,V_DSPLY
	
	String S_Lst_trc=ListMatch(ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!A_*"),"!SRSamp_*")
	
	If(ItemsInList(S_Lst_trc)==0)
		return 0
	Endif
	
	If(ParamISDefault(V_DSPLY))
		V_DSPLY=1
	Endif
	
	// ... name of first trace taken as representative for entire series 
	WAVE w=$StringFromList(0,S_Lst_trc)
	
	If(ParamIsDefault(V_BSLstart) || ParamIsDefault(V_BSLend) || ParamIsDefault(V_RSPstart) || ParamIsDefault(V_RSPend))
		If(numpnts(w)<=50000) // assuming 10kHz --> <=5s duration
//			V_BSLstart=0.4
//			V_BSLend=0.99
//			V_RSPstart=1.0
//			V_RSPend=1.99
		
			// 28.01.2016 ... 20Hz stimulation; 1st peak analysis
			V_BSLstart=0.25
			V_BSLend=0.299
			V_RSPstart=0.303
			V_RSPend=0.315
			
		Else
			V_BSLstart=2.79
			V_BSLend=3.79
			V_RSPstart=3.80
			V_RSPend=10.00
		Endif
	
		Prompt V_BSLstart,"Baseline period start [s]:"
		Prompt V_BSLend,"Baseline period end [s]:"
		Prompt V_RSPstart,"Response period start [s]:"
		Prompt V_RSPend,"Response period end [s]:"
		DoPrompt "Specify RESPONSE windows...", V_BSLstart,V_BSLend,V_RSPstart,V_RSPend
			If(V_flag)
				return -1
			Endif	
	Endif
	
	Variable i
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	// ... name of first trace taken as representative for entire series 
	WAVE w=$StringFromList(0,S_Lst_trc)
	String S_shID="SRSamp_"+FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")
	
	MAKE/O/N=(ItemsInList(S_Lst_trc)) $S_shID
		WAVE W_SRSamp=$S_shID
	
	For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
		WAVE w=$StringFromList(i,S_Lst_trc)
		
		String S_tmp=FMI_StringfromString(note(w),"pFolder1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_"
		String S_trcID=ReplaceString(S_tmp,nameofwave(w),"")
		
		// ############################### COMPUTATION ###############################
		WaveStats/Q/Z/R=(V_BSLstart,V_BSLend) w
		Variable V_preVal=V_avg
		
		WaveStats/Q/Z/R=(V_RSPstart,V_RSPend) w
		Variable V_rspVal=V_avg
		
		W_SRSamp[i]=V_rspVal-V_preVal
	Endfor
	
	Duplicate/O W_SRSamp,$"n"+NameOfWave(W_SRSamp)
		WAVE W_nSRSamp=$"n"+NameOfWave(W_SRSamp)
	
	WaveStats/Q W_SRSamp
		W_nSRSamp/=V_min
	
	If(V_DSPLY)
		FMI_SRSamp_display(w=W_SRSamp)
		FMI_nSRSamp_display(w=W_nSRSamp)
	Endif
	
	WaveStats_to_Note(W_SRSamp)
	WaveStats_to_Note(W_nSRSamp)
	
	String S_note="\rBSLstart: "+num2str(V_BSLstart)+"\rBSLsend: "+num2str(V_BSLend)+"\rRSPstart: "+num2str(V_RSPstart)+"\rRSPsend: "+num2str(V_RSPend)
	Note W_SRSamp,S_note+note(w)
	Note W_nSRSamp,S_note+note(w)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_SRSamp_display([w])
	WAVE w
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(ParamIsDefault(w)) 					// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	
		Display/K=1/W=(400,45,800,250) w
		ModifyGraph mode=4
		ModifyGraph marker=19
		ModifyGraph rgb=(0,0,65280)
		ModifyGraph font="Arial"		
		ModifyGraph fSize=16
		ModifyGraph axThick=0.5
		Label left "\\u#2I\\Bopto\\M (pA)"
		Label bottom "\\u#2Trial #"
		SetAxis left *,0
	
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_nSRSamp_display([w])
	WAVE w
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(ParamIsDefault(w)) 					// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	
		Display/K=1/W=(420,65,820,270) w
		ModifyGraph mode=4,marker=8,opaque=1
		ModifyGraph rgb=(0,0,65280)
		ModifyGraph font="Arial"
		ModifyGraph fSize=16
		ModifyGraph axThick=0.5
		Label left "\\u#2Normalized I\\Bopto\\M"
		Label bottom "\\u#2Trial #"
		SetAxis left *,*
	
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_wvDELTA([w,V_BSLstart,V_BSLend,V_RSPstart,V_RSPend])
	WAVE w
	Variable V_BSLstart,V_BSLend,V_RSPstart,V_RSPend
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(ParamIsDefault(w)) 					// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	
	If(ParamIsDefault(V_BSLstart)) 			// default: parameter is not specified
		V_BSLstart=2.79
	Endif
	If(ParamIsDefault(V_BSLend)) 			// default: parameter is not specified
		V_BSLend=3.79
	Endif
	If(ParamIsDefault(V_RSPstart)) 		// default: parameter is not specified
		V_RSPstart=3.80
	Endif
	If(ParamIsDefault(V_RSPend)) 			// default: parameter is not specified
		V_RSPend=10.00
	Endif
	
	If(waveexists(w)==0)
		SetDataFolder CDF
		return -1
	Endif
	
	// ############################### COMPUTATION ###############################
	WaveStats/Q/Z/R=(V_BSLstart,V_BSLend) w
	Variable V_preVal=V_avg
		
	WaveStats/Q/Z/R=(V_RSPstart,V_RSPend) w
	Variable V_rspVal=V_avg
	
	String S_note=""
	
	S_note+="\r"+GetWavesDataFolder(w,3)
	S_note+="\r\tBASELINE value: "+num2str(V_preVal*1e12)+" pA"
	S_note+="\r\tRESPONSE value: "+num2str(V_rspVal*1e12)+" pA"
	S_note+="\r\t\t--> DELTA value: "+num2str((V_rspVal-V_preVal)*1e12)+" pA"
	
	Print S_note
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_AVGtrc([V_zero])
	Variable V_zero
	
	If(ParamIsDefault(V_zero))
		V_zero=1	
	Endif
	
	String S_Lst_trc=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!A_*") 

	Variable i
	
	// ... name of first trace taken as representative for entire series 
	WAVE w=$StringFromList(0,S_Lst_trc)
	String S_shID="A_"+FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")
	
	For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
		WAVE w=$StringFromList(i,S_Lst_trc)
		
		String S_tmp=FMI_StringfromString(note(w),"pFolder1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_"
		String S_trcID=ReplaceString(S_tmp,nameofwave(w),"")
		
		If(i==0)
			Duplicate/O w,$S_shID+"_"+S_trcID
				WAVE W_AVG=$S_shID+"_"+S_trcID
		Else
			W_AVG+=w
		Endif
	Endfor
	
	W_AVG/=ItemsInList(S_Lst_trc)
	
	If(V_zero)
		WaveStats/Q/R=(25e-3,75e-3) W_AVG
			W_AVG-=V_avg
	Endif
	
	Duplicate/O W_AVG,$NameOfWave(W_AVG)+"_smth"
	Smooth/B 75, $NameOfWave(W_AVG)+"_smth"

End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_VCvd([w,V_PKstart,V_PKend,V_SSstart,V_SSend])
	WAVE w
	Variable V_PKstart,V_PKend,V_SSstart,V_SSend
	
	String S_Lst_trc=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!N_*") 
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		If(ItemsInList(S_Lst_trc)==0)
			return 0
		Endif
		
		// ... consider only first trace  
		WAVE w=$StringFromList(0,S_Lst_trc)
	Endif
	
	If(ParamIsDefault(V_PKstart)) 				// default: parameter is not specified
		V_PKstart=2
	Endif
	If(ParamIsDefault(V_PKend)) 				// default: parameter is not specified
		V_PKend=2.05
	Endif
	If(ParamIsDefault(V_SSstart)) 				// default: parameter is not specified
		V_SSstart=9.5
	Endif
	If(ParamIsDefault(V_SSend)) 				// default: parameter is not specified
		V_SSend=9.55
	Endif
	
	String S_note=note(w)
	
	// ... zero trace
	If(StringMatch(S_note,"*TRACE ZEROED*")==0)
		WaveStats/Q/R=(25e-3,75e-3) w
			w-=V_avg
			NOTE/K/NOCR w,S_note+"\r\rTRACE ZEROED (baseline: "+num2str(25e-3)+"s, "+num2str(75e-3)+"s)"
	Endif
	
	MAKE/O/N=3 W_VCvd

	Wavestats/Q/R=(V_PKstart,V_PKend) w
		W_VCvd[0]=V_avg
	
	Wavestats/Q/R=(V_SSstart,V_SSend) w
		W_VCvd[1]=V_avg
	
	W_VCvd[2]=W_VCvd[1]/W_VCvd[0]
	
	// ... normalized trace
	String S_shID="N_"+FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")
	String S_tmp=FMI_StringfromString(note(w),"pFolder1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_"
	String S_trcID=ReplaceString(S_tmp,nameofwave(w),"")
	
	Duplicate/O w,$S_shID+"_"+S_trcID
		WAVE W_N=$S_shID+"_"+S_trcID
	
	W_N/=W_VCvd[0]
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_Rin([w,V_mode,V_amp,V_BLstart,V_BLend,V_RSPstart,V_RSPend])
	WAVE w
	Variable V_mode,V_amp,V_BLstart,V_BLend,V_RSPstart,V_RSPend
	
	Variable V_BLfluctTHR
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(ParamIsDefault(w)) 					// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_mode))			// default: parameter is not specified
		V_mode=0						// 0: current clamp; 1: voltage clamp
	Endif
	If(ParamIsDefault(V_amp)) 				// default: parameter is not specified
		V_amp=5
	Endif
	If(ParamIsDefault(V_BLstart)) 			// default: parameter is not specified
		V_BLstart=0.4
	Endif
	If(ParamIsDefault(V_BLend)) 			// default: parameter is not specified
		V_BLend=0.49
	Endif
	If(ParamIsDefault(V_RSPstart)) 			// default: parameter is not specified
		V_RSPstart=0.9
	Endif
	If(ParamIsDefault(V_RSPend)) 			// default: parameter is not specified
		V_RSPend=0.99
	Endif
	
	If(waveexists(w)==0)
		SetDataFolder CDF
		return -1
	Endif
	
	Switch(V_mode)
		case 0:
			V_BLfluctTHR=1e-2//5e-4	
			break
		case 1:
			V_BLfluctTHR=20e-12
			break
	Endswitch
	
	// ############################### PARAMETER RETRIEVAL ###############################
	If(ParamIsDefault(V_amp)!=0 || ParamIsDefault(V_BLstart)!=0 || ParamIsDefault(V_BLend)!=0 || ParamIsDefault(V_RSPstart)!=0 || ParamIsDefault(V_RSPend)!=0) // all optional parameters specified...
		String S_pulseName=FMI_StringfromString(note(w),"ephys.pulseName: ")
		String S_findthisStr="hp",S_substring
		
		Variable V_duration=(V_RSPstart-V_BLstart)*1e3
		If(strlen(S_pulseName)==0)
			Switch(V_mode)
				case 0:
					Prompt V_amp,"I-Amp (pA)"
					break
				case 1:
					Prompt V_amp,"V-Amp (mV)"	
					break
			Endswitch
			
			DoPrompt "Specifiy (hyperpolarization) pulse parameter(s)",V_amp
			If(V_flag)						// Cancel clicked
				SetDataFolder CDF
				return -1
			Endif
		Else
			SplitString/E=("("+S_findthisStr+".*)") S_pulseName,S_substring
			sscanf S_substring,"%*["+S_findthisStr+"]%e",V_duration
			
			SplitString/E=("("+S_findthisStr+num2str(V_duration)+"ms_"+".*)") S_pulseName,S_substring
			sscanf S_substring,"%*["+S_findthisStr+num2str(V_duration)+"ms_]%e",V_amp
		Endif
		
		If(V_amp==0)	// pulseName found, but no V_amp retrieved from pulseName
			SetDataFolder CDF
			return NaN
		Endif
	Endif
	
	// ############################### ASSESSMENT OF "RECORDING STABILITY" ###############################
	WaveStats/Q/Z/R=(V_BLstart,V_BLend) w				
	If(V_sdev>V_BLfluctTHR)
		SetDataFolder CDF
		return NaN
	Endif
	
	WaveStats/Q/Z/R=(V_RSPstart,V_RSPend) w	// "response range" 
		
	// ############################### COMPUTATION ###############################
	WaveStats/Q/Z/R=(V_BLstart,V_BLend) w
	Variable V_preVal=V_avg
		
	WaveStats/Q/Z/R=(V_RSPstart,V_RSPend) w
	Variable V_rspVal=V_avg
	
	Variable V_dVal=V_rspVal-V_preVal
	Variable V_Rin
	
	Switch(V_mode)
		case 0:
			V_Rin=abs(V_dVal/(V_amp*1e-12))		// V_amp is pA
			break
		case 1:
			V_Rin=abs((V_amp*1e-3)/V_dVal)		// V_amp is mV
			break
	Endswitch	
			
	SetDataFolder CDF
	
	If(numtype(V_Rin)==0)		// real number
		return V_Rin
	Else						// +/- INF, NaN
		return NaN
	Endif
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_mTC([w,V_start,V_end,V_killWVs])
	WAVE w
	Variable V_start,V_end,V_killWVs
	
	VARIABLE V_FitMaxIters=200 		// V_FitMaxIters controls the maximum number of passes without convergence before stopping the fit.
	VARIABLE V_FITOPTIONS=4		//  V_FITOPTIONS=4 (bit 2) suppresses the appearance of the curve fit window 
	
	Variable V_RTerror
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(ParamIsDefault(w)) 					// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_start)) 			// default: parameter is not specified
		V_start=0.5
	Endif
	If(ParamIsDefault(V_end)) 			// default: parameter is not specified
		V_end=1
	Endif
	If(ParamIsDefault(V_killWVs)) 			// default: parameter is not specified
		V_killWVs=0
	Endif
	
	If(waveexists(w)==0)
		SetDataFolder CDF
		return -1
	Endif
	
	// ############################### CURVE FITTING ###############################
	Duplicate/O w,$NameOfWave(w)+"_fit",$NameOfWave(w)+"_res"
	WAVE W_fit=$NameOfWave(w)+"_fit"
	WAVE W_res=$NameOfWave(w)+"_res"
	
	CurveFit/Q/N/O/NTHR=0/TBOX=0 exp_XOffset w [x2pnt(w,V_start),x2pnt(w,V_end)]  /D=W_fit /R=W_res
	V_RTerror=GetRTError(1)
		
	W_fit[,x2pnt(w,V_start)-1]=NaN;W_fit[x2pnt(w,V_end)+1,]=NaN
	W_res[,x2pnt(w,V_start)-1]=NaN;W_res[x2pnt(w,V_end)+1,]=NaN
		
	Variable V_tau
	WAVE W_coef
	If(waveexists(W_coef))
		V_tau=W_coef[2]
	Else
		V_tau=NaN
	Endif
	Killwaves/Z W_coef,W_sigma,W_fitConstants
	
	If(V_killWVs)
		Killwaves/Z W_fit,W_res
	Endif
	
	SetDataFolder CDF
	
	return V_tau
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_segAVG([V_zero])
	Variable V_zero
	
	If(ParamIsDefault(V_zero))
		V_zero=0
	Endif

	DFREF CDF=GetDataFolderDFR( )
	
	Variable i,j
	
	String S_Lst_trc=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!A_*") 
	
	If(ItemsinList(S_Lst_trc)==0)
		return 0
	Endif
	
	Make/O/N=0/T W_segID_Lst
		WAVE/T W_segID_Lst
	
	// ... collect information about existing segments in CDF
	For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
		WAVE w=$StringFromList(i,S_Lst_trc)
		
		String S_segID=FMI_StringfromString(note(w),"segment.ID: ")
		
		FindValue/TEXT=S_segID/Z W_segID_Lst
		If(V_Value==-1)	// not found
			InsertPoints numpnts(W_segID_Lst),1,W_segID_Lst
			W_segID_Lst[inf]=S_segID
		Endif
	Endfor
	
	// ... name of first trace taken as representative for entire series 
	WAVE w=$StringFromList(0,S_Lst_trc)
	String S_shID="A_"+FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")
	
	NewDataFolder/O :individual_traces
	
	// ... create average wave for each segment
	For(i=0;i<numpnts(W_segID_Lst);i+=1)
		String S_WvLst_seg=ListMatch(ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"*_"+W_segID_Lst[i]+"_*"),"!A_*")		
		
		For(j=0;j<ItemsInList(S_WvLst_seg);j+=1)
			WAVE w=$StringFromList(j,S_WvLst_seg)
			
			String S_tmp=FMI_StringfromString(note(w),"pFolder1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_"+W_segID_Lst[i]+"_"
			String S_trcID=ReplaceString(S_tmp,nameofwave(w),"")
			
			If(j==0)
				Duplicate/O w,$S_shID+"_"+W_segID_Lst[i]+"_"+S_trcID
					WAVE W_AVG=$S_shID+"_"+W_segID_Lst[i]+"_"+S_trcID
			Else
				W_AVG+=w
			Endif
			
			Duplicate/O w,$":individual_traces:"+nameofwave(w)
			Killwaves/Z w
		Endfor
		
		W_AVG/=ItemsInList(S_WvLst_seg)
		
		If(V_zero)
			WaveStats/Q/R=[20,29] W_AVG
				W_AVG-=V_avg
		Endif
	Endfor
	
	Killwaves/Z W_segID_Lst
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_WvSegmentation([V_mode,V_BL,V_intvl,S_RegEXP,V_subPtNum,V_segNum_hp,V_segLngth_hp,V_segAmp_hp,V_segNum_dp,V_segLngth_dp,V_segAmp_dp,V_ampINCR])
	Variable V_mode,V_BL,V_intvl,V_subPtNum
	String S_RegEXP
	Variable V_segNum_hp,V_segLngth_hp,V_segAmp_hp,V_segNum_dp,V_segLngth_dp,V_segAmp_dp,V_ampINCR
	
	If(ParamIsDefault(V_mode))			// default: parameter is not specified
		V_mode=1					// 1: String-based parameter extraction; 2: direct parameter specification
	Endif
	If(ParamIsDefault(V_BL)) 			// default: parameter is not specified
		V_BL=100e-3				// [s]
	Endif
	If(ParamIsDefault(V_intvl)) 			// default: parameter is not specified
		V_intvl=500e-3				// [s]
	Endif
	If(ParamIsDefault(S_RegEXP)) 		// default: parameter is not specified
		S_RegEXP="CCstep_([[:digit:]]+)xhp([[:digit:]]+)ms_([[:digit:]]+)pA_([[:digit:]]+)xdp([[:digit:]]+)ms_([[:digit:]]+)pA"
	Endif
	If(ParamIsDefault(V_subPtNum)) 	// default: parameter is not specified
		V_subPtNum=6				
	Endif
	If(ParamIsDefault(V_ampINCR))		// default: parameter is not specified
		V_ampINCR=1				// 1: AMP increases in between segments; 0: AMP is constant  
	Endif
	
	Variable i,i2
	String S_segNum_hp,S_segLngth_hp,S_segAmp_hp,S_segNum_dp,S_segLngth_dp,S_segAmp_dp
	
	String S_Lst_trc=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!*_s*") 
	
	If(ItemsinList(S_Lst_trc)==0)
		return 0
	Endif
	
	NewDataFolder/O :unsegmented_traces
	
	// #############################################################################################
	For(i=0;i<ItemsinList(S_Lst_trc);i+=1)
		WAVE w=$StringfromList(i,S_Lst_trc)
		 
		String S_pulsNm=FMI_StringfromString(note(w),"ephys.pulseName: ")
		
		If(V_mode==1)
			StrSwitch(S_RegEXP)
				case "CCstep_([[:digit:]]+)xhp([[:digit:]]+)ms_([[:digit:]]+)pA_([[:digit:]]+)xdp([[:digit:]]+)ms_([[:digit:]]+)pA":
					SplitString /E=(S_RegEXP) S_pulsNm,S_segNum_hp,S_segLngth_hp,S_segAmp_hp,S_segNum_dp,S_segLngth_dp,S_segAmp_dp
					break
				
				case "hp([[:digit:]]+)ms_([[:digit:]]+)pA_dp([[:digit:]]+)ms_([[:digit:]]+)pA":
					SplitString /E=(S_RegEXP) S_pulsNm,S_segLngth_hp,S_segAmp_hp,S_segLngth_dp,S_segAmp_dp
					S_segNum_hp="1"
					S_segNum_dp="1"
					break
				
				default:
					continue
					break
			Endswitch
		
			V_segNum_hp=str2num(S_segNum_hp)
			V_segLngth_hp=str2num(S_segLngth_hp)*1e-3+V_intvl
			V_segAmp_hp=-str2num(S_segAmp_hp)
			
			V_segNum_dp=str2num(S_segNum_dp)
			V_segLngth_dp=str2num(S_segLngth_dp)*1e-3+V_intvl
			V_segAmp_dp=str2num(S_segAmp_dp)
			
			If(V_flag!=V_subPtNum)	// number of matched subpatterns
				continue
			Endif
		Endif
		
		Duplicate/O w,$":unsegmented_traces:"+nameofwave(w)
		
		Variable/G V_seg_bl=0
		If(V_BL>1e-24)			// basically > 0
			V_seg_bl=1
		Endif
		Variable/G V_seg_hp=V_segNum_hp
		Variable/G V_seg_dp=V_segNum_dp
		
		String S_note
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		If(V_seg_bl==1)			// basically > 0
			Duplicate/O/R=[,x2pnt(w,V_BL)-1] w,$ReplaceString("_tr",nameofwave(w),"_s0_tr")
			WAVE W_seg=$ReplaceString("_tr",nameofwave(w),"_s0_tr")
			S_note="\rSEGMENTED trace"
			S_note+="\r\tsegment.parentWAVE: "+nameofwave(w)
			S_note+="\r\tsegment.type: bl" 
			S_note+="\r\tsegment.num: 1 of 1 baseline segments"
			S_note+="\r\tsegment.ID: s0"
			S_note+="\r\tsegment.amp: 0"
			S_note+="\r\tsegment.length: "+num2str(V_BL)
			S_note+="\r\tsegment.range: "+num2str(V_BL)
			S_note+="\r\tsegment.offset: "+num2str(0)
			S_note+=note(w)
			Note/K W_seg,S_note
		Endif
				
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		For(i2=0;i2<(V_segNum_hp);i2+=1)			
			Duplicate/O/R=[x2pnt(w,V_BL+i2*V_segLngth_hp),x2pnt(w,V_BL+(i2+1)*V_segLngth_hp)-1] w,$ReplaceString("_tr",nameofwave(w),"_s"+num2str(i2+1)+"_tr")
			WAVE W_seg=$ReplaceString("_tr",nameofwave(w),"_s"+num2str(i2+1)+"_tr")
			S_note="\rSEGMENTED trace"
			S_note+="\r\tsegment.parentWAVE: "+nameofwave(w)
			S_note+="\r\tsegment.type: hp" 
			S_note+="\r\tsegment.num: "+num2str(i2+1)+" of "+num2str(V_segNum_hp)+" hyperpolarization segments" 
			S_note+="\r\tsegment.ID: s"+num2str(i2+V_seg_bl)
			If(V_ampINCR)
				S_note+="\r\tsegment.amp: "+num2str((i2+1)*V_segAmp_hp)
			Else
				S_note+="\r\tsegment.amp: "+num2str(V_segAmp_hp)
			Endif
			S_note+="\r\tsegment.length: "+num2str(V_segLngth_hp)
			S_note+="\r\tsegment.range: "+num2str(V_segLngth_hp-V_intvl)
			S_note+="\r\tsegment.offset: "+num2str(V_BL+i2*V_segLngth_hp)
			S_note+=note(w)
			Note/K W_seg,S_note
		Endfor
		Variable V_hpOffset=V_BL+V_segNum_hp*V_segLngth_hp
		
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		For(i2=0;i2<(V_segNum_dp);i2+=1)			
			Duplicate/O/R=[x2pnt(w,V_hpOffset+i2*V_segLngth_dp),x2pnt(w,V_hpOffset+(i2+1)*V_segLngth_dp)-1] w,$ReplaceString("_tr",nameofwave(w),"_s"+num2str(V_segNum_hp+i2+1)+"_tr")
			WAVE W_seg=$ReplaceString("_tr",nameofwave(w),"_s"+num2str(V_segNum_hp+i2+1)+"_tr")
			S_note="\rSEGMENTED trace"
			S_note+="\r\tsegment.parentWAVE: "+nameofwave(w)
			S_note+="\r\tsegment.type: dp"
			S_note+="\r\tsegment.num: "+num2str(i2+1)+" of "+num2str(V_segNum_dp)+" depolarization segments" 
			S_note+="\r\tsegment.ID: s"+num2str(i2+V_seg_bl+V_segNum_hp)
			If(V_ampINCR)
				S_note+="\r\tsegment.amp: "+num2str((i2+1)*V_segAmp_dp)
			Else
				S_note+="\r\tsegment.amp: "+num2str(V_segAmp_dp)
			Endif
			S_note+="\r\tsegment.length: "+num2str(numpnts(W_seg)*deltax(W_seg))
			S_note+="\r\tsegment.range: "+num2str(V_segLngth_dp-V_intvl)
			S_note+="\r\tsegment.offset: "+num2str(V_hpOffset+i2*V_segLngth_dp)
			S_note+=note(w)
			Note/K W_seg,S_note
		Endfor
		
		Killwaves/Z w
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_WvSegmentation_undo()
	DFREF CDF=GetDataFolderDFR( )
	
	Variable i
	
	String S_Lst_trc=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"*_s*") 
	
	If(DataFolderExists(":unsegmented_traces")!=1)	// safety... if unsegemented traces cannot be found, do not delete segmented traces
		return -1
	Endif
	
	For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
		WAVE w=$StringfromList(i,S_Lst_trc)
		Killwaves/Z w
	Endfor
	
	SetDataFolder :unsegmented_traces
	S_Lst_trc=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")
		
	For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
		WAVE w=$StringfromList(i,S_Lst_trc)
		Duplicate/O w,::$nameofwave(w)
	Endfor
	SetDataFolder ::
	
	KillDataFolder/Z :unsegmented_traces	
		
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_SMM_analysis([V_mode,S_matchStr_DF,S_matchStr_sDF])
	Variable V_mode
	String S_matchStr_DF,S_matchStr_sDF
	
	
	If(ParamIsDefault(V_mode)) 			// default: parameter is not specified
		V_mode=0
	Endif
	If(ParamIsDefault(S_matchStr_DF)) 		// default: parameter is not specified
		S_matchStr_DF="E_*"
	Endif
	If(ParamIsDefault(S_matchStr_sDF)) 	// default: parameter is not specified
		S_matchStr_sDF="AAAA*"
	Endif
	
	Variable i,i2
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_DFLst=ListMatch(DFList(),S_matchStr_DF)
	
	If(ItemsInList(S_DFLst)==0)
		return 0
	Endif
	
	// ------------------------------------------------- DATA FOLDER LOOP ------------------------------------------------
	For(i=0;i<ItemsInList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
		String S_sDFLst=ListMatch(DFList(),S_matchStr_sDF)
			
		If(ItemsInList(S_sDFLst)==0)
			continue
		Endif
			
		// ------------------------------------------------- DATA subFOLDER ------------------------------------------------
		SetDataFolder $StringfromList(0,S_sDFLst)
				
		Switch(V_mode)
			case 0:
				FMI_SPK_analysis_seg()
				break
			case 1:
				FMI_PVector_init()
				break
		Endswitch
					
		SetDataFolder CDF
	Endfor

End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
StrConstant S_pvctDF="root:Packages:FMI_CPV"

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_PVct_manPARset()
	DFREF CDF=GetDataFolderDFR( )
	
	String S_DFLst=ListMatch(DFList(),"!*EXCLUDED")
	If(ItemsinList(S_DFLst)==0)
		return -1
	Endif
	
	Variable V_XLoc,V_YLoc,V_ZLoc,V_Cm,V_Ihold
	
	WAVE W_manPAR_call=$matchStrToWaveRef("W_manPAR_*",0)
	WAVE W_manPAR_lbl_call=$matchStrToWaveRef("W_manPAR_lbl_*",1)
	If(waveexists(W_manPAR_call)&&waveexists(W_manPAR_lbl_call))
		V_XLoc=W_manPAR_call[FVCV_FindEntry("rostro-caudal position (x.x / 5.0)",W_manPAR_lbl_call,1)]
		V_YLoc=W_manPAR_call[FVCV_FindEntry("distance to lateral surface (um)",W_manPAR_lbl_call,1)]
		V_ZLoc=W_manPAR_call[FVCV_FindEntry("depth from surface (um)",W_manPAR_lbl_call,1)]
		V_Cm=W_manPAR_call[FVCV_FindEntry("Cell capacitance estimate (pF)",W_manPAR_lbl_call,1)]
		V_Ihold=W_manPAR_call[FVCV_FindEntry("Holding current - CC (pA)",W_manPAR_lbl_call,1)]
	Else
		V_XLoc=0
		V_YLoc=0
		V_ZLoc=0
		V_Cm=5
		V_Ihold=NaN
	Endif
	
	Prompt V_XLoc,"Cell location: posterior to anterior (x.x / 5.0)"
	Prompt V_YLoc,"Cell location: distance to lateral surface (um)"
	Prompt V_ZLoc,"Cell location: depth from (ventral) surface (um)"
	Prompt V_Cm,"Cell capacitance estimate (pF)"
	Prompt V_Ihold,"Holding current - current clamp (pA)"
	DoPrompt "Specify 'manual' cell parameters", V_XLoc,V_YLoc,V_ZLoc,V_Cm,V_Ihold
		If(V_flag)	// CANCEL
			return -1
		Endif
	
	SetDataFolder ::
		String S_EXPid=ReplaceString("E_",GetDataFolder(0),"")
	SetDataFolder CDF
	
	MAKE/O/N=5 $"W_manPAR_"+S_EXPid
		WAVE W_manPAR=$"W_manPAR_"+S_EXPid
	MAKE/T/O/N=5 $"W_manPAR_lbl_"+S_EXPid
		WAVE/T W_manPAR_lbl=$"W_manPAR_lbl_"+S_EXPid
	
	W_manPAR[0]=V_XLoc
	W_manPAR[1]=V_YLoc
	W_manPAR[2]=V_ZLoc
	W_manPAR[3]=V_Cm
	W_manPAR[4]=V_Ihold
	
	W_manPAR_lbl[0]="rostro-caudal position (x.x / 5.0)"
	W_manPAR_lbl[1]="distance to lateral surface (um)"
	W_manPAR_lbl[2]="depth from surface (um)"
	W_manPAR_lbl[3]="Cell capacitance estimate (pF)"
	W_manPAR_lbl[4]="Holding current - CC (pA)"
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_PVector_init()
	DFREF CDF=GetDataFolderDFR( )
	String DFsav=GetDataFolder(1)
	
	String S_lbl="CELL" 
	
	Execute "NewDataFolder/O/S "+S_pvctDF
	DFREF pvctDF=GetDataFolderDFR( )
		
	String/G S_anlID="EXP_"
	String/G S_lblList="msCI;ssCI;vdCC;vdVC;esCC;esVC"
	String/G S_lblList_offsetA="msCI:18;ssCI:18;vdCC:4;vdVC:10;esCC:0;esVC:19"		// ... contains number of entries
	String/G S_lblList_offsetB="msCI:51;ssCI:33;vdCC:0;vdVC:4;esCC:14;esVC:14"		// ... contains cumulative entry number
		
	Variable/G V_PVct_offset=6
	SetDataFolder CDF
	
	Variable i,i2
	Variable V_offset=0
	
	String S_DFLst=SortList(ListMatch(DFList(),S_anlID+"*"))
	
	String S_EXPid=""
	String S_note=""
	S_note+="\rEXP.fullDF: "+DFsav
	
	For(i=0;i<ItemsinList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
			
		For(i2=0;i2<ItemsinList(S_lblList);i2+=1)
			If(StringMatch(GetDataFolder(0),"*"+StringfromList(i2,S_lblList)+"*")==1)
				S_EXPid=ReplaceString(S_anlID+StringfromList(i2,S_lblList),GetDataFolder(0),"")
				S_note+="\r\tsDF."+num2str(i)+": "+GetDataFolder(1)
				S_note+="\r\t\tsLBL."+num2str(i)+": "+StringfromList(i2,S_lblList)
				S_note+="\r\t\tsOFF."+num2str(i)+": "+num2str(NumberByKey(StringfromList(i2,S_lblList),S_lblList_offsetB))
			Endif
		Endfor
			
		SetDataFolder CDF
	Endfor
	
	S_note+="\r\rEXP.ID: "+S_EXPid
	S_note+="\rsDF.num: "+num2str(i)
			
	SetDataFolder pvctDF
	WAVE/T W_PVct_h=$"PVct_h_"+S_lbl+S_EXPid
	WAVE W_PVct=$"PVct_"+S_lbl+S_EXPid
		
	Make/O/T/N=(V_PVct_offset) $"PVct_h_"+S_lbl+S_EXPid
	WAVE/T W_PVct_h=$"PVct_h_"+S_lbl+S_EXPid
	Make/O/N=(V_PVct_offset) $"PVct_"+S_lbl+S_EXPid
	WAVE W_PVct=$"PVct_"+S_lbl+S_EXPid
		
	Note/K/NOCR W_PVct_h,S_note
	Note/K/NOCR W_PVct,S_note
		
	// ################################# FILL ENTRIES ####################################
	W_PVct_h [0] = "approximate caudo-rostral position [x/5]"
	W_PVct_h [1] = "approximate latero-medial position [um]"
	W_PVct_h [2] = "approximate depth from surface [um]"
	W_PVct_h [3] = "approximate cell capacitance [pF]"
	W_PVct_h [4] = "approximate I(hold) {CC} [pA]"
	W_PVct_h [5] = "transgenic marker expression [binary]"
		
	StrSwitch(S_lbl)
			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		default:
			InsertPoints numpnts(W_PVct_h),NumberByKey("vdCC",S_lblList_offsetA),W_PVct_h,W_PVct
				W_PVct_h [V_PVct_offset+NumberByKey("vdCC",S_lblList_offsetB)+0] = "sEPSP frequency [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdCC",S_lblList_offsetB)+1] = "sEPSP amplitude [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdCC",S_lblList_offsetB)+2] = "sEPSP risetime [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdCC",S_lblList_offsetB)+3] = "sEPSP inter-event interval [ms]"

			InsertPoints numpnts(W_PVct_h),NumberByKey("vdVC",S_lblList_offsetA),W_PVct_h,W_PVct	
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+0] = "Rin [GO] @ -70mV"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+1] = "sEPSC frequency [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+2] = "sEPSC amplitude [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+3] = "sEPSC risetime [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+4] = "sEPSC inter-event interval [ms]"
						
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+5] = "Rin [GO] @ 0mV"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+6] = "sIPSC frequency [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+7] = "sIPSC amplitude [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+8] = "sIPSC risetime [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("vdVC",S_lblList_offsetB)+9] = "sIPSC inter-event interval [ms]"
			
			InsertPoints numpnts(W_PVct_h),NumberByKey("esCC",S_lblList_offsetA),W_PVct_h,W_PVct
			
			InsertPoints numpnts(W_PVct_h),NumberByKey("esVC",S_lblList_offsetA),W_PVct_h,W_PVct
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+0] = "eEPSC: MinMin latency [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+1] = "eEPSC: AvgMin latency [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+2] = "eIPSC: MinMin latency [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+3] = "eIPSC: AvgMin latency [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+4] = "eIPSC delay {AvgMin latency} [ms]"
				
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+5] = "eEPSC: AvgAvg amplitude {FE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+6] = "eEPSC: AvgAvg amplitude {cE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+7] = "eEPSC: AvgMax amplitude {cE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+8] = "eEPSC: AvgAvg charge transfer {cE @30V} [pC]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+9] = "eIPSC: AvgAvg amplitude {FE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+10] = "eIPSC: AvgAvg amplitude {cE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+11] = "eIPSC: AvgMax amplitude {cE @30V} [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+12] = "eIPSC: AvgAvg charge transfer {cE @30V} [pC]"

				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+13] = "eEPSC: early STP index {E#2/E#1 @30V}]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+14] = "eEPSC: late STP index {E#10/E#2 @30V}"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+15] = "eIPSC: early STP index {E#2/E#1 @30V}]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+16] = "eIPSC: late STP index {E#10/E#2 @30V}"
			
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+17] = "eEPSC: Avg event # {per shock @30V}]"
				W_PVct_h [V_PVct_offset+NumberByKey("esVC",S_lblList_offsetB)+18] = "eIPSC: Avg event # {per shock @30V}]"
				
				
			InsertPoints numpnts(W_PVct_h),NumberByKey("ssCI",S_lblList_offsetA),W_PVct_h,W_PVct	
				// PASSIVE MEMBRANE PROPERTIES
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+0] = "[sngl_seg] baseline Vm [mV]"	// @ I(hold)
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+1] = "[sngl_seg] tau [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+2] = "[sngl_seg] Rin [GO]"
						
				// INPUT-OUTPUT FUNCTION				
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+3] = "[sngl_seg] rheobase [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+4] = "[sngl_seg] F @ rheobase [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+5] = "[sngl_seg] max I [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+6] = "[sngl_seg] F @ max I [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+7] = "[sngl_seg] max F [Hz]"
						
				// FIRST AP @ rheobase
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+8] = "[sngl_seg] FSL [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+9] = "[sngl_seg] AP threshold [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+10] = "[sngl_seg] AP amplitude [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+11] = "[sngl_seg] AP peak [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+12] = "[sngl_seg] AP width [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+13] = "[sngl_seg] AP risetime [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+14] = "[sngl_seg] AP max upstroke [V/s]"
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+15] = "[sngl_seg] AP max downstroke [V/s]"
						
				// AP 'TRAIN' STATISTICS
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+16] = "[sngl_seg] AP variability"		// first entry
				W_PVct_h [V_PVct_offset+NumberByKey("ssCI",S_lblList_offsetB)+17] = "[sngl_seg] AP accomodation"	// first entry
			
			InsertPoints numpnts(W_PVct_h),NumberByKey("msCI",S_lblList_offsetA),W_PVct_h,W_PVct	
				// PASSIVE MEMBRANE PROPERTIES
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+0] = "[mult_seg] baseline Vm [mV]"	// @ I(hold)
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+1] = "[mult_seg] tau [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+2] = "[mult_seg] Rin [GO]"
						
				// INPUT-OUTPUT FUNCTION				
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+3] = "[mult_seg] rheobase [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+4] = "[mult_seg] F @ rheobase [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+5] = "[mult_seg] max I [pA]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+6] = "[mult_seg] F @ max I [Hz]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+7] = "[mult_seg] max F [Hz]"
						
				// FIRST AP @ rheobase
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+8] = "[mult_seg] FSL [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+9] = "[mult_seg] AP threshold [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+10] = "[mult_seg] AP amplitude [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+11] = "[mult_seg] AP peak [mV]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+12] = "[mult_seg] AP width [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+13] = "[mult_seg] AP risetime [ms]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+14] = "[mult_seg] AP max upstroke [V/s]"
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+15] = "[mult_seg] AP max downstroke [V/s]"
						
				// AP 'TRAIN' STATISTICS
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+16] = "[mult_seg] AP variability"		// first entry
				W_PVct_h [V_PVct_offset+NumberByKey("msCI",S_lblList_offsetB)+17] = "[mult_seg] AP accomodation"	// first entry
			break 
		
	Endswitch
		
	W_PVct=NaN
	
	SetDataFolder CDF
				
	FMI_PVct_Wvfill(S_lbl,S_EXPid)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_PVct_Wvfill(S_lbl,S_EXPid)
	String S_lbl,S_EXPid
	
	DFREF CDF=GetDataFolderDFR( )
	
	Variable i
	
	SetDataFolder $S_pvctDF+":"
	NVAR V_PVct_offset

	WAVE/T W_PVct_h=$"PVct_h_"+S_lbl+S_EXPid
	WAVE W_PVct=$"PVct_"+S_lbl+S_EXPid
	
	If(waveexists(W_PVct_h)==0 || waveexists(W_PVct)==0)	// either of the two not existing...
		SetDataFolder CDF
		return -1
	Endif
	
	If(DataFolderExists(FMI_StringfromString(note(W_PVct_h),"EXP.fullDF: "))==0)
		SetDataFolder CDF
		return -1
	Endif
		
	SetDataFolder $FMI_StringfromString(note(W_PVct_h),"EXP.fullDF: ")
	DFREF eDF=GetDataFolderDFR( )
	
	Variable sDFnum=FVCV_ValuefromString(note(W_PVct_h),"sDF.num: ")
		
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: SUBLABELS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<sDFnum;i+=1)
		
		// ................................ 'MANUAL EXPERIMENT PARAMETERS' ..................................
		WAVE W_manPAR=FMI_matchStrToWaveRef("W_manPAR*",0)
		WAVE/T W_manPAR_lbl=FMI_matchStrToWaveRef("W_manPAR_lbl*",1)
		
		If(waveexists(W_manPAR)&&waveexists(W_manPAR_lbl))
			W_PVct [0] = W_manPAR[FindEntry("rostro-caudal position (x.x / 5.0)",W_manPAR_lbl)]		// "approximate caudo-rostral position [x/5]"
			W_PVct [1] = W_manPAR[FindEntry("distance to lateral surface (um)",W_manPAR_lbl)]		// "approximate latero-medial position [um]"
			W_PVct [2] = W_manPAR[FindEntry("depth from surface (um)",W_manPAR_lbl)]			// "approximate depth from surface [um]"
			W_PVct [3] = W_manPAR[FindEntry("Cell capacitance estimate (pF)",W_manPAR_lbl)]		// "approximate cell capacitance [pF]"
			W_PVct [4] = W_manPAR[FindEntry("Holding current - CC (pA)",W_manPAR_lbl)]			// "approximate I(hold) {CC} [pA]"
			W_PVct [5] = NaN																	// "transgenic marker expression [binary]"
		Endif
		
		// ................................ 'ANALYSIS PARAMETERS' ..................................
		String S_sDF=FMI_StringfromString(note(W_PVct_h),"sDF."+num2str(i)+": ")
			
		If(DataFolderExists(S_sDF)!=1)
			SetDataFolder CDF
			continue
		Endif
		String S_sublbl=FMI_StringfromString(note(W_PVct_h),"sLBL."+num2str(i)+": ")
			
		Variable V_offset=FVCV_ValuefromString(note(W_PVct_h),"sOFF."+num2str(i)+": ")
			
		SetDataFolder S_sDF
			
		StrSwitch(S_sublbl)
				// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			case "vdCC":
				WAVE W_f=FMI_matchStrToWaveRef("W_F_EPSP*",0)
				If(waveexists(W_f))
					WaveStats/Q W_f
					W_PVct[V_PVct_offset+V_offset+0]=V_avg
				Else
					W_PVct[V_PVct_offset+V_offset+0]=NaN
				Endif
				
				WAVE W_Amp=FMI_matchStrToWaveRef("W_AMP_EPSP*",0)
				If(waveexists(W_Amp))
					WaveStats/Q W_Amp
					W_PVct[V_PVct_offset+V_offset+1]=V_avg*1e3		// conversion into mV
				Else
					W_PVct[V_PVct_offset+V_offset+1]=NaN
				Endif
				
				WAVE W_RsT=FMI_matchStrToWaveRef("W_RST_EPSP*",0)
				If(waveexists(W_RsT))
					WaveStats/Q W_RsT
					W_PVct[V_PVct_offset+V_offset+2]=V_avg*1e3		// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+2]=NaN
				Endif	
				
				WAVE W_IEI=FMI_matchStrToWaveRef("W_IEI_EPSP*",0)
				If(waveexists(W_RsT))
					WaveStats/Q W_RsT
					W_PVct[V_PVct_offset+V_offset+3]=V_avg*1e3		// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+3]=NaN
				Endif
				
				break
					
				// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			case "vdVC":
				WAVE W_Rin=FMI_matchStrToWaveRef("W_Rin_EPSC*",0)
				If(waveexists(W_Rin))
					WaveStats/Q W_Rin
					W_PVct[V_PVct_offset+V_offset+0]=V_avg*1e-9	// conversion into GO
				Else
					W_PVct[V_PVct_offset+V_offset+0]=NaN
				Endif
				
				WAVE W_F=FMI_matchStrToWaveRef("W_F_EPSC*",0)
				If(waveexists(W_F))
					WaveStats/Q W_F
					W_PVct[V_PVct_offset+V_offset+1]=V_avg
				Else
					W_PVct[V_PVct_offset+V_offset+1]=NaN
				Endif
				
				WAVE W_AMP=FMI_matchStrToWaveRef("W_AMP_EPSC*",0)
				If(waveexists(W_AMP))
					WaveStats/Q W_AMP
					W_PVct[V_PVct_offset+V_offset+2]=V_avg*1e12	// conversion into pA
				Else
					W_PVct[V_PVct_offset+V_offset+2]=NaN
				Endif			
				
				WAVE W_RST=FMI_matchStrToWaveRef("W_RST_EPSC*",0)
				If(waveexists(W_RST))
					WaveStats/Q W_RST
					W_PVct[V_PVct_offset+V_offset+3]=V_avg*1e3	// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+3]=NaN
				Endif
						
				WAVE W_IEI=FMI_matchStrToWaveRef("W_IEI_EPSC*",0)
				If(waveexists(W_IEI))
					WaveStats/Q W_IEI
					W_PVct[V_PVct_offset+V_offset+4]=V_avg*1e3	// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+4]=NaN
				Endif
						
				// ......................................................... IPSC ..............................................................
				WAVE W_Rin=FMI_matchStrToWaveRef("W_Rin_IPSC*",0)
				If(waveexists(W_Rin))
					WaveStats/Q W_Rin
					W_PVct[V_PVct_offset+V_offset+5]=V_avg*1e-9	// conversion into GO
				Else
					W_PVct[V_PVct_offset+V_offset+5]=NaN
				Endif
				
				WAVE W_F=FMI_matchStrToWaveRef("W_F_IPSC*",0)
				If(waveexists(W_F))
					WaveStats/Q W_F
					W_PVct[V_PVct_offset+V_offset+6]=V_avg
				Else
					W_PVct[V_PVct_offset+V_offset+6]=NaN
				Endif
				
				WAVE W_AMP=FMI_matchStrToWaveRef("W_AMP_IPSC*",0)
				If(waveexists(W_AMP))
					WaveStats/Q W_AMP
					W_PVct[V_PVct_offset+V_offset+7]=V_avg*1e12	// conversion into pA
				Else
					W_PVct[V_PVct_offset+V_offset+7]=NaN
				Endif			
				
				WAVE W_RST=FMI_matchStrToWaveRef("W_RST_IPSC*",0)
				If(waveexists(W_RST))
					WaveStats/Q W_RST
					W_PVct[V_PVct_offset+V_offset+8]=V_avg*1e3	// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+8]=NaN
				Endif
						
				WAVE W_IEI=FMI_matchStrToWaveRef("W_IEI_IPSC*",0)
				If(waveexists(W_IEI))
					WaveStats/Q W_IEI
					W_PVct[V_PVct_offset+V_offset+9]=V_avg*1e3	// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+9]=NaN
				Endif
				break
				
				// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			case "esVC":
				WAVE W_minFEL_EPSC=FMI_matchStrToWaveRef("W_minFEL_EPSC*",0)	// "eEPSC: MinMin latency [ms]"
				If(waveexists(W_minFEL_EPSC)&&numpnts(W_minFEL_EPSC)>0)
					WaveStats/Q W_minFEL_EPSC
					W_PVct[V_PVct_offset+V_offset+0]=V_min*1e3
				Else
					W_PVct[V_PVct_offset+V_offset+0]=NaN
				Endif
				
				WAVE W_avgFEL_EPSC=FMI_matchStrToWaveRef("W_avgFEL_EPSC*",0)	// "eEPSC: AvgMin latency [ms]"
				If(waveexists(W_avgFEL_EPSC)&&numpnts(W_avgFEL_EPSC)>0)
					WaveStats/Q W_avgFEL_EPSC
					W_PVct[V_PVct_offset+V_offset+1]=V_min*1e3
				Else
					W_PVct[V_PVct_offset+V_offset+1]=NaN
				Endif
				
				WAVE W_minFEL_IPSC=FMI_matchStrToWaveRef("W_minFEL_IPSC*",0)	// "eIPSC: MinMin latency [ms]"
				If(waveexists(W_minFEL_IPSC)&&numpnts(W_minFEL_IPSC)>0)
					WaveStats/Q W_minFEL_IPSC
					W_PVct[V_PVct_offset+V_offset+2]=V_min*1e3
				Else
					W_PVct[V_PVct_offset+V_offset+2]=NaN
				Endif
				
				WAVE W_avgFEL_IPSC=FMI_matchStrToWaveRef("W_avgFEL_IPSC*",0)	// "eIPSC: AvgMin latency [ms]"
				If(waveexists(W_avgFEL_IPSC)&&numpnts(W_avgFEL_IPSC)>0)
					WaveStats/Q W_avgFEL_IPSC
					W_PVct[V_PVct_offset+V_offset+3]=V_min*1e3
				Else
					W_PVct[V_PVct_offset+V_offset+3]=NaN
				Endif
				
				If(waveexists(W_avgFEL_EPSC)&&numpnts(W_avgFEL_EPSC)>0&&waveexists(W_avgFEL_IPSC)&&numpnts(W_avgFEL_IPSC)>0)	// "eIPSC delay {AvgMin latency} [ms]"
					W_PVct[V_PVct_offset+V_offset+4]=W_PVct[V_PVct_offset+V_offset+3]-W_PVct[V_PVct_offset+V_offset+1]
				Else
					W_PVct[V_PVct_offset+V_offset+4]=NaN
				Endif
				
				// ... AMPLITUDE & CHARGE TRANSFER
				WAVE W_avgFEA_EPSC=FMI_matchStrToWaveRef("W_avgFEA_EPSC*",0)	// "eEPSC: AvgAvg amplitude {FE @30V} [pA]"
				If(waveexists(W_avgFEA_EPSC)&&numpnts(W_avgFEA_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+5]=W_avgFEA_EPSC[inf]*1e12	
				Else
					W_PVct[V_PVct_offset+V_offset+5]=NaN
				Endif
				
				WAVE W_avgcEA_EPSC=FMI_matchStrToWaveRef("W_avgcEA_EPSC*",0)	// "eEPSC: AvgAvg amplitude {cE @30V} [pA]"
				If(waveexists(W_avgcEA_EPSC)&&numpnts(W_avgcEA_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+6]=W_avgcEA_EPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+6]=NaN
				Endif
				
				WAVE W_maxcEA_EPSC=FMI_matchStrToWaveRef("W_maxcEA_EPSC*",0)	// "eEPSC: AvgMax amplitude {cE @30V} [pA]"
				If(waveexists(W_maxcEA_EPSC)&&numpnts(W_maxcEA_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+7]=W_maxcEA_EPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+7]=NaN
				Endif
				
				WAVE W_avgcEQ_EPSC=FMI_matchStrToWaveRef("W_avgcEQ_EPSC*",0)	//  "eEPSC: AvgAvg charge transfer {cE @30V} [pC]"
				If(waveexists(W_avgcEQ_EPSC)&&numpnts(W_avgcEQ_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+8]=W_avgcEQ_EPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+8]=NaN
				Endif
				
				WAVE W_avgFEA_IPSC=FMI_matchStrToWaveRef("W_avgFEA_IPSC*",0)		// "eIPSC: AvgAvg amplitude {FE @30V} [pA]"
				If(waveexists(W_avgFEA_IPSC)&&numpnts(W_avgFEA_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+9]=W_avgFEA_IPSC[inf]*1e12	
				Else
					W_PVct[V_PVct_offset+V_offset+9]=NaN
				Endif
				
				WAVE W_avgcEA_IPSC=FMI_matchStrToWaveRef("W_avgcEA_IPSC*",0)		// "eIPSC: AvgAvg amplitude {cE @30V} [pA]"
				If(waveexists(W_avgcEA_IPSC)&&numpnts(W_avgcEA_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+10]=W_avgcEA_IPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+10]=NaN
				Endif
				
				WAVE W_maxcEA_IPSC=FMI_matchStrToWaveRef("W_maxcEA_IPSC*",0)	// "eIPSC: AvgMax amplitude {cE @30V} [pA]"
				If(waveexists(W_maxcEA_IPSC)&&numpnts(W_maxcEA_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+11]=W_maxcEA_IPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+11]=NaN
				Endif
				
				WAVE W_avgcEQ_IPSC=FMI_matchStrToWaveRef("W_avgcEQ_IPSC*",0)		//  "eIPSC: AvgAvg charge transfer {cE @30V} [pC]"
				If(waveexists(W_avgcEQ_IPSC)&&numpnts(W_avgcEQ_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+12]=W_avgcEQ_IPSC[inf]*1e12
				Else
					W_PVct[V_PVct_offset+V_offset+12]=NaN
				Endif
				
				// ... SHORT-TERM PLASTICITY
				WAVE W_erlSTP_EPSC=FMI_matchStrToWaveRef("W_erlSTP_EPSC*",0)		// "eEPSC: early STP index {E#2/E#1 @30V}]"
				If(waveexists(W_erlSTP_EPSC)&&numpnts(W_erlSTP_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+13]=W_erlSTP_EPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+13]=NaN
				Endif
				
				WAVE W_latSTP_EPSC=FMI_matchStrToWaveRef("W_latSTP_EPSC*",0)		// "eEPSC: late STP index {E#10/E#2 @30V}"
				If(waveexists(W_latSTP_EPSC)&&numpnts(W_latSTP_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+14]=W_latSTP_EPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+14]=NaN
				Endif
				
				WAVE W_erlSTP_IPSC=FMI_matchStrToWaveRef("W_erlSTP_IPSC*",0)		// "eIPSC: early STP index {E#2/E#1 @30V}]"
				If(waveexists(W_erlSTP_IPSC)&&numpnts(W_erlSTP_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+15]=W_erlSTP_IPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+15]=NaN
				Endif
				
				WAVE W_latSTP_IPSC=FMI_matchStrToWaveRef("W_latSTP_IPSC*",0)		// "eIPSC: late STP index {E#10/E#2 @30V}"
				If(waveexists(W_latSTP_IPSC)&&numpnts(W_latSTP_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+16]=W_latSTP_IPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+16]=NaN
				Endif
				
				//... MISC
				WAVE W_EVTnum_EPSC=FMI_matchStrToWaveRef("W_EVTnum_EPSC*",0)		// "eEPSC: Avg event # {per shock @30V}]"
				If(waveexists(W_EVTnum_EPSC)&&numpnts(W_EVTnum_EPSC)>0)
					W_PVct[V_PVct_offset+V_offset+17]=W_EVTnum_EPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+17]=NaN
				Endif
				
				WAVE W_EVTnum_IPSC=FMI_matchStrToWaveRef("W_EVTnum_IPSC*",0)		// "eIPSC: Avg event # {per shock @30V}]"
				If(waveexists(W_EVTnum_IPSC)&&numpnts(W_EVTnum_IPSC)>0)
					W_PVct[V_PVct_offset+V_offset+18]=W_EVTnum_IPSC[inf]
				Else
					W_PVct[V_PVct_offset+V_offset+18]=NaN
				Endif
				break
				
				// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			case "msCI":
			case "ssCI":
				WAVE W_BL=FMI_matchStrToWaveRef("W_BL*",0)
				If(waveexists(W_BL))
					WaveStats/Q W_BL
					W_PVct[V_PVct_offset+V_offset+0]=V_avg*1e3	// conversion into mV
				Else
					W_PVct[V_PVct_offset+V_offset+0]=NaN
				Endif
							
				WAVE W_mTC=FMI_matchStrToWaveRef("W_mTC*",0)
				If(waveexists(W_mTC))
					WaveStats/Q W_mTC
					W_PVct[V_PVct_offset+V_offset+1]=V_avg*1e3	// conversion into ms
				Else
					W_PVct[V_PVct_offset+V_offset+1]=NaN
				Endif
						
				WAVE W_ccRin=FMI_matchStrToWaveRef("W_ccRin*",0)
				If(waveexists(W_ccRin))
					WaveStats/Q W_ccRin
					W_PVct[V_PVct_offset+V_offset+2]=V_avg*1e-9	// conversion into GO
				Else
					W_PVct[V_PVct_offset+V_offset+2]=NaN
				Endif
						
				WAVE W_IF_I=FMI_matchStrToWaveRef("W_IF_I*",0)
				WAVE W_IF_V=FMI_matchStrToWaveRef("W_IF_V*",0)
						
				If(waveexists(W_IF_I)&&waveexists(W_IF_V))
					W_PVct [V_PVct_offset+V_offset+3] = W_IF_I[0]*1e12						// "rheobase [pA]"
					W_PVct [V_PVct_offset+V_offset+4] = W_IF_V[0]							// "F @ rheobase [Hz]"
					W_PVct [V_PVct_offset+V_offset+5] = W_IF_I[numpnts(W_IF_I)-1]*1e12		// "max I [pA]"
					W_PVct [V_PVct_offset+V_offset+6] = W_IF_V[numpnts(W_IF_I)-1]			// "F @ max I [Hz]"
							
					WaveStats/Q W_IF_V
					W_PVct [V_PVct_offset+V_offset+7] = V_max								// "max F [Hz]"
				Else
					W_PVct [V_PVct_offset+V_offset+7,V_PVct_offset+V_offset+7] = NaN
				Endif
						
				WAVE W_FSL_V=FMI_matchStrToWaveRef("W_FSL_V*",0)
				If(waveexists(W_FSL_V))
					W_PVct [V_PVct_offset+V_offset+8] = W_FSL_V[0]*1e3	// "FSL [ms]"
				Else
					W_PVct [V_PVct_offset+V_offset+8] = NaN
				Endif
						
				WAVE W_APthr_V=FMI_matchStrToWaveRef("W_APthr_V*",0)
				If(waveexists(W_APthr_V))
					W_PVct [V_PVct_offset+V_offset+9] = W_APthr_V[0]*1e3	// "AP threshold [mV]"
				Else
					W_PVct [V_PVct_offset+V_offset+9] = NaN
				Endif
						
				WAVE W_APht_V=FMI_matchStrToWaveRef("W_APht_V*",0)
				If(waveexists(W_APht_V))
					W_PVct [V_PVct_offset+V_offset+10] = W_APht_V[0]*1e3	// "AP amplitude [mV]"
				Else
					W_PVct [V_PVct_offset+V_offset+10] = NaN
				Endif
							
				WAVE W_APpk_V=FMI_matchStrToWaveRef("W_APpk_V*",0)
				If(waveexists(W_APpk_V))
					W_PVct [V_PVct_offset+V_offset+11] = W_APpk_V[0]*1e3		// "AP peak [mV]"
				Else
					W_PVct [V_PVct_offset+V_offset+11] = NaN
				Endif
						
				WAVE W_APwd_V=FMI_matchStrToWaveRef("W_APwd_V*",0)
				If(waveexists(W_APwd_V))
					W_PVct [V_PVct_offset+V_offset+12] = W_APwd_V[0]*1e3		// "AP width [ms]"
				Else
					W_PVct [V_PVct_offset+V_offset+12] = NaN
				Endif
						
				WAVE W_APrs_V=FMI_matchStrToWaveRef("W_APrs_V*",0)
				If(waveexists(W_APrs_V))
					W_PVct [V_PVct_offset+V_offset+13] = W_APrs_V[0]*1e3		// "AP risetime [ms]"
				Else
					W_PVct [V_PVct_offset+V_offset+13] = NaN
				Endif
						
				WAVE W_APup_V=FMI_matchStrToWaveRef("W_APup_V*",0)
				If(waveexists(W_APup_V))
					W_PVct [V_PVct_offset+V_offset+14] = W_APup_V[0]		// "AP max upstroke [V/s]"
				Else
					W_PVct [V_PVct_offset+V_offset+14] = NaN
				Endif
						
				WAVE W_APdn_V=FMI_matchStrToWaveRef("W_APdn_V*",0)
				If(waveexists(W_APdn_V))
					W_PVct [V_PVct_offset+V_offset+15] = W_APdn_V[0]		// "AP max downstroke [V/s]"
				Else
					W_PVct [V_PVct_offset+V_offset+15] = NaN
				Endif
						
				WAVE W_AC_V=FMI_matchStrToWaveRef("W_AC_V*",0)
				If(waveexists(W_AC_V))
					W_PVct [V_PVct_offset+V_offset+16] = W_AC_V[0]		//  "AP variability (CV of ISI)"	(first entry)
				Else
					W_PVct [V_PVct_offset+V_offset+16] = NaN
				Endif
						
				WAVE W_VR_V=FMI_matchStrToWaveRef("W_VR_V*",0)
				If(waveexists(W_VR_V))
					W_PVct [V_PVct_offset+V_offset+17] = W_VR_V[0]		// "AP accomodation (Interval last 2 APs / Interval first 2 APs)"	(first entry)
				Else
					W_PVct [V_PVct_offset+V_offset+17] = NaN
				Endif
				break
		EndSwitch
				
		SetDataFolder eDF
	Endfor	// SUBLABELS Loop
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
	SetDataFolder CDF
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
CONSTANT V_binWidth_Amp_EPSP=0.5e-3
CONSTANT V_binWidth_Amp_EPSC=-2.5e-12
CONSTANT V_binWidth_Amp_IPSC=2.5e-12
CONSTANT V_binWidth_RsT_EPSP=0.5e-3
CONSTANT V_binWidth_RsT_XPSC=0.2e-3
CONSTANT V_binWidth_IEI_XPSX=20e-3
CONSTANT V_HST_binNum=40

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_STIMinfo(w[,V_BLstart,V_BLend])
	WAVE w
	Variable V_BLstart,V_BLend
	
	If(waveexists(w)==0)
		return -1
	Endif
	
	If(ParamIsDefault(V_BLstart)) 		// default: parameter is not specified
		V_BLstart=25e-3				// [s]
	Endif
	If(ParamIsDefault(V_BLend)) 		// default: parameter is not specified
		V_BLend=75e-3				// [s]
	Endif
	
	// ... infer stimulus amplitude
	WaveStats/Q w
	Variable V_peak=V_max
	
	// ... STIMamp 'Lookup table'
	Variable/G V_STIMamp
		
	If(V_peak>=11e-9)
		V_STIMamp=30
		
	ElseIf(V_peak>=8e-9 && V_peak<11e-9)
		V_STIMamp=20
		
	ElseIf(V_peak>=6e-9 && V_peak<8e-9)
		V_STIMamp=10
		
	ElseIf(V_peak>=4e-9 && V_peak<6e-9)
		V_STIMamp=5
		
	ElseIf(V_peak>=2e-9 && V_peak<3e-9)
		V_STIMamp=2.5
		
	ElseIf(V_peak>=1e-9 && V_peak<2e-9)
		V_STIMamp=1
		
	ElseIf(V_peak>=0.5e-9 && V_peak<1e-9)
		V_STIMamp=0
		
	Endif
		
	// ... infer stimulus number (train / single)
	FindLevels/EDGE=1/M=5e-3/P/Q w,(V_peak*0.9)	// minimum level: 90% of peak 
	If(V_flag==2)
		return -2	// No level crossings were found
	Endif
		
	Variable/G V_STIMnum=V_LevelsFound
		
	WAVE/Z W_FindLevels
	Killwaves/Z W_FindLevels
			
	// ... infer holding potential (class)
	WaveStats/Q/R=(V_BLstart,V_BLend) w
	Variable/G V_HOLDmode	// 1 = voltage clamp / EPSC; 2 = voltage clamp / IPSC		
			
	If(V_avg<1.5e-11)			// empirically chosen & DIRTY: in a healthy cell @ a holding potential of -70mV (very little) negative current has to be injected
		V_HOLDmode=1
			
	ElseIf(V_avg>=1.5e-11)		// empirically chosen & DIRTY: in a healthy cell @ a holding potential of 0mV, (considerable) negative current has to be injected
		V_HOLDmode=2
			
	Endif
	
	return 1
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EVT_analysis_seg()	
	Variable i,i2,i3
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_DFLst=ListMatch(DFList(),"STIM_VCtest*")
	S_DFLst+=ListMatch(DFList(),"VC_*")
	
	If(ItemsinList(S_DFLst)==0)
		return -1
	Endif
	
	Variable V_box=5
	
	// ..................................................................................
	String S_HOLDmodeList="EPSCs;IPSCs;all",S_HOLDmodeCHOICE
	Prompt S_HOLDmodeCHOICE,"PSC type: ", popup,S_HOLDmodeList
	DoPrompt "Select PSCs to analyze...",S_HOLDmodeCHOICE
		If(V_flag)
			return -1
		Endif
	
	Variable V_zero
	Variable V_HOLDmodeCHOICE
	StrSwitch (S_HOLDmodeCHOICE)
		case "EPSCs":
				V_HOLDmodeCHOICE=1
				V_zero=0
			break
		case "IPSCs":
				V_HOLDmodeCHOICE=2
				V_zero=1
			break
		case "all":
				V_HOLDmodeCHOICE=3
				V_zero=0
			break
	Endswitch
	// ..................................................................................
	
	For(i=0;i<ItemsInList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
		DFREF sDF=GetDataFolderDFR( )
		String S_sDF=GetDataFolder(0)
			
		WAVE W_ref=FMI_matchStrToWaveRef("*_tr*",0)
		If(waveexists(W_ref))
					
			If(FMI_STIMinfo(W_ref))	// STIMinfo did not cause errors
				NVAR V_STIMamp,V_STIMnum,V_HOLDmode
				
				If(V_HOLDmode!=V_HOLDmodeCHOICE && V_HOLDmodeCHOICE!=3)	// ... allows selective analysis of one XPSC type...
					SetDataFolder CDF
					continue
				Endif
				
				FMI_WvSegmentation(V_mode=2,V_BL=0.3,V_intvl=0,V_segNum_hp=0,V_segLngth_hp=0,V_segAmp_hp=0,V_segNum_dp=V_STIMnum,V_segLngth_dp=50e-3,V_segAmp_dp=V_STIMamp,V_ampINCR=0)
				FMI_segAVG(V_zero=V_zero)
			Else
				SetDataFolder CDF
				continue
			Endif
		Else
			SetDataFolder CDF
			continue
		Endif
			
		// .......................................................... DESIGNED to work on segmented data only ...............................................
		NVAR V_seg_bl,V_seg_hp,V_seg_dp
		If(NVAR_Exists(V_seg_dp)==0)							
			continue
		Endif
			
		Variable V_segOffset=0; String S_ignore=""
		String S_grpID_BL="",S_grpID_hp=""
		If(NVAR_Exists(V_seg_bl)==1)							
			V_segOffset+=V_seg_bl
			S_grpID_BL="_s"+num2str(V_segOffset-1)+"_"	// in case there would be >1 BL segments, only the last one would be included
		Endif
		If(NVAR_Exists(V_seg_hp)==1)							
			V_segOffset+=V_seg_hp
			S_grpID_hp="_s"+num2str(V_segOffset-1)+"_"		// in case there would be >1 hp segments, only the last one would be included
		Endif
			
		For(i2=0;i2<V_segOffset;i2+=1)
			S_ignore+="_s"+num2str(i2)+"_"
			If(i2<V_segOffset-1)
				S_ignore+="|"
			Endif
		Endfor
			
		// ########################### SERIES INFORMATION (rep#) ###############################
		String S_RPT,S_tmp
		SplitString /E=("(_n.*)") StringfromList(i,S_DFLst),S_tmp
		S_tmp=ReplaceString("_n",S_tmp,"") 
		sscanf S_tmp, "%s",S_RPT
		Variable/G V_RPT=str2num(S_RPT)
			
		// ############################### PREPARATION - WAVE LISTS ###############################
		String S_Lst_seg=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")	// ALL TRACES (segments)
					
		String S_Lst_trc=RemoveFromList(GrepList(WaveList("*_tr*",";",""),"("+S_ignore+")"),S_Lst_seg)	// RELEVANT TRACES (segments) 
		If(ItemsInList(S_Lst_trc)==0)
			SetDataFolder CDF
			continue
		Endif
			
		String S_Lst_trc_BL=GrepList(WaveList("*_tr*",";",""),"("+S_grpID_BL+")")
				
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: EXP STRING (identifier) :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		WAVE w=$StringFromList(0,S_Lst_trc)			
		String S_YYMMDD=ReplaceString("E_",(FMI_StringfromString(note(w),"pFolder2: ")),"")
		If(strlen(S_YYMMDD)!=6)	// YYMMDD
			S_YYMMDD="YYMMDD"
		Endif
		String S_EXPnum=FMI_StringfromString(note(w),"Field1: ")
			
		String/G S_shID=S_YYMMDD+"_"+S_EXPnum+ReplaceString(CleanUpName(FMI_StringfromString(note(w),"ephys.pulseName: "),0),S_sDF,"")
			
		// ############################### ANALYSIS - INDIVIDUAL WAVES ###############################			
		For(i2=0;i2<ItemsInList(S_Lst_trc);i2+=1)
			WAVE w=$StringFromList(i2,S_Lst_trc)
				
			WAVE w_BL=FMI_matchStrToWaveRef("*"+FMI_StringfromString(note(w),"Field3: ")+S_grpID_BL+"*",0)
			Duplicate/O w_BL,W_tmp
			Smooth/B V_box,W_tmp
			WaveStats/Q/R=(0,0.1) W_tmp
			Killwaves/Z W_tmp
						
			FMI_STIM_EventDTCT(w=w,V_BLANK=1,V_config=V_HOLDmode,V_noise=4*V_sdev,V_box=V_box)
		Endfor
			
		// ############################### SERIES SUMMARY ###############################		
		If(DataFolderExists(":TRC_analysis_EVT"))
			SetDataFolder :TRC_analysis_EVT
			
			DFREF eDF=GetDataFolderDFR( )
			
			String S_WvLst_onst=WaveList("*_EVTonst",";","")
						
			Make/O/N=(ItemsInList(S_WvLst_onst)) $"W_EVTonst_"+S_shID,$"W_EVTpkTm_"+S_shID,$"W_EVTamp_"+S_shID
			WAVE W_onst=$"W_EVTonst_"+S_shID
			WAVE W_pkTm=$"W_EVTpkTm_"+S_shID
			WAVE W_amp=$"W_EVTamp_"+S_shID
			SetScale d,0,0,"s",W_onst,W_pkTm
			SetScale d,0,0,WaveUnits(w,-1),W_amp
							
			For(i2=0;i2<ItemsInList(S_WvLst_onst);i2+=1)
				WAVE W_onst_tmp=$StringFromList(i2,S_WvLst_onst)
				WAVE W_peak_tmp=$ReplaceString("onst",nameofwave(W_onst_tmp),"peak")
				WAVE W_amp_tmp=$ReplaceString("onst",nameofwave(W_onst_tmp),"amp")
							
				If(numpnts(W_onst_tmp)>0)
					W_onst[i2]=W_onst_tmp[0]*DimDelta(W_ref,0)	// first event only...
					W_pkTm[i2]=(W_peak_tmp[0]-W_onst_tmp[0])*DimDelta(W_ref,0)	// first event only...
					W_amp[i2]=W_amp_tmp[0]	// first event only...
				Else
					W_onst[i2]=NaN	// first event only...
					W_pkTm[i2]=NaN	// first event only...
					W_amp[i2]=NaN	// first event only...
				Endif 
				Killwaves/Z W_onst_tmp,W_peak_tmp,W_amp_tmp
			Endfor
						
			WaveStats_to_Note(W_onst);WaveStats_to_Note(W_pkTm);WaveStats_to_Note(W_amp)
			
			SetDataFolder ::
			
			// ... check whether any events have been detected in this DF
			WAVE W_FEL=FMI_STIM_EventDTCT_SRSsmm()
			If(waveexists(W_FEL)==0 || numpnts(W_FEL)==0)
				SetDataFolder CDF
				NewDataFolder/O :NoEVTsrs
				DuplicateDataFolder sDF, $":NoEVTsrs:"+S_sDF
				KillDataFolder/Z sDF
			Endif
			
		Endif

		SetDataFolder CDF
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EVT_analysis_seg_SMM([S_ID])	
	String S_ID
	Variable i
	
	If(ParamIsDefault(S_ID))
		S_ID=""
	Endif
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_STIMLst="0;1;2.5;5;10;20;30"
	
	// 2013 data...
//	String S_DFLst=ListMatch(DFList(),"STIM_VCtest*")
	// 2014 data...
	String S_DFLst=ListMatch(DFList(),"VC_0_1DLY_0_1DUR*")
	
	If(ItemsinList(S_DFLst)==0)
		return -1
	Else
		SetDataFolder $StringfromList(0,S_DFLst)
		SVAR S_shID
			String S_YYMMDD,S_EXPnum
			SplitString /E=( "([[:digit:]]+)_([[:digit:]]+)") S_shID,S_YYMMDD,S_EXPnum
			String S_EXP=S_YYMMDD+"_"+S_EXPnum
		SetDataFolder CDF
	Endif
	
	// ############################### SETUP EXPERIMENT(=CDF) ANALYSIS ###############################
	NewDataFolder/O/S $":EXP_esVC"+S_EXP
		DFREF eDF=GetDataFolderDFR( )
		
		KIllwaves/A/Z
		
		MAKE/O/N=(ItemsinList(S_DFLst)) $"W_minFEL_EPSC_"+S_EXP=NaN,$"W_avgFEL_EPSC_"+S_EXP=NaN,$"W_minFEL_IPSC_"+S_EXP=NaN,$"W_avgFEL_IPSC_"+S_EXP=NaN
		
		MAKE/O/N=(ItemsinList(S_STIMLst),ItemsinList(S_DFLst)) $"M_maxFEA_EPSC_"+S_EXP=NaN,$"M_maxcEA_EPSC_"+S_EXP=NaN,$"M_avgFEA_EPSC_"+S_EXP=NaN,$"M_avgcEA_EPSC_"+S_EXP=NaN,$"M_avgFEQ_EPSC_"+S_EXP=NaN,$"M_avgcEQ_EPSC_"+S_EXP=NaN
		MAKE/O/N=(ItemsinList(S_STIMLst),ItemsinList(S_DFLst)) $"M_maxFEA_IPSC_"+S_EXP=NaN,$"M_maxcEA_IPSC_"+S_EXP=NaN,$"M_avgFEA_IPSC_"+S_EXP=NaN,$"M_avgcEA_IPSC_"+S_EXP=NaN,$"M_avgFEQ_IPSC_"+S_EXP=NaN,$"M_avgcEQ_IPSC_"+S_EXP=NaN
		MAKE/O/N=(ItemsinList(S_STIMLst),ItemsinList(S_DFLst)) $"M_erlSTP_EPSC_"+S_EXP=NaN,$"M_latSTP_EPSC_"+S_EXP=NaN,$"M_erlSTP_IPSC_"+S_EXP=NaN,$"M_latSTP_IPSC_"+S_EXP=NaN
		MAKE/O/N=(ItemsinList(S_STIMLst),ItemsinList(S_DFLst))  $"M_EVTnum_EPSC_"+S_EXP=NaN,$"M_EVTnum_IPSC_"+S_EXP=NaN
		
		// ... monitoring
		MAKE/O/N=(ItemsinList(S_DFLst)) $"W_STIMamp_"+S_EXP=NaN; WAVE W_STIMamp=$"W_STIMamp_"+S_EXP
	SetDataFolder CDF
	
	For(i=0;i<ItemsInList(S_DFLst);i+=1)	// ... each iteration corresponds to one series
		SetDataFolder $StringfromList(i,S_DFLst)
		DFREF sDF=GetDataFolderDFR( )
		
		NVAR V_HOLDmode,V_STIMamp,V_seg_dp
		
		If(DataFolderExists(":unsegmented_traces"))
			SetDataFolder :unsegmented_traces
		Endif	
			WAVE w=FMI_matchStrToWaveRef("*_tr*",0)
			FMI_STIMinfo(w)
			NVAR V_STIMamp;Variable V_STIMamp_update=V_STIMamp
		SetDataFolder sDF
		
		NVAR V_STIMamp;V_STIMamp=V_STIMamp_update
			W_STIMamp[i]=V_STIMamp
		
		Switch(V_HOLDmode)
			case 1:	// EPSC
				WAVE/SDFR=eDF W_minFEL=$"W_minFEL_EPSC_"+S_EXP
				WAVE/SDFR=eDF W_avgFEL=$"W_avgFEL_EPSC_"+S_EXP
				
				WAVE/SDFR=eDF M_maxFEA=$"M_maxFEA_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_maxcEA=$"M_maxcEA_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgFEA=$"M_avgFEA_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgcEA=$"M_avgcEA_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgFEQ=$"M_avgFEQ_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgcEQ=$"M_avgcEQ_EPSC_"+S_EXP
				
				WAVE/SDFR=eDF M_erlSTP=$"M_erlSTP_EPSC_"+S_EXP
				WAVE/SDFR=eDF M_latSTP=$"M_latSTP_EPSC_"+S_EXP
				
				WAVE/SDFR=eDF M_EVTnum=$"M_EVTnum_EPSC_"+S_EXP
				break
			
			case 2:	// IPSC
				WAVE/SDFR=eDF W_minFEL=$"W_minFEL_IPSC_"+S_EXP
				WAVE/SDFR=eDF W_avgFEL=$"W_avgFEL_IPSC_"+S_EXP
				
				WAVE/SDFR=eDF M_maxFEA=$"M_maxFEA_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_maxcEA=$"M_maxcEA_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgFEA=$"M_avgFEA_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgcEA=$"M_avgcEA_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgFEQ=$"M_avgFEQ_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_avgcEQ=$"M_avgcEQ_IPSC_"+S_EXP
				
				WAVE/SDFR=eDF M_erlSTP=$"M_erlSTP_IPSC_"+S_EXP
				WAVE/SDFR=eDF M_latSTP=$"M_latSTP_IPSC_"+S_EXP

				WAVE/SDFR=eDF M_EVTnum=$"M_EVTnum_IPSC_"+S_EXP
				break
		Endswitch
		
		If(DataFolderExists(":TRC_analysis_EVT"))
			SetDataFolder :TRC_analysis_EVT
			DFREF aDF=GetDataFolderDFR( )
			
			FMI_STIM_EventDTCT_AMPupdate()
			FMI_STIM_EventAVG_update()
			
			// .............................................................................................
			NVAR V_STIMamp=::V_STIMamp
			Variable V_row=WhichListItem(num2str(V_STIMamp),S_STIMLst)
			// .............................................................................................
			
			
			WAVE W_FEL=FMI_matchStrToWaveRef("W_FEL_*",0)	
			If(waveexists(W_FEL))
				Wavestats/Q W_FEL
				W_minFEL[i]=V_min	// one wave per cell: EACH ENTRY = 1 series 
				W_avgFEL[i]=V_avg	// one wave per cell: EACH ENTRY = 1 series 
			Else
				W_minFEL[i]=NaN
				W_avgFEL[i]=NaN
			Endif
			
			WAVE W_FEA=FMI_matchStrToWaveRef("W_FEA_*",0)	
			If(waveexists(W_FEA))
				Wavestats/Q W_FEA
				Switch(V_HOLDmode)
					case 1:	// EPSC
						M_maxFEA[V_row][i]=V_min		// one wave per cell: EACH ENTRY = 1 series 
						break
					case 2:	// IPSC
						M_maxFEA[V_row][i]=V_max		// one wave per cell: EACH ENTRY = 1 series 
						break
				Endswitch			 
				M_avgFEA[V_row][i]=V_avg		// one wave per cell: EACH ENTRY = 1 series
			Endif
			
			
			WAVE W_cEA=FMI_matchStrToWaveRef("W_cEA_*",0)	
			If(waveexists(W_cEA))
				Wavestats/Q W_cEA
				Switch(V_HOLDmode)
					case 1:	// EPSC
						M_maxcEA[V_row][i]=V_min		// one wave per cell: EACH ENTRY = 1 series 
						break
					case 2:	// IPSC
						M_maxcEA[V_row][i]=V_max		// one wave per cell: EACH ENTRY = 1 series 
						break
				Endswitch
				M_avgcEA[V_row][i]=V_avg				// one wave per cell: EACH ENTRY = 1 series 
				
				If(numpnts(W_cEA)==V_seg_dp)
					M_erlSTP[V_row][i]=W_cEA[1]/W_cEA[0]					// one wave per cell: EACH ENTRY = 1 series 
					M_latSTP[V_row][i]=W_cEA[numpnts(W_cEA)-1]/W_cEA[1]	// one wave per cell: EACH ENTRY = 1 series 
				Endif
			Endif
			
			WAVE W_FEQ=FMI_matchStrToWaveRef("W_FEQ_*",0)	
			If(waveexists(W_FEQ))
				Wavestats/Q W_FEQ
				M_avgFEQ[V_row][i]=V_avg		// one wave per cell: EACH ENTRY = 1 series 
			Endif
			
			WAVE W_cEQ=FMI_matchStrToWaveRef("W_cEQ_*",0)	
			If(waveexists(W_cEQ))
				Wavestats/Q W_cEQ
				M_avgcEQ[V_row][i]=V_avg		// one wave per cell: EACH ENTRY = 1 series 
			Endif
			
			WAVE W_XPSCnum=FMI_matchStrToWaveRef("W_EVTnum_*",0)
			If(waveexists(W_XPSCnum)&&numpnts(W_XPSCnum)>1)
				Wavestats/Q W_XPSCnum
				M_EVTnum[V_row][i]=V_avg		// one wave per cell: EACH ENTRY = 1 series 
			Endif
			
			SetScale d,0,0,"s",W_minFEL,W_avgFEL
			SetScale d,0,0,"A",M_maxFEA,M_avgFEA,M_maxcEA,M_avgcEA
			SetScale d,0,0,"STP index",M_erlSTP,M_latSTP
			SetScale d,0,0,"C",M_avgFEQ,M_avgcEQ
			SetScale d,0,0,"events",M_EVTnum
			
							
			// =================================== STIMamp-DISTINCTIVE ANALYSIS ===================================== 
			Variable V_SRScnt
			String S_note
			
			WAVE W_srsavgEVT=FMI_matchStrToWaveRef("W_avgEVT_*",0)
			
			WAVE W_srsNFEA=FMI_matchStrToWaveRef("W_NFEA_*",0)
			WAVE W_srsNcEA=FMI_matchStrToWaveRef("W_NcEA_*",0)
			
			WAVE W_srsPTH=FMI_matchStrToWaveRef("W_PTH_*",0)
			WAVE W_srsPTHs=FMI_matchStrToWaveRef("W_PTHs_*",0)
			
			SetDataFolder aDF
			
			String S_WvLst_Xtms=WaveList("*_Xtms",";","")
			
			SetDataFolder eDF
			
			// ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ AVERAGE EVENT TIME COURSE ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
			If(waveexists(W_srsavgEVT) && ItemsInList(S_WvLst_Xtms)>0)
				
				String S_WVnm_avgEVT
				 	
				Switch(V_HOLDmode)
				case 1:	// EPSC
					S_WVnm_avgEVT="M_avgEPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
					break
				
				case 2:	// IPSC
					S_WVnm_avgEVT="M_avgIPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
					break
				Endswitch
			
				WAVE M_avgEVT=$S_WVnm_avgEVT
			
				If(waveexists(M_avgEVT)==0)
					MAKE/O/N=(numpnts(W_srsavgEVT),1) $S_WVnm_avgEVT;WAVE M_avgEVT=$S_WVnm_avgEVT
						CopyScales/P W_srsavgEVT,M_avgEVT
				Else
					InsertPoints/M=1 inf,1,M_avgEVT
				Endif
				
				M_avgEVT[][inf]=W_srsavgEVT[p]
			Endif
			
			
			// ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ AVERAGE TRAIN TIME COURSE ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
			If(V_seg_dp>1 && ItemsInList(S_WvLst_Xtms)>0)
				SetDataFolder sDF 
				
				String S_Lst_seg=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")							// ALL TRACES (segments)
				String S_Lst_trc=RemoveFromList(GrepList(WaveList("*_tr*",";",""),"(_s0_)"),S_Lst_seg)	// RELEVANT TRACES (segments) 
				
				SetDataFolder eDF

				Variable k
				If(ItemsinList(S_Lst_trc)>1)
					
					String S_WVnm_avgTRN
					
					For(k=1;k<=ItemsinList(S_Lst_trc);k+=1)
						WAVE/SDFR=sDF w=$StringFromList(k-1,S_Lst_trc)
						WAVE/SDFR=aDF W_Xtms_tmp=$NameOfWave(w)+"_Xtms"
						
						// ... only traces, in which >=1 event has been detected should be considered for the respective average event...
						If(waveexists(W_Xtms_tmp)==0)
							continue
						Endif
						
						Switch(V_HOLDmode)
						case 1:	// EPSC
							S_WVnm_avgTRN="M_avgEPSC"+num2str(k)+"_"+num2str(V_STIMamp)+"V_"+S_EXP
							break
						
						case 2:	// IPSC
							S_WVnm_avgTRN="M_avgIPSC"+num2str(k)+"_"+num2str(V_STIMamp)+"V_"+S_EXP
							break
						Endswitch
					
						WAVE M_avgTRN=$S_WVnm_avgTRN
						
						If(waveexists(M_avgTRN)==0)
							MAKE/O/N=(numpnts(w),1) $S_WVnm_avgTRN;WAVE M_avgTRN=$S_WVnm_avgTRN
								CopyScales/P w,M_avgTRN
						Else
							InsertPoints/M=1 inf,1,M_avgTRN
						Endif
						
						M_avgTRN[][inf]=w[p]
					Endfor
				Endif
			Endif
			
			SetDataFolder eDF
			
			// ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ STP (normalized response amplitude) ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
			If(waveexists(W_srsNFEA)&&waveexists(W_srsNcEA))
				
				String S_WVnm_NFEA,S_WVnm_NcEA
				
				Switch(V_HOLDmode)
					case 1:	// EPSC
						S_WVnm_NFEA="M_NFEA_EPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						S_WVnm_NcEA="M_NcEA_EPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						break
					
					case 2:	// IPSC
						S_WVnm_NFEA="M_NFEA_IPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						S_WVnm_NcEA="M_NcEA_IPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						break
					Endswitch
				
				WAVE M_NFEA=$S_WVnm_NFEA
				WAVE M_NcEA=$S_WVnm_NcEA
				
				If(waveexists(M_NFEA)==0)
					MAKE/O/N=(numpnts(W_srsNFEA),1) $S_WVnm_NFEA;WAVE M_NFEA=$S_WVnm_NFEA
						CopyScales/P W_srsNFEA,M_NFEA
				Else
					InsertPoints/M=1 inf,1,M_NFEA
				Endif
				If(waveexists(M_NcEA)==0)
					MAKE/O/N=(numpnts(W_srsNcEA),1) $S_WVnm_NcEA;WAVE M_NcEA=$S_WVnm_NcEA
						CopyScales/P W_srsNcEA,M_NcEA
				Else
					InsertPoints/M=1 inf,1,M_NcEA
				Endif
				
				M_NFEA[][inf]=W_srsNFEA[p]
				M_NcEA[][inf]=W_srsNcEA[p]
			Endif
			
			// ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨ PSTH ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
			If(waveexists(W_srsPTH)&&waveexists(W_srsPTHs))
				
				String S_WVnm_PTH,S_WVnm_PTHs
				
				Switch(V_HOLDmode)
					case 1:	// EPSC
						S_WVnm_PTH="M_PTH_EPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						S_WVnm_PTHs="M_PTHs_EPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						break
					
					case 2:	// IPSC
						S_WVnm_PTH="M_PTH_IPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						S_WVnm_PTHs="M_PTHs_IPSC_"+num2str(V_STIMamp)+"V_"+S_EXP
						break
					Endswitch
				
				WAVE W_PTH=$S_WVnm_PTH
				WAVE W_PTHs=$S_WVnm_PTHs
				
				If(waveexists(M_PTH)==0)
					MAKE/O/N=(numpnts(W_srsPTH),1) $S_WVnm_PTH;WAVE M_PTH=$S_WVnm_PTH
						CopyScales/P W_srsPTH,M_PTH
				Else
					InsertPoints/M=1 inf,1,M_PTH
				Endif
				If(waveexists(M_PTHs)==0)
					MAKE/O/N=(numpnts(W_srsPTHs),1) $S_WVnm_PTHs;WAVE M_PTHs=$S_WVnm_PTHs
						CopyScales/P W_srsPTHs,M_PTHs
				Else
					InsertPoints/M=1 inf,1,M_PTHs
				Endif
				
				M_PTH[][inf]=W_srsPTH[p]
				M_PTHs[][inf]=W_srsPTHs[p]==0 ? NaN : W_srsPTHs[p]
			Endif
		Endif
		
		SetDataFolder CDF
	Endfor	// ... each iteration corresponds to one series
	
	SetDataFolder eDF
		String S_WvLst_M=WaveList("M*",";","")
		
		For(i=0;i<ItemsInList(S_WvLst_M);i+=1)
			WAVE M_tmp=$StringFromList(i,S_WvLst_M)
			
			If(DimSize(M_tmp,1)>1)
				WAVE W_AVG=MatrixStats(M_tmp);WAVE W_SD=$ReplaceString("_AVG",nameofwave(W_AVG),"_SD",1);WAVE W_SEM=$ReplaceString("_AVG",nameofwave(W_AVG),"_SEM",1)
					Duplicate/O W_AVG,$ReplaceString("_AVG",nameofwave(W_AVG),"",1)
					Killwaves/Z W_AVG,W_SD,W_SEM
			Else
				MAKE/O/N=(DimSize(M_tmp,0)) $ReplaceString("M",nameofwave(M_tmp),"W")
					WAVE W_tmp=$ReplaceString("M",nameofwave(M_tmp),"W")
					W_tmp[]=M_tmp[p][0]
					CopyScales/P M_tmp,W_tmp
					Killwaves/Z M_tmp
			Endif
		Endfor

		WaveStats_to_Note_all(V_add=1)
		CleanUp_Waves_empty()
	SetDataFolder CDF
	
	
	
	// ==================================================================================================================
	// ============================================== GRAND AVERAGE =====================================================
	SetDataFolder root:
	DFREF rtDF=GetDataFolderDFR( )
	
	// ... for each experiment, all average values (except latency) are itemized according to stimulation amplitude (one stimulation amplitude corresponds
	// ... to one row in the respective waves [vecors & matrices]) 
	// ... here, the one stimulation amplitude on which the calculation of the grand average is based is selected 
	Variable V_STIMampSEL=30
		V_row=WhichListItem(num2str(V_STIMampSEL),S_STIMLst)
	String S_noteGA=""
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// ... LATENCY	- 	one wave; EACH ENTRY = 1 cell
	// ... EXPERIMENT WAVES 
	WAVE/SDFR=eDF W_minFEL_EPSC=$"W_minFEL_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgFEL_EPSC=$"W_avgFEL_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_minFEL_IPSC=$"W_minFEL_IPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgFEL_IPSC=$"W_avgFEL_IPSC_"+S_EXP
	
	// ... GRAND AVERAGE WAVES
	WAVE W_MinMinFEL_EPSC_GA=$"W_MinMinFEL_EPSC_GA"+S_ID
	WAVE W_AvgMinFEL_EPSC_GA=$"W_AvgMinFEL_EPSC_GA"+S_ID
	WAVE W_MinMinFEL_IPSC_GA=$"W_MinMinFEL_IPSC_GA"+S_ID
	WAVE W_AvgMinFEL_IPSC_GA=$"W_AvgMinFEL_IPSC_GA"+S_ID
	WAVE W_IPSC_dt_GA=$"W_IPSC_dt_GA"+S_ID
	
	// ... min-min latency (EPSC)
	If(waveexists(W_MinMinFEL_EPSC_GA)==0)
		MAKE/O/N=1 $"W_MinMinFEL_EPSC_GA"+S_ID;WAVE W_MinMinFEL_EPSC_GA=$"W_MinMinFEL_EPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_MinMinFEL_EPSC_GA
	Endif
		If(waveexists(W_minFEL_EPSC))
			WaveStats/Q W_minFEL_EPSC
			W_MinMinFEL_EPSC_GA[inf]=V_min
			CopyScales/P W_minFEL_EPSC,W_MinMinFEL_EPSC_GA
		Else
			W_MinMinFEL_EPSC_GA[inf]=NaN
		Endif
	
	// ... avg-min latency (EPSC)
	If(waveexists(W_AvgMinFEL_EPSC_GA)==0)
		MAKE/O/N=1 $"W_AvgMinFEL_EPSC_GA"+S_ID;WAVE W_AvgMinFEL_EPSC_GA=$"W_AvgMinFEL_EPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_AvgMinFEL_EPSC_GA
	Endif
		If(waveexists(W_avgFEL_EPSC))
			WaveStats/Q W_avgFEL_EPSC
			W_AvgMinFEL_EPSC_GA[inf]=V_min
			CopyScales/P W_avgFEL_EPSC,W_AvgMinFEL_EPSC_GA
		Else
			W_AvgMinFEL_EPSC_GA[inf]=NaN
		Endif
	
	// ... min-min latency (IPSC)
	If(waveexists(W_MinMinFEL_IPSC_GA)==0)
		MAKE/O/N=1 $"W_MinMinFEL_IPSC_GA"+S_ID;WAVE W_MinMinFEL_IPSC_GA=$"W_MinMinFEL_IPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_MinMinFEL_IPSC_GA
	Endif
		If(waveexists(W_minFEL_IPSC))
			WaveStats/Q W_minFEL_IPSC
			W_MinMinFEL_IPSC_GA[inf]=V_min
			CopyScales/P W_minFEL_IPSC,W_MinMinFEL_IPSC_GA
		Else
			W_MinMinFEL_IPSC_GA[inf]=NaN
		Endif
	
	// ... avg-min latency (IPSC)
	If(waveexists(W_AvgMinFEL_IPSC_GA)==0)
		MAKE/O/N=1 $"W_AvgMinFEL_IPSC_GA"+S_ID;WAVE W_AvgMinFEL_IPSC_GA=$"W_AvgMinFEL_IPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_AvgMinFEL_IPSC_GA
	Endif
		If(waveexists(W_avgFEL_IPSC))
			WaveStats/Q W_avgFEL_IPSC
			W_AvgMinFEL_IPSC_GA[inf]=V_min
			CopyScales/P W_avgFEL_IPSC,W_AvgMinFEL_IPSC_GA
		Else
			W_AvgMinFEL_IPSC_GA[inf]=NaN
		Endif
	
	// ... [avg-min (IPSC)] - [avg-min (EPSC)] latency
	If(waveexists(W_IPSC_dt_GA)==0)
		MAKE/O/N=1 $"W_IPSC_dt_GA"+S_ID;WAVE W_IPSC_dt_GA=$"W_IPSC_dt_GA"+S_ID
	Else
		InsertPoints inf,1,W_IPSC_dt_GA
	Endif
		If(waveexists(W_avgFEL_EPSC) && waveexists(W_avgFEL_IPSC))
			W_IPSC_dt_GA[inf]=W_AvgMinFEL_IPSC_GA[inf]-W_AvgMinFEL_EPSC_GA[inf]
			CopyScales/P W_avgFEL_EPSC,W_IPSC_dt_GA
		Else
			W_IPSC_dt_GA[inf]=NaN
		Endif
	
	WaveStats_to_Note(W_MinMinFEL_EPSC_GA)
	WaveStats_to_Note(W_AvgMinFEL_EPSC_GA)
	WaveStats_to_Note(W_MinMinFEL_IPSC_GA)
	WaveStats_to_Note(W_AvgMinFEL_IPSC_GA)
	WaveStats_to_Note(W_IPSC_dt_GA)
	
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// ... AMPLITUDE & INTEGRAL	- 	one wave; EACH ENTRY = 1 cell
	// ... EXPERIMENT WAVES 
	WAVE/SDFR=eDF W_maxcEA_EPSC=$"W_maxcEA_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgcEA_EPSC=$"W_avgcEA_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgcEQ_EPSC=$"W_avgcEQ_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_maxcEA_IPSC=$"W_maxcEA_IPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgcEA_IPSC=$"W_avgcEA_IPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgcEQ_IPSC=$"W_avgcEQ_IPSC_"+S_EXP
	
	// ... GRAND AVERAGE WAVES
	WAVE W_maxcEA_EPSC_GA=$"W_maxcEA_EPSC_GA"+S_ID
	WAVE W_avgcEA_EPSC_GA=$"W_avgcEA_EPSC_GA"+S_ID
	WAVE W_avgcEQ_EPSC_GA=$"W_avgcEQ_EPSC_GA"+S_ID
	WAVE W_maxcEA_IPSC_GA=$"W_maxcEA_IPSC_GA"+S_ID
	WAVE W_avgcEA_IPSC_GA=$"W_avgcEA_IPSC_GA"+S_ID
	WAVE W_avgcEQ_IPSC_GA=$"W_avgcEQ_IPSC_GA"+S_ID
	
	// ... maximum cumulative event amplitude (EPSC) 
	If(waveexists(W_maxcEA_EPSC_GA)==0)
		MAKE/O/N=1 $"W_maxcEA_EPSC_GA"+S_ID;WAVE W_maxcEA_EPSC_GA=$"W_maxcEA_EPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_maxcEA_EPSC_GA
	Endif
		If(waveexists(W_maxcEA_EPSC))
			W_maxcEA_EPSC_GA[inf]=W_maxcEA_EPSC[V_row]
			CopyScales/P W_maxcEA_EPSC,W_maxcEA_EPSC_GA
		Else
			W_maxcEA_EPSC_GA[inf]=NaN
		Endif
		
	// ... average cumulative event amplitude (EPSC) 
	If(waveexists(W_avgcEA_EPSC_GA)==0)
		MAKE/O/N=1 $"W_avgcEA_EPSC_GA"+S_ID;WAVE W_avgcEA_EPSC_GA=$"W_avgcEA_EPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_avgcEA_EPSC_GA
	Endif
		If(waveexists(W_avgcEA_EPSC))
			W_avgcEA_EPSC_GA[inf]=W_avgcEA_EPSC[V_row]
			CopyScales/P W_avgcEA_EPSC,W_avgcEA_EPSC_GA
		Else
			W_avgcEA_EPSC_GA[inf]=NaN
		Endif
	
	// ... average cumulative event charge transfer (EPSC) 
	If(waveexists(W_avgcEQ_EPSC_GA)==0)
		MAKE/O/N=1 $"W_avgcEQ_EPSC_GA"+S_ID;WAVE W_avgcEQ_EPSC_GA=$"W_avgcEQ_EPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_avgcEQ_EPSC_GA
	Endif
		If(waveexists(W_avgcEQ_EPSC))
			W_avgcEQ_EPSC_GA[inf]=W_avgcEQ_EPSC[V_row]
			CopyScales/P W_avgcEQ_EPSC,W_avgcEQ_EPSC_GA
		Else
			W_avgcEQ_EPSC_GA[inf]=NaN
		Endif
	
	// ... maximum cumulative event amplitude (IPSC) 
	If(waveexists(W_maxcEA_IPSC_GA)==0)
		MAKE/O/N=1 $"W_maxcEA_IPSC_GA"+S_ID;WAVE W_maxcEA_IPSC_GA=$"W_maxcEA_IPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_maxcEA_IPSC_GA
	Endif
		If(waveexists(W_maxcEA_IPSC))
			W_maxcEA_IPSC_GA[inf]=W_maxcEA_IPSC[V_row]
			CopyScales/P W_maxcEA_IPSC,W_maxcEA_IPSC_GA
		Else
			W_maxcEA_IPSC_GA[inf]=NaN
		Endif
	
	// ... average cumulative event amplitude (IPSC) 
	If(waveexists(W_avgcEA_IPSC_GA)==0)
		MAKE/O/N=1 $"W_avgcEA_IPSC_GA"+S_ID;WAVE W_avgcEA_IPSC_GA=$"W_avgcEA_IPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_avgcEA_IPSC_GA
	Endif
		If(waveexists(W_avgcEA_IPSC))
			W_avgcEA_IPSC_GA[inf]=W_avgcEA_IPSC[V_row]
			CopyScales/P W_avgcEA_IPSC,W_avgcEA_IPSC_GA
		Else
			W_avgcEA_IPSC_GA[inf]=NaN
		Endif
	
	// ... average cumulative event charge transfer (EPSC) 
	If(waveexists(W_avgcEQ_IPSC_GA)==0)
		MAKE/O/N=1 $"W_avgcEQ_IPSC_GA"+S_ID;WAVE W_avgcEQ_IPSC_GA=$"W_avgcEQ_IPSC_GA"+S_ID
	Else
		InsertPoints inf,1,W_avgcEQ_IPSC_GA
	Endif
		If(waveexists(W_avgcEQ_IPSC))
			W_avgcEQ_IPSC_GA[inf]=W_avgcEQ_IPSC[V_row]
			CopyScales/P W_avgcEQ_IPSC,W_avgcEQ_IPSC_GA
		Else
			W_avgcEQ_IPSC_GA[inf]=NaN
		Endif
	
	WaveStats_to_Note(W_maxcEA_EPSC_GA)
	WaveStats_to_Note(W_avgcEA_EPSC_GA)
	WaveStats_to_Note(W_avgcEQ_EPSC_GA)
	WaveStats_to_Note(W_maxcEA_IPSC_GA)
	WaveStats_to_Note(W_avgcEA_IPSC_GA)
	WaveStats_to_Note(W_avgcEQ_IPSC_GA)
	
	// ... RESPONSE amplitude VS STIMULATION amplitude
	// ... EXPERIMENT WAVES 
	WAVE/SDFR=eDF W_avgcEA_EPSC=$"W_avgcEA_EPSC_"+S_EXP
	WAVE/SDFR=eDF W_avgcEA_IPSC=$"W_avgcEA_IPSC_"+S_EXP
	
	// ... GRAND AVERAGE WAVES
	WAVE M_avgcEA_EPSC_GA=$"M_avgcEA_EPSC_GA"+S_ID
	WAVE M_avgcEA_IPSC_GA=$"M_avgcEA_IPSC_GA"+S_ID
	
	WAVE W_STIMLst=$"W_STIMLst_GA"+S_ID
	If(waveexists(W_STIMLst)==0)
		MAKE/O/N=(ItemsinList(S_STIMLst)) $"W_STIMLst_GA"+S_ID;WAVE W_STIMLst=$"W_STIMLst_GA"+S_ID 
		For(i=0;i<ItemsInList(S_STIMLst);i+=1)
			W_STIMLst[i]=Str2Num(StringFromList(i,S_STIMLst))
		Endfor
	Endif
	
	// ... EPSC amplitude
	If(waveexists(W_avgcEA_EPSC))
		If(waveexists(M_avgcEA_EPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgcEA_EPSC,0),1) $"M_avgcEA_EPSC_GA"+S_ID;WAVE M_avgcEA_EPSC_GA=$"M_avgcEA_EPSC_GA"+S_ID
			CopyScales/P W_avgcEA_EPSC,M_avgcEA_EPSC_GA
			Note M_avgcEA_EPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgcEA_EPSC_GA
		Endif
		M_avgcEA_EPSC_GA[][inf]=W_avgcEA_EPSC[p]
		
		Note/NOCR M_avgcEA_EPSC_GA,"\r\t "+S_EXP
	Endif
	
	// ... IPSC amplitude
	If(waveexists(W_avgcEA_IPSC))
		If(waveexists(M_avgcEA_IPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgcEA_IPSC,0),1) $"M_avgcEA_IPSC_GA"+S_ID;WAVE M_avgcEA_IPSC_GA=$"M_avgcEA_IPSC_GA"+S_ID
			CopyScales/P W_avgcEA_IPSC,M_avgcEA_IPSC_GA
			Note M_avgcEA_IPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgcEA_IPSC_GA
		Endif
		M_avgcEA_IPSC_GA[][inf]=W_avgcEA_IPSC[p]
		
		Note/NOCR M_avgcEA_IPSC_GA,"\r\t "+S_EXP
	Endif
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// ... TIME COURSE (lumped event)
	// ... EXPERIMENT WAVES 
	WAVE/SDFR=eDF W_avgEPSC=$"W_avgEPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_avgIPSC=$"W_avgIPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	
	// ... GRAND AVERAGE WAVES
	WAVE M_avgEPSC_GA=$"M_avgEPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_avgIPSC_GA=$"M_avgIPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	
	// ... lumped event (EPSC) @30V
	If(waveexists(W_avgEPSC))
		If(waveexists(M_avgEPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgEPSC,0),1) $"M_avgEPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_avgEPSC_GA=$"M_avgEPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_avgEPSC,M_avgEPSC_GA
			Note M_avgEPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgEPSC_GA
		Endif
		M_avgEPSC_GA[][inf]=W_avgEPSC[p]
		
		Note/NOCR M_avgEPSC_GA,"\r\t "+S_EXP
	Endif
	
	// ... lumped event (IPSC) @30V
	If(waveexists(W_avgIPSC))
		If(waveexists(M_avgIPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgIPSC,0),1)$"M_avgIPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_avgIPSC_GA=$"M_avgIPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_avgIPSC,M_avgIPSC_GA
			Note M_avgIPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgIPSC_GA
		Endif
		M_avgIPSC_GA[][inf]=W_avgIPSC[p]
		
		Note/NOCR M_avgIPSC_GA,"\r\t "+S_EXP
	Endif
	
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// ... TIME COURSE (trains)
	SetDataFolder eDF
		String S_WvLst_avgEPSC_seg=WaveList("W_avgEPSC*_"+num2str(V_STIMampSEL)+"V_*",";","")
			S_WvLst_avgEPSC_seg=RemoveFromList(nameofwave(W_avgEPSC),S_WvLst_avgEPSC_seg)
		String S_WvLst_avgIPSC_seg=WaveList("W_avgIPSC*_"+num2str(V_STIMampSEL)+"V_*",";","")
			S_WvLst_avgIPSC_seg=RemoveFromList(nameofwave(W_avgIPSC),S_WvLst_avgIPSC_seg)
	SetDataFolder rtDF
	
	Variable j,V_segID
	
	// ... 10x train (EPSC) @30V
	For(j=0;j<ItemsinList(S_WvLst_avgEPSC_seg);j+=1)
		// ... EXPERIMENT WAVES 
		WAVE/SDFR=eDF W_avgTRN_EPSC=$StringFromList(j,S_WvLst_avgEPSC_seg)
			sscanf NameofWave(W_avgTRN_EPSC),"%*[W_avgEPSC]%d",V_segID 
		
		// ... GRAND AVERAGE WAVES
		WAVE M_avgTRN_EPSC_GA=$"M_avgEPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
		
		If(waveexists(M_avgTRN_EPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgTRN_EPSC,0),1)$"M_avgEPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_avgTRN_EPSC_GA=$"M_avgEPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_avgTRN_EPSC,M_avgTRN_EPSC_GA
			Note M_avgTRN_EPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgTRN_EPSC_GA
		Endif
		M_avgTRN_EPSC_GA[][inf]=W_avgTRN_EPSC[p]
		
		Note/NOCR M_avgTRN_EPSC_GA,"\r\t "+S_EXP
	Endfor

	// ... 10x train (IPSC) @30V
	For(j=0;j<ItemsinList(S_WvLst_avgIPSC_seg);j+=1)
		// ... EXPERIMENT WAVES 
		WAVE/SDFR=eDF W_avgTRN_IPSC=$StringFromList(j,S_WvLst_avgIPSC_seg)
			sscanf NameofWave(W_avgTRN_IPSC),"%*[W_avgIPSC]%d",V_segID 
		
		// ... GRAND AVERAGE WAVES
		WAVE M_avgTRN_IPSC_GA=$"M_avgIPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
		
		If(waveexists(M_avgTRN_IPSC_GA)==0)
			MAKE/O/N=(DimSize(W_avgTRN_IPSC,0),1)$"M_avgIPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_avgTRN_IPSC_GA=$"M_avgIPSC"+num2str(V_segID)+"_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_avgTRN_IPSC,M_avgTRN_IPSC_GA
			Note M_avgTRN_IPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_avgTRN_IPSC_GA
		Endif
		M_avgTRN_IPSC_GA[][inf]=W_avgTRN_IPSC[p]
		
		Note/NOCR M_avgTRN_IPSC_GA,"\r\t "+S_EXP
	Endfor
	
	
	// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// ... SHORT-TERM PLASTICITY
	// ... EXPERIMENT WAVES  
	WAVE/SDFR=eDF W_NcEA_EPSC=$"W_NcEA_EPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_PTH_EPSC=$"W_PTH_EPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_PTHs_EPSC=$"W_PTHs_EPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_NcEA_IPSC=$"W_NcEA_IPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_PTH_IPSC=$"W_PTH_IPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	WAVE/SDFR=eDF W_PTHs_IPSC=$"W_PTHs_IPSC_"+num2str(V_STIMampSEL)+"V_"+S_EXP
	
	// ... GRAND AVERAGE WAVES
	WAVE M_NcEA_EPSC_GA=$"M_NcEA_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_PTH_EPSC_GA=$"M_PTH_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_PTHs_EPSC_GA=$"M_PTHs_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_NcEA_IPSC_GA=$"M_NcEA_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_PTH_IPSC_GA=$"M_PTH_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	WAVE M_PTHs_IPSC_GA=$"M_PTHs_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
	
	// normalized cumulative event amplitude (EPSC) @30V [10x train]
	If(waveexists(W_NcEA_EPSC))
		If(waveexists(M_NcEA_EPSC_GA)==0)
			MAKE/O/N=(DimSize(W_NcEA_EPSC,0),1) $"M_NcEA_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_NcEA_EPSC_GA=$"M_NcEA_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_NcEA_EPSC,M_NcEA_EPSC_GA
			Note M_NcEA_EPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_NcEA_EPSC_GA
		Endif
		M_NcEA_EPSC_GA[][inf]=W_NcEA_EPSC[p]
		
		Note/NOCR M_NcEA_EPSC_GA,"\r\t "+S_EXP
	Endif
	
	// PSTH (EPSC) @30V
	If(waveexists(W_PTH_EPSC))
		If(waveexists(M_PTH_EPSC_GA)==0)
			MAKE/O/N=(DimSize(W_PTH_EPSC,0),1) $"M_PTH_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_PTH_EPSC_GA=$"M_PTH_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_PTH_EPSC,M_PTH_EPSC_GA
			Note M_PTH_EPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_PTH_EPSC_GA
		Endif
		M_PTH_EPSC_GA[][inf]=W_PTH_EPSC[p]
		
		Note/NOCR M_PTH_EPSC_GA,"\r\t "+S_EXP
	Endif
	
	// PSTH scaling (EPSC) @30V
	If(waveexists(W_PTHs_EPSC))
		If(waveexists(M_PTHs_EPSC_GA)==0)
			MAKE/O/N=(DimSize(W_PTHs_EPSC,0),1) $"M_PTHs_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_PTHs_EPSC_GA=$"M_PTHs_EPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_PTHs_EPSC,M_PTHs_EPSC_GA
			Note M_PTHs_EPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_PTHs_EPSC_GA
		Endif
		M_PTHs_EPSC_GA[][inf]=W_PTHs_EPSC[p]
		
		Note/NOCR M_PTHs_EPSC_GA,"\r\t "+S_EXP
	Endif
	
	
	// normalized cumulative event amplitude (IPSC) @30V [10x train]
	If(waveexists(W_NcEA_IPSC))
		If(waveexists(M_NcEA_IPSC_GA)==0)
			MAKE/O/N=(DimSize(W_NcEA_IPSC,0),1) $"M_NcEA_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_NcEA_IPSC_GA=$"M_NcEA_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_NcEA_IPSC,M_NcEA_IPSC_GA
			Note M_NcEA_IPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_NcEA_IPSC_GA
		Endif
		M_NcEA_IPSC_GA[][inf]=W_NcEA_IPSC[p]
		
		Note/NOCR M_NcEA_IPSC_GA,"\r\t "+S_EXP
	Endif
	
	// PSTH (IPSC) @30V
	If(waveexists(W_PTH_IPSC))
		If(waveexists(M_PTH_IPSC_GA)==0)
			MAKE/O/N=(DimSize(W_PTH_IPSC,0),1) $"M_PTH_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_PTH_IPSC_GA=$"M_PTH_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_PTH_IPSC,M_PTH_IPSC_GA
			Note M_PTH_IPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_PTH_IPSC_GA
		Endif
		M_PTH_IPSC_GA[][inf]=W_PTH_IPSC[p]
		
		Note/NOCR M_PTH_IPSC_GA,"\r\t "+S_EXP
	Endif
	
	// PSTH scaling (IPSC) @30V
	If(waveexists(W_PTHs_IPSC))
		If(waveexists(M_PTHs_IPSC_GA)==0)
			MAKE/O/N=(DimSize(W_PTHs_IPSC,0),1) $"M_PTHs_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID;WAVE M_PTHs_IPSC_GA=$"M_PTHs_IPSC_"+num2str(V_STIMampSEL)+"V_GA"+S_ID
			CopyScales/P W_PTHs_IPSC,M_PTHs_IPSC_GA
			Note M_PTHs_IPSC_GA,"\rList of included experiments: "
		Else
			InsertPoints/M=1 inf,1,M_PTHs_IPSC_GA
		Endif
		M_PTHs_IPSC_GA[][inf]=W_PTHs_IPSC[p]
		
		Note/NOCR M_PTHs_IPSC_GA,"\r\t "+S_EXP
	Endif
	
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_STIM_EventDTCT_SRSsmm()
	SVAR S_shID
	
	Variable i
	
	// ############################### SERIES SUMMARY ###############################		
	If(DataFolderExists(":TRC_analysis_EVT"))
		SetDataFolder :TRC_analysis_EVT
		String S_WvLst_Xtms=WaveList("*_Xtms",";","")
		
		WAVE/Z W_EVTamp=$"W_EVTamp_"+S_shID
		WAVE/Z W_EVTpkTm=$"W_EVTpkTm_"+S_shID
		WAVE/Z W_EVTonst=$"W_EVTonst_"+S_shID
		
		// ... CLEANUP of old (initial) analysis
		Killwaves/Z W_EVTpkTm,W_EVTonst
		
		// ... PREPARE new analysis 
		Make/O/N=(ItemsInList(S_WvLst_Xtms)) $"W_FEL_"+S_shID,$"W_FEA_"+S_shID
			WAVE W_FEL=$"W_FEL_"+S_shID
			WAVE W_FEA=$"W_FEA_"+S_shID
			SetScale d,0,0,"s",W_FEL
			If(waveexists(W_EVTamp))
				SetScale d,0,0,WaveUnits(W_EVTamp,-1),W_FEA
			Else
				SetScale d,0,0,"A",W_FEA
			Endif
			
		For(i=0;i<ItemsInList(S_WvLst_Xtms);i+=1)
			WAVE W_Xtms_tmp=$StringFromList(i,S_WvLst_Xtms)
						
			If(numpnts(W_Xtms_tmp)>0)
				W_FEL[i]=W_Xtms_tmp[0]-FVCV_ValuefromString(note(W_Xtms_tmp),"segment.offset: ")	// first event only...
			Else
				W_FEL[i]=NaN	// first event only...
				W_FEA[i]=NaN
			Endif 
		Endfor
		
		FMI_STIM_EventDTCT_AMPupdate()		// ... updates W_FEA
					
		WaveStats_to_Note(W_FEL);WaveStats_to_Note(W_FEA)
					
		SetDataFolder ::
	Endif
	
	return W_FEL
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_STIM_EventAVG_update()
	DFREF CDF=GetDataFolderDFR( )
	
	Variable i
	
	// ... supposed to be in :TRC_analysis_EVT
	If(cmpstr(GetDataFolder(0),"TRC_analysis_EVT")!=0) 
		return -1
	Endif
	
	SetDataFolder ::
	
	DFREF sDF=GetDataFolderDFR( )
	NVAR V_STIMnum,V_STIMamp,V_HOLDmode
	SVAR S_shID
	
	String S_Lst_seg=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")							// ALL TRACES (segments)
	String S_Lst_trc=RemoveFromList(GrepList(WaveList("*_tr*",";",""),"(_s0_)"),S_Lst_seg)	// RELEVANT TRACES (segments) 
	
	If(ItemsinList(S_Lst_trc)>0)
		SetDataFolder CDF
		
		If(ItemsinList(S_Lst_trc)>1)
			For(i=0;i<ItemsInList(S_Lst_trc);i+=1)
				WAVE/SDFR=sDF w=$StringFromList(i,S_Lst_trc)
				
				If(i==0)
					MAKE/O/N=(numpnts(w),ItemsInList(S_Lst_trc)) $"M_avgEVT_"+S_shID; 
						WAVE M_avgEVT=$"M_avgEVT_"+S_shID
						CopyScales/P w,M_avgEVT
						M_avgEVT=NaN
				Endif
				
				WAVE W_Xtms_tmp=$NameOfWave(w)+"_Xtms"
				
				If(waveexists(W_Xtms_tmp))	// ... only traces, in which >=1 event has been detected should be considered for the average event...
					M_avgEVT [][i]=w[p] 
				Endif
			Endfor
			
			WAVE W_AVG=MatrixStats(M_avgEVT)
				WAVE W_SD=$ReplaceString("_AVG", nameofwave(W_AVG),"_SD",1)
				WAVE W_SEM=$ReplaceString("_AVG", nameofwave(W_AVG),"_SEM",1)
				
			Duplicate/O W_AVG,$"W_avgEVT_"+S_shID;Killwaves/Z W_AVG,W_SD,W_SEM
		
		Else
			WAVE/SDFR=sDF w=$StringFromList(0,S_Lst_trc)
			Duplicate/O w,$"W_avgEVT_"+S_shID
		Endif
		
		Killwaves/Z M_avgEVT
	Endif
	
	SetDataFolder CDF
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_STIM_EventDTCT_AMPupdate()
	Variable V_BLperiod=1e-3
	Variable V_minEVTlngth=5e-3
	Variable V_BINsize=1e-3
	
	DFREF CDF=GetDataFolderDFR( )
	
	Variable i,j
	
	// ... supposed to be in :TRC_analysis_EVT
	If(cmpstr(GetDataFolder(0),"TRC_analysis_EVT")!=0) 
		return -1
	Endif
	
	FMI_RemoveNANsinDF()
	CleanUp_Waves_empty()
	
	NVAR V_seg_dp=::V_seg_dp
	
	String S_WvLst_Xtms=SortList(WaveList("*_Xtms",";",""),";",16)
	
	WAVE W_FEA=FMI_matchStrToWaveRef("W_FEA*",0)
	If(waveexists(W_FEA)==0)
		return -1
	Endif
	
	// ... first event charge transfer
	Duplicate/O W_FEA,$ReplaceString("FEA", NameOfWave(W_FEA),"FEQ"); W_FEA=NaN
	WAVE W_FEQ=$ReplaceString("FEA", NameOfWave(W_FEA),"FEQ"); W_FEQ=NaN
	SetScale d,0,0,"C",W_FEQ
	
	// ... 'cumulative event amplitude'
	Duplicate/O W_FEA,$ReplaceString("FEA", NameOfWave(W_FEA),"cEA")
	WAVE W_cEA=$ReplaceString("FEA", NameOfWave(W_FEA),"cEA"); W_cEA=NaN
	SetScale d,0,0,WaveUnits(W_FEA,-1),W_cEA
	
	// ... 'cumulative event charge transfer'
	Duplicate/O W_FEA,$ReplaceString("FEA", NameOfWave(W_FEA),"cEQ")
	WAVE W_cEQ=$ReplaceString("FEA", NameOfWave(W_FEA),"cEQ"); W_cEQ=NaN
	SetScale d,0,0,"C",W_cEQ
	
	// ... event number
	Duplicate/O W_FEA,$ReplaceString("FEA", NameOfWave(W_FEA),"EVTnum")
	WAVE W_EVTnum=$ReplaceString("FEA", NameOfWave(W_FEA),"EVTnum"); W_EVTnum=NaN
	SetScale d,0,0,"events",W_EVTnum
	
	WAVE W_PTH=FMI_matchStrToWaveRef("W_PTH_*",0)
	WAVE W_PTHs=FMI_matchStrToWaveRef("W_PTHs_*",0)
	If(waveexists(W_PTH))
		Killwaves/Z W_PTH,W_PTHs
	Endif
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::: STIMnum LOOP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<ItemsInList(S_WvLst_Xtms);i+=1)
		WAVE W_Xtms_tmp=$StringFromList(i,S_WvLst_Xtms)
		
		W_EVTnum[i]=DimSize(W_Xtms_tmp,0)
					
		If(numpnts(W_Xtms_tmp)>0)
			SetDataFolder ::
			NVAR V_HOLDmode
			
			WAVE w=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"")

			If(waveexists(w)==0)
				SetDataFolder CDF
				continue
			Else
				Duplicate/O w,W_tmp;WAVE W_tmp
				Variable V_box=5
				Smooth/B V_box,W_tmp
			Endif
			
			SetDataFolder CDF
				MAKE/O/N=(DimSize(W_Xtms_tmp,0)) $ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTamp"),$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTchg")
				WAVE W_EVTamp=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTamp")
				WAVE W_EVTchg=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTchg")
			
				WAVE W_PTH=FMI_matchStrToWaveRef("W_PTH_*",0)
				WAVE W_PTHs=FMI_matchStrToWaveRef("W_PTHs_*",0)
				If(waveexists(W_PTH)==0)
					Variable V_BINnum=FVCV_ValuefromString(note(W_Xtms_tmp),"segment.length: ")/V_BINsize
					
					MAKE/O/N=(V_BINnum) $ReplaceString("FEA", NameOfWave(W_FEA),"PTH"),$ReplaceString("FEA", NameOfWave(W_FEA),"PTHs")
					WAVE W_PTH=$ReplaceString("FEA", NameOfWave(W_FEA),"PTH")
					WAVE W_PTHs=$ReplaceString("FEA", NameOfWave(W_FEA),"PTHs")
						SetScale/P x, 0,V_BINsize,"s",W_PTH,W_PTHs
				Endif
			
			// ......................................................... EVENT LOOP ...............................................................
			For(j=0;j<DimSize(W_Xtms_tmp,0);j+=1)
				
				Variable V_BLamp
				WaveStats/Q/R=(W_Xtms_tmp[j][0]-V_BLperiod,W_Xtms_tmp[j][0]) W_tmp
				V_BLamp=V_avg
				
				Variable V_end
				If(j==DimSize(W_Xtms_tmp,0)-1)
					V_end=inf
				Else
					V_end=W_Xtms_tmp[j+1][0]
				Endif
				
				// AMPLITUDE
				WaveStats/Q/R=(W_Xtms_tmp[j][0],V_end) W_tmp
				Switch(V_HOLDmode)
					case 1:
						If(j==0)
							W_FEA[i]=V_min-V_BLamp
						Endif
						W_EVTamp[j]=V_min-V_BLamp
						break
					case 2:
						If(j==0)
							W_FEA[i]=V_max-V_BLamp
						Endif
						W_EVTamp[j]=V_max-V_BLamp
						break
				Endswitch
				
				Variable V_EVTtim=(W_Xtms_tmp[j][0]-FVCV_ValuefromString(note(W_Xtms_tmp),"segment.offset: "))/V_BINsize
				W_PTH[round(V_EVTtim)-1]+=1
				W_PTHs[round(V_EVTtim)-1]+=W_EVTamp[j]
				
				// ... cumulative
				If(j==0)
					WaveStats/Q/R=(W_Xtms_tmp[j][0],inf) W_tmp
					Switch(V_HOLDmode)
						case 1:
							W_cEA[i]=V_min-V_BLamp
							break
						case 2:
							W_cEA[i]=V_max-V_BLamp
							break
					Endswitch
				Endif
				
				// CHARGE (INTEGRAL)
				Switch(V_HOLDmode)
					case 1:
						FindLevel/EDGE=1/P/Q/R=(W_Xtms_tmp[j][0]+V_minEVTlngth,V_end) W_tmp, V_BLamp
						break
					case 2:
						FindLevel/EDGE=2/P/Q/R=(W_Xtms_tmp[j][0]+V_minEVTlngth,V_end) W_tmp, V_BLamp
						break
				Endswitch
				If(V_flag==0)	// level was found
					If(j==0)
						W_FEQ[i]=abs(area(w,W_Xtms_tmp[j][0],V_LevelX))
					Endif
					W_EVTchg[j]=abs(area(w,W_Xtms_tmp[j][0],V_LevelX))
				Else
					If(j==0)
						W_FEQ[i]=NaN
					Endif
					W_EVTchg[j]=NaN
				Endif
				
				// ... cumulative
				If(j==0)
					Switch(V_HOLDmode)
					case 1:
						FindLevel/EDGE=1/P/Q/R=(W_Xtms_tmp[j][0]+V_minEVTlngth,inf) W_tmp, V_BLamp
						break
					case 2:
						FindLevel/EDGE=2/P/Q/R=(W_Xtms_tmp[j][0]+V_minEVTlngth,inf) W_tmp, V_BLamp
						break
					Endswitch
					If(V_flag==0)	// level was found
						W_cEQ[i]=abs(area(w,W_Xtms_tmp[j][0],V_LevelX))
					Else
						W_cEQ[i]=NaN
					Endif
				Endif
				
			Endfor
			// ......................................................... EVENT LOOP ...............................................................
			
			Killwaves/Z W_tmp
			
		Else
			W_FEA[i]=NaN
			W_FEQ[i]=NaN
			W_EVTnum[i]=NaN
			W_cEA[i]=NaN
			W_cEQ[i]=NaN
		Endif
	Endfor
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::: STIMnum LOOP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
	W_PTHs/=W_PTH				// ... i.e. W_PTHs now contains the average response amplitude - within each time bin 
		W_PTHs=numtype(W_PTHs[p])==2 ? 0 : W_PTHs[p]
	W_PTH/=ItemsInList(S_WvLst_Xtms)	// ... i.e. W_PSTH now contains the average number of events per MOT shock - within each time bin 
	
	SetScale d,0,0,"event probability",W_PTH
	SetScale d,0,0,"A [average event amplitude]",W_PTHs
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::: STP :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	Variable V_offset=0
	If(ItemsInList(S_WvLst_Xtms)>1)
		MAKE/O/N=(V_seg_dp) $ReplaceString("FEA", NameOfWave(W_FEA),"NFEA"),$ReplaceString("cEA", NameOfWave(W_cEA),"NcEA")
			WAVE W_NFEA=$ReplaceString("FEA", NameOfWave(W_FEA),"NFEA")
			WAVE W_NcEA=$ReplaceString("cEA", NameOfWave(W_cEA),"NcEA")
			
		For(i=0;i<V_seg_dp;i+=1)
			WAVE W_Xtms_tmp=FMI_matchStrToWaveRef("*s"+num2str(i+1)+"_*_Xtms",0)
			
			If(waveexists(W_Xtms_tmp))
				W_NFEA[i]=W_FEA[i-V_offset]
				W_NcEA[i]=W_cEA[i-V_offset]
			Else
				W_NFEA[i]=NaN
				W_NcEA[i]=NaN
				V_offset+=1
			Endif
		Endfor
		
		Variable V_maxFEA,W_maxcEA
		Switch(V_HOLDmode)
			case 1:
				WaveStats/Q W_FEA
					V_maxFEA=V_min
				WaveStats/Q W_cEA
					W_maxcEA=V_min
				break
			case 2:
				WaveStats/Q W_FEA
					V_maxFEA=V_max
				WaveStats/Q W_cEA
					W_maxcEA=V_max
				break
		Endswitch
		
		W_NFEA/=V_maxFEA;NOTE/K W_NFEA
		W_NcEA/=W_maxcEA;NOTE/K W_NcEA
	Endif
	
	WaveStats_to_Note(W_FEA)
	WaveStats_to_Note(W_FEQ)
	WaveStats_to_Note(W_EVTnum)
	WaveStats_to_Note(W_cEA)
	WaveStats_to_Note(W_cEQ)
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_STIM_EventDTCT([w,V_algorithm,V_BLANK,V_BLANKstart,V_BLANKend,V_DIFthr,V_noise,V_box,V_config,V_BLstart,V_BLend,V_start,V_end,S_mode,V_BSL])
	WAVE w
	Variable V_algorithm,V_BLANK,V_BLANKstart,V_BLANKend,V_DIFthr,V_noise,V_box,V_config,V_BLstart,V_BLend,V_start,V_end,V_BSL
	String S_mode

	DFREF CDF=GetDataFolderDFR( )
	String S_note=""
	String S_unit
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_algorithm)) 	// default: parameter is not specified
		V_algorithm=2				// 0: threshold (w') detection of derivative; 1: sliding template (Clements & Bekkers, 1997); 2: threshold detection algorithm (Kudoh & Taguzchi, 2002)		
	Endif
	If(ParamIsDefault(V_BLANK)) 
		V_BLANK=0
	Endif
	If(ParamIsDefault(V_BLANKstart)) 
		V_BLANKstart=0
	Endif
	If(ParamIsDefault(V_BLANKend)) 
		V_BLANKend=2e-3
	Endif
	If(ParamIsDefault(V_box)) 
		V_box=11
	Endif
	If(ParamIsDefault(V_BLstart)) 
		V_BLstart=-inf
	Endif
	If(ParamIsDefault(V_BLend)) 
		V_BLend=inf
	Endif
	If(ParamIsDefault(V_start)) 
		V_start=-inf
	Endif
	If(ParamIsDefault(V_end)) 
		V_end=inf
	Endif
	If(ParamIsDefault(S_mode)) 
		S_mode="esVC"
	Endif
	If(ParamIsDefault(V_BSL)) 
		V_BSL=0
	Endif
	
	If(V_BLANK)
		w[(V_BLANKstart/DimDelta(w,0))-1,(V_BLANKend/DimDelta(w,0))-1]=NaN
	Endif
	
	Variable/G V_mode=V_config		// 0 = current clamp; 1 = voltage clamp / EPSC; 2 = voltage clamp / IPSC 
	
	Switch(V_mode)
		case 0:
			S_unit="V/s"
			break
		case 1:
			S_unit="A/s"
			break
		case 2:
			S_unit="A/s"
			break
	Endswitch
	
	Switch(V_BSL)
		default:
			NewDataFolder/O/S :TRC_analysis_EVT
			break
		
		case 1:
			NewDataFolder/O/S :TRC_analysis_BSL
			break
	Endswitch
	// ######################### CHOICE OF EVENT DETECTION ALGORITHM ########################
	Switch(V_algorithm)
		case 0:	// threshold detection of derivative (w') 
			WAVE W_FindLevels=FMI_EVTdtct_DIFthr(w=w,S_unit=S_unit,V_mode=V_mode)
			break

		case 1:	// template matching algorithm (Clements & Bekkers, 1997)
			WAVE W_FindLevels=FMI_EVTdtct_MatchTemplate(w=w)
			break
				
		case 2:	// threshold detection algorithm (Kudoh & Taguzchi, 2002)	
			WAVE W_FindLevels=FMI_EVTdtct_THR(w=w,V_mode=V_mode,V_noise=V_noise,V_box=V_box,V_BLstart=V_BLstart,V_BLend=V_BLend,V_start=V_start,V_end=V_end,S_mode=S_mode,V_BSL=V_BSL)
			break
	Endswitch 
		
	If(waveexists(W_FindLevels)==0 || numpnts(W_FindLevels)==0)
		SetDataFolder CDF
	Endif
		
	SetDataFolder CDF
	
	return W_FindLevels
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_EVTdtct_THR([w,V_thr,V_mode,V_noise,V_box,V_plot,V_BLstart,V_BLend,V_start,V_end,S_mode,V_BSL])
	WAVE w
	Variable V_thr,V_mode,V_noise,V_box,V_plot,V_BLstart,V_BLend,V_start,V_end,V_BSL
	String S_mode
	
	DFREF CDF=GetDataFolderDFR( )
	
	Variable V_vdVC_offset
	String S_note=""
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_mode)) 		// default: parameter is not specified
		V_mode=1					// 0 = current clamp; 1 = voltage clamp / EPSC; 2 = voltage clamp / IPSC 
	Endif
	If(ParamIsDefault(V_box)) 			// default: parameter is not specified
		V_box=11				
	Endif
	If(ParamIsDefault(V_plot)) 			// default: parameter is not specified
		StrSwitch(S_mode)
			case "esVC":
				V_plot=1
				break
			case "vdVC":
				V_plot=1
				break
			case "vdCC":
				V_plot=1
				break	
		Endswitch	
	Endif
	If(ParamIsDefault(V_start)) 		// default: parameter is not specified
		V_start=-inf	
	Endif
	If(ParamIsDefault(V_end)) 			// default: parameter is not specified
		V_end=inf				
	Endif
	If(ParamIsDefault(S_mode)) 
		S_mode="esVC"
	Endif
	If(ParamIsDefault(V_BSL)) 
		V_BSL=1
	Endif
	
	If(V_start==-inf)
		V_vdVC_offset=0
	Else
		V_vdVC_offset=V_start
	Endif
	
	SetDataFolder GetWavesDataFolderDFR(w)
		SVAR S_shID
	SetDataFolder CDF
		
	Variable i,j,k,l,m
	
	Duplicate/O/R=(V_start,V_end) w,W_tmp; WAVE W_tmp
	Smooth/B V_box,W_tmp
	
	Make/O/N=0 $NameOfWave(w)+"_EVTonst",$NameOfWave(w)+"_EVTpeak",$NameOfWave(w)+"_EVTamp"
	WAVE W_EVTonst=$NameOfWave(w)+"_EVTonst"
	WAVE W_EVTpeak=$NameOfWave(w)+"_EVTpeak"
	WAVE W_EVTamp=$NameOfWave(w)+"_EVTamp"
	
	If(V_BLstart != -inf && V_BLend != inf)
		MAKE/O/N=0 $NameOfWave(w)+"_AVGamp"
		WAVE W_AVGamp=$NameOfWave(w)+"_AVGamp"
	Endif
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	Variable V_wi,V_bin,V_pp
	Variable V_noteScaling
	String S_noteUnits
	
	StrSwitch(S_mode)
		// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
		case "esVC":
			
			V_wi=2e-3/DimDelta(w,0)
			V_bin=0.5e-3/DimDelta(w,0)
			V_pp=4e-3/DimDelta(w,0)
			
			If(ParamIsDefault(V_thr)) 	
				Switch(V_mode)
					case 0:					// CURRENT CLAMP		
						V_thr=0.3e-3		
						break
					case 1:					// VOLTAGE CLAMP: EPSC analysis
						V_thr=-4e-12		
						break
					case 2:					// IPSC analysis
						V_thr=15e-12			
						V_bin=3e-3/DimDelta(w,0)
						break
				Endswitch
			Endif	
			
			Switch(V_mode)
				case 2:					// IPSC analysis			
					V_bin=3e-3/DimDelta(w,0)
					break
			Endswitch
			break
		
		// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
		case "vdVC":
			
			V_wi=1.5e-3/DimDelta(w,0)	// the smaller, the fewer events detected
			V_bin=1.5e-3/DimDelta(w,0)	// the smaller, the more events detected
			V_pp=8e-3/DimDelta(w,0)		// the smaller, the more events detected (often 'double' or multiple detections, if too small...)
			
			If(ParamIsDefault(V_thr))
				Switch(V_mode)
					case 1:					// VOLTAGE CLAMP: EPSC analysis
						V_thr=-5e-12		
						break
					case 2:					// IPSC analysis
						V_thr=20e-12			
						break
				Endswitch
			Endif
			
			Switch(V_mode)
				case 2:						// IPSC analysis	
					V_wi=1.5e-3/DimDelta(w,0)	// the smaller, the fewer events detected
					V_bin=2e-3/DimDelta(w,0)
					V_pp=15e-3/DimDelta(w,0)
					break
			Endswitch
			
			S_noteUnits=" pA"
			V_noteScaling=1e12
			break
		
		// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
		case "vdCC":
			
			// ... before 03.09.2014
//			V_wi=1.0e-3/DimDelta(w,0)	// the smaller, the fewer events detected
//			V_bin=2.0e-3/DimDelta(w,0)	// the smaller, the more events detected
//			V_pp=20e-3/DimDelta(w,0)		// the smaller, the more events detected (often 'double' or multiple detections, if too small...)
//			
//			If(ParamIsDefault(V_thr))
//				V_thr=0.3e-3
//			Endif
			
			// ... after 03.09.2014 --- NOT PERFECT YET
			V_wi=1.5e-3/DimDelta(w,0)		// the smaller, the fewer events detected
			V_bin=1e-3/DimDelta(w,0)		// the smaller, the more events detected
			V_pp=25e-3/DimDelta(w,0)		// the smaller, the more events detected (often 'double' or multiple detections, if too small...)
			
			If(ParamIsDefault(V_thr))
				V_thr=0.3e-3
			Endif
			
			S_noteUnits=" mV"
			V_noteScaling=1e3
			break
	Endswitch
	
	
	If(StringMatch(S_mode,"vdCC")||StringMatch(S_mode,"vdVC"))
		S_note+="\rORIGINAL TRACE PARAMETERS:"
		S_note+="\r\tw.DimDelta: "+num2str(DimDelta(w,0))+" s"
		S_note+="\r\tw.ANALYSISwindow: "+num2str(numpnts(W_tmp)*DimDelta(w,0))+" s"
		S_note+="\rEVENT DETECTION PARAMETERS ("+date()+" @ "+time()+"):"
		S_note+="\r\tthreshold / minum event level (V_thr) = "+num2str(V_thr*V_noteScaling)+S_noteUnits
		S_note+="\r\tsliding detection window (V_wi) = "+num2str(V_wi*DimDelta(w,0)*1e3)+" ms"
		S_note+="\r\tonset / peak average window (V_bin) = "+num2str(V_bin*DimDelta(w,0)*1e3)+" ms"
		S_note+="\r\tpeak limit (V_pp) = "+num2str(V_pp*DimDelta(w,0)*1e3)+" ms"
	Endif
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<numpnts(W_tmp);i+=1)	// initial search
		
		Switch(V_mode)			
			case 1:					// VOLTAGE CLAMP: EPSC analysis			
				If(W_tmp[i+V_wi]-W_tmp[i]<V_thr)
					
					InsertPoints numpnts(W_EVTonst),1,W_EVTonst,W_EVTpeak,W_EVTamp
					W_EVTonst[numpnts(W_EVTonst)-1]=i
					W_EVTpeak[numpnts(W_EVTpeak)-1]=i+V_wi
						
					For(j=i;j<i+V_wi;j+=1)	// onset search
						WaveStats/Q/R=[j,j+V_bin] W_tmp
						If(V_avg<W_tmp[i]-V_noise)
							W_EVTonst[numpnts(W_EVTonst)-1]=j
							break
						Endif
					Endfor	// onset search
						
					For(l=W_EVTonst[numpnts(W_EVTonst)-1];l<W_EVTonst[numpnts(W_EVTonst)-1]+V_pp;l+=1)	// (tmp) peak search (forward)
						WaveStats/Q/R=[l,l+V_bin] W_tmp
						If(V_avg>=W_tmp[l]+V_noise)
							W_EVTpeak[numpnts(W_EVTpeak)-1]=l
							break
						Endif
					Endfor	// (tmp) peak search (forward)
					
					For(m=l;m>W_EVTonst[numpnts(W_EVTonst)-1];m-=1)	// (true) peak search (backward)
						WaveStats/Q/R=[m,m-V_bin] W_tmp
						If(V_avg<=W_tmp[l])
							W_EVTpeak[numpnts(W_EVTpeak)-1]=m
							break
						Endif
					Endfor	// (true) peak search (backward)
					
					// ... amplitude check
					W_EVTamp[numpnts(W_EVTamp)-1]=W_tmp[W_EVTpeak[numpnts(W_EVTpeak)-1]]-W_tmp[W_EVTonst[numpnts(W_EVTonst)-1]]
					
					// ... i is set at the index of the peak point. This ascertains that the next event is detected after the peak point of the previous event.
					i=W_EVTpeak[numpnts(W_EVTpeak)-1]
				Endif		
				break
			
			default:					// VOLTAGE CLAMP: IPSC analysis &&  CURRENT CLAMP		
				If(W_tmp[i+V_wi]-W_tmp[i]>V_thr)
					
					InsertPoints numpnts(W_EVTonst),1,W_EVTonst,W_EVTpeak,W_EVTamp
					W_EVTonst[numpnts(W_EVTonst)-1]=i
					W_EVTpeak[numpnts(W_EVTpeak)-1]=i+V_wi
						
					For(j=i;j<i+V_wi;j+=1)	// onset search
						WaveStats/Q/R=[j,j+V_bin] W_tmp
						If(V_avg>W_tmp[i]+V_noise)
							W_EVTonst[numpnts(W_EVTonst)-1]=j
							break
						Endif
					Endfor	// onset search
						
					For(l=W_EVTonst[numpnts(W_EVTonst)-1];l<W_EVTonst[numpnts(W_EVTonst)-1]+V_pp;l+=1)	// (tmp) peak search (forward)
						WaveStats/Q/R=[l,l+V_bin] W_tmp
						If(V_avg<=W_tmp[l]-V_noise)
							W_EVTpeak[numpnts(W_EVTpeak)-1]=l
							break
						Endif
					Endfor	// (tmp) peak search (forward)
					
					For(m=l;m>W_EVTonst[numpnts(W_EVTonst)-1];m-=1)	// (true) peak search (backward)
						WaveStats/Q/R=[m,m-V_bin] W_tmp
						If(V_avg>=W_tmp[l])
							W_EVTpeak[numpnts(W_EVTpeak)-1]=m
							break
						Endif
					Endfor	// (true) peak search (backward)
					
					// ... amplitude check
					W_EVTamp[numpnts(W_EVTamp)-1]=W_tmp[W_EVTpeak[numpnts(W_EVTpeak)-1]]-W_tmp[W_EVTonst[numpnts(W_EVTonst)-1]]
					
					// ... i is set at the index of the peak point. This ascertains that the next event is detected after the peak point of the previous event.
					i=W_EVTpeak[numpnts(W_EVTpeak)-1]
				Endif		
				break
		Endswitch

	Endfor	// initial search
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(numpnts(W_EVTonst)>0)
		MAKE/O/N=(numpnts(W_EVTonst),2) $NameOfWave(w)+"_Xtms"
		WAVE/Z W_Xtms=$NameOfWave(w)+"_Xtms"; FastOP W_Xtms=0
		
		StrSwitch(S_mode)
			case "esVC":
				NOTE/K/NOCR W_Xtms,note(w)+"\rDF.shID: "+S_shID+"\rw.ENTRY: "+num2str(WhichListItem(NameOfWave(W_Xtms),WaveList("*_Xtms",";","")))
				W_Xtms[][0]=W_EVTonst[p]*DimDelta(w,0)+FVCV_ValuefromString(note(w),"segment.offset: ")
				break
			default: // "vdCC" & "vdVC" (= void current clamp & void voltage clamp)
				NOTE/K/NOCR W_Xtms,S_note
				NOTE/K/NOCR W_EVTamp,S_note;NOTE/K/NOCR W_EVTpeak,S_note;NOTE/K/NOCR W_EVTonst,S_note
				W_Xtms[][0]=W_EVTonst[p]*DimDelta(w,0)+V_vdVC_offset
				break
		Endswitch
		W_Xtms[][1]=1
	
		If(V_plot)
			Display/K=1 w;AppendToGraph/R W_Xtms[][1] vs W_Xtms[][0];DelayUpdate
			ModifyGraph mode($nameofwave(W_Xtms))=1,rgb($nameofwave(w))=(0,0,0);DelayUpdate
			ModifyGraph nticks=3,axThick=0.5,font="Arial",fsize=14,lsize=0.5;DelayUpdate
			ModifyGraph nticks(right)=0,noLabel(right)=2,axThick(right)=0;DelayUpdate
			SetAxis right 0,1;DelayUpdate
			
			SetWindow kwTopWin,userdata(wREF)=GetWavesDataFolder(w,2)
			SetWindow kwTopWin,userdata(wNM)=NameOfWave(w)
			SetWindow kwTopWin,userdata(XtmsREF)=GetWavesDataFolder(W_Xtms,2)
			SetWindow kwTopWin,userdata(XtmsNM)=NameOfWave(W_Xtms)
			SetWindow kwTopWin,userdata(actEVT)=num2str(DimSize(W_Xtms,0)-1)
	
			// Add Control Bar
			GetWindow kwTopWin,wsize
			ControlInfo kwControlBar
			If(V_height==0)
				ControlBar CBarHeight
				MoveWindow V_left,V_top,V_right,V_bottom+CBarHeight
			Endif
			
			Button Button_EVTplot_Rescale,pos={101,2},size={50,20},proc=ButtonProc_FMI_Ephus_EVTplot,title="Rescale"
					
			StrSwitch(S_mode)
				case "esVC":
					WAVE W_FEL=FMI_matchStrToWaveRef("*_FEL_*",0)
						
					SetWindow kwTopWin,hook(MainHook)=FMI_EVTdtct_WinHook,hookcursor=1,hookevents=7
									
					Button Button_EVTplot_AddEVENT,pos={1,2},size={50,20},proc=ButtonProc_FMI_Ephus_EVTplot,title="Add EVT"
					Button Button_EVTplot_DelEVENT,pos={51,2},size={50,20},proc=ButtonProc_FMI_Ephus_EVTplot,title="Kill EVT"
					Button Button_EVTplot_FEL,pos={151,2},size={50,20},proc=ButtonProc_FMI_Ephus_EVTplot,title="FEL"
					SetVariable Setvar_EVTplot_actEVT,pos={208,4},size={105,16},bodyWidth=40,proc=SetVarProc_FMI_Ephus_EVTplot,title="Active Event",limits={0,DimSize(W_Xtms,0)-1,1},value= _NUM:DimSize(W_Xtms,0)-1
					SetVariable Setvar_EVTplot_EVTtim,pos={348,4},size={105,16},bodyWidth=50,noproc,title="Event timing (ms)",limits={0,inf,0},value= _NUM:(W_Xtms[DimSize(W_Xtms,0)-1][0]-FVCV_ValuefromString(note(W_Xtms),"segment.offset: "))*1e3,noedit=1,format="%.1f"
					break	
			Endswitch	
		Endif
	Endif
	
	// ... added AVGamp wave on 04.09.2014 - general dVm during stimulation period, relative to baseline period
	If(waveexists(W_AVGamp))
		InsertPoints numpnts(w)-1, 1, W_AVGamp 
		
		WaveStats/Q/R=(V_BLstart,V_BLend) w
			Variable V_BLamp=V_avg
		
		WaveStats/Q/R=(V_start,V_end) w
			W_AVGamp[numpnts(W_AVGamp)-1]=V_avg-V_BLamp
	Endif
	
	Killwaves/Z W_tmp
	
	return W_EVTonst
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Constant CBarHeight=24

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EVTdtct_WinHook(s)
	STRUCT WMWinHookStruct &s
		
	DFREF CDF=GetDataFolderDFR( )
	
	Variable hookResult = 0
		
	WAVE w=$GetUserData(s.winName,"","wREF")
	WAVE W_Xtms=$GetUserData(s.winName,"","XtmsREF")
	If(waveexists(w)==0||waveexists(W_Xtms)==0)
		return -1
	Endif
	
	DFREF evtDF=GetWavesDataFolderDFR(W_Xtms)
	
	Variable V_AxisVal=x2pnt(w,AxisValFromPixel(s.winName,"bottom",s.mouseLoc.h))
	Variable V_actEVT=str2num(GetUserData(s.winName,"","actEVT"))
	
	Variable V_oldVal=W_Xtms[V_actEVT][0]
	Variable V_newVal=W_Xtms[V_actEVT][0]
	
	switch(s.eventCode)
		case 3:	// "mousedown"
			If(strlen(StringByKey("TRACE",TraceFromPixel(s.mouseLoc.h, s.mouseLoc.v,"WINDOW:"+s.winName+";ONLY:"+GetUserData(s.winName,"","XtmsNM"))))>0)
				WAVE W_HIT=TraceNameToWaveRef(s.winName, StringByKey("TRACE",TraceFromPixel(s.mouseLoc.h, s.mouseLoc.v,"WINDOW:"+s.winName+";ONLY:"+GetUserData(s.winName,"","XtmsNM"))))
			Endif
			
			If(waveexists(W_HIT))
				FindLevel/P/Q W_Xtms, AxisValFromPixel(s.winName,"bottom",s.mouseLoc.h)
				If(V_flag==0)
					V_actEVT=round(V_LevelX)	
				Else
					V_actEVT=0
				Endif

				FMI_EVTplot_hook_update(s.winName,V_actEVT,DimSize(W_Xtms,0)-1)
			Endif

			V_newVal=AxisValFromPixel(s.winName,"bottom",s.mouseLoc.h)

			break

		case 22:	// mousewheel
			Switch(s.eventMod)
				default:	
					V_newVal+=s.wheelDy*DimDelta(w,0)
					break
				
				case 2:	// Shift (Windows ) is down
					V_newVal+=s.wheelDy*DimDelta(w,0)*50
					break
					
				case 8:	// Ctrl (Windows ) is down.
					V_newVal+=s.wheelDy*DimDelta(w,0)*10
					break
				
				case 10:	// Shift (Windows ) & Ctrl (Windows ) is down
					If(V_actEVT+s.wheelDy<0)
						V_actEVT=0
					ElseIf(V_actEVT+s.wheelDy>=DimSize(W_Xtms,0))
						V_actEVT=DimSize(W_Xtms,0)-1
					Else
						V_actEVT+=s.wheelDy
					Endif
					
					FMI_EVTplot_hook_update(s.winName,V_actEVT,DimSize(W_Xtms,0)-1)
					break
			Endswitch
			
			
	endswitch
	
	If(V_oldVal==V_newVal)
		return hookResult
	Endif
	
	// ... evaluates whether the adjustment of event timers results in a change of the event order in time (FORBIDDEN)  
	If((V_actEVT>0 && V_newVal<=W_Xtms[V_actEVT-1][0]) || (V_actEVT!=DimSize(W_Xtms,0)-1 && V_newVal>=W_Xtms[V_actEVT+1][0]))
		return 0
	Else
		// ... update value in Xtms wave
		W_Xtms[V_actEVT][0]=V_newVal
		
		// ... blank value in first event amplitude wave (W_FEA) - as integrity of this entry is violated
		WAVE/SDFR=evtDF W_FEA=$"W_FEA_"+FMI_StringfromString(note(W_Xtms),"DF.shID: ") 
			If(waveexists(W_FEA))
				Variable V_entry=FVCV_ValuefromString(note(W_Xtms),"w.ENTRY: ")
				W_FEA[V_entry]=NaN
			Endif
			
		// ... update Variable display in graph window
		FMI_EVTplot_hook_update_EVTtim(W_Xtms,s.winName,V_actEVT)
	Endif
	
	SetDataFolder GetWavesDataFolderDFR(w)
		Sort W_Xtms,W_Xtms 
		FMI_STIM_EventDTCT_SRSsmm()
	SetDataFolder CDF
	
	return hookResult		// 0 if nothing done, else 1
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function ButtonProc_FMI_Ephus_EVTplot(ba) : ButtonControl
	STRUCT WMButtonAction &ba
		
	DFREF CDF=GetDataFolderDFR( )
	
	WAVE w=$GetUserData(ba.win,"","wREF")
	WAVE W_Xtms=$GetUserData(ba.win,"","XtmsREF")
	If(waveexists(w)==0||waveexists(W_Xtms)==0)
		return -1
	Endif
	
	DFREF evtDF=GetWavesDataFolderDFR(W_Xtms)
	
	Variable V_actEVT=str2num(GetUserData(ba.win,"","actEVT"))
	
	switch( ba.eventCode )
		case 2: // mouse up
			StrSwitch(ba.ctrlName)
			
				// ..............................................................................	
				case "Button_EVTplot_AddEVENT":
					InsertPoints/M=0 DimSize(W_Xtms,0),1, W_Xtms
						W_Xtms[DimSize(W_Xtms,0)-1][0]=FVCV_ValuefromString(note(w),"segment.offset: ")+0.95*FVCV_ValuefromString(note(w),"segment.length: ")
						W_Xtms[DimSize(W_Xtms,0)-1][1]=1
					
					FMI_EVTplot_hook_update(ba.win,DimSize(W_Xtms,0)-1,DimSize(W_Xtms,0)-1)
					break
				
				// ..............................................................................	
				case "Button_EVTplot_DelEVENT":
					DeletePoints/M=0 V_actEVT,1,W_Xtms
					
					FMI_EVTplot_hook_update(ba.win,DimSize(W_Xtms,0)-1,DimSize(W_Xtms,0)-1)
					break
					
				// ..............................................................................	
				case "Button_EVTplot_Rescale":
					SetAxis/A
					SetAxis right 0,1
					break
				
				// ..............................................................................	
				case "Button_EVTplot_FEL":
					SetDataFolder evtDF
						WAVE W_FEL=FMI_matchStrToWaveRef("*_FEL_*",0)
					SetDataFolder CDF 
					
					If(waveexists(W_FEL))
						GetWindow $ba.win,wsize
						
						DoWindow $nameofwave(W_FEL)
							If(V_flag)	// ... window exists
								DoWindow/F $nameofwave(W_FEL) // Brings the window with the given name to the front (top of desktop).
								MoveWindow/W=$nameofwave(W_FEL) V_left,V_bottom+30,V_right,V_bottom+(V_bottom-V_top)+30
								break 
							Endif
							
						GetWindow $ba.win,wsize
							Display/K=1/W=(V_left,V_bottom+30,V_right,V_bottom+(V_bottom-V_top)+30) W_FEL
							DoWindow/C $nameofwave(W_FEL)
					Endif	
					break
			Endswitch
		break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EVTplot_hook_update(win,V_actEVT,V_max)
	String win
	Variable V_actEVT,V_max
	
	SetWindow $win,userdata(actEVT)=num2str(V_actEVT)
	SetVariable Setvar_EVTplot_actEVT,limits={0,V_max,1},value= _NUM:V_actEVT,win=$win
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EVTplot_hook_update_EVTtim(W_Xtms,win,V_actEVT)
	WAVE W_Xtms
	String win
	Variable V_actEVT
	
	If(waveexists(W_Xtms)==0)
		return -1
	Endif
	
	SetVariable Setvar_EVTplot_EVTtim,value= _NUM:(W_Xtms[V_actEVT][0]-FVCV_ValuefromString(note(W_Xtms),"segment.offset: "))*1e3,win=$win
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function SetVarProc_FMI_Ephus_EVTplot(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	
	WAVE W_Xtms=$GetUserData(sva.win,"","XtmsREF")
	If(waveexists(W_Xtms)==0)
		return -1
	Endif
	
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update	
			SetWindow kwTopWin,userdata(actEVT)=num2str(sva.dval)
			SetVariable Setvar_EVTplot_actEVT,limits={0,DimSize(W_Xtms,0)-1,1},value= _NUM:sva.dval
			break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_EVTdtct_DIFthr([w,S_unit,V_tmin,V_tmax,V_box1,V_box2,V_mode,V_DIFthr])
	WAVE w
	String S_unit
	Variable V_tmin,V_tmax,V_box1,V_box2,V_mode,V_DIFthr
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(S_unit)) 				// default: parameter is not specified
		S_unit="A/s"
	Endif
	If(ParamIsDefault(V_tmin)) 			// default: parameter is not specified
		V_tmin=-inf
	Endif
	If(ParamIsDefault(V_tmax)) 		// default: parameter is not specified
		V_tmax=inf
	Endif
	If(ParamIsDefault(V_box1)) 		// default: parameter is not specified
		V_box1=7
	Endif
	If(ParamIsDefault(V_box2)) 		// default: parameter is not specified
		V_box2=25
	Endif
	If(ParamIsDefault(V_mode)) 		// default: parameter is not specified
		V_mode=1					// 0 = current clamp; 1 = voltage clamp / EPSC; 2 = voltage clamp / IPSC 
	Endif

	Differentiate w /D=$NameOfWave(w)+"_DIF"
	WAVE W_DIF=$NameOfWave(w)+"_DIF"
	SetScale d 0,0,S_unit,W_DIF
		
	Duplicate/O W_DIF,$NameOfWave(W_DIF)+"_smth"
	WAVE W_smthDIF=$NameOfWave(W_DIF)+"_smth";Killwaves/Z W_DIF
	Smooth/B V_box1,W_smthDIF
	Smooth/B V_box2,W_smthDIF
				
	If(ParamIsDefault(V_DIFthr)) 		// default: parameter is not specified
		Switch(V_mode)
			case 0:					// CURRENT CLAMP		
				V_DIFthr=0.1			// dV/dt [V/s]; empirically chosen
				break
			case 1:					// VOLTAGE CLAMP: EPSC analysis
				V_DIFthr=-2.5e-9		// dI/dt [A/s]; empirically chosen
				break
			case 2:					// IPSC analysis
				V_DIFthr=1.5e-9		// dI/dt [A/s]; empirically chosen
				break
		Endswitch
	Endif
		
	Switch(V_mode)
		case 0:	// EPSP
			FindLevels/EDGE=1/Q/R=(V_tmin,V_tmax)/M=.5e-3 W_smthDIF,V_DIFthr				// DEFINE APPROPRIATE ANALYSIS RANGE
			break
		case 1:	// EPSC
			FindLevels/EDGE=2/Q/R=(V_tmin,V_tmax)/M=.5e-3 W_smthDIF,V_DIFthr				// DEFINE APPROPRIATE ANALYSIS RANGE
			break
		case 2:	// IPSC
			
			break
	Endswitch

	WAVE W_FindLevels
		
	If(waveexists(W_FindLevels))
		return W_FindLevels
	Endif
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_EVTdtct_MatchTemplate([w,V_thr])
	WAVE w
	Variable V_thr
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_thr)) 				// default: parameter is not specified
		V_thr=4
	Endif
	
	Variable V_rate=10e3
	Variable V_tau_ons=2e-3
	Variable V_tau_dcy=8e-3
	Variable V_base=0.5e-3
	Variable V_funct=10e-3
	
	WAVE W_tmplt = MatchTemplateMake(1,V_tau_ons,V_tau_dcy,V_base,V_funct,1/V_rate)
	
	WAVE W_MatchTmplt=MatchTemplateCompute(w,W_tmplt)
	
	If(waveexists(W_MatchTmplt))
		FindLevels/M=.5e-3/P/Q W_MatchTmplt,V_thr
		WAVE W_FindLevels
		
		If(waveexists(W_FindLevels))
			return W_FindLevels
		Endif
	Endif
End

// 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
Function/WAVE MatchTemplateCompute(w,W_tmplt) // match template to wave
	WAVE w
	WAVE W_tmplt
	
	Variable icnt
	String S_WvNm="EV_MatchTmplt"
	
	if (numtype(sum(W_tmplt, -inf, inf)) > 0)
	
		Print "template wave contains one or more non-numbers; converted to zero"
		
		Wave t = W_tmplt
		
		for (icnt = 0; icnt < numpnts(t); icnt += 1)
			if (numtype(t[icnt]) > 0)
				t[icnt] = 0
			endif
		endfor
		
	endif
	
	Duplicate /O w $S_WvNm
	
	Execute /Z "MatchTemplate /C " + NameOfWave(W_tmplt) + ", " + S_WvNm // NEW FORMAT
	
	WAVE W_MatchTmplt=$S_WvNm
	
	return W_MatchTmplt
	
End // MatchTemplateCompute

// 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
Function/WAVE MatchTemplateMake(fxn, tau1, tau2, base, wform, dx)
	Variable fxn, tau1, tau2, base, wform, dx

	String wName = "W_template"
	
	Make /D/O/N=((base + wform) / dx) $wName
	SetScale /P x, 0, dx, $wName
	
	Wave pulse = $wName
	
	switch(fxn)
		case 1: // 2-exp
			pulse = ((1-exp((base - x)/tau1))) * exp(((base - x))/tau2)
			break
		case 2: // alpha wave
			pulse = (x - base)*exp((base - x)/tau1)
			break
	endswitch
	
	pulse[0, x2pnt(pulse, base)] = 0
	
	Wavestats /Q/Z pulse
	pulse /= v_max
	
	return pulse

End // MatchTemplateMake

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_vdEVT_LVL1_anl(W_FindLevels[,V_BSL])
	WAVE W_FindLevels
	Variable V_BSL
	
	If(ParamIsDefault(V_BSL))
		V_BSL=0
	Endif
	
	Variable V_DIFthr,V_tmin,V_tmax,V_box1,V_box2
	
	DFREF sDF=GetDataFolderDFR( )
	String S_note=""
	
	Variable i
	
	If(waveexists(W_FindLevels)==0)
		return -1
	Endif
	
	Switch(V_BSL)
		default:
			SetDataFolder :TRC_analysis_EVT
			break
		
		case 1:
			SetDataFolder :TRC_analysis_BSL
			break
	Endswitch
		
		DFREF aDF=GetDataFolderDFR( )
		// ############################### EVENT amplitude & risetime ###############################	
		If(numpnts(W_FindLevels)>0)	// ... W_FindLevels = W_*_EVTonst returned by FMI_EVTdtct_THR (adapted from Kudoh and Taguchi (2002))
			Variable V_delta=FVCV_ValuefromString(note(W_FindLevels),"w.DimDelta: ")
			
			WAVE W_amp=$ReplaceString("EVTonst",NameOfWave(W_FindLevels),"EVTamp")
			WAVE W_peak=$ReplaceString("EVTonst",NameOfWave(W_FindLevels),"EVTpeak")
			
			Duplicate/O W_FindLevels,$ReplaceString("EVTonst",NameOfWave(W_FindLevels),"EVTRsT")
			WAVE W_RsT=$ReplaceString("EVTonst",NameOfWave(W_FindLevels),"EVTRsT")
				SetScale d 0,0,"s",W_RsT
			
			W_RsT=(W_peak-W_FindLevels)*V_delta
				
			// ############################### IEI wave ############################### 
			If(numpnts(W_FindLevels)>1)
				MAKE/O/N=(numpnts(W_FindLevels)-1) $ReplaceString("EVTonst",NameOfWave(W_FindLevels),"IEI")
				WAVE/Z W_IEI=$ReplaceString("EVTonst",NameOfWave(W_FindLevels),"IEI")
					SetScale d 0,0,"s",W_IEI
						
				For(i=0;i<numpnts(W_IEI);i+=1)					
					W_IEI[i]=(W_FindLevels[i+1]-W_FindLevels[i])*V_delta
				Endfor
			Endif			
		Endif
		
		WaveStats_to_Note(W_amp)
		WaveStats_to_Note(W_RsT)
		WaveStats_to_Note(W_IEI)
		
		Killwaves/Z W_FindLevels,W_peak	
	SetDataFolder sDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_vdEVT_LVL2_anl([V_GA,S_ID,S_DFsav])		// event detection: SPONTANEOUS events
	Variable V_GA
	String S_ID,S_DFsav
	
	If(ParamIsDefault(V_GA))
		V_GA=0
	Endif
	If(ParamIsDefault(S_ID))
		S_ID=""
	Endif
	If(ParamIsDefault(S_DFsav))
		S_DFsav=GetDataFolder(1)
	Endif
	
	Variable i,i2,i3,j,h
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_baseID=S_ID
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	String S_DFLst,S_grepList
	S_DFLst=""
	S_grepList="void*;VCtest*;*nos*;"
	
	For(i=0;i<ItemsInList(S_grepList);i+=1)
		S_DFLst+=ListMatch(DFList(),StringfromList(i,S_grepList))
	Endfor
	
	S_DFLst=RemoveFromList(ListMatch(DFList(),"EXP*"), S_DFLst)
	
	If(ItemsinList(S_DFLst)==0)
		return -1
	Endif
	
	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<ItemsInList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
		DFREF sDF=GetDataFolderDFR( )
			
		// ########################### SERIES INFORMATION (rep#) ###############################
		Variable V_config,V_BSL,V_BLstart,V_BLend,V_TPstart,V_TPend,V_RSPstart,V_RSPend
		If(stringmatch(GetDataFolder(0),"void*"))			// ... assumed to be CC (spontaneous EPSPs)
			V_config=0
			V_BSL=0
			V_BLstart=-inf
			V_BLend=inf
			V_RSPstart=0
			V_RSPend=inf
		
		ElseIf(stringmatch(GetDataFolder(0),"VCtest*"))	// ... assumed to be VC (spontaneous EPSCs / IPSCs)
			V_config=1
			V_BSL=0
			V_BLstart=0.010
			V_BLend=0.090
			V_TPstart=0.145	// ... TP = test pulse
			V_TPend=0.195
			V_RSPstart=0.25
			V_RSPend=inf
		
		ElseIf(stringmatch(GetDataFolder(0),"*nos*"))	// ... assumed to be CC (spontaneous EPSPs)
			V_config=0
			V_BSL=1
			V_TPstart=0.1	// ... TP = test pulse
			V_TPend=0.195
			V_BLstart=0.2
			V_BLend=3.7
			V_RSPstart=3.8
			V_RSPend=10
		Endif
					
		String S_RPT,S_tmp
		SplitString /E=("(_n.*)") StringfromList(i,S_DFLst),S_tmp
			S_tmp=ReplaceString("_n",S_tmp,"") 
			// ... --> added on 03.09.2014: DIRTY WORKAROUND				
				S_tmp=ReplaceString("_dc95",S_tmp,"")
				S_tmp=ReplaceString("_dc45",S_tmp,"")
				S_tmp=ReplaceString("_dc15",S_tmp,"")
				S_tmp=ReplaceString("_dc05",S_tmp,"")
				S_tmp=ReplaceString("_dc01",S_tmp,"")
				S_tmp=ReplaceString("_dc005",S_tmp,"")
				S_tmp=ReplaceString("_dc002",S_tmp,"")
				S_tmp=ReplaceString("_dc00",S_tmp,"")
				S_tmp=ReplaceString("osC",S_tmp,"")
				S_tmp=ReplaceString("osP",S_tmp,"")			
			
		sscanf S_tmp, "%s",S_RPT
		Variable/G V_RPT=str2num(S_RPT)
		
		String S_Lst_trc=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")	// ALL TRACES 
			
		// ############################### EXTRACT trace INFO & CHECK ###############################
		WAVE w=$StringFromList(0,S_Lst_trc)	

		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: EXP STRING (identifier) :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		String S_YYMMDD=ReplaceString("E_",(FMI_StringfromString(note(w),"pFolder2: ")),"")
		If(strlen(S_YYMMDD)!=6)	// YYMMDD
			S_YYMMDD="YYMMDD"
		Endif
		String S_EXPnum=FMI_StringfromString(note(w),"Field1: ")
		
		String S_shID=S_YYMMDD+"_"+S_EXPnum+"_"+"n"+S_RPT
			
		Variable V_stimAMP
		WAVE/Z W_stim=$StringFromList(0,WaveList("*_stim",";",""))
		If(waveexists(W_stim))
			WaveStats/Q/R=(V_TPstart,V_TPend) W_stim
			V_stimAMP=round(V_avg*1e3)	// conversion V to mV
		Endif
		
		// ... CLEANUP (only for backward compatibility... this DF is no longer created)
		If(DataFolderExists(":SRS_analysis_EVT"))
			KillDataFolder/Z  :SRS_analysis_EVT
		Endif
		
		// ... CLEANUP
		If(DataFolderExists(":TRC_analysis_EVT"))
			KillDataFolder/Z  :TRC_analysis_EVT
		Endif
		
		// ... CLEANUP
		If(DataFolderExists(":TRC_analysis_BSL"))
			KillDataFolder/Z  :TRC_analysis_BSL
		Endif
			
		// ############################### ANALYSIS - INDIVIDUAL WAVES ###############################			
		For(i2=0;i2<ItemsInList(S_Lst_trc);i2+=1)
			WAVE w=$StringFromList(i2,S_Lst_trc)
			
			// ########################## ... REMOVE NOISY TRACES... ##########################
			// ... added on: 11 Sep 13
			// ... automatically remove the first trace in VC series - as it usually has a strong(er) 50Hz noise...
			Variable/G V_trcKILLnum=5
			
			If(V_config>0 && ItemsinList(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")) >= V_trcKILLnum && i2==0)
				String S_WvLst_EXCL=WaveList("*"+nameofwave(w)+"*",";","")
				
				NewDataFolder/O :EXCLUDED
				For(j=0;j<ItemsinList(S_WvLst_EXCL);j+=1)
					WAVE W_excl=$StringfromList(j,S_WvLst_EXCL)
					Duplicate/O W_excl,$":EXCLUDED:"+nameofwave(W_excl)
					Killwaves/Z W_excl
				Endfor
				
				continue
			Endif
	
			// ############################### SMOOTH TRACE ############################### 
			NewDataFolder/O/S :TRC_analysis_EVT
				DFREF aDF=GetDataFolderDFR( )
				
				Duplicate/O w,$NameOfWave(w)+"_smth"
				WAVE W_smth=$NameOfWave(w)+"_smth"
				Smooth/B 5,W_smth
			SetDataFolder ::
			
			If(V_BSL)
				NewDataFolder/O/S :TRC_analysis_BSL
					DFREF aDFbsl=GetDataFolderDFR( )
					
					Duplicate/O w,$NameOfWave(w)+"_smth"
					WAVE W_smth=$NameOfWave(w)+"_smth"
					Smooth/B 5,W_smth
				SetDataFolder ::
			Endif
			
			String S_config
			Switch(V_config)
				// ... CURRENT-CLAMP (CC) ...
				case 0:
					// ... inserted on 03.09.2014
					If(V_BSL)
						// ... EVT analysis during 'baseline' period [no DC dVm analysis]
						WAVE W_FindLevels=FMI_STIM_EventDTCT(w=w,V_config=0,V_start=V_BLstart,V_end=V_BLend,S_mode="vdCC",V_BSL=1)
						FMI_vdEVT_LVL1_anl(W_FindLevels,V_BSL=1)
						
						// ... EVT analysis during 'response' period [w/ DC dVm analysis]
						WAVE W_FindLevels=FMI_STIM_EventDTCT(w=w,V_config=0,V_BLstart=V_BLstart,V_BLend=V_BLend,V_start=V_RSPstart,V_end=V_RSPend,S_mode="vdCC")
						FMI_vdEVT_LVL1_anl(W_FindLevels)
					
					Else
						// ... EVT analysis during entire period [no DC dVm analysis]
						WAVE W_FindLevels=FMI_STIM_EventDTCT(w=w,V_config=0,V_start=V_RSPstart,V_end=V_RSPend,S_mode="vdCC")
						FMI_vdEVT_LVL1_anl(W_FindLevels)
					Endif	
						
					
					
					break
				
				// ... VOLTAGE-CLAMP (VC) ...
				default:
					WaveStats/Q w
					If(V_avg<1.5e-11)				// empirically chosen & DIRTY: in a healthy cell @ a holding potential of -70mV (very little) negative current has to be injected
						V_config=1
						S_config="EPSC"
					ElseIf(V_avg>=1.5e-11)		// empirically chosen & DIRTY: in a healthy cell @ a holding potential of 0mV, (considerable) negative current has to be injected
						V_config=2
						S_config="IPSC"
					Endif
					
					WAVE/SDFR=aDF W_Rin=$"W_Rin_"+S_config+"_"+S_shID
					If(waveexists(W_Rin)==0)
						SetDataFolder :TRC_analysis_EVT
							Make/O/N=(ItemsInList(S_Lst_trc)) $"W_Rin_"+S_config+"_"+S_shID=NaN
							WAVE W_Rin=$"W_Rin_"+S_config+"_"+S_shID
							SetScale d 0,0,"Ohm",W_Rin
						SetDataFolder ::
					Endif
					
					// ##################### EVT detection & analysis ########################
					WAVE W_FindLevels=FMI_STIM_EventDTCT(w=w,V_config=V_config,V_start=V_RSPstart,S_mode="vdVC")
					FMI_vdEVT_LVL1_anl(W_FindLevels)
					
					// ############################### PSD ############################### 
					fPowerSpectralDensity(w,2^(7+6),"Hann",1)	// npsd= 2^(7+seglen)				// number of points in group (resultant psd wave len= npsd/2+1); see "PowerSpectralDensity"
					Killwaves/Z ctmp
					
					WAVE W_psd=$nameofwave(w)+"_psd"
					Duplicate/O W_psd,$":TRC_analysis_EVT:"+nameofwave(W_psd)
					Killwaves/Z W_psd
					
					// ############################### Rin ############################### 
					W_Rin[i2]=FMI_Rin(w=w,V_mode=1,V_amp=V_stimAMP,V_BLstart=V_BLstart,V_BLend=V_BLend,V_RSPstart=V_TPstart,V_RSPend=V_TPend)
					break
			Endswitch
		Endfor
		
		RemoveNANs(W_Rin);WaveStats_To_Note(W_Rin)
			
		NVAR V_mode
			
		If(stringmatch(GetDataFolder(0),"void*"))
			WAVE/Z W_stim=$StringFromList(0,WaveList("*_stim",";",""))	
			Killwaves/Z W_stim
		Endif
					
		If(DataFolderExists(":TRC_analysis_EVT")!=1 || NVAR_exists(V_mode)==0)	// problems with FMI_EventDTCT - which creates the folder TRC_analysis_EVT 
			SetDataFolder CDF
			continue
		Endif
		
		// ###########################################################################################
		// ############################### ANALYSIS - SERIES SUMMARY ###############################
		For(h=0;h<=V_BSL;h+=1)
			Switch(h)
				case 0:
					SetDataFolder :TRC_analysis_EVT
					break
				
				case 1:
					SetDataFolder :TRC_analysis_BSL
					break
			Endswitch
			
			String S_SRS,S_units
				
			STRING/G S_type
					
			Switch(V_mode)
				case 0:		// EPSP analysis
					S_SRS="EPSP_"+S_shID
					S_units="V"
					S_type="EPSP"
					break
						
				case 1:		// EPSC anaylsis
					S_SRS="EPSC_"+S_shID
					S_units="A"
					S_type="EPSC"
					break
						
				case 2:		// IPSC analysis
					S_SRS="IPSC_"+S_shID
					S_units="A"
					S_type="IPSC"
					break
			Endswitch
			
			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			String S_Lst_AVGamp=WaveList("*_AVGamp",";","")
			
			If(ItemsinList(S_Lst_AVGamp)>0)
				MAKE/O/N=(ItemsinList(S_Lst_AVGamp)) $"W_dVm_"+S_SRS
					WAVE W_dVm=$"W_dVm_"+S_SRS;SetScale d 0,0,"V",W_dVm
				
				For(i2=0;i2<ItemsInList(S_Lst_AVGamp);i2+=1)
					WAVE W_AVGamp_tmp=$StringFromList(i2,S_Lst_AVGamp)
					W_dVm[i2]=W_AVGamp_tmp[0]	// W_AVGamp_tmp only has one entry...
				Endfor
				
				WaveStats_to_Note(W_dVm)
			Endif
			
			
			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			String S_Lst_Xtms=WaveList("*_Xtms",";","")
			
			If(ItemsinList(S_Lst_Xtms)>0)
				MAKE/O/N=0 $"W_AMP_"+S_SRS,$"W_RST_"+S_SRS,$"W_IEI_"+S_SRS
					WAVE W_AMP=$"W_AMP_"+S_SRS;SetScale d 0,0,S_units,W_Amp
					WAVE W_RST=$"W_RST_"+S_SRS;SetScale d 0,0,"s",W_RsT
					WAVE W_IEI=$"W_IEI_"+S_SRS;SetScale d 0,0,"s",W_IEI
					
				MAKE/O/N=1 $"W_F_"+S_SRS
					WAVE W_F=$"W_F_"+S_SRS;SetScale d 0,0,"Hz",W_F
					
				WAVE W_psdProxy=FMI_matchStrToWaveRef("*_psd",0)
				If(waveexists(W_psdProxy))
					MAKE/O/N=(numpnts(W_psdProxy)) $"W_psd_"+S_SRS
					WAVE W_PSD=$"W_psd_"+S_SRS; FastOP W_PSD=0;CopyScales/P W_psdProxy,W_PSD			
				Endif
				
				
				// LOOP through analysis results (waves) of individual traces within the current series (DF)
				Variable V_Ttot=0,V_cnt=0
				For(i2=0;i2<ItemsInList(S_Lst_Xtms);i2+=1)
					WAVE W_Xtms_tmp=$StringFromList(i2,S_Lst_Xtms)
					
					Variable V_delta=FVCV_ValuefromString(note(W_Xtms_tmp),"w.DimDelta: ")
					Variable V_ANLwin=FVCV_ValuefromString(note(W_Xtms_tmp),"w.ANALYSISwindow: ")
					
					If(numtype(V_delta)==2 || numtype(V_ANLwin)==2)	// ... numtype(2) = NaN
						continue
					Endif
					
					V_Ttot+=V_ANLwin
					V_cnt+=1
					
					WAVE W_IEI_tmp=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_IEI")
					WAVE W_AMP_tmp=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTamp")
					WAVE W_RST_tmp=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_EVTRsT")
					WAVE W_psd_tmp=$ReplaceString("_Xtms",nameofwave(W_Xtms_tmp),"_psd")
					If(waveexists(W_psd_tmp))
						W_psd+=W_psd_tmp
					Endif
					
					
					Variable V_P10=numpnts(W_AMP)
					Variable V_P11=numpnts(W_IEI)
					InsertPoints inf,DimSize(W_Xtms_tmp,0),W_AMP,W_RST
					InsertPoints inf,DimSize(W_Xtms_tmp,0)-1,W_IEI
						W_AMP[V_P10,]=W_AMP_tmp[p-V_P10]
						W_RST[V_P10,]=W_RST_tmp[p-V_P10]
						If(waveexists(W_IEI_tmp))	//... W_IEI_tmp will not be created if only one event present
							W_IEI[V_P11,]=W_IEI_tmp[p-V_P11]
						Endif
	
					Killwaves/Z W_IEI_tmp,W_AMP_tmp,W_RST_tmp,W_psd_tmp
				Endfor
				// LOOP through analysis results (waves) of individual traces within the current series (DF)
				
				If(numpnts(W_AMP)==0)	// ... IN CASE OF NO EVENTS: SKIP NEXT SECTION...
					SetDataFolder CDF
					continue	
				Endif
				
				WaveStats_to_Note(W_AMP)
				WaveStats_to_Note(W_RST)
				WaveStats_to_Note(W_IEI)
				
				W_F[0]=	numpnts(W_AMP)/V_Ttot;WaveStats_To_Note(W_F)
				If(waveexists(W_psd))
					W_psd/=V_cnt
				Endif
				
				// CDFs
				WAVE W_AMPcdfX=FMI_CDFcomp(W_AMP,"AMP",V_mode=V_mode)
				WAVE W_RSTcdfX=FMI_CDFcomp(W_RST,"RST")
				WAVE W_IEIcdfX=FMI_CDFcomp(W_IEI,"IEI")
				
				// HISTOGRAMs
				Variable/G V_binNum,V_binWidth_Amp,V_binWidth_RsT,V_binWidth_IEI
					
				Switch(V_config)
					default:	// EPSP
						V_binNum=V_HST_binNum;V_binWidth_Amp=V_binWidth_Amp_EPSP;V_binWidth_RsT=V_binWidth_RsT_EPSP;V_binWidth_IEI=V_binWidth_IEI_XPSX
						break
						
					case 1:	// EPSC
						V_binNum=V_HST_binNum;V_binWidth_Amp=V_binWidth_Amp_EPSC;V_binWidth_RsT=V_binWidth_RsT_XPSC;V_binWidth_IEI=V_binWidth_IEI_XPSX
						break
						
					case 2:	// IPSC
						V_binNum=V_HST_binNum;V_binWidth_Amp=V_binWidth_Amp_IPSC;V_binWidth_RsT=V_binWidth_RsT_XPSC;V_binWidth_IEI=V_binWidth_IEI_XPSX
						break
				Endswitch
				
				MAKE/O/N=(V_binNum) $"W_AMP_Hist_"+S_SRS,$"W_RST_Hist_"+S_SRS,$"W_IEI_Hist_"+S_SRS
					WAVE W_AMP_Hist=$"W_AMP_Hist_"+S_SRS;FastOP W_AMP_Hist=0;SetScale/P x,0,V_binWidth_Amp,S_units,W_AMP_Hist
					WAVE W_RST_Hist=$"W_RST_Hist_"+S_SRS;FastOP W_RST_Hist=0;SetScale/P x,0,V_binWidth_RsT,"s",W_RST_Hist
					WAVE W_IEI_Hist=$"W_IEI_Hist_"+S_SRS;FastOP W_IEI_Hist=0;SetScale/P x,0,V_binWidth_IEI,"s",W_IEI_Hist
						SetScale d 0,0,"Event number",W_AMP_Hist,W_RST_Hist,W_IEI_Hist
					
					// ... flags: 	/P		Normalizes the histogram as a probability distribution function, and shifts wave scaling so that data correspond to the bin centers.
					Histogram/B={0,V_binWidth_Amp,V_binNum}/P W_AMP,W_AMP_Hist
					Histogram/B={0,V_binWidth_RsT,V_binNum}/P W_RST,W_RST_Hist
					If(waveexists(W_IEI)&&numpnts(W_IEI)>0)
						Histogram/B={0,V_binWidth_IEI,V_binNum}/P W_IEI,W_IEI_Hist
					Else
						Killwaves/Z W_IEI_Hist
					Endif
				
				// ... relative change in F and AMP, i.e. relative and normalized to baseline period 
				If(h==1) // ... happens only if V_BSL==1
					SetDataFolder aDF // --> back to :TRC_analysis_EVT
						WAVE W_F_RSP=$"W_F_"+S_SRS
						WAVE W_AMP_RSP=$"W_AMP_"+S_SRS
						
						MAKE/O/N=1 $"W_dF_"+S_SRS,$"W_dAMP_"+S_SRS
							WAVE W_dF=$"W_dF_"+S_SRS
							WAVE W_dAMP=$"W_dAMP_"+S_SRS;SetScale d 0,0,"change rel. to b.l. (%)",W_dF,W_dAMP
							
						W_dF[0]=((W_F_RSP[0]-W_F[0])*100)/W_F[0]
						W_dAMP[0]=((mean(W_AMP_RSP)-mean(W_AMP))*100)/mean(W_AMP)
						
						WaveStats_to_Note(W_dF)
						WaveStats_to_Note(W_dAMP)
				Endif
					
			Else
				SetDataFolder CDF
				continue	
			Endif
			
			SetDataFolder ::
		Endfor // ...h
		
		SetDataFolder CDF
	Endfor // ... i
	
	// ############################### SETUP EXPERIMENT(=CDF) ANALYSIS ###############################
	String S_EXP=S_YYMMDD+"_"+S_EXPnum
	
	MAKE/O/N=(2,4)/T M_EXPanl_par;WAVE/T M_EXPanl_par
	M_EXPanl_par[][0]={"void_1*","EXP_vdCC_"}
	M_EXPanl_par[][1]={"VCtest_*","EXP_vdVC_"}
	M_EXPanl_par[][2]={"*nosP**","EXP_PnosCC_"}
	M_EXPanl_par[][3]={"*nosC**","EXP_CnosCC_"}
	
	For(i=0;i<DimSize(M_EXPanl_par,1);i+=1)
		String S_srsDFLst=ListMatch(DFList(),M_EXPanl_par[0][i])
		If(ItemsinList(S_srsDFLst)==0)
			continue
			
		Else
			// -------------------------------------------------- CREATE EXP AVERAGE WAVES -------------------------------------------
			NewDataFolder/O/S $M_EXPanl_par[1][i]+S_EXP		
			DFREF eDF=GetDataFolderDFR( )
			
			String S_prmLst=""
					
			Killwaves/Z/A
					
			If(cmpstr(M_EXPanl_par[1][i],"EXP_vdCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
				MAKE/O/N=0 $"W_RST_EPSP_"+S_EXP, $"W_AMP_EPSP_"+S_EXP, $"W_F_EPSP_"+S_EXP,$"W_IEI_EPSP_"+S_EXP
				
				MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_EPSP_"+S_EXP,$"W_RST_HST_EPSP_"+S_EXP,$"W_IEI_HST_EPSP_"+S_EXP
					WAVE W_AMP_HST_EPSP=$"W_AMP_HST_EPSP_"+S_EXP;SetScale/P x,V_binWidth_Amp_EPSP/2,V_binWidth_Amp_EPSP,"V",W_AMP_HST_EPSP;NOTE/K W_AMP_HST_EPSP,"\rw.num: "+num2str(0)
					WAVE W_RST_HST_EPSP=$"W_RST_HST_EPSP_"+S_EXP;SetScale/P x,V_binWidth_RsT_EPSP/2,V_binWidth_RsT_EPSP,"s",W_RST_HST_EPSP;NOTE/K W_RST_HST_EPSP,"\rw.num: "+num2str(0)
					WAVE W_IEI_HST_EPSP=$"W_IEI_HST_EPSP_"+S_EXP;SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_EPSP;NOTE/K W_IEI_HST_EPSP,"\rw.num: "+num2str(0)
				
				If(cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
					MAKE/O/N=0 $"W_dVm_EPSP_"+S_EXP,$"W_dF_EPSP_"+S_EXP,$"W_dAMP_EPSP_"+S_EXP
					
					S_prmLst="RST;AMP;F;IEI;dVm;dF;dAMP"
				
				Else		
					S_prmLst="RST;AMP;F;IEI"
				Endif
						
			Elseif(cmpstr(M_EXPanl_par[1][i],"EXP_vdVC_")==0)
				MAKE/O/N=0 $"W_Rin_EPSC_"+S_EXP,$"W_RST_EPSC_"+S_EXP, $"W_AMP_EPSC_"+S_EXP, $"W_F_EPSC_"+S_EXP,$"W_IEI_EPSC_"+S_EXP,$"W_Rin_EPSC_"+S_EXP						
				MAKE/O/N=0 $"W_Rin_IPSC_"+S_EXP,$"W_RST_IPSC_"+S_EXP, $"W_AMP_IPSC_"+S_EXP, $"W_F_IPSC_"+S_EXP,$"W_IEI_IPSC_"+S_EXP,$"W_Rin_IPSC_"+S_EXP	
						
				MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_EPSC_"+S_EXP,$"W_RST_HST_EPSC_"+S_EXP,$"W_IEI_HST_EPSC_"+S_EXP
					WAVE W_AMP_HST_EPSC=$"W_AMP_HST_EPSC_"+S_EXP;SetScale/P x,V_binWidth_Amp_EPSC/2,V_binWidth_Amp_EPSC,"A",W_AMP_HST_EPSC;NOTE/K W_AMP_HST_EPSC,"\rw.num: "+num2str(0)
					WAVE W_RST_HST_EPSC=$"W_RST_HST_EPSC_"+S_EXP;SetScale/P x,V_binWidth_RsT_XPSC/2,V_binWidth_RsT_XPSC,"s",W_RST_HST_EPSC;NOTE/K W_RST_HST_EPSC,"\rw.num: "+num2str(0)
					WAVE W_IEI_HST_EPSC=$"W_IEI_HST_EPSC_"+S_EXP;SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_EPSC;NOTE/K W_IEI_HST_EPSC,"\rw.num: "+num2str(0)
				
				MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_IPSC_"+S_EXP,$"W_RST_HST_IPSC_"+S_EXP,$"W_IEI_HST_IPSC_"+S_EXP
					WAVE W_AMP_HST_IPSC=$"W_AMP_HST_IPSC_"+S_EXP;SetScale/P x,V_binWidth_Amp_IPSC/2,V_binWidth_Amp_IPSC,"A",W_AMP_HST_IPSC;NOTE/K W_AMP_HST_IPSC,"\rw.num: "+num2str(0)
					WAVE W_RST_HST_IPSC=$"W_RST_HST_IPSC_"+S_EXP;SetScale/P x,V_binWidth_RsT_XPSC/2,V_binWidth_RsT_XPSC,"s",W_RST_HST_IPSC;NOTE/K W_RST_HST_IPSC,"\rw.num: "+num2str(0)
					WAVE W_IEI_HST_IPSC=$"W_IEI_HST_IPSC_"+S_EXP;SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_IPSC;NOTE/K W_IEI_HST_IPSC,"\rw.num: "+num2str(0)
								
				S_prmLst="RST;AMP;F;IEI;Rin"
			Endif
					
			SetDataFolder CDF
					
			// -------------------------------------------------- FILL EXP AVERAGE WAVES -------------------------------------------
			For(i2=0;i2<ItemsInList(S_srsDFLst);i2+=1)	// series DF LOOP
				SetDataFolder $StringFromList(i2, S_srsDFLst)
							
				If(DataFolderExists(":TRC_analysis_EVT")==1)
					SetDataFolder :TRC_analysis_EVT

					SVAR S_type
									
					// ::::::::::::::::::::::::::::::::::::::::: HISTOGRAMS ::::::::::::::::::::::::::::::::::::::::::::::::::::::
					WAVE W_AMP_Hist_tmp=FMI_matchStrToWaveRef("W_AMP_Hist_*",0)
					WAVE W_RST_Hist_tmp=FMI_matchStrToWaveRef("W_RST_Hist_*",0)
					WAVE W_IEI_Hist_tmp=FMI_matchStrToWaveRef("W_IEI_Hist_*",0)
									
					WAVE/SDFR=eDF W_AMP_HST=$"W_AMP_HST_"+S_type+"_"+S_EXP
					WAVE/SDFR=eDF W_RST_HST=$"W_RST_HST_"+S_type+"_"+S_EXP
					WAVE/SDFR=eDF W_IEI_HST=$"W_IEI_HST_"+S_type+"_"+S_EXP
					
					Variable V_count=0
					If(waveexists(W_AMP_Hist_tmp))
						V_count=FVCV_ValuefromString(note(W_AMP_HST),"w.num: ")+1
						W_AMP_HST+=W_AMP_Hist_tmp
						Note/K W_AMP_HST,"\rw.num: "+num2str(V_count)
					Endif
					If(waveexists(W_RST_Hist_tmp))
						V_count=FVCV_ValuefromString(note(W_RST_HST),"w.num: ")+1
						W_RST_HST+=W_RST_Hist_tmp
						Note/K W_RST_HST,"\rw.num: "+num2str(V_count)
					Endif
					If(waveexists(W_IEI_Hist_tmp))
						V_count=FVCV_ValuefromString(note(W_IEI_HST),"w.num: ")+1
						W_IEI_HST+=W_IEI_Hist_tmp
						Note/K W_IEI_HST,"\rw.num: "+num2str(V_count)
					Endif
																		 
					// ::::::::::::::::::::::::::::::::::::::::: 'SINGLE PARAMETERS' ::::::::::::::::::::::::::::::::::::::::::::::::::::::
					For(i3=0;i3<ItemsInList(S_prmLst);i3+=1)
						WAVE/SDFR=eDF W_V=$"W_"+StringfromList(i3,S_prmLst)+"_"+S_type+"_"+S_EXP
										
						If(waveexists(W_V))
							WAVE w3=FMI_matchStrToWaveRef("W_"+StringfromList(i3,S_prmLst)+"_"+S_type+"*",0)
							If(waveexists(w3))
								InsertPoints numpnts(W_V),1,W_V
								If(numpnts(w3)>0)
									WaveStats/Q w3
									W_V[numpnts(W_V)-1]=V_avg
								Else
									W_V[numpnts(W_V)-1]=NaN
								Endif
												
								SetScale d 0,0,WaveUnits(w3,-1),W_V		// redundant in a loop (only necessary once) 
							Endif
						Endif
					Endfor
									
					SetDataFolder CDF
							
				Else
					SetDataFolder CDF
					continue
				Endif
						
				SetDataFolder CDF
			Endfor	// series DF LOOP
			
			SetDataFolder CDF
		Endif	
		
		SetDataFolder eDF
		String S_WvLST_HST=WaveList("*_HST_*",";","")
			
		For(j=0;j<itemsinList(S_WvLST_HST);j+=1)
			WAVE w_HST=$StringfromList(j,S_WvLST_HST)
			
			V_count=FVCV_ValuefromString(note(w_HST),"w.num: ")
				
			w_HST/=V_count
		Endfor
		
		WaveStats_to_Note_all(S_matchStr="!*HST*")					// average of those waves represents grand average (of a given experiment, i.e. cell)
		CleanUp_Waves_empty()
			
		SetDataFolder CDF
		
		If(V_GA==1)
			// ==================================================================================================================
			// ============================================== GRAND AVERAGE =====================================================
			SetDataFolder $S_DFsav
			DFREF rtDF=GetDataFolderDFR( ) // = CDF
			
			Killwaves
			
			String S_WvLST_HST_GA=""
			
			// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// ... WAVE ASSIGNMENT
			// ... EXPERIMENT WAVES - one wave per cell; EACH ENTRY = 1 series
			If(cmpstr(M_EXPanl_par[1][i],"EXP_vdCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
				WAVE/SDFR=eDF W_F=$"W_F_EPSP_"+S_EXP
				WAVE/SDFR=eDF W_AMP=$"W_AMP_EPSP_"+S_EXP	
				WAVE/SDFR=eDF W_RST=$"W_RST_EPSP_"+S_EXP	
				WAVE/SDFR=eDF W_IEI=$"W_IEI_EPSP_"+S_EXP
				
				WAVE/SDFR=eDF W_AMP_HST=$"W_AMP_HST_EPSP_"+S_EXP	
				WAVE/SDFR=eDF W_RST_HST=$"W_RST_HST_EPSP_"+S_EXP	
				WAVE/SDFR=eDF W_IEI_HST=$"W_IEI_HST_EPSP_"+S_EXP
				
				If(cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
					WAVE/SDFR=eDF W_dVm=$"W_dVm_EPSP_"+S_EXP
					WAVE/SDFR=eDF W_dF=$"W_dF_EPSP_"+S_EXP
					WAVE/SDFR=eDF W_dAMP=$"W_dAMP_EPSP_"+S_EXP
				Endif
				
			Elseif(cmpstr(M_EXPanl_par[1][i],"EXP_vdVC_")==0)
				// ... EPSCs
				WAVE/SDFR=eDF W_Rin_EPSC=$"W_Rin_EPSC_"+S_EXP
				WAVE/SDFR=eDF W_F_EPSC=$"W_F_EPSC_"+S_EXP
				WAVE/SDFR=eDF W_AMP_EPSC=$"W_AMP_EPSC_"+S_EXP	
				WAVE/SDFR=eDF W_RST_ESPC=$"W_RST_EPSC_"+S_EXP	
				WAVE/SDFR=eDF W_IEI_EPSC=$"W_IEI_EPSC_"+S_EXP
				
				WAVE/SDFR=eDF W_AMP_HST_EPSC=$"W_AMP_HST_EPSC_"+S_EXP	
				WAVE/SDFR=eDF W_RST_HST_EPSC=$"W_RST_HST_EPSC_"+S_EXP	
				WAVE/SDFR=eDF W_IEI_HST_EPSC=$"W_IEI_HST_EPSC_"+S_EXP
				
				// ... IPSCs
				WAVE/SDFR=eDF W_Rin_IPSC=$"W_Rin_IPSC_"+S_EXP
				WAVE/SDFR=eDF W_F_IPSC=$"W_F_IPSC_"+S_EXP
				WAVE/SDFR=eDF W_AMP_IPSC=$"W_AMP_IPSC_"+S_EXP	
				WAVE/SDFR=eDF W_RST_IPSC=$"W_RST_IPSC_"+S_EXP	
				WAVE/SDFR=eDF W_IEI_IPSC=$"W_IEI_IPSC_"+S_EXP
				
				WAVE/SDFR=eDF W_AMP_HST_IPSC=$"W_AMP_HST_IPSC_"+S_EXP	
				WAVE/SDFR=eDF W_RST_HST_IPSC=$"W_RST_HST_IPSC_"+S_EXP	
				WAVE/SDFR=eDF W_IEI_HST_IPSC=$"W_IEI_HST_IPSC_"+S_EXP
			Endif
			
			// -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// ... WAVE ASSIGNMENT
			// ... GRAND AVERAGE WAVES - one wave per pxp file; EACH ENTRY = 1 cell
			
			
			
			// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ CC ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
			If(cmpstr(M_EXPanl_par[1][i],"EXP_vdCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
				
				If(cmpstr(M_EXPanl_par[1][i],"EXP_vdCC_")==0)
					S_ID=S_baseID+"_vdCC"
				ElseIf(cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0)
					S_ID=S_baseID+"_nosP"
				ElseIf(cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
					S_ID=S_baseID+"_nosC"
				Endif
				
				
				If(cmpstr(M_EXPanl_par[1][i],"EXP_PnosCC_")==0 || cmpstr(M_EXPanl_par[1][i],"EXP_CnosCC_")==0)
					
					// ... 'DC' DEPOLARIZATION, RELATIVE to baseline
					WAVE W_dVm_GA=$"W_dVm_GA"+S_ID
					If(waveexists(W_dVm_GA)==0)
						MAKE/O/N=1 $"W_dVm_GA"+S_ID;WAVE W_dVm_GA=$"W_dVm_GA"+S_ID
					Else
						InsertPoints inf,1,W_dVm_GA
					Endif
						If(waveexists(W_dVm))
							WaveStats/Q W_dVm
							W_dVm_GA[inf]=V_avg
							CopyScales/P W_dVm,W_dVm_GA
						Else
							W_dVm_GA[inf]=NaN
						Endif
				
					// ... (normalized) change in event FREQUENCY, RELATIVE to baseline
					WAVE W_dF_EPSP_GA=$"W_dF_EPSP_GA"+S_ID
					If(waveexists(W_dF_EPSP_GA)==0)
						MAKE/O/N=1 $"W_dF_EPSP_GA"+S_ID;WAVE W_dF_EPSP_GA=$"W_dF_EPSP_GA"+S_ID
					Else
						InsertPoints inf,1,W_dF_EPSP_GA
					Endif
						If(waveexists(W_dF))
							WaveStats/Q W_dF
							W_dF_EPSP_GA[inf]=V_avg
							CopyScales/P W_dF,W_dF_EPSP_GA
						Else
							W_dF_EPSP_GA[inf]=NaN
						Endif
						
					// ... (normalized) change in event AMPLITUDE, RELATIVE to baseline
					WAVE W_dAMP_EPSP_GA=$"W_dAMP_EPSP_GA"+S_ID
					If(waveexists(W_dAMP_EPSP_GA)==0)
						MAKE/O/N=1 $"W_dAMP_EPSP_GA"+S_ID;WAVE W_dAMP_EPSP_GA=$"W_dAMP_EPSP_GA"+S_ID
					Else
						InsertPoints inf,1,W_dAMP_EPSP_GA
					Endif
						If(waveexists(W_dAMP))
							WaveStats/Q W_dAMP
							W_dAMP_EPSP_GA[inf]=V_avg
							CopyScales/P W_dAMP,W_dAMP_EPSP_GA
						Else
							W_dAMP_EPSP_GA[inf]=NaN
						Endif
				Endif
				
				// ... EVENT FREQUENCY
				WAVE W_F_EPSP_GA=$"W_F_EPSP_GA"+S_ID
				If(waveexists(W_F_EPSP_GA)==0)
					MAKE/O/N=1 $"W_F_EPSP_GA"+S_ID;WAVE W_F_EPSP_GA=$"W_F_EPSP_GA"+S_ID
				Else
					InsertPoints inf,1,W_F_EPSP_GA
				Endif
					If(waveexists(W_F))
						WaveStats/Q W_F
						W_F_EPSP_GA[inf]=V_avg
						CopyScales/P W_F,W_F_EPSP_GA
					Else
						W_F_EPSP_GA[inf]=NaN
					Endif
				
				// ... EVENT AMPLITUDE
				WAVE W_AMP_EPSP_GA=$"W_AMP_EPSP_GA"+S_ID
				If(waveexists(W_AMP_EPSP_GA)==0)
					MAKE/O/N=1 $"W_AMP_EPSP_GA"+S_ID;WAVE W_AMP_EPSP_GA=$"W_AMP_EPSP_GA"+S_ID
				Else
					InsertPoints inf,1,W_AMP_EPSP_GA
				Endif
					If(waveexists(W_AMP))
						WaveStats/Q W_AMP
						W_AMP_EPSP_GA[inf]=V_avg
						CopyScales/P W_AMP,W_AMP_EPSP_GA
					Else
						W_AMP_EPSP_GA[inf]=NaN
					Endif
				
				// ... EVENT RISETIME
				WAVE W_RST_EPSP_GA=$"W_RST_EPSP_GA"+S_ID
				If(waveexists(W_RST_EPSP_GA)==0)
					MAKE/O/N=1 $"W_RST_EPSP_GA"+S_ID;WAVE W_RST_EPSP_GA=$"W_RST_EPSP_GA"+S_ID
				Else
					InsertPoints inf,1,W_RST_EPSP_GA
				Endif
					If(waveexists(W_RST))
						WaveStats/Q W_RST
						W_RST_EPSP_GA[inf]=V_avg
						CopyScales/P W_RST,W_RST_EPSP_GA
					Else
						W_RST_EPSP_GA[inf]=NaN
					Endif
				
				// ... INTER-EVENT INTERVAL
				WAVE W_IEI_EPSP_GA=$"W_IEI_EPSP_GA"+S_ID
				If(waveexists(W_IEI_EPSP_GA)==0)
					MAKE/O/N=1 $"W_IEI_EPSP_GA"+S_ID;WAVE W_IEI_EPSP_GA=$"W_IEI_EPSP_GA"+S_ID
				Else
					InsertPoints inf,1,W_IEI_EPSP_GA
				Endif
					If(waveexists(W_IEI))
						WaveStats/Q W_IEI
						W_IEI_EPSP_GA[inf]=V_avg
						CopyScales/P W_IEI,W_IEI_EPSP_GA
					Else
						W_IEI_EPSP_GA[inf]=NaN
					Endif
				
				
				V_count=0
				// ... EVENT AMPLITUDE HISTOGRAM
				WAVE W_AMP_HST_EPSP_GA=$"W_AMP_HST_EPSP_GA"+S_ID
				If(waveexists(W_AMP_HST_EPSP_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_EPSP_GA"+S_ID
						WAVE W_AMP_HST_EPSP_GA=$"W_AMP_HST_EPSP_GA"+S_ID
						SetScale/P x,V_binWidth_Amp_EPSP/2,V_binWidth_Amp_EPSP,"V",W_AMP_HST_EPSP_GA;NOTE/K W_AMP_HST_EPSP_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_AMP_HST))
						V_count=FVCV_ValuefromString(note(W_AMP_HST_EPSP_GA),"w.num: ")+1
						W_AMP_HST_EPSP_GA+=W_AMP_HST
						Note/K W_AMP_HST_EPSP_GA,"\rw.num: "+num2str(V_count)
					Endif
					
				// ... EVENT RISETIME HISTOGRAM
				WAVE W_RST_HST_EPSP_GA=$"W_RST_HST_EPSP_GA"+S_ID
				If(waveexists(W_RST_HST_EPSP_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_RST_HST_EPSP_GA"+S_ID
						WAVE W_RST_HST_EPSP_GA=$"W_RST_HST_EPSP_GA"+S_ID
						SetScale/P x,V_binWidth_RsT_EPSP/2,V_binWidth_RsT_EPSP,"s",W_RST_HST_EPSP_GA;NOTE/K W_RST_HST_EPSP_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_RST_HST))
						V_count=FVCV_ValuefromString(note(W_RST_HST_EPSP_GA),"w.num: ")+1
						W_RST_HST_EPSP_GA+=W_RST_HST
						Note/K W_RST_HST_EPSP_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				// ... INTER-EVENT INTERVAL HISTOGRAM
				WAVE W_IEI_HST_EPSP_GA=$"W_IEI_HST_EPSP_GA"+S_ID
				If(waveexists(W_IEI_HST_EPSP_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_IEI_HST_EPSP_GA"+S_ID
						WAVE W_IEI_HST_EPSP_GA=$"W_IEI_HST_EPSP_GA"+S_ID
						SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_EPSP_GA;NOTE/K W_IEI_HST_EPSP_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_IEI_HST))
						V_count=FVCV_ValuefromString(note(W_IEI_HST_EPSP_GA),"w.num: ")+1
						W_IEI_HST_EPSP_GA+=W_IEI_HST
						Note/K W_IEI_HST_EPSP_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				WaveStats_to_Note(W_F_EPSP_GA)
				WaveStats_to_Note(W_AMP_EPSP_GA)
				WaveStats_to_Note(W_RST_EPSP_GA)
				WaveStats_to_Note(W_IEI_EPSP_GA)
				If(waveexists(W_dVm_GA) && waveexists(W_dF_EPSP_GA) && waveexists(W_dAMP_EPSP_GA))
					WaveStats_to_Note(W_dVm_GA)
					WaveStats_to_Note(W_dF_EPSP_GA)
					WaveStats_to_Note(W_dAMP_EPSP_GA)
				Endif
			
			// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ VC ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
			Elseif(cmpstr(M_EXPanl_par[1][i],"EXP_vdVC_")==0)
				
				// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ EPSCs ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
				// ... INPUT RESISTANCE
				WAVE W_Rin_EPSC_GA=$"W_Rin_EPSC_GA"+S_ID
				If(waveexists(W_Rin_EPSC_GA)==0)
					MAKE/O/N=1 $"W_Rin_EPSC_GA"+S_ID;WAVE W_Rin_EPSC_GA=$"W_Rin_EPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_Rin_EPSC_GA
				Endif
					If(waveexists(W_Rin_EPSC))
						WaveStats/Q W_Rin_EPSC
						W_Rin_EPSC_GA[inf]=V_avg
						CopyScales/P W_Rin_EPSC,W_Rin_EPSC_GA
					Else
						W_Rin_EPSC_GA[inf]=NaN
					Endif
					
				// ... FREQUENCY
				WAVE W_F_EPSC_GA=$"W_F_EPSC_GA"+S_ID
				If(waveexists(W_F_EPSC_GA)==0)
					MAKE/O/N=1 $"W_F_EPSC_GA"+S_ID;WAVE W_F_EPSC_GA=$"W_F_EPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_F_EPSC_GA
				Endif
					If(waveexists(W_F_EPSC))
						WaveStats/Q W_F_EPSC
						W_F_EPSC_GA[inf]=V_avg
						CopyScales/P W_F_EPSC,W_F_EPSC_GA
					Else
						W_F_EPSC_GA[inf]=NaN
					Endif
				
				// ... AMPLITUDE
				WAVE W_AMP_EPSC_GA=$"W_AMP_EPSC_GA"+S_ID
				If(waveexists(W_AMP_EPSC_GA)==0)
					MAKE/O/N=1 $"W_AMP_EPSC_GA"+S_ID;WAVE W_AMP_EPSC_GA=$"W_AMP_EPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_AMP_EPSC_GA
				Endif
					If(waveexists(W_AMP_EPSC))
						WaveStats/Q W_AMP_EPSC
						W_AMP_EPSC_GA[inf]=V_avg
						CopyScales/P W_AMP_EPSC,W_AMP_EPSC_GA
					Else
						W_AMP_EPSC_GA[inf]=NaN
					Endif
				
				// ... RISETIME
				WAVE W_RST_EPSC_GA=$"W_RST_EPSC_GA"+S_ID
				If(waveexists(W_RST_EPSC_GA)==0)
					MAKE/O/N=1 $"W_RST_EPSC_GA"+S_ID;WAVE W_RST_EPSC_GA=$"W_RST_EPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_RST_EPSC_GA
				Endif
					If(waveexists(W_RST_EPSC))
						WaveStats/Q W_RST_EPSC
						W_RST_EPSC_GA[inf]=V_avg
						CopyScales/P W_RST_EPSC,W_RST_EPSC_GA
					Else
						W_RST_EPSC_GA[inf]=NaN
					Endif
				
				// ... INTER-EVENT INTERVAL
				WAVE W_IEI_EPSC_GA=$"W_IEI_EPSC_GA"+S_ID
				If(waveexists(W_IEI_EPSC_GA)==0)
					MAKE/O/N=1 $"W_IEI_EPSC_GA"+S_ID;WAVE W_IEI_EPSC_GA=$"W_IEI_EPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_IEI_EPSC_GA
				Endif
					If(waveexists(W_IEI_EPSC))
						WaveStats/Q W_IEI_EPSC
						W_IEI_EPSC_GA[inf]=V_avg
						CopyScales/P W_IEI_EPSC,W_IEI_EPSC_GA
					Else
						W_IEI_EPSC_GA[inf]=NaN
					Endif
				
				
				V_count=0
				// ... AMPLITUDE HISTOGRAM
				WAVE W_AMP_HST_EPSC_GA=$"W_AMP_HST_EPSC_GA"+S_ID
				If(waveexists(W_AMP_HST_EPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_EPSC_GA"+S_ID
						WAVE W_AMP_HST_EPSC_GA=$"W_AMP_HST_EPSC_GA"+S_ID
						SetScale/P x,V_binWidth_Amp_EPSC/2,V_binWidth_Amp_EPSC,"A",W_AMP_HST_EPSC_GA;NOTE/K W_AMP_HST_EPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_AMP_HST_EPSC))
						V_count=FVCV_ValuefromString(note(W_AMP_HST_EPSC_GA),"w.num: ")+1
						W_AMP_HST_EPSC_GA+=W_AMP_HST_EPSC
						Note/K W_AMP_HST_EPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
					
				// ... RISETIME HISTOGRAM
				WAVE W_RST_HST_EPSC_GA=$"W_RST_HST_EPSC_GA"+S_ID
				If(waveexists(W_RST_HST_EPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_RST_HST_EPSC_GA"+S_ID
						WAVE W_RST_HST_EPSC_GA=$"W_RST_HST_EPSC_GA"+S_ID
						SetScale/P x,V_binWidth_RsT_XPSC/2,V_binWidth_RsT_XPSC,"s",W_RST_HST_EPSC_GA;NOTE/K W_RST_HST_EPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_RST_HST_EPSC))
						V_count=FVCV_ValuefromString(note(W_RST_HST_EPSC_GA),"w.num: ")+1
						W_RST_HST_EPSC_GA+=W_RST_HST_EPSC
						Note/K W_RST_HST_EPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				// ... INTER-EVENT INTERVAL HISTOGRAM
				WAVE W_IEI_HST_EPSC_GA=$"W_IEI_HST_EPSC_GA"+S_ID
				If(waveexists(W_IEI_HST_EPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_IEI_HST_EPSC_GA"+S_ID
						WAVE W_IEI_HST_EPSC_GA=$"W_IEI_HST_EPSC_GA"+S_ID
						SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_EPSC_GA;NOTE/K W_IEI_HST_EPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_IEI_HST_EPSC))
						V_count=FVCV_ValuefromString(note(W_IEI_HST_EPSC_GA),"w.num: ")+1
						W_IEI_HST_EPSC_GA+=W_IEI_HST_EPSC
						Note/K W_IEI_HST_EPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				WaveStats_to_Note(W_Rin_EPSC_GA)
				WaveStats_to_Note(W_F_EPSC_GA)
				WaveStats_to_Note(W_AMP_EPSC_GA)
				WaveStats_to_Note(W_RST_EPSC_GA)
				WaveStats_to_Note(W_IEI_EPSC_GA)
				
				// ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ IPSCs ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
				// ... INPUT RESISTANCE
				WAVE W_Rin_IPSC_GA=$"W_Rin_IPSC_GA"+S_ID
				If(waveexists(W_Rin_IPSC_GA)==0)
					MAKE/O/N=1 $"W_Rin_IPSC_GA"+S_ID;WAVE W_Rin_IPSC_GA=$"W_Rin_IPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_Rin_IPSC_GA
				Endif
					If(waveexists(W_Rin_IPSC))
						WaveStats/Q W_Rin_IPSC
						W_Rin_IPSC_GA[inf]=V_avg
						CopyScales/P W_Rin_IPSC,W_Rin_IPSC_GA
					Else
						W_Rin_IPSC_GA[inf]=NaN
					Endif
					
				// ... FREQUENCY
				WAVE W_F_IPSC_GA=$"W_F_IPSC_GA"+S_ID
				If(waveexists(W_F_IPSC_GA)==0)
					MAKE/O/N=1 $"W_F_IPSC_GA"+S_ID;WAVE W_F_IPSC_GA=$"W_F_IPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_F_IPSC_GA
				Endif
					If(waveexists(W_F_IPSC))
						WaveStats/Q W_F_IPSC
						W_F_IPSC_GA[inf]=V_avg
						CopyScales/P W_F_IPSC,W_F_IPSC_GA
					Else
						W_F_IPSC_GA[inf]=NaN
					Endif
				
				// ... AMPLITUDE
				WAVE W_AMP_IPSC_GA=$"W_AMP_IPSC_GA"+S_ID
				If(waveexists(W_AMP_IPSC_GA)==0)
					MAKE/O/N=1 $"W_AMP_IPSC_GA"+S_ID;WAVE W_AMP_IPSC_GA=$"W_AMP_IPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_AMP_IPSC_GA
				Endif
					If(waveexists(W_AMP_IPSC))
						WaveStats/Q W_AMP_IPSC
						W_AMP_IPSC_GA[inf]=V_avg
						CopyScales/P W_AMP_IPSC,W_AMP_IPSC_GA
					Else
						W_AMP_IPSC_GA[inf]=NaN
					Endif
				
				// ... RISETIME
				WAVE W_RST_IPSC_GA=$"W_RST_IPSC_GA"+S_ID
				If(waveexists(W_RST_IPSC_GA)==0)
					MAKE/O/N=1 $"W_RST_IPSC_GA"+S_ID;WAVE W_RST_IPSC_GA=$"W_RST_IPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_RST_IPSC_GA
				Endif
					If(waveexists(W_RST_IPSC))
						WaveStats/Q W_RST_IPSC
						W_RST_IPSC_GA[inf]=V_avg
						CopyScales/P W_RST_IPSC,W_RST_IPSC_GA
					Else
						W_RST_IPSC_GA[inf]=NaN
					Endif
				
				// ... INTER-EVENT INTERVAL
				WAVE W_IEI_IPSC_GA=$"W_IEI_IPSC_GA"+S_ID
				If(waveexists(W_IEI_IPSC_GA)==0)
					MAKE/O/N=1 $"W_IEI_IPSC_GA"+S_ID;WAVE W_IEI_IPSC_GA=$"W_IEI_IPSC_GA"+S_ID
				Else
					InsertPoints inf,1,W_IEI_IPSC_GA
				Endif
					If(waveexists(W_IEI_IPSC))
						WaveStats/Q W_IEI_IPSC
						W_IEI_IPSC_GA[inf]=V_avg
						CopyScales/P W_IEI_IPSC,W_IEI_IPSC_GA
					Else
						W_IEI_IPSC_GA[inf]=NaN
					Endif
				
				
				V_count=0
				// ... AMPLITUDE HISTOGRAM
				WAVE W_AMP_HST_IPSC_GA=$"W_AMP_HST_IPSC_GA"+S_ID
				If(waveexists(W_AMP_HST_IPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_AMP_HST_IPSC_GA"+S_ID
						WAVE W_AMP_HST_IPSC_GA=$"W_AMP_HST_IPSC_GA"+S_ID
						SetScale/P x,V_binWidth_Amp_IPSC/2,V_binWidth_Amp_IPSC,"A",W_AMP_HST_IPSC_GA;NOTE/K W_AMP_HST_IPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_AMP_HST_IPSC))
						V_count=FVCV_ValuefromString(note(W_AMP_HST_IPSC_GA),"w.num: ")+1
						W_AMP_HST_IPSC_GA+=W_AMP_HST_IPSC
						Note/K W_AMP_HST_IPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
					
				// ... RISETIME HISTOGRAM
				WAVE W_RST_HST_IPSC_GA=$"W_RST_HST_IPSC_GA"+S_ID
				If(waveexists(W_RST_HST_IPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_RST_HST_IPSC_GA"+S_ID
						WAVE W_RST_HST_IPSC_GA=$"W_RST_HST_IPSC_GA"+S_ID
						SetScale/P x,V_binWidth_RsT_XPSC/2,V_binWidth_RsT_XPSC,"s",W_RST_HST_IPSC_GA;NOTE/K W_RST_HST_IPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_RST_HST_IPSC))
						V_count=FVCV_ValuefromString(note(W_RST_HST_IPSC_GA),"w.num: ")+1
						W_RST_HST_IPSC_GA+=W_RST_HST_IPSC
						Note/K W_RST_HST_IPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				// ... INTER-EVENT INTERVAL HISTOGRAM
				WAVE W_IEI_HST_IPSC_GA=$"W_IEI_HST_IPSC_GA"+S_ID
				If(waveexists(W_IEI_HST_IPSC_GA)==0)
					MAKE/O/N=(V_HST_binNum) $"W_IEI_HST_IPSC_GA"+S_ID
						WAVE W_IEI_HST_IPSC_GA=$"W_IEI_HST_IPSC_GA"+S_ID
						SetScale/P x,V_binWidth_IEI_XPSX/2,V_binWidth_IEI_XPSX,"s",W_IEI_HST_IPSC_GA;NOTE/K W_IEI_HST_IPSC_GA,"\rw.num: "+num2str(0)
				Endif
					If(waveexists(W_IEI_HST_IPSC))
						V_count=FVCV_ValuefromString(note(W_IEI_HST_IPSC_GA),"w.num: ")+1
						W_IEI_HST_IPSC_GA+=W_IEI_HST_IPSC
						Note/K W_IEI_HST_IPSC_GA,"\rw.num: "+num2str(V_count)
					Endif
				
				WaveStats_to_Note(W_Rin_IPSC_GA)
				WaveStats_to_Note(W_F_IPSC_GA)
				WaveStats_to_Note(W_AMP_IPSC_GA)
				WaveStats_to_Note(W_RST_IPSC_GA)
				WaveStats_to_Note(W_IEI_IPSC_GA)
			Endif
			
			SetDataFolder CDF
		Endif // (V_GA)
	
	Endfor	// ANALYSIS TYPE LOOP, i.e. COLUMNS of M_EXPanl_par
	
	Killwaves/Z M_EXPanl_par	
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_SPK_analysis_seg()
	Variable i,i2,i3
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_DFLst=ListMatch(DFList(),"*dp*")
	
	If(ItemsinList(S_DFLst)==0)
		return -1
	Endif
	
	For(i=0;i<ItemsInList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
		DFREF sDF=GetDataFolderDFR( )
		
		If(DataFolderExists(":SRS_analysis_SPK")==1)
			SetDataFolder :SRS_analysis_SPK 
				Killwaves/Z/A
			SetDataFolder sDF
		Endif
		
		If(DataFolderExists(":TRC_analysis_SPK")==1)
			SetDataFolder :TRC_analysis_SPK 
				Killwaves/Z/A
			SetDataFolder sDF
		Endif
			
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: SEGEMENTATION :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		If(StringMatch(GetDataFolder(0),"CC_*"))
			FMI_WvSegmentation(V_BL=0.1,V_intvl=0.5,S_RegEXP="CCstep_([[:digit:]]+)xhp([[:digit:]]+)ms_([[:digit:]]+)pA_([[:digit:]]+)xdp([[:digit:]]+)ms_([[:digit:]]+)pA",V_subPtNum=6)
		ElseIf(StringMatch(GetDataFolder(0),"hp*"))
			FMI_WvSegmentation(V_BL=0.5,V_intvl=0.5,S_RegEXP="hp([[:digit:]]+)ms_([[:digit:]]+)pA_dp([[:digit:]]+)ms_([[:digit:]]+)pA",V_subPtNum=4)
		Endif
			
		// .......................................................... DESIGNED to work on segmented data only ...............................................
		NVAR V_seg_bl,V_seg_hp,V_seg_dp
		If(NVAR_Exists(V_seg_dp)==0)							
			continue
		Endif
			
		Variable V_segOffset=0; String S_ignore=""
		String S_grpID_BL="",S_grpID_hp=""
		If(NVAR_Exists(V_seg_bl)==1)							
			V_segOffset+=V_seg_bl
			S_grpID_BL="_s"+num2str(V_segOffset-1)+"_"		// in case there would be >1 BL segments, only the last one would be included
		Endif
		If(NVAR_Exists(V_seg_hp)==1)							
			V_segOffset+=V_seg_hp
			S_grpID_hp="_s"+num2str(V_segOffset-1)+"_"		// in case there would be >1 hp segments, only the last one would be included
		Endif
			
		For(i2=0;i2<V_segOffset;i2+=1)
			S_ignore+="_s"+num2str(i2)+"_"
			If(i2<V_segOffset-1)
				S_ignore+="|"
			Endif
		Endfor
			
		// ########################### SERIES INFORMATION (rep#) ###############################
		String S_RPT,S_tmp
		SplitString /E=("(_n.*)") StringfromList(i,S_DFLst),S_tmp
		S_tmp=ReplaceString("_n",S_tmp,"") 
		sscanf S_tmp, "%s",S_RPT
		Variable/G V_RPT=str2num(S_RPT)
			
		// ############################### PREPARATION - SEGMENT INFO ###############################
		String S_Lst_seg=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")	// ALL TRACES (segments)
					
		String S_Lst_trc=RemoveFromList(GrepList(WaveList("*_tr*",";",""),"("+S_ignore+")"),S_Lst_seg)	// RELEVANT TRACES (segments) 
		If(ItemsInList(S_Lst_trc)==0)
			SetDataFolder CDF
			continue
		Endif
			
		String S_Lst_trc_BL=GrepList(WaveList("*_tr*",";",""),"("+S_grpID_BL+")")
		String S_Lst_trc_hp=GrepList(WaveList("*_tr*",";",""),"("+S_grpID_hp+")")
		
		
		// ---------------------------------------------------- extract stimulus amplitudes used in SRS ------------------------------------------------- 
		MAKE/O/N=0 W_stimAMP,W_stimLNG,W_stimRNG,W_stimOFF,W_stimNUM
		WAVE W_stimAMP
		WAVE W_stimLNG
		WAVE W_stimRNG
		WAVE W_stimOFF
		WAVE W_stimNUM
			
		Variable V_amp,V_lng,V_rng,V_off,V_num
		For(i2=0;i2<ItemsInList(S_Lst_trc);i2+=1)
			WAVE w=$StringFromList(i2,S_Lst_trc)
				
			V_amp=FVCV_ValuefromString(note(w),"segment.amp: ")
			V_lng=FVCV_ValuefromString(note(w),"segment.length: ")
			V_rng=FVCV_ValuefromString(note(w),"segment.range: ")
			V_off=FVCV_ValuefromString(note(w),"segment.offset: ")
			V_num=FVCV_ValuefromString(nameofwave(w),FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_s")
			
			If(numtype(V_amp)==2)
				continue
			Endif
			
			FindValue/V=(V_amp)/Z W_stimAMP
			If(V_Value==-1) // Value not found
				InsertPoints numpnts(W_stimAMP),1,W_stimAMP,W_stimLNG,W_stimRNG,W_stimOFF,W_stimNUM
				W_stimAMP[numpnts(W_stimAMP)-1]=V_amp
				W_stimLNG[numpnts(W_stimRNG)-1]=V_lng
				W_stimRNG[numpnts(W_stimLNG)-1]=V_rng
				W_stimOFF[numpnts(W_stimOFF)-1]=V_off
				W_stimNUM[numpnts(W_stimNUM)-1]=V_num
			Endif
		Endfor
			
		// CONSISTENCY CHECK
		If(numpnts(W_stimAMP)!=V_seg_dp)
			Print "\t"+GetDataFolder(0)+": MISMATCH between EXPECTED SEGMENT number and DETECTED SEGMENT number - series skipped" 
			SetDataFolder CDF
			continue
		Endif
						
		// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: EXP STRING (identifier) :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		WAVE w=$StringFromList(0,S_Lst_trc)			
		String S_YYMMDD=ReplaceString("E_",(FMI_StringfromString(note(w),"pFolder2: ")),"")
		If(strlen(S_YYMMDD)!=6)	// YYMMDD
			S_YYMMDD="YYMMDD"
		Endif
		String S_EXPnum=FMI_StringfromString(note(w),"Field1: ")
			
		String S_shID=S_YYMMDD+"_"+S_EXPnum+"_"+"n"+num2str(i)
			
		// ############################### ANALYSIS - INDIVIDUAL WAVES ###############################			
		For(i2=0;i2<ItemsInList(S_Lst_trc);i2+=1)
			WAVE w=$StringFromList(i2,S_Lst_trc)
			
			FMI_SpikeDTCT(w=w)
		Endfor
	
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: BASELINE Vm ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		For(i2=0;i2<ItemsInList(S_Lst_trc_BL);i2+=1)
			WAVE w0=$StringFromList(i2,S_Lst_trc_BL)
				
			If(DataFolderExists(":SRS_analysis_SPK")==0)
				NewDataFolder/O/S :SRS_analysis_SPK
			Else
				SetDataFolder :SRS_analysis_SPK
			Endif
				
			If(i2==0)
				String S_Note_BL="\r 1st order ANALYSIS - SERIES (segmented data) - ENTRIES are individual repetitions (loop)"
				S_Note_BL+="\r\tsegment.DF: "+StringfromList(i,S_DFLst)
				S_Note_BL+="\r\tsegment.length: "+FMI_StringfromString(note(w0),"segment.length: ")
				S_Note_BL+="\r\tsegment.range: "+FMI_StringfromString(note(w0),"segment.range: ")
				S_Note_BL+="\r\tsegment.offset: "+FMI_StringfromString(note(w0),"segment.offset: ")
						
				MAKE/O/N=(ItemsinList(S_Lst_trc_BL)) $"W_BL_"+S_shID
				WAVE W_BL=$"W_BL_"+S_shID;Note/K/NOCR W_BL, S_Note_BL
				SetScale d 0,0,WaveUnits(w0,-1),W_BL
			Endif
					
			WaveStats/Q w0
			W_BL[i2]=V_avg
				
			SetDataFolder ::
		Endfor
			
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: INPUT RESISTANCE ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		For(i2=0;i2<ItemsInList(S_Lst_trc_hp);i2+=1)
			WAVE w1=$StringFromList(i2,S_Lst_trc_hp)
				
			If(DataFolderExists(":SRS_analysis_SPK")==0)
				NewDataFolder/O/S :SRS_analysis_SPK
			Else
				SetDataFolder :SRS_analysis_SPK
			Endif
				
			If(i2==0)
				String S_Note_hp="\r 1st order ANALYSIS - SERIES (segmented data) - ENTRIES are individual repetitions (loop)"
				S_Note_hp+="\r\tsegment.DF: "+StringfromList(i,S_DFLst)
				S_Note_hp+="\r\tsegment.length: "+FMI_StringfromString(note(w1),"segment.length: ")
				S_Note_hp+="\r\tsegment.range: "+FMI_StringfromString(note(w1),"segment.range: ")
				S_Note_hp+="\r\tsegment.offset: "+FMI_StringfromString(note(w1),"segment.offset: ")
						
				MAKE/O/N=(ItemsinList(S_Lst_trc_hp)) $"W_ccRin_"+S_shID
				WAVE W_ccRin=$"W_ccRin_"+S_shID;Note/K/NOCR W_ccRin, S_Note_hp
				SetScale d 0,0,"Ohm",W_ccRin
			Endif
					
			V_amp=FVCV_ValuefromString(note(w1),"segment.amp: ")
			V_lng=FVCV_ValuefromString(note(w1),"segment.length: ")
			V_rng=FVCV_ValuefromString(note(w1),"segment.range: ")
			V_off=FVCV_ValuefromString(note(w1),"segment.offset: ")
					
			W_ccRin[i2]=FMI_Rin(w=w1,V_mode=0,V_amp=V_amp,V_BLstart=V_off+(V_lng*0.8),V_BLend=V_off+V_lng,V_RSPstart=V_off+(V_rng*0.8),V_RSPend=V_off+V_rng)
				
			SetDataFolder ::
		Endfor
			
		If(DataFolderExists(":TRC_analysis_SPK")!=1)	// problems with FMI_SpikeDTCT - which creates the folder TRC_analysis_SPK 
			SetDataFolder CDF
			continue
		Else
			SetDataFolder :TRC_analysis_SPK
		Endif
			
		// ############################### ANALYSIS - SERIES SUMMARY - FIRING RATE ###############################
		// ############################### ANALYSIS - SERIES SUMMARY - (first) AP parameters ###############################
		For(i2=0;i2<V_seg_dp;i2+=1)	// W_Lvls LOOP 
			Make/O/N=(V_seg_dp) W_spiking
			WAVE W_spiking
				
			String S_SRS=S_YYMMDD+"_"+S_EXPnum+"_"+num2str(W_stimAMP[i2])+"pA_"+"n"+S_RPT
				
			String S_Note_seg="\r 1st order ANALYSIS - SERIES (segmented data) - ENTRIES are individual repetitions (loop)"
			S_Note_seg+="\r\tsegment.DF: "+StringfromList(i,S_DFLst)
			S_Note_seg+="\r\tsegment.SRS: "+S_SRS
			S_Note_seg+="\r\tsegment.num: "+num2str(i2+1)
			S_Note_seg+="\r\tsegment.ID: s"+num2str(W_stimNUM[i2])
			S_Note_seg+="\r\tsegment.amp: "+num2str(W_stimAMP[i2])
			S_Note_seg+="\r\tsegment.length: "+num2str(W_stimLNG[i2])
			S_Note_seg+="\r\tsegment.range: "+num2str(W_stimRNG[i2])
			S_Note_seg+="\r\tsegment.offset: "+num2str(W_stimOFF[i2])
			S_Note_seg+="\r\tsegment.rep: "+S_RPT
				
			String S_Lst_lvls=GrepList(WaveList("*_s"+num2str(W_stimNUM[i2])+"_tr*",";",""),"(Lvls$)")
			If(ItemsInList(S_Lst_lvls)==0)
				W_spiking[i2]=0
						
				// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: MEMBRANE time constant ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
				SetDataFolder sDF
				String S_Lst_trc_dp=GrepList(WaveList("*_s"+num2str(W_stimNUM[i2])+"_tr*",";",""),"(tr1$|tr2$)")	// ALL TRACES (segments)
						
				NewDataFolder/O/S :SRS_analysis_SPK
				MAKE/O/N=(ItemsinList(S_Lst_trc_dp)) $"W_mTC_"+S_SRS
				WAVE W_mTC=$"W_mTC_"+S_SRS;Note/K/NOCR W_mTC, S_Note_seg
				SetScale d 0,0,"s",W_mTC
								
				SetDataFolder sDF
									
				For(i3=0;i3<ItemsInList(S_Lst_trc_dp);i3+=1)
					// ... membrane time constant
					WAVE w2=$StringFromList(i3,S_Lst_trc_dp)
								
					If(waveexists(w2))
						W_mTC[i3]=FMI_mTC(w=w2,V_start=W_stimOFF[i2],V_end=W_stimOFF[i2]+W_stimRNG[i2],V_killWVs=1)
					Endif
				Endfor
						
				SetDataFolder :TRC_analysis_SPK
				continue		// if spiking seen in none of the segments (always jumped to next iteration of W_Lvls LOOP)
			Else
				W_spiking[i2]=1
			Endif
				
			NewDataFolder/O/S ::SRS_analysis_SPK					
				MAKE/O/N=(ItemsinList(S_Lst_lvls)) $"W_rate_"+S_SRS, $"W_APup_"+S_SRS, $"W_APdn_"+S_SRS,$"W_APthr_"+S_SRS,$"W_FSL_"+S_SRS
					WAVE W_rate=$"W_rate_"+S_SRS;Note/K/NOCR W_rate, S_Note_seg
						SetScale d 0,0,"Hz",W_rate
					WAVE W_APup=$"W_APup_"+S_SRS;Note/K/NOCR W_APup, S_Note_seg
					WAVE W_APdn=$"W_APdn_"+S_SRS;Note/K/NOCR W_APdn, S_Note_seg
						SetScale d 0,0,"V/s",W_APup,W_APdn
					WAVE W_APthr=$"W_APthr_"+S_SRS;Note/K/NOCR W_APthr, S_Note_seg
					WAVE W_FSL=$"W_FSL_"+S_SRS;Note/K/NOCR W_FSL, S_Note_seg
				
				MAKE/O/N=(ItemsinList(S_Lst_lvls)) $"W_APht_"+S_SRS, $"W_APrs_"+S_SRS,$"W_APpk_"+S_SRS,$"W_APwd_"+S_SRS,$"W_APahp_"+S_SRS
					WAVE W_APht=$"W_APht_"+S_SRS;Note/K/NOCR W_APht, S_Note_seg
					WAVE W_APrs=$"W_APrs_"+S_SRS;Note/K/NOCR W_APrs, S_Note_seg
					WAVE W_APpk=$"W_APpk_"+S_SRS;Note/K/NOCR W_APpk, S_Note_seg
					WAVE W_APwd=$"W_APwd_"+S_SRS;Note/K/NOCR W_APwd, S_Note_seg
					WAVE W_APahp=$"W_APahp_"+S_SRS;Note/K/NOCR W_APahp, S_Note_seg
					SetScale d 0,0,"V",W_APthr,W_APht,W_APpk,W_APahp
					SetScale d 0,0,"s",W_FSL,W_APrs,W_APwd
			SetDataFolder ::TRC_analysis_SPK
					
			For(i3=0;i3<ItemsInList(S_Lst_lvls);i3+=1)
				// ... firing rate
				WAVE w2=$StringFromList(i3,S_Lst_lvls)
				If(waveexists(w2))
					Wavestats/Q w2
					W_rate[i3]=V_npnts/(FVCV_ValuefromString(note(W_rate),"segment.range: "))		// [Hz]
				Endif
						
				// ... AP up-/downstroke
				WAVE w2_1=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"UPst")
				WAVE w2_2=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"DNst")
				If(waveexists(w2_1)&&waveexists(w2_2))
					W_APup[i3]=w2_1[0]		// only FIRST AP evaluated
					W_APdn[i3]=w2_2[0]		// only FIRST AP evaluated
				Endif
						
				// single AP threshold (5* SDEV of DIF_DIF) and timing of its crossing (w2=W_xxxxxx_Lvls)
				WAVE w2_3=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"thr")
				WAVE w2_4=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"tAP")
				If(waveexists(w2_3)&&waveexists(w2_4))
					W_APthr[i3]=w2_3[0]		// only FIRST AP evaluated
					W_FSL[i3]=w2_4[0]-FVCV_ValuefromString(note(W_rate),"segment.offset: ")
				Endif
						
				// single AP height (A(peak)-A(threshold)) and rise time (t(peak)-t(threshold))
				WAVE w2_5=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"APht")
				WAVE w2_6=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"APrs")
				If(waveexists(w2_5)&&waveexists(w2_6))
					W_APht[i3]=w2_5[0]		// only FIRST AP evaluated
					W_APrs[i3]=w2_6[0]		// only FIRST AP evaluated
				Endif
						
				// single AP PEAK VALUE (The peak value is simply the greater of the two unsmoothed values surrounding the peak center) and WIDTH (The peak edges are found where the second derivative of the smoothed result crosses zero)
				WAVE w2_7=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"PkVl")
				WAVE w2_8=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"PkWd")
				If(waveexists(w2_7)&&waveexists(w2_8))
					W_APpk[i3]=w2_7[0]		// only FIRST AP evaluated
					W_APwd[i3]=w2_8[0]		// only FIRST AP evaluated
				Endif
				
				// single AP after-hyperpolarization
				WAVE w2_9=$ReplaceString("Lvls",StringFromList(i3,S_Lst_lvls),"APahp")
				If(waveexists(w2_9))
					W_APahp[i3]=w2_9[0]		
				Endif
			Endfor	// W_Lvls LOOP 
					
			// ############################### ANALYSIS - SERIES SUMMARY - AP ACCOMODATION / VARIABILITY ###############################
			String S_Lst_ISI=GrepList(WaveList("*_s"+num2str(W_stimNUM[i2])+"_tr*",";",""),"(ISI$)")
			If(ItemsinList(S_Lst_ISI)>0)
				NewDataFolder/O/S ::SRS_analysis_SPK
				MAKE/O/N=(ItemsinList(S_Lst_ISI)) $"W_acc1_"+S_SRS,$"W_var1_"+S_SRS
				WAVE W_acc1=$"W_acc1_"+S_SRS;Note/K/NOCR W_acc1, S_Note_seg
				SetScale d 0,0,"AP accomodation (last ISI / first ISI)",W_acc1
				WAVE W_var1=$"W_var1_"+S_SRS;Note/K/NOCR W_var1, S_Note_seg
				SetScale d 0,0,"CV (ISI)",W_var1
				SetDataFolder ::TRC_analysis_SPK			
			Endif
						
			For(i3=0;i3<ItemsInList(S_Lst_ISI);i3+=1)	// W_ISI LOOP
				WAVE w3=$StringFromList(i3,S_Lst_ISI)
				If(waveexists(w3))
					// ... acommodation
					If(numpnts(w3)>=2)	// at least 3 APs
						W_acc1[i3]=w3[numpnts(w3)-1]/w3[0]	// AP accommodation is calculated as the ratio ‘‘interval between last 2 APs’’/‘‘interval between first 2 APs"
					Else
						W_acc1[i3]=NaN
					Endif
							
					// ... variability
					If(numpnts(w3)>=4)	// at least 5 APs
						Wavestats/Q w3
						W_var1[i3]=V_sdev/V_avg				// Variability in AP firing during a current step is quantified as coefficient of variation (CV) of the intervals between successive APs.
					Else
						W_var1[i3]=NaN
					Endif
				Endif
						
				// CLEANING 'EMPTY' (i.e. containing only NaNs) ISI-based ANALYSIS WAVES
				WaveStats/Q W_acc1
				If(V_npnts==0)
					Killwaves/Z W_acc1 
				Endif
							
				WaveStats/Q W_var1
				If(V_npnts==0)
					Killwaves/Z W_var1 
				Endif
						
			Endfor	// W_ISI LOOP
				
		Endfor	// segment-ID LOOP 
			
		// -------------------------------------------------------------- MOVE SEGMENT PARAMETER WAVES -------------------------------------------------- 
		If(DataFolderExists("::SRS_analysis_SPK"))
			SetDataFolder ::SRS_analysis_SPK	
			WaveStats_to_Note_all(V_add=1)
			Duplicate/O W_stimAMP,:W_stimAMP
			Duplicate/O W_stimLNG,:W_stimLNG
			Duplicate/O W_stimRNG,:W_stimRNG
			Duplicate/O W_stimOFF,:W_stimOFF
			Duplicate/O W_stimNUM,:W_stimNUM
			Duplicate/O W_spiking,:W_spiking
			Killwaves/Z W_stimAMP,W_stimLNG,W_stimRNG,W_stimOFF,W_stimNUM,W_spiking
			
			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			// ... (average) 1st AP time trace @ 'rheobase' in that series (not real rheobase of cell, yet...!!) 
			WAVE W_spiking,W_stimNUM,W_stimAMP
			Variable j,k
			Variable V_avgAPduration=30e-3	// [s]
			For(j=0;j<numpnts(W_spiking);j+=1)
				If(W_spiking[j]>0)
					String S_ID=S_YYMMDD+"_"+S_EXPnum+"_"+num2str(W_stimAMP[j])+"pA_"+"n"+S_RPT
					
					SetDataFolder ::TRC_analysis_SPK
						DFREF trcaDF=GetDataFolderDFR( )
						
						String S_WvLst_APs=WaveList("*_s"+num2str(W_stimNUM[j])+"_*AP_AVG",";","")
					SetDataFolder ::SRS_analysis_SPK
				
					For(k=0;k<ItemsInList(S_WvLst_APs);k+=1)
						WAVE/SDFR=trcaDF W_AP=$StringFromList(k,S_WvLst_APs)
						
						If(k==0)
							MAKE/O/N=(V_avgAPduration/DimDelta(W_AP,0),ItemsInList(S_WvLst_APs)) $"M_fAP_"+S_ID=NaN
								WAVE M_fAP=$"M_fAP_"+S_ID;CopyScales/P W_AP,M_fAP
						Endif		
						
						M_fAP[][k]=W_AP[p]
					Endfor
					
					If(DimSize(M_fAP,1)>1)
						WAVE W_fAP_AVG=MatrixStats(M_fAP)
						WAVE W_fAP_SD=$ReplaceString("AVG",Nameofwave(W_fAP_AVG),"SD")
						WAVE W_fAP_SEM=$ReplaceString("AVG",Nameofwave(W_fAP_AVG),"SEM")
					Else
						Duplicate/O/R=(,)(0,0) M_fAP,$ReplaceString("M_",Nameofwave(M_fAP),"W_")+"_AVG";WAVE W_fAP_AVG=$ReplaceString("M_",Nameofwave(M_fAP),"W_")+"_AVG"
						Redimension/N=(DimSize(M_fAP,0)) W_fAP_AVG
					Endif
					
					Note/K W_fAP_AVG,"\rn="+num2str(ItemsInList(S_WvLst_APs))+" first spike(s) averaged"
					
					Killwaves/Z M_fAP,W_fAP_SD,W_fAP_SEM
				Endif
			Endfor
			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		Else
			SetDataFolder sDF
			Duplicate/O W_spiking,:W_spiking
			Killwaves/Z W_spiking
		Endif		
		
		SetDataFolder sDF
		FMI_slimDF(V_grade=0)
		FMI_WVsegmentation_undo()
			
		SetDataFolder CDF	
	Endfor // SRS LOOP
	
	
	// ############################### SETUP EXPERIMENT(=CDF) ANALYSIS ###############################
	String S_EXP=S_YYMMDD+"_"+S_EXPnum
	
	MAKE/O/N=(2,2)/T M_EXPanl_par;WAVE/T M_EXPanl_par
	M_EXPanl_par[][0]={"CC_*","EXP_msCI_"}
	M_EXPanl_par[][1]={"hp*","EXP_ssCI_"}
	
	For(i=0;i<DimSize(M_EXPanl_par,1);i+=1)
		String S_srsDFLst=ListMatch(DFList(),M_EXPanl_par[0][i])
		If(ItemsinList(S_srsDFLst)==0)
			continue
			
		Else
			// -------------------------------------------------- CREATE EXP AVERAGE WAVES -------------------------------------------
			NewDataFolder/O/S $M_EXPanl_par[1][i]+S_EXP		
			DFREF eDF=GetDataFolderDFR( )
					
			Killwaves/Z/A
					
			// BL Vm
			MAKE/O/N=0 $"W_BL_V_"+S_EXP
			WAVE W_BL_V=$"W_BL_V_"+S_EXP
					
			// Rin
			MAKE/O/N=0 $"W_ccRin_V_"+S_EXP
			WAVE W_ccRin_V=$"W_ccRin_V_"+S_EXP
					
			// membrane time constant
			MAKE/O/N=0 $"W_mTC_V_"+S_EXP
			WAVE W_mTC_V=$"W_mTC_V_"+S_EXP
					
			// FIRING RATE	
			MAKE/O/N=0 $"W_IF_V_"+S_EXP,$"W_IF_I_"+S_EXP,$"W_IF_N_"+S_EXP
			MAKE/O/N=0/T $"W_IF_T_"+S_EXP
			WAVE W_IF_F=$"W_IF_V_"+S_EXP
			WAVE W_IF_I=$"W_IF_I_"+S_EXP
			WAVE W_IF_N=$"W_IF_N_"+S_EXP
			WAVE/T W_IF_T=$"W_IF_T_"+S_EXP
						
			// AP ACCOMODATION / VARIABILITY
			MAKE/O/N=0 $"W_AC_V_"+S_EXP,$"W_AC_I_"+S_EXP,$"W_AC_N_"+S_EXP
			WAVE W_AC_V=$"W_AC_V_"+S_EXP
			WAVE W_AC_I=$"W_AC_I_"+S_EXP
			WAVE W_AC_N=$"W_AC_N_"+S_EXP
			MAKE/O/N=0 $"W_VR_V_"+S_EXP,$"W_VR_I_"+S_EXP,$"W_VR_N_"+S_EXP
			WAVE W_VR_V=$"W_VR_V_"+S_EXP
			WAVE W_VR_I=$"W_VR_I_"+S_EXP
			WAVE W_VR_N=$"W_VR_N_"+S_EXP
				
			SetDataFolder CDF
					
			// -------------------------------------------------- FILL EXP AVERAGE WAVES -------------------------------------------
			For(i2=0;i2<ItemsInList(S_srsDFLst);i2+=1)	// series DF LOOP
				SetDataFolder $StringFromList(i2, S_srsDFLst)
							
				If(DataFolderExists(":SRS_analysis_SPK")==1)
					SetDataFolder :SRS_analysis_SPK
									
					WAVE W_spiking,W_stimAMP	// any of the two required waves not found in the SRS_analysis_SPK folder 
					If(waveexists(W_spiking)==0||waveexists(W_stimAMP)==0)
						SetDataFolder CDF
						continue
					Endif
									
					// BL Vm
					WAVE W_BL=FMI_matchStrToWaveRef("W_BL_*",0)
					If(waveexists(W_BL))
						InsertPoints numpnts(W_BL_V),1,W_BL_V
						WaveStats/Q W_BL
						W_BL_V[numpnts(W_BL_V)-1]=V_avg
											
						SetScale d 0,0,WaveUnits(W_BL,-1),W_BL_V			// redundant in a loop (only necessary once) 
											
					Endif
									
					// Input resistance
					WAVE W_ccRin=FMI_matchStrToWaveRef("W_ccRin_*",0)
					If(waveexists(W_ccRin))
						InsertPoints numpnts(W_ccRin_V),1,W_ccRin_V
						WaveStats/Q W_ccRin
						W_ccRin_V[numpnts(W_ccRin_V)-1]=V_avg
											
						SetScale d 0,0,WaveUnits(W_ccRin,-1),W_ccRin_V		// redundant in a loop (only necessary once) 
					Endif
									
					// membrane time constant
					WAVE W_mTC=FMI_matchStrToWaveRef("W_mTC_*",0,V_entry=-1)
					If(waveexists(W_mTC))
						InsertPoints numpnts(W_mTC_V),1,W_mTC_V
						WaveStats/Q W_mTC
						W_mTC_V[numpnts(W_mTC_V)-1]=V_avg
											
						SetScale d 0,0,WaveUnits(W_mTC,-1),W_mTC_V		// redundant in a loop (only necessary once) 
											
						// ... documentation
						String S_note_mTC_V=note(W_mTC_V)
						S_note_mTC_V+="\rENTRY: (average of) wave: "+nameofwave(W_mTC)
						NOTE/K/NOCR W_mTC_V,S_note_mTC_V
					Endif
									
					For(i3=0;i3<numpnts(W_spiking);i3+=1)
						If(W_spiking[i3]==0)			// no spiking at the defined stimulus amplitude (W_stimAMP[i3])
							continue
						Else
							// FIRING RATE
							FMI_EXP_SMMsub(W_IF_F,W_IF_I,W_IF_N,W_stimAMP[i3],"rate",S_ID2=num2str(W_stimAMP[i3])+"pA",W_T=W_IF_T)
											
							// AP ACCOMODATION / VARIABILITY
							FMI_EXP_SMMsub(W_AC_V,W_AC_I,W_AC_N,W_stimAMP[i3],"acc1",S_ID2=num2str(W_stimAMP[i3])+"pA")
							FMI_EXP_SMMsub(W_VR_V,W_VR_I,W_VR_N,W_stimAMP[i3],"var1",S_ID2=num2str(W_stimAMP[i3])+"pA")
						Endif
					Endfor
									
				Else
					SetDataFolder CDF
					continue
				Endif
						
				SetDataFolder CDF
			Endfor	// series DF LOOP
					
			WaveStats_to_Note(W_BL_V,V_add=1)			// average of this wave represents grand average (of a given experiment, i.e. cell)
			WaveStats_to_Note(W_ccRin_V,V_add=1)		// average of this wave represents grand average (of a given experiment, i.e. cell)
			WaveStats_to_Note(W_mTC_V,V_add=1)		// average of this wave represents grand average (of a given experiment, i.e. cell)
					
			Sort W_IF_I,W_IF_F,W_IF_I,W_IF_N,W_IF_T
			Sort W_AC_I,W_AC_V,W_AC_I,W_AC_N
			Sort W_VR_I,W_VR_V,W_VR_I,W_VR_N 
					
			SetDataFolder $M_EXPanl_par[1][i]+S_EXP
			CleanUp_Waves_empty()
			SetDataFolder CDF
		Endif	
		
		
		If(waveexists(W_IF_F)&&waveexists(W_IF_I))
			Display/K=1 W_IF_F vs W_IF_I
			FMI_GRPHstyle()
			SetAxis left 0,*;SetAxis bottom 0,*
			Label left "\\u#2Firing rate (Hz)"
			Label bottom "\\u#2I\\Bstep\\M amplitude (pA)"	
				
			StrSwitch(M_EXPanl_par[0][i])
				case "CC_*":
					TextBox/C/N=text0/F=0/B=1/A=LT "\\Z14multiple segments (0.5s) "
					break
				case "hp*":
					TextBox/C/N=text0/F=0/B=1/A=LT "\\Z14single segment (5s)"
					break
			Endswitch
		Endif	
		
		//			// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::: RHEOBASE :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		Variable V_rheobase=round(W_IF_I[0])
			
		If(DataFolderExists(W_IF_T[0])==0)
			continue
		Endif
			
		SetDataFolder eDF
		
		// ... FOR FMI_EXP_SMMsub
		MAKE/O/N=0 $"W_APup_V_"+S_EXP,$"W_APup_I_"+S_EXP,$"W_APup_N_"+S_EXP
			WAVE W_APup_V=$"W_APup_V_"+S_EXP
			WAVE W_APup_I=$"W_APup_I_"+S_EXP
			WAVE W_APup_N=$"W_APup_N_"+S_EXP
		MAKE/O/N=0 $"W_APdn_V_"+S_EXP,$"W_APdn_I_"+S_EXP,$"W_APdn_N_"+S_EXP
			WAVE W_APdn_V=$"W_APdn_V_"+S_EXP
			WAVE W_APdn_I=$"W_APdn_I_"+S_EXP
			WAVE W_APdn_N=$"W_APdn_N_"+S_EXP
		MAKE/O/N=0 $"W_APthr_V_"+S_EXP,$"W_APthr_I_"+S_EXP,$"W_APthr_N_"+S_EXP
			WAVE W_APthr_V=$"W_APthr_V_"+S_EXP
			WAVE W_APthr_I=$"W_APthr_I_"+S_EXP
			WAVE W_APthr_N=$"W_APthr_N_"+S_EXP
		MAKE/O/N=0 $"W_FSL_V_"+S_EXP,$"W_FSL_I_"+S_EXP,$"W_FSL_N_"+S_EXP
			WAVE W_FSL_V=$"W_FSL_V_"+S_EXP
			WAVE W_FSL_I=$"W_FSL_I_"+S_EXP
			WAVE W_FSL_N=$"W_FSL_N_"+S_EXP
		MAKE/O/N=0 $"W_APht_V_"+S_EXP,$"W_APht_I_"+S_EXP,$"W_APht_N_"+S_EXP
			WAVE W_APht_V=$"W_APht_V_"+S_EXP
			WAVE W_APht_I=$"W_APht_I_"+S_EXP
			WAVE W_APht_N=$"W_APht_N_"+S_EXP
		MAKE/O/N=0 $"W_APpk_V_"+S_EXP,$"W_APpk_I_"+S_EXP,$"W_APpk_N_"+S_EXP
			WAVE W_APpk_V=$"W_APpk_V_"+S_EXP
			WAVE W_APpk_I=$"W_APpk_I_"+S_EXP
			WAVE W_APpk_N=$"W_APpk_N_"+S_EXP
		MAKE/O/N=0 $"W_APwd_V_"+S_EXP,$"W_APwd_I_"+S_EXP,$"W_APwd_N_"+S_EXP
			WAVE W_APwd_V=$"W_APwd_V_"+S_EXP
			WAVE W_APwd_I=$"W_APwd_I_"+S_EXP
			WAVE W_APwd_N=$"W_APwd_N_"+S_EXP
		MAKE/O/N=0 $"W_APrs_V_"+S_EXP,$"W_APrs_I_"+S_EXP,$"W_APrs_N_"+S_EXP
			WAVE W_APrs_V=$"W_APrs_V_"+S_EXP
			WAVE W_APrs_I=$"W_APrs_I_"+S_EXP
			WAVE W_APrs_N=$"W_APrs_N_"+S_EXP
		MAKE/O/N=0 $"W_APahp_V_"+S_EXP,$"W_APahp_I_"+S_EXP,$"W_APahp_N_"+S_EXP
			WAVE W_APahp_V=$"W_APahp_V_"+S_EXP
			WAVE W_APahp_I=$"W_APahp_I_"+S_EXP
			WAVE W_APahp_N=$"W_APahp_N_"+S_EXP
				
		SetDataFolder CDF
		SetDataFolder :$W_IF_T[0]:SRS_analysis_SPK
		
		// (first) AP TIME COURSE @ rheobase
		WAVE W_fAP=FMI_matchStrToWaveRef("W_fAP*_"+num2str(V_rheobase)+"*",0)
		If(waveexists(W_fAP))
			SetDataFolder eDF
				
				Duplicate/O W_fAP,$"W_fAP_RHEO"+num2str(V_rheobase)+"pA_"+S_EXP
			
			SetDataFolder CDF
			SetDataFolder :$W_IF_T[0]:SRS_analysis_SPK	
		Endif
				
		// 28.05.2013... this part should be modified - to be able to incorporate descriptive statistics (i.e. calculate Sdev) 
		// (first) AP UPSTROKE / DOWNSTROKE @ rheobase
		FMI_EXP_SMMsub(W_APup_V,W_APup_I,W_APup_N,V_rheobase,"APup")
		FMI_EXP_SMMsub(W_APdn_V,W_APdn_I,W_APdn_N,V_rheobase,"APdn")
					
		// (first) AP threshold / SL / height / risetime @ rheobase
		FMI_EXP_SMMsub(W_APthr_V,W_APthr_I,W_APthr_N,V_rheobase,"APthr")
		FMI_EXP_SMMsub(W_FSL_V,W_FSL_I,W_FSL_N,V_rheobase,"FSL")
		FMI_EXP_SMMsub(W_APht_V,W_APht_I,W_APht_N,V_rheobase,"APht")
		FMI_EXP_SMMsub(W_APpk_V,W_APpk_I,W_APpk_N,V_rheobase,"APpk")
		FMI_EXP_SMMsub(W_APwd_V,W_APwd_I,W_APwd_N,V_rheobase,"APwd")
		FMI_EXP_SMMsub(W_APrs_V,W_APrs_I,W_APrs_N,V_rheobase,"APrs")
		FMI_EXP_SMMsub(W_APahp_V,W_APahp_I,W_APahp_N,V_rheobase,"APahp")
			
		// ADJUST WAVE UNITS & 'CALCULATE AVERAGE'
		SetDataFolder eDF
		String S_WvLst_I=WaveList("*_I_*",";","")
		For(i2=0;i2<ItemsinList(S_WvLst_I);i2+=1)
			WAVE W_I=$StringFromList(i2,S_WvLst_I)
			W_I*=1e-12;SetScale d 0,0,"A",W_I
					
			WAVE W_V=$ReplaceString("_I_",NameOfWave(W_I),"_V_")
			WAVE W_N=$ReplaceString("_I_",NameOfWave(W_I),"_N_")
			W_V/=W_N
		Endfor
				
		SetDataFolder CDF
			
	Endfor	// ANALYSIS TYPE LOOP, i.e. COLUMNS of M_EXPanl_par
	
	SetDataFolder CDF
	
	Killwaves/Z M_EXPanl_par
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_EXP_SMMsub(W_Y,W_X,W_N,V_dpAMP,S_ID[,S_ID2,W_T])
	WAVE W_Y
	WAVE W_X
	WAVE W_N
	Variable V_dpAMP
	String S_ID
	String S_ID2
	WAVE/T W_T
	
	Variable V_DFtrack
	If(ParamIsDefault(S_ID2)) 			// default: parameter is not specified
		S_ID2=""				
	Endif
	If(ParamIsDefault(W_T)) 			// default: parameter is not specified
		V_DFtrack=0
	Else
		V_DFtrack=1
	Endif
	
	WAVE W_input=$matchStrToWaveRef("W_"+S_ID+"_*"+S_ID2+"_*",0)
					
	If(waveexists(W_input))
		Variable V_index
		
		FindValue/Z/T=1e-9/V=(V_dpAMP) W_X
		If(V_Value==-1)		// Value not found
			If(V_DFtrack)
				InsertPoints numpnts(W_X),1,W_Y,W_X,W_N,W_T
				W_T[numpnts(W_X)]=FMI_StringfromString(note(W_input),"segment.DF: ")
			Else
				InsertPoints numpnts(W_X),1,W_Y,W_X,W_N
			Endif
				
			V_index=numpnts(W_X)-1
			W_X[V_index]=V_dpAMP
		Else
			V_index=V_Value
		Endif
		
		Wavestats/Q W_input
		W_Y[V_index]+=V_avg
		W_N[V_index]+=1
		
		SetScale d 0,0,WaveUnits(W_input,-1),W_Y
	Endif
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_SpikeDTCT([w,V_thr,V_DIFthr,V_tmin,V_tmax,V_mthd,V_sAPanlWin,V_BLstart,V_BLend,V_BLscale,V_minWidth])
	WAVE w
	Variable V_thr,V_DIFthr,V_tmin,V_tmax,V_mthd,V_sAPanlWin,V_BLstart,V_BLend,V_BLscale,V_minWidth
	
	Variable V_kurtCUT=10
	
	Variable scnt,i,V_rmvcnt
	
	DFREF CDF=GetDataFolderDFR( )
	String S_note=""
	
	If(ParamIsDefault(w)) 				// default: parameter is not specified
		WAVE w=FindByBrowser("Select wave")
		SetDataFolder GetWavesDataFolderDFR(w)
	Endif
	If(ParamIsDefault(V_DIFthr)) 			// default: parameter is not specified
		V_DIFthr=7							// dV/dt [V/s]; empirically chosen
	Endif
	If(ParamIsDefault(V_thr)) 			// default: parameter is not specified
		V_thr=-35e-3							// [V]
	Endif
	If(ParamIsDefault(V_tmin)) 			// default: parameter is not specified
		V_tmin=-inf
	Endif
	If(ParamIsDefault(V_tmax)) 			// default: parameter is not specified
		V_tmax=inf
	Endif
	If(ParamIsDefault(V_mthd)) 			// default: parameter is not specified
		V_mthd=0
	Endif
	If(ParamIsDefault(V_sAPanlWin)) 		// default: parameter is not specified
		V_sAPanlWin=3e-3						// [s]; time window for analysis of AP upstroke / downstroke
	Endif
	If(ParamIsDefault(V_BLstart)) 		// default: parameter is not specified
		V_BLstart=10e-3						// [s]
	Endif
	If(ParamIsDefault(V_BLend)) 			// default: parameter is not specified
		V_BLend=1.5							// [s]
	Endif
	If(ParamIsDefault(V_BLscale)) 		// default: parameter is not specified
		V_BLscale=5							// [s] factor by which V_sdev of 2nd derivative is multiplied to set the detection threshold for "AP threshold" 
	Endif
	If(ParamIsDefault(V_minWidth)) 		// default: parameter is not specified
		V_minWidth=10e-3						// [s] sets the minimum X distance between level crossings (in FindLevels function, used for spike detection)  
	Endif
	
	If(waveexists(w)==0)
		SetDataFolder CDF
		return -1
	Endif
	
	// ############################### EXTRACT trace INFO & CHECK ###############################
	String S_trc
	
	If(StringMatch(NameOfWave(w),"*_tr1")==1)
		S_trc="_tr1"
	ElseIf(StringMatch(NameOfWave(w),"*_tr2")==1)
		S_trc="_tr2"
	Else
		return -1
	Endif
	
	StrSwitch(FMI_StringfromString(note(w),"Ch"+ReplaceString("_tr",S_trc,"")+".input_units: "))
		case "pA":
			If(ParamIsDefault(w))
				SetDataFolder CDF
				Abort "Data is not current clamp." 
			Else
				SetDataFolder CDF
				return -2
			Endif
			break
	Endswitch
	
	NewDataFolder/O/S :TRC_analysis_SPK
	
	// ############################### SPIKE DETECTION ############################### 
	Variable V_LevelsFND=0
	
	Switch (V_mthd)
		case 0:	// ... threshold crossing in 1st derivative
			Differentiate w /D=$NameOfWave(w)+"_DIF"
			WAVE/Z W_DIF=$NameOfWave(w)+"_DIF"
			SetScale d 0,0,"V/s",W_DIF
				
			Differentiate W_DIF /D=$NameOfWave(w)+"_DIF2"
			WAVE/Z W_DIF2=$NameOfWave(w)+"_DIF2"
			SetScale d 0,0,"V/s²",W_DIF2
				
			FindLevels/B=5/EDGE=1/Q/R=(V_tmin,V_tmax)/M=(V_minWidth) W_DIF,V_DIFthr
			WAVE W_FindLevels
			break
			
		case 1:	// plain threshold crossing...
			FindLevels/EDGE=1/Q/R=(V_tmin,V_tmax)/M=(V_minWidth) w,V_thr		// EDGE=1: Searches only for crossing where the Y values are increasing as level is crossed from wave start towards wave end.
			WAVE W_FindLevels
			break
	Endswitch
			
	// ############################### EVENT (timing) WAVE (RASTER PLOT) ############################### 
	// ############################### AP upstroke / downstroke ###############################
	// ############################### AP threshold (value & timing) ###############################
	If(V_LevelsFound>0)
		Duplicate/O W_FindLevels,$NameOfWave(w)+"_Lvls";Killwaves/Z W_FindLevels
		WAVE W_FindLevels=$NameOfWave(w)+"_Lvls"
			
		MAKE/O/N=(numpnts(W_FindLevels),2) $NameOfWave(w)+"_Xtms"
		WAVE/Z W_Xtimes=$NameOfWave(w)+"_Xtms"; FastOP W_Xtimes=0
		W_Xtimes[][0]=W_FindLevels[p]
		W_Xtimes[][1]=1
				
		String S_note2=note(w)
		S_note2+=FMI_StringfromString(note(w),"segment.parentWAVE: ")
		S_note2+="\r\rsegment.delta: "+num2str(DimDelta(w,0))
		S_note2+="\rspike detection threshold (dV/dt): "+num2str(V_DIFthr)+" V/s"
		S_note2+="\rspike detection minimum distance: "+num2str(V_minWidth*1e3)+" ms"
		NOTE/K/NOCR W_Xtimes,S_note2
				
		MAKE/O/N=(numpnts(W_FindLevels)) $NameOfWave(w)+"_UPst",$NameOfWave(w)+"_DNst"
		WAVE W_UPst=$NameOfWave(w)+"_UPst"
		WAVE W_DNst=$NameOfWave(w)+"_DNst"
		SetScale d 0,0,"V/s",W_UPst, W_DNst
			
		MAKE/O/N=(numpnts(W_FindLevels)) $NameOfWave(w)+"_thr",$NameOfWave(w)+"_tAP"
		WAVE W_thr=$NameOfWave(w)+"_thr"
		WAVE W_tAP=$NameOfWave(w)+"_tAP"
		SetScale d 0,0,"V",W_thr
		SetScale d 0,0,"s",W_tAP
			
		// BASELINE FLUCTUATIONS OF 2nd DERIVATIVE
		Wavestats/Q/R=(V_BLStart,V_BLend) W_DIF2
		Variable V_DIF2thr=V_BLscale*V_sdev
			
		For(scnt=0;scnt<numpnts(W_FindLevels);scnt+=1)		// scnt = spike count
			// AP upstroke / downstroke
			Wavestats/Q/R=(W_FindLevels[scnt],W_FindLevels[scnt]+V_sAPanlWin) W_DIF
			W_UPst[scnt]=V_max
			W_DNst[scnt]=V_min
				
			// timing of AP threshold crossing & value of AP threshold
			FindLevel/EDGE=1/Q/R=(W_FindLevels[scnt]-V_sAPanlWin,W_FindLevels[scnt]+V_sAPanlWin) W_DIF2,V_DIF2thr
			If(V_flag==0)				// level was found
				W_tAP[scnt]=V_LevelX
				W_thr[scnt]=w[x2pnt(w,V_LevelX)]					
			Else
				W_tAP[scnt]=W_FindLevels[scnt]
				W_thr[scnt]=w[x2pnt(w,W_FindLevels[scnt])]
			Endif				
		Endfor
			
		//		W_FindLevels=W_tAP
		//		Killwaves/Z W_tAP
	Else
		Killwaves/Z W_FindLevels,W_Xtimes,W_DIF
	Endif
		
	Killwaves/Z W_DIF2
		
	// ############################### ISI wave ############################### 
	Wavestats/Z/Q/M=1 W_FindLevels
	If(V_npnts>1)
		MAKE/O/N=(V_npnts-1) $NameOfWave(w)+"_ISI"
		WAVE/Z W_ISI=$NameOfWave(w)+"_ISI"
		SetScale d 0,0,"s",W_ISI
				
		For(i=0;i<numpnts(W_ISI);i+=1)					
			W_ISI[i]=W_FindLevels[i+1]-W_FindLevels[i]
		Endfor
	Endif
		
	If(waveexists(W_ISI))
		FMI_APanl(w,W_FindLevels,NameOfWave(w),W_ISI=W_ISI)
		
		// ... remove "outliers", such as caused by stimulation intervals
		Wavestats/Q/Z W_ISI
		If(V_kurt>V_kurtCUT)
			do
				W_ISI[V_maxRowLoc]=NaN
				V_rmvcnt+=1
				S_note+="\r\t OUTLIER removed; value: "+num2str(V_max)+", location: "+num2str(V_maxRowLoc)
				Wavestats/Q/Z W_ISI	
			while (V_kurt>V_kurtCUT)
		Endif
			
		S_note+="\rIn total "+num2str(V_rmvcnt)+" OUTLIER removed; kurtosis cutoff was: "+num2str(V_kurtCUT)
			
		RemoveNANs(W_ISI)
			
		Note/K W_ISI,S_note
			
		WaveStats_to_Note(W_ISI,V_add=1)
		
	Else
		FMI_APanl(w,W_FindLevels,NameOfWave(w))
	Endif
			
	WAVE W_PkVl=$ReplaceString("_Lvls",NameOfWave(W_FindLevels),"_PkVl")
	WAVE W_PkLc=$ReplaceString("_Lvls",NameOfWave(W_FindLevels),"_PkLc")
		
	If(waveexists(W_PkVl)&&waveexists(W_PkLc))
		// AP HEIGHT / RISETIME [based on: PkVl, Pklc		- 	from 'FindPeak' analysis in FMI_APanl()]  
		MAKE/O/N=(numpnts(W_FindLevels)) $NameOfWave(w)+"_APht",$NameOfWave(w)+"_APrs"
			WAVE W_APht=$NameOfWave(w)+"_APht"
			WAVE W_APrs=$NameOfWave(w)+"_APrs"
			SetScale d 0,0,"V",W_APht
			SetScale d 0,0,"s",W_APrs
				
		W_APht=W_PkVl-W_thr					// AP HEIGHT is the difference between the AP peak voltage (PkVl) and AP voltage threshold 
		W_APrs=W_PkLc-W_FindLevels		// AP RISETIME is the difference between the AP peak location (PkLc) and the AP voltage threshold crossing 
	Endif
	
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_APanl(w,W_pos,S_WVstr[,W_ISI])
	WAVE w
	WAVE W_pos
	String S_WVstr
	WAVE W_ISI
	
	Variable V_cutMTHD=1,V_cutoff=0.2,V_bnSZ=10,V_cutPNT
	Variable V_Acnd=1	// ... deliberately analysing only the 1st AP
	Variable V_startX=5e-3,V_endX=10e-3
	Variable V_preRNG=0.5e-3	// [s] -> 500us
	Variable i
	
	Variable V_offset=FVCV_ValuefromString(note(w),"segment.offset: ")
	
	String S_note=""
		
	// ############################### ASSESS analysis INPUT condition ###############################
	If(waveexists(W_ISI)==0 && numpnts(W_pos)==0)		// NO spikes for analysis
		return -1
	Endif
	
	// ----------------------------------------------- For function-internal use: input waves w/o temporal offset -------------------------------------------
	Duplicate/O w,w_off
	Duplicate/O W_pos,W_pos_off
	SetScale/P x,0,DimDelta(w,0),WaveUnits(w,0),w_off
	W_pos_off=W_pos-V_offset
	
	If(waveexists(W_ISI)==0 && numpnts(W_pos)>0)			// only ONE spike for analysis
		MAKE/O/N=(x2pnt(w_off,DimSize(w_off,0)*deltax(w_off)-W_pos_off[0]),numpnts(W_pos_off)) $S_Wvstr+"_APs"		
//		V_Acnd=1
		
	ElseIf(waveexists(W_ISI))									// >ONE spikes for analysis
		Wavestats/Q/M=1 W_ISI
		MAKE/O/N=(ceil(V_max/deltax(w_off))+ceil(V_preRNG/deltax(w_off)),numpnts(W_pos_off)) $S_Wvstr+"_APs"
//		V_Acnd=2
	 	
	Endif
	 
	WAVE M_tmp=$S_Wvstr+"_APs" 
	M_tmp=Nan
	CopyScales/P w_off,M_tmp
	 
	// fill matrix, used for averaging
	For(i=0;i<numpnts(W_pos_off);i+=1)
		If(i==numpnts(W_pos_off)-1)	// ... "end effect"
			M_tmp[][i]= w[p+x2pnt(w,W_pos[i])-ceil(V_preRNG/deltax(w))] 
		Else
			M_tmp[][i]= (p+x2pnt(w_off,W_pos_off[i]))<(x2pnt(w_off,W_pos_off[i+1])) ? w_off[p+x2pnt(w_off,W_pos_off[i])-ceil(V_preRNG/deltax(w_off))] : NaN
		Endif
	Endfor
	
	// create average AP trace 
	If(V_Acnd==2)
		WAVE W_AVG=MatrixStats(M_tmp)
		WAVE W_SD=$ReplaceString("AVG",Nameofwave(W_AVG),"SD")
		WAVE W_SEM=$ReplaceString("AVG",Nameofwave(W_AVG),"SEM")

	Elseif(V_Acnd==1)
		Duplicate/O/R=(,)(0,0) M_tmp,W_AVG,W_SD
		Redimension/N=(DimSize(M_tmp,0)) W_AVG,W_SD
		W_SD=NaN
		
	Endif
	Duplicate/O W_AVG,$S_WVstr+"_AP_AVG";Killwaves/Z W_AVG; WAVE W_AVG= $S_WVstr+"_AP_AVG"
	Duplicate/O W_SD,$S_WVstr+"_AP_SD";Killwaves/Z W_SD; WAVE W_SD= $S_WVstr+"_AP_SD"
	Killwaves/Z W_SEM
	
	
	// 18.02.2019 --> AHP (on average AP trace)
	MAKE/O/N=1 $S_WVstr+"_APahp"; WAVE W_AHP= $S_WVstr+"_APahp"
	
	Variable V_pre,V_post
	WaveStats/Q/R=[0,2] W_AVG
		V_pre= V_avg
	WaveStats/Q/R=[270,299] W_AVG		// 27ms - 30ms
		V_post= V_avg
		
		W_AHP= V_post-V_pre
	
		
	// determine "CUTOFF" (in time) of AP trace
	If(V_Acnd==2)
		Switch (V_cutMTHD)
			case 1:				
				Wavestats/Q W_ISI
				V_cutPNT=x2pnt(w_off,V_min)	// smallest ISI
				break
			
			case 2:
				For(i=0;i<DimSize(M_tmp,0);i+=1)
					MAKE/O/N=(numpnts(W_pos_off)) W_tmp
					W_tmp[]=M_tmp[i][p]
					Wavestats/Q/M=1 W_tmp
					If(V_npnts<V_cutoff*numpnts(W_pos_off))
						V_cutPNT=i
						break
					Endif
				Endfor
				Killwaves/Z W_tmp
				break
		Endswitch	
	
	Elseif(V_Acnd==1)
		V_cutPNT=x2pnt(w_off,30e-3)		// 30ms
	Endif
	
	DeletePoints/M=0 V_cutPNT,numpnts(W_AVG),W_AVG,W_SD,M_tmp
	
	
	//	ANALYZE individual APs
	MAKE/O/N=(5,DimSize(M_tmp,1)) M_FPrslt
	WAVE M_FPrslt
	
	For(i=0;i<DimSize(M_tmp,1);i+=1)
		MAKE/O/N=(DimSize(M_tmp,0)) W_tmp
		W_tmp[]=M_tmp[p][i]
		CopyScales/P M_tmp,W_tmp
		
		WaveStats/Q/Z W_tmp
		Variable V_minLvl
		If(V_max<=0)					// peak value has negative sign
			If(V_max>-2e-3)			// peak value between -2mV and 0mV
				V_minLvl=-2e-3		// -2mV as arbitrariliy chosen minimum value (threshold) for peak
			Else
				V_minLvl=V_max*1.1
			Endif
		Elseif(V_max>0)				// peak value has positive sign
			If(V_max<2e-3)			// peak value between 0mV and +2mV
				V_minLvl=-2e-3		// -2mV as arbitrariliy chosen minimum value (threshold) for peak
			Else
				V_minLvl=V_max/1.1
			Endif
		Endif
		
		FindPeak/Q/M=(V_minLvl) W_tmp
		If(V_flag==0)								// ... peak was found
			M_FPrslt[0][i]=V_LeadingEdgeLoc		// ... The peak edges are found where the second derivative of the smoothed result crosses zero
			M_FPrslt[1][i]=V_PeakLoc				// ... The peak center is found where the derivative of this smoothed result crosses zero
			M_FPrslt[2][i]=V_TrailingEdgeLoc		// ... The peak edges are found where the second derivative of the smoothed result crosses zero
			M_FPrslt[3][i]=V_PeakVal				// ... The peak value is simply the greater of the two unsmoothed values surrounding the peak center
			M_FPrslt[4][i]=V_PeakWidth			// = V_TrailingEdgeLoc-V_LeadingEdgeLoc
		Else
			M_FPrslt[][i]=NaN
		Endif
		Killwaves/Z W_tmp
	Endfor
	
	MAKE/O/N=(DimSize(M_tmp,1)) $S_Wvstr+"_PkVl",$S_Wvstr+"_PkWd",$S_Wvstr+"_PkLc"
	WAVE W_PkLc=$S_Wvstr+"_PkLc"
	WAVE W_PkVl=$S_Wvstr+"_PkVl"
	WAVE W_PkWd=$S_Wvstr+"_PkWd"
	W_PkLc[]=M_FPrslt[1][p]+W_pos[p]-V_preRNG		// V_PeakLoc (and any other location value in this function) is in relative scaling, i.e. it is transformed into absolute timing coordinates here  
	W_PkVl[]=M_FPrslt[3][p]
	W_PkWd[]=M_FPrslt[4][p]
	
	SetScale d 0,0,WaveUnits(w,0),W_PkWd,W_PkLc
	SetScale d 0,0,WaveUnits(w,-1),W_PkVl
	
	WaveStats_to_Note(W_PkLc)
	WaveStats_to_Note(W_PkVl)
	WaveStats_to_Note(W_PkWd)
	
	If(V_Acnd==1)
		S_note+="\r1 / "+num2str(numpnts(W_pos))+" spikes analysed"
	Else
		S_note+="\r# spikes analysed: "+num2str(numpnts(W_pos))
	Endif
	Note/K W_AVG,S_note
	Note/K W_SD,S_note
	
	KIllwaves/Z M_Fprslt,w_off,W_pos_off
	
	SetScale/P x,0,DimDelta(w,0),WaveUnits(w,0) W_AVG,W_SD,M_tmp
	
	If(V_Acnd==1)
		Killwaves/Z W_SD
	Endif
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_ACTION_ALL([V_cmd,S_matchStr_DF0,S_matchStr_DF1,S_matchStr_DF2])
	Variable V_cmd
	String S_matchStr_DF0,S_matchStr_DF1,S_matchStr_DF2
	
	
	If(ParamIsDefault(V_cmd)) 				// default: parameter is not specified
		V_cmd=0
	Endif
	If(ParamIsDefault(S_matchStr_DF0)) 		// default: parameter is not specified
		S_matchStr_DF0="*dp*"
	Endif
	If(ParamIsDefault(S_matchStr_DF1)) 		// default: parameter is not specified
		S_matchStr_DF1="*"
	Endif
	If(ParamIsDefault(S_matchStr_DF2)) 		// default: parameter is not specified
		S_matchStr_DF2="E_*"
	Endif
	
	Variable i,i2,i3
	
	DFREF CDF=GetDataFolderDFR( )
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	String S_grepDF2Lst=ListMatch(DFList(),S_matchStr_DF2)
	
	If(ItemsInList(S_grepDF2Lst)==0)
		return 0
	Endif
	
	Variable V_EXPnum= ItemsInList(S_grepDF2Lst)
	
	String S_prompt="",S_ID="",S_WvLst_Kill,S_DFLst
	Variable j
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==3)	// IF curve, all DFs
		MAKE/O/N=10 M_ssCI_IF_V,W_ssCI_IF_I
		WAVE M_ssCI_IF_V,W_ssCI_IF_I
		W_ssCI_IF_I={5,10,15,20,25,30,40,50,75,100};W_ssCI_IF_I*=1e-12
		M_ssCI_IF_V=NaN
			
		MAKE/O/N=17 M_msCI_IF_V,W_msCI_IF_I
		WAVE M_msCI_IF_V,W_msCI_IF_I
		W_msCI_IF_I={2,4,5,6,8,10,15,20,25,30,40,50,75,100,200,300,400};W_msCI_IF_I*=1e-12
		M_msCI_IF_V=NaN
		
		DoWindow ssCI
		If(V_flag)
			DoWindow/K ssCI
		Endif
		
		DoWindow msCI
		If(V_flag)
			DoWindow/K msCI
		Endif
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==4)	// vdCC & vdVC grand average (pxp-wide) analysis
		String S_DFsav=GetDataFolder(1)
		
		Prompt S_prompt,"Identifier string: "
		DoPrompt "Specify...",S_prompt
			If(V_Flag)	// ... cancel
				SetDataFolder CDF
				return -1
			Endif
			If(strlen(S_prompt)>0)
				S_ID="_"+S_prompt
			Endif
		
		SetDataFolder CDF
		
		// ... CLEANUP
		S_WvLst_Kill=WaveList("*GA"+S_ID,";","")
			For(j=0;j<ItemsInList(S_WvLst_Kill);j+=1)
				WAVE w=$StringFromList(j,S_WvLst_Kill)
					Killwaves/Z w
			Endfor
		
		SetDataFolder CDF
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==5)	// STIM_VCtest grand average (pxp-wide) analysis
		Prompt S_prompt,"Identifier string: "
		DoPrompt "Specify...",S_prompt
			If(V_Flag)	// ... cancel
				SetDataFolder CDF
				return -1
			Endif
			If(strlen(S_prompt)>0)
				S_ID="_"+S_prompt
			Endif
		
		SetDataFolder root:
		
		// ... CLEANUP
		
		S_WvLst_Kill=WaveList("*GA"+S_ID+"*",";","")
			For(j=0;j<ItemsInList(S_WvLst_Kill);j+=1)
				WAVE w=$StringFromList(j,S_WvLst_Kill)
					Killwaves/Z w
			Endfor
		
		SetDataFolder CDF
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==7)
		String S_WvID=""
		Prompt S_WvID,"Wave identifier string: "
		DoPrompt "Specify...",S_WvID
			If(V_Flag)	// ... cancel
				SetDataFolder CDF
				return -1
			Endif
			If(strlen(S_WvID)==0)
				SetDataFolder CDF
				return -1
			Endif
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	Variable  V_BSLstart,V_BSLend,V_RSPstart,V_RSPend
	If(V_cmd==10)
		// 28.01.2016 ... 20Hz stimulation; 1st peak analysis
		V_BSLstart=0.25
		V_BSLend=0.299
		V_RSPstart=0.303
		V_RSPend=0.315
			
//		V_BSLstart=2.79
//		V_BSLend=3.79
//		V_RSPstart=3.80
//		V_RSPend=10.00
	
		Prompt V_BSLstart,"Baseline period start [s]:"
		Prompt V_BSLend,"Baseline period end [s]:"
		Prompt V_RSPstart,"Response period start [s]:"
		Prompt V_RSPend,"Response period end [s]:"
		DoPrompt "Specify RESPONSE windows...", V_BSLstart,V_BSLend,V_RSPstart,V_RSPend
			If(V_flag)
				return -1
			Endif	
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==8)
		MAKE/O/N=(V_EXPnum) W_msCI_AHP=NaN,W_ssCI_AHP=NaN
			WAVE W_msCI_AHP,W_ssCI_AHP
	Endif
	
	
	// ##################################################################################################################################
	// -----------------------------------------------------------------------------------------------------------------------
	For(i=0;i<ItemsInList(S_grepDF2Lst);i+=1)
		SetDataFolder $StringfromList(i,S_grepDF2Lst)
			
		// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		String S_grepDF1Lst=ListMatch(DFList(),S_matchStr_DF1)
		If(ItemsInList(S_grepDF1Lst)==0)
			SetDataFolder ::
			continue
		Endif
			
		// -----------------------------------------------------------------------------------------------------------------------
		For(i2=0;i2<ItemsInList(S_grepDF1Lst);i2+=1)
			SetDataFolder $StringfromList(i2,S_grepDF1Lst)
					
			If(V_cmd==1)
				FMI_unGROUPit(V_dialog=0)
				FMI_GROUPit()
				SetDataFolder ::
				continue
			Endif
					
			If(V_cmd==2)
				FMI_rstPlot_display()
				SetDataFolder ::
				continue
			Endif
					
			If(V_cmd==3)
				FMI_IF_display(M_ssCI_IF_V,W_ssCI_IF_I,"*ssCI*")
				FMI_IF_display(M_msCI_IF_V,W_msCI_IF_I,"*msCI*")
				SetDataFolder ::
				continue
			Endif
			
			If(V_cmd==4)	// vdCC & vdVC grand average (pxp-wide) analysis
				FMI_vdEVT_LVL2_anl(V_GA=1,S_ID=S_ID,S_DFsav=S_DFsav)
				SetDataFolder ::
				continue
			Endif
								
			If(V_cmd==5)	// STIM_VCtest grand average (pxp-wide) analysis
				FMI_EVT_analysis_seg_SMM(S_ID=S_ID)
				SetDataFolder ::
				continue
			Endif
			
			If(V_cmd==8)
				FMI_SPK_analysis_seg()
					// 19.02.2019
					S_DFLst= ListMatch(DFList(), "EXP_msCI*")
					If(ItemsInList(S_DFLst)>0)
					SetDataFolder $StringFromList(0,S_DFLst)
						WAVE W_AHP= FMI_matchStrToWaveRef("W_APahp_V_*",0)
							WaveStats/Q W_AHP
								W_msCI_AHP[i]= V_avg
					SetDataFolder ::
					Endif
					
					S_DFLst= ListMatch(DFList(), "EXP_ssCI*")
					If(ItemsInList(S_DFLst)>0)
					SetDataFolder $StringFromList(0,S_DFLst)
						WAVE W_AHP= FMI_matchStrToWaveRef("W_APahp_V_*",0)
							WaveStats/Q W_AHP
								W_msCI_AHP[i]= V_avg
					SetDataFolder ::
					Endif
				
				SetDataFolder ::
				continue
			Endif
			
			If(V_cmd==9)
				FMI_PVector_init()
				SetDataFolder ::
				continue
			Endif
			
			If(V_cmd==19)
				
				
			Endif
			
			// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			String S_grepDF0Lst=ListMatch(DFList(),S_matchStr_DF0)
			If(ItemsInList(S_grepDF0Lst)==0)
				SetDataFolder ::
				continue
			Endif
					
			// -----------------------------------------------------------------------------------------------------------------------
			For(i3=0;i3<ItemsInList(S_grepDF0Lst);i3+=1)
				SetDataFolder $StringfromList(i3,S_grepDF0Lst)
							
				Switch(V_cmd)
					case 0:
						FMI_rstPlot_display()
						break
					
					case 6:
						WAVE W_EPSC=FMI_matchStrToWaveRef("W_avgEPSC_30V*",0)
						If(waveexists(W_EPSC))
							DoWindow avgEPSC
								If(V_flag)
									AppendToGraph W_EPSC
								Else
									Display/K=1 W_EPSC 
										DoWindow/C avgEPSC
								Endif
						Endif
						break
					
					case 7:
						WAVE W_WvID=FMI_matchStrToWaveRef(S_WvID,0)
						If(waveexists(W_WvID))
							DoWindow $CleanupName(S_WvID,0) 
								If(V_flag)
									AppendToGraph W_WvID
								Else
									Display/K=1 W_WvID 
										DoWindow/C $CleanupName(S_WvID,0) 
								Endif
						Endif
						break
					
					case 10:
						FMI_AVGtrc()
						FMI_srsAMP(V_BSLstart=V_BSLstart,V_BSLend=V_BSLend,V_RSPstart=V_RSPstart,V_RSPend=V_RSPend,V_DSPLY=0)
						break
				Endswitch
							
				SetDataFolder ::
			Endfor
			// -----------------------------------------------------------------------------------------------------------------------
					
			SetDataFolder ::
		Endfor
		// -----------------------------------------------------------------------------------------------------------------------
			
		SetDataFolder ::	
	Endfor	
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==3)
//		DeletePoints/M=1 DimSize(M_ssCI_IF_V,1)-1,1,M_ssCI_IF_V
		DeletePoints/M=1 DimSize(M_msCI_IF_V,1)-1,1,M_msCI_IF_V
		
//		MatrixStats(M_ssCI_IF_V);WAVE W_ssCI_IF_V_AVG;WAVE W_ssCI_IF_V_SEM;WAVE W_ssCI_IF_V_SD
		MatrixStats(M_msCI_IF_V);WAVE W_msCI_IF_V_AVG;WAVE W_msCI_IF_V_SEM;WAVE W_msCI_IF_V_SD
		
//		AppendToGraph/W=ssCI W_ssCI_IF_V_AVG vs W_ssCI_IF_I
//		ModifyGraph/W=ssCI mode=4,marker=8,opaque=1,lsize=0.5
//		ModifyGraph/W=ssCI rgb(W_ssCI_IF_V_AVG)=(0,0,0),marker(W_ssCI_IF_V_AVG)=19
//		ErrorBars/W=ssCI/T=0.25/L=0.25 W_ssCI_IF_V_AVG Y,wave=(W_ssCI_IF_V_SEM,W_ssCI_IF_V_SEM)
//		//			ErrorBars/W=ssCI/T=0.25/L=0.25 W_ssCI_IF_V_AVG Y,wave=(W_ssCI_IF_V_SD,W_ssCI_IF_V_SD)
			
		AppendToGraph/W=msCI W_msCI_IF_V_AVG vs W_msCI_IF_I
		ModifyGraph/W=msCI mode=4,marker=8,opaque=1,lsize=0.5
		ModifyGraph/W=msCI rgb(W_msCI_IF_V_AVG)=(0,0,0),marker(W_msCI_IF_V_AVG)=19
		ErrorBars/W=msCI/T=0.25/L=0.25 W_msCI_IF_V_AVG Y,wave=(W_msCI_IF_V_SEM,W_msCI_IF_V_SEM)
		//			ErrorBars/W=msCI/T=0.25/L=0.25 W_msCI_IF_V_AVG Y,wave=(W_msCI_IF_V_SD,W_msCI_IF_V_SD)
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==4)	// vdCC & vdVC grand average (pxp-wide) analysis
		String S_WvLST_HST_GA=WaveList("*_HST_*_GA*",";","")
		For(j=0;j<ItemsinList(S_WvLST_HST_GA);j+=1)
			WAVE w_HST_GA=$StringfromList(j,S_WvLST_HST_GA)
			
			Variable V_count=FVCV_ValuefromString(note(w_HST_GA),"w.num: ")
				
			w_HST_GA/=V_count
		Endfor
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	If(V_cmd==5)
		String S_WvLst_M=WaveList("M_*",";","DIMS:2")
		
		For(i=0;i<ItemsinList(S_WvLst_M);i+=1)
			WAVE M_tmp=$StringFromList(i,S_WvLst_M)
			MatrixStats(M_tmp)
		Endfor
	Endif
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function/WAVE FindByBrowser(DBtitle,[V_TEXT])
	String DBtitle
	Variable V_TEXT

	If(ParamIsDefault(V_TEXT))
		V_TEXT=0
	Endif
	
	String cmd
	Variable/G V_flag
	String/G S_BrowserList=""
	Sprintf cmd,"CreateBrowser prompt=\""+DBtitle+"\",showWaves=1,showVars=0,showStrs=0"
	Execute cmd
	
	If(V_flag==0)									// ... User cancelled
		Abort
	Elseif(V_flag==1)								// ... User selected 
		If(V_TEXT==1)
			WAVE/T W_T=$StringfromList(0,S_BrowserList)		// ... first selected item in Data Browser
			return W_T
		Else
			WAVE w=$StringfromList(0,S_BrowserList)		// ... first selected item in Data Browser
			return w
		Endif
	Endif
	
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function/WAVE MatrixStats(w)
	WAVE w
	Variable i
	
	If(DimSize(w,1)==0)
		return none
	Endif
	
	Make/O/N=(DimSize(w,0)) $ReplaceString("M_",Nameofwave(w),"W_",1)+"_SEM",$ReplaceString("M_",Nameofwave(w),"W_",1)+"_SD",$ReplaceString("M_",Nameofwave(w),"W_",1)+"_AVG"
	WAVE W_AVG=$ReplaceString("M_",Nameofwave(w),"W_",1)+"_AVG"
	WAVE W_SD=$ReplaceString("M_",Nameofwave(w),"W_",1)+"_SD"
	WAVE W_SEM=$ReplaceString("M_",Nameofwave(w),"W_",1)+"_SEM"
		
	CopyScales/P w,W_AVG,W_SD,W_SEM
		
	For(i=0;i<DimSize(w,0);i+=1)
		Imagestats/Q/G={i,i,0,DimSize(w,1)-1} w
		W_AVG[i]=V_avg
		W_SD[i]=V_sdev
		W_SEM[i]=V_sdev/sqrt(V_npnts)		
	Endfor	
	
	return W_AVG
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/S FMI_StringfromString(inputStr,findthisStr)
	String inputStr
	String findthisStr
	
	String substring
	String S_return
	
	SplitString/E=("("+findthisStr+".*)") inputStr,substring
	substring=ReplaceString(findthisStr,substring,"") 
	sscanf substring, "%s",S_return
		
	If(V_flag==0 || V_flag==-1)
		S_return=""
	Endif
	
	return S_return
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function Killwvs(S_matchStr)
	String S_matchStr
	
	String S_WvList=WaveList(S_matchStr,";","")
	Variable i
	
	For(i=0;i<itemsinList(S_WvList);i+=1)
		WAVE w=$StringfromList(i,S_WvList)
		Killwaves/Z w
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function CleanUp_Waves_empty([S_matchStr])
	String S_matchStr
	
	If(ParamIsDefault(S_matchStr))		// default: parameter is not specified
		S_matchStr="*"
	Endif
	
	String S_WvList=WaveList(S_matchStr,";","")
	Variable i
	
	For(i=0;i<itemsinList(S_WvList);i+=1)
		WAVE w=$StringfromList(i,S_WvList)
		If(numpnts(w)==0)
			Killwaves/Z w
		Else
			If(WaveType(w,1)==2)	// text wave...
				continue
			Endif
			
			WaveStats/Q w
				If(V_npnts==0)
					Killwaves/Z w
				Endif
		Endif
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function WaveStats_to_Note_all([S_matchStr,V_add,V_removeNaNs])
	String S_matchStr
	Variable V_add
	Variable V_removeNaNs
	
	If(ParamIsDefault(S_matchStr))		// default: parameter is not specified
		S_matchStr="*"
	Endif
	If(ParamIsDefault(V_add))			// default: parameter is not specified
		V_add=0
	Endif
	If(ParamIsDefault(V_removeNaNs))	// default: parameter is not specified
		V_removeNaNs=0
	Endif
	
	String S_WvList=WaveList(S_matchStr,";","")
	Variable i
	
	For(i=0;i<itemsinList(S_WvList);i+=1)
		WAVE w=$StringfromList(i,S_WvList)
		If(V_removeNaNs)
			RemoveNANs(w)
		Endif
		WaveStats_to_Note(w,V_add=V_add)
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function WaveStats_to_Note(w[,V_add])
	WAVE w
	Variable V_add
	
	If(ParamIsDefault(V_add))		// default: parameter is not specified
		V_add=0
	Endif
	
	String S_note
	 
	Switch(V_add)
		case 0:
			S_note=""
			break
		case 1:
			S_note=note(w)+"\r"
			break
	Endswitch
	
	If(waveexists(w)==0)
		return -1
	Endif
	
	Wavestats/Q/Z w
	S_note+="\r"+Secs2Date(DateTime,2)+" @ "+Secs2Time(DateTime,3)
	S_note+="\r\tAverage: "+num2str(V_avg)+" "+WaveUnits(w,-1)
	S_note+="\r\tStandard deviation (s.d.): "+num2str(V_Sdev)+" "+WaveUnits(w,-1)
	S_note+="\r\tStandard error of mean (s.e.m.): "+num2str(V_Sdev/sqrt(V_npnts))+" "+WaveUnits(w,-1)
	S_note+="\r\tCoefficient of variation (C.V.): "+num2str(V_Sdev/V_avg)
	S_note+="\r\tMedian: "+num2str(StatsMedian(w))+" "+WaveUnits(w,-1)
	S_note+="\r\tSum: "+num2str(sum(w))
	S_note+="\r\tMinimum entry: "+num2str(V_min)+" "+WaveUnits(w,-1)
	S_note+="\r\tMaximum entry: "+num2str(V_max)+" "+WaveUnits(w,-1)
	S_note+="\r\t# overall entries (w NaNs and INFs): "+num2str(numpnts(w))
	S_note+="\r\t# entries (w/o NaNs and INFs): "+num2str(V_npnts)
	S_note+="\r\t# NaNs: "+num2str(V_numNaNs)
	Note/K w,S_note
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_CDFcomp(w,S_kw[,V_mode])
	WAVE w
	String S_kw
	Variable V_mode
	
	If(waveexists(w) && strlen(S_kw)>0)
	
		If(ParamIsDefault(V_mode))
			V_mode=0
		Endif
		
		// CDFs
		Duplicate/O w,$ReplaceString(S_kw,NameOfWave(w),S_kw+"cdfX"),$ReplaceString(S_kw,NameOfWave(w),S_kw+"cdfY")
			WAVE w_cdfX=$ReplaceString(S_kw,NameOfWave(w),S_kw+"cdfX")
			WAVE w_cdfY=$ReplaceString(S_kw,NameOfWave(w),S_kw+"cdfY")
			
		Switch(V_mode)
			default:		// EPSP & IPSC analysis
				Sort w,w_cdfX
				break
					
			case 1:		// EPSC anaylsis
				Sort/R w,w_cdfX
				break
		Endswitch
	
		w_cdfY[]=p/numpnts(w_cdfY)
		SetScale d,0,0, "Cumulative probability",w_cdfY
		
		return w_cdfX
	Endif

End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMItrcnum(w)
	WAVE w
	
	String S_INTL,S_FLD1,S_FLD2,S_FLD3
	sscanf NameOfWave(w),"%2[A-Za-z]%4[0-9]%4[A-Za-z]%4[0-9]",S_INTL,S_FLD1,S_FLD2,S_FLD3
	String S_WVstr=S_INTL+S_FLD1+S_FLD2+S_FLD3
	
	return str2num(ReplaceString(S_WVstr+"_tr",NameOfWave(w),""))
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function/WAVE FMI_matchStrToWaveRef(matchStr,TEXT,[DIMS,V_entry])
	String matchStr
	Variable DIMS,TEXT,V_entry
	
	String WvLst=""
	
	If(ParamIsDefault(V_entry))		// default: parameter is not specified
		V_entry=0
	Endif
	
	If(ParamIsDefault(DIMS)==1)	// ... DIMS not specified
		WvLst=WaveList(matchStr,";","TEXT:"+num2str(TEXT))
	Else
		WvLst=WaveList(matchStr,";","DIMS:"+num2str(DIMS)+",TEXT:"+num2str(TEXT))
	Endif
	
	If(V_entry==-1)
		V_entry=ItemsInList(WvLst)-1
	Endif
	
	wave w=$StringfromList(V_entry,WvLst)
	
	If(waveexists(w)==1)
		return w
	Endif	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function/S DFList()
	Variable i;String DFLst=""
	For(i=0;i<CountObjects(":", 4 );i+=1)
		DFLst+= GetIndexedObjName(":", 4,i)+";"
	Endfor
	return DFLst
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_rnmDFs()
	String S_grepDFLst=ListMatch(DFList(),"*pA_*")
	
	Variable i
	
	For(i=0;i<ItemsinList(S_grepDFLst);i+=1)
		String S_dpAMP,S_skip1,S_dpLNGTH,S_skip2,S_skip3,S_skip4,S_dpRPT
		SplitString /E=("([[:digit:]]+)(pA_)([[:digit:]]+)(s_)([[:digit:]]+)(_n)([[:digit:]]+)") StringfromList(i,S_grepDFLst),S_dpAMP,S_skip1,S_dpLNGTH,S_skip2,S_skip3,S_skip4,S_dpRPT
		Variable V_dpLNGTH
		V_dpLNGTH=1e3*str2num(S_dpLNGTH)
		
		String S_newName="dp"+num2str(V_dpLNGTH)+"ms_"+S_dpAMP+"pA_n"+S_dpRPT
		
		RenameDataFolder $StringfromList(i,S_grepDFLst),$S_newName
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function DFrnm(S_in,S_out)
	String S_in
	String S_out
	
	String S_grepDFLst=ListMatch(DFList(),"*"+S_in+"*")
	
	Variable i
	
	For(i=0;i<ItemsinList(S_grepDFLst);i+=1)
		String S_newName=ReplaceString(S_in, StringfromList(i,S_grepDFLst), S_out)
		
		RenameDataFolder $StringfromList(i,S_grepDFLst),$S_newName
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_RemoveNANsinDF()
	String S_WvLst=WaveList("*",";","")
	Variable i
	
	For(i=0;i<ItemsinList(S_WvLst);i+=1)
		WAVE w=$StringfromList(i,S_WvLst)
		
		FMI_RemoveNANs(w)
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_RemoveNANs(w,[value])
	Variable value
	WAVE w
	Variable i
	
	If(waveexists(w)==0)
		return -1
	Endif
			
	For(i=0;i<numpnts(w);i+=1)
		If(ParamIsDefault(value))
			If(numtype(w[i])==2)
				DeletePoints i,1, w
				i-=1
			Endif
		Else
			If(w[i]==value)
				DeletePoints i,1, w
				i-=1
			Endif
		Endif
	Endfor
End