#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include ":FMI_Ephus"

Menu "Ephus"
	Submenu "DISPLAY"
		"-"
		"Add trace AVERAGE && ERROR BARS",/Q,FMI_addAVGmrk() 
		"-"
		"Display - 2 channels",/Q,FMI_2Ch_display()
		"-"
		"Vm time trace",/Q,FMI_GRPHstyle_Vm_vs_t()
		"-"
		"Blank STIM - segmented traces",/Q,FMI_GRPH_ES_blank()
		"Blank STIM - unsegmented traces [1x]",/Q,FMI_GRPH_ES_blank_u(V_num=1)
		"Blank STIM - unsegmented traces [10x]",/Q,FMI_GRPH_ES_blank_u(V_num=10)
		"Blank STIM - unsegmented traces [20+2Hz]",/Q,FMI_GRPH_ES_blank_20plus2()
		"-"
		"Scatter Box Plot",/Q,FMI_ScatterBoxPlot()
		"-"
		"Create extTRIG wave",/Q,FMI_extTRIG_wave()
		"   --> Append extTRIG wave",/Q,FMI_extTRIG_Display2()
		Submenu "STYLE macros"
			"DEFAULT graph prefs",/Q,FMI_GRPHstyle()
			"I-F curve",/Q,IFdisplay()
		End
	End
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_ScatterBoxPlot()
	Variable V_width=0.3
	
	Variable V_num=3
	Prompt V_num,"Number of waves: "
	DoPrompt "Number of Input Waves: ",V_num
		If(V_flag==1)
			return -1
		Endif
	
	Variable i
	String S_WvLst=""
	
	DFREF CDF=GetDataFolderDFR( )
	
	// ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	For(i=0;i<V_num;i+=1)
		WAVE W_sel=FindByBrowser("Input WAVE #"+num2str(i+1))
			If(waveexists(W_sel))
				S_WvLst=AddListItem(GetWavesDataFolder(W_sel,2),S_WvLst,";",inf)
			Endif
	Endfor
	// ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	NewDataFolder/O/S root:Packages:SBP
	
		For(i=1;i<=ItemsinList(S_WvLst);i+=1)
			WAVE w=$StringFromList(i-1,S_WvLst)
			
			String S_WvID=UniqueName("W_X_",1,0)
			Make/N=(numpnts(w))/O $S_WvID
				WAVE W_X=$S_WvID
			
			W_X=i+enoise(V_width)
			
			If(i==1)
				Display/K=1 w vs W_X
			Else
				AppendToGraph w vs W_X
			Endif
		Endfor
		
		ModifyGraph/Z nticks=3,font="Arial",fSize=16,axThick=0.5
		ModifyGraph/Z mode=3,marker=19,axThick(bottom)=0,noLabel(bottom)=2
			Label left "\\u#2EPSC latency (ms)"
			SetAxis left 0,*
	SetDataFolder CDF
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function/WAVE FindByBrowser(DBtitle)
	String DBtitle

	String cmd
	Variable/G V_flag
	String/G S_BrowserList=""
	Sprintf cmd,"CreateBrowser prompt=\""+DBtitle+"\",showWaves=1,showVars=0,showStrs=0"
	Execute cmd
	
	If(V_flag==0)									// ... User cancelled
		Abort
	Elseif(V_flag==1)								// ... User selected 
		WAVE w=$StringfromList(0,S_BrowserList)		// ... first selected item in Data Browser
	Endif
	
	return w
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_addAVGmrk()
	Variable i
	
	DFREF CDF=GetDataFolderDFR( )
	
	String S_grfName=""
	// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	String S_WinLst=WinList("*",";","WIN:1")
			// +++++++++++++++++++++
		If(ItemsinList(S_WinLst)==0)
			Abort "No Graph."
		Else
			S_grfName=StringfromList(0,S_WinLst)
		Endif
		// +++++++++++++++++++++
	// '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	String S_TrcLst=GraphWvLst()
	
	For(i=0;i<ItemsinList(S_TrcLst);i+=1)
		wave W_Y=TraceNameToWaveRef(S_grfName,StringfromList(i,S_TrcLst)) 
		wave W_X=XWaveRefFromTrace(S_grfName,StringfromList(i,S_TrcLst) )
		
		If(waveexists(W_Y))
			WaveStats/Q W_Y
				Variable V_npntsY=V_npnts
				Variable V_avgY=V_avg
				Variable V_sdevY=V_sdev
				Variable V_semY=V_sem
				
				If(V_npntsY==0)
					continue
				Endif
				
				String S_WvNm_avgY=UniqueName(S_grfName+"_wY"+num2str(i)+"_AVG_",1,0)
				String S_WvNm_errY=UniqueName(S_grfName+"_wY"+num2str(i)+"_SEM_",1,0)
				
				MAKE/O/N=1 $S_WvNm_avgY=V_avgY
				MAKE/O/N=1 $S_WvNm_errY=V_semY
				WAVE W_avgY=$S_WvNm_avgY
				WAVE W_errY=$S_WvNm_errY
					CopyScales/P W_Y,W_avgY,W_errY
					
				If(waveexists(W_X))
					WaveStats/Q W_X
					Variable V_npntsX=V_npnts
					Variable V_avgX=V_avg
					Variable V_sdevX=V_sdev
					Variable V_semX=V_sem
					
					String S_WvNm_avgX=UniqueName(S_grfName+"_wX"+num2str(i)+"_AVG_",1,0)
					String S_WvNm_errX=UniqueName(S_grfName+"_wX"+num2str(i)+"_SEM_",1,0)
					
					MAKE/O/N=1 $S_WvNm_avgX=V_avgX
					MAKE/O/N=1 $S_WvNm_errX=V_semX
					WAVE W_avgX=$S_WvNm_avgX
					WAVE W_errX=$S_WvNm_errX
						CopyScales/P W_X,W_avgX,W_errX
						
					AppendToGraph/W=$S_grfName W_avgY vs W_avgX
					ErrorBars/W=$S_grfName $S_WvNm_avgY XY,wave=(W_errX,W_errX),wave=(W_errY,W_errY)
				Else
					AppendToGraph/W=$S_grfName W_avgY
					ErrorBars/W=$S_grfName $S_WvNm_avgY Y,wave=(W_errY,W_errY)
				Endif
				
				ModifyGraph mode($S_WvNm_avgY)=3,marker($S_WvNm_avgY)=19
				
				String S_note=""
				Wavestats/Q/Z W_Y
					S_note+="\rADD AVERAGE MARKER - WAVESTATS FOR Y WAVE ("+NameOfWave(W_Y)+"):"
					S_note+="\r"+Secs2Date(DateTime,2)+" @ "+Secs2Time(DateTime,3)
					S_note+="\r\tAverage: "+num2str(V_avg)+" "+WaveUnits(W_Y,-1)
					S_note+="\r\tStandard deviation (s.d.): "+num2str(V_Sdev)+" "+WaveUnits(W_Y,-1)
					S_note+="\r\tStandard error of mean (s.e.m.): "+num2str(V_Sdev/sqrt(V_npnts))+" "+WaveUnits(W_Y,-1)
					S_note+="\r\tCoefficient of variation (C.V.): "+num2str(V_Sdev/V_avg)
					S_note+="\r\tMedian: "+num2str(StatsMedian(W_Y))+" "+WaveUnits(W_Y,-1)
					S_note+="\r\tSum: "+num2str(sum(W_Y))
					S_note+="\r\tMinimum entry: "+num2str(V_min)+" "+WaveUnits(W_Y,-1)
					S_note+="\r\tMaximum entry: "+num2str(V_max)+" "+WaveUnits(W_Y,-1)
					S_note+="\r\t# overall entries (w NaNs and INFs): "+num2str(numpnts(W_Y))
					S_note+="\r\t# entries (w/o NaNs and INFs): "+num2str(V_npnts)
					S_note+="\r\t# NaNs: "+num2str(V_numNaNs)
					Note/K W_avgY,S_note
				
				If(waveexists(W_X))
				S_note=""
					Wavestats/Q/Z W_X
						S_note+="\rADD AVERAGE MARKER - WAVESTATS FOR X WAVE ("+NameOfWave(W_X)+"):"
						S_note+="\r"+Secs2Date(DateTime,2)+" @ "+Secs2Time(DateTime,3)
						S_note+="\r\tAverage: "+num2str(V_avg)+" "+WaveUnits(W_X,-1)
						S_note+="\r\tStandard deviation (s.d.): "+num2str(V_Sdev)+" "+WaveUnits(W_X,-1)
						S_note+="\r\tStandard error of mean (s.e.m.): "+num2str(V_Sdev/sqrt(V_npnts))+" "+WaveUnits(W_X,-1)
						S_note+="\r\tCoefficient of variation (C.V.): "+num2str(V_Sdev/V_avg)
						S_note+="\r\tMedian: "+num2str(StatsMedian(W_X))+" "+WaveUnits(W_X,-1)
						S_note+="\r\tSum: "+num2str(sum(W_X))
						S_note+="\r\tMinimum entry: "+num2str(V_min)+" "+WaveUnits(W_X,-1)
						S_note+="\r\tMaximum entry: "+num2str(V_max)+" "+WaveUnits(W_X,-1)
						S_note+="\r\t# overall entries (w NaNs and INFs): "+num2str(numpnts(W_X))
						S_note+="\r\t# entries (w/o NaNs and INFs): "+num2str(V_npnts)
						S_note+="\r\t# NaNs: "+num2str(V_numNaNs)
						Note/K W_avgX,S_note
				Endif
		Endif
	Endfor
End

End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Function/S GraphWvLst()
	Variable i
	String WnWvLst=""
		WnWvLst=TraceNameList("",";",1)
		WnWvLst+=ImageNameList("",";")
		do
			wave w = WaveRefIndexed("",i,3)
			If(waveexists(w)==1)
				If(WhichListItem(NameofWave(w),WnWvLst)==-1)
					WnWvLst+=NameofWave(w)+";"		// ... For table windows, type  is 1 for data columns, 2 for index or dimension label columns, 3 for either data or index or dimension label columns.
				Endif
			Endif
			i+=1
		while(waveexists(w)==1)
	Return WnWvLst
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPH_ES_blank()
	Variable i
	Variable V_blnkRNG=3e-3
	
	String S_trcList=GraphWvLst()
	
	For(i=0;i<ItemsInList(S_trcList);i+=1)
		wave w = TraceNameToWaveRef("",StringfromList(i,S_trcList))
		
		If(waveexists(w))
			w[0,x2pnt(w,V_blnkRNG+DimOffset(w,0))]=NaN
		Endif
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPH_ES_blank_20plus2()
	FMI_GRPH_ES_blank_u(V_num=10,V_offset=5,V_step=50e-3)
	FMI_GRPH_ES_blank_u(V_num=6,V_offset=5.5,V_step=500e-3)
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPH_ES_blank_u([V_num,V_offset,V_step,V_blnkRNG])
	Variable V_num
	Variable V_offset
	Variable V_blnkRNG
	Variable V_step
	
	If(ParamIsDefault(V_num))
		V_num=10
	Endif
	If(ParamIsDefault(V_offset))
		V_offset=0.3
	Endif
	If(ParamIsDefault(V_step))
		V_step=50e-3
	Endif
	If(ParamIsDefault(V_blnkRNG))
		V_blnkRNG=3e-3
	Endif
	
	Variable i,i2
	
	String S_trcList=GraphWvLst()
	
	For(i=0;i<ItemsInList(S_trcList);i+=1)
		wave w = TraceNameToWaveRef("",StringfromList(i,S_trcList))
		
		For(i2=0;i2<V_num;i2+=1)
			If(waveexists(w))
				w[x2pnt(w,V_offset+(i2*V_step)),x2pnt(w,V_offset+(i2*V_step)+V_blnkRNG)]=NaN
			Endif
		Endfor
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPH_RMVoffset()
	Variable i
	Variable V_BLstart=25e-3
	Variable V_BLend=75e-3
	
	String S_trcList=GraphWvLst()
	
	For(i=0;i<ItemsInList(S_trcList);i+=1)
		wave w = TraceNameToWaveRef("",StringfromList(i,S_trcList))
		
		If(waveexists(w))
			WaveStats/Q/R=(V_BLstart,V_BLend) w
				w-=V_avg
		Endif
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function Blank()
	Variable i
	Variable V_blnkRNG=3e-3
	
	
	String S_trcList=GraphWvLst()
	
	For(i=0;i<ItemsInList(S_trcList);i+=1)
		wave w = TraceNameToWaveRef("",StringfromList(i,S_trcList))
		
		If(waveexists(w))
			w[0,x2pnt(w,V_blnkRNG+DimOffset(w,0))]=NaN
		Endif
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_extTRIG_wave([V_delay,V_duration,V_num,V_ISI,V_length])
	Variable V_delay,V_duration,V_num,V_ISI,V_length
	
	If(ParamIsDefault(V_delay))
		V_delay=0.3
	Endif
	If(ParamIsDefault(V_duration))
		V_duration=0.5e-3
	Endif
	If(ParamIsDefault(V_num))
		V_num=10
	Endif
	If(ParamIsDefault(V_ISI))
		V_ISI=0.05
	Endif
	If(ParamIsDefault(V_length))
		V_length=1.5
	Endif
	
	If(ParamIsDefault(V_delay) || ParamIsDefault(V_duration) || ParamIsDefault(V_num) || ParamIsDefault(V_ISI) || ParamIsDefault(V_length))
		Prompt V_delay,"Trigger delay [s]:"
		Prompt V_duration,"Trigger duration [s]:"
		Prompt V_num,"Trigger # [s]:"
		Prompt V_ISI,"Trigger ISI  [s]:"
		Prompt V_length,"Trigger length [s]:"
		DoPrompt "Specify extTRIG parameters...", V_delay,V_duration,V_num,V_ISI,V_length
			If(V_flag)
				return -1
			Endif	
	Endif
	
	Variable V_sample=1e-4
	
	Variable i
	
	MAKE/O/N=(V_length/V_sample) $CleanupName("W_extTRG_"+num2str(V_duration),0)=NaN
		WAVE w=$CleanupName("W_extTRG_"+num2str(V_duration),0)
		SetScale/P x,0,V_sample,"s", w
			
	For(i=0;i<V_num;i+=1)
		w[x2pnt(w,V_delay+i*V_ISI),x2pnt(w,V_delay+i*V_ISI+V_duration)]=1
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_extTRIG_Display2([w,S_color])
	WAVE w
	String S_color
	
	If(ParamIsDefault(w))
		WAVE w=FindByBrowser("Select W_extTRG")
	Endif
		
	If(waveexists(w)==0)
		return 0
	Endif
	
	If(ParamIsDefault(S_color))
		S_color="Orange"
		Prompt S_color,"extTRIG wave color: ",popup,"Orange;Red;Black;Blue;Grey;Green"
		DoPrompt "Specify... extTRIG wave color",S_color
			If(V_flag)
				return -1
			Endif
	Endif 
	
	Variable V_R,V_G,V_B
	StrSwitch(S_color)
		case "Orange":
			V_R=65280
			V_G=43520
			V_B=0
			break
			
		case "Red":
			V_R=65280
			V_G=0
			V_B=0
			break
			
		case "Black":
			V_R=0
			V_G=0
			V_B=0
			break
			
		case "Blue":
			V_R=0
			V_G=0
			V_B=65280
			break
			
		case "Grey":
			V_R=26112
			V_G=26112
			V_B=26112
			break
		
		case "Green":
			V_R=0
			V_G=43520
			V_B=0
			break
	Endswitch
	
	AppendToGraph/L=left2 w
	ModifyGraph noLabel(left2)=2,axThick(left2)=0,freePos(left2)=0
	ModifyGraph axisEnab(left)={0,0.96},axisEnab(left2)={0.97,1}
	SetAxis left2 0,1
	ModifyGraph lsize($Nameofwave(w))=1,rgb($Nameofwave(w))=(V_R,V_G,V_B),mode($Nameofwave(w))=1
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_extTRIG_Display()
	String S_ID="STIM_VCtest*"

	DFREF CDF=GetDataFolderDFR( )
	
	Variable i,i2
	
	String S_DFLst=ListMatch(DFList(),S_ID)
		
	If(ItemsInList(S_DFLst)==0)
		return -1
	Endif
	
	Variable V_BLstart=25e-3				// [s]
	Variable V_BLend=75e-3
	
	DoWindow/K $"extTRIG_Display_EPSC"
	DoWindow/K $"extTRIG_Display_IPSC"
	
	For(i=0;i<ItemsinList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
			String S_WvLst=GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)")	// ALL TRACES
			
			For(i2=0;i2<ItemsInList(S_WvLst);i2+=1)
				WAVE w=$StringfromList(i2,S_WvLst)
				
				If(i2==0)
					// ... infer holding potential (class)
					String/G S_holdCLASS
					Variable/G V_holdCLASS
					
					WaveStats/Q/R=(V_BLstart,V_BLend) w					
						If(V_avg<2e-11)			// empirically chosen & DIRTY: in a healthy cell @ a holding potential of -70mV (very little) negative current has to be injected
							S_holdCLASS="EPSC"
							V_holdCLASS=1
						ElseIf(V_avg>=2e-11)		// empirically chosen & DIRTY: in a healthy cell @ a holding potential of 0mV, (considerable) negative current has to be injected
							S_holdCLASS="IPSC"
							V_holdCLASS=2
						Endif
				Endif
	
				DoWindow $"extTRIG_Display_"+S_holdCLASS
					If(V_flag)
						AppendToGraph/W=$"extTRIG_Display_"+S_holdCLASS w
					Else
						Display/K=1 w
					DoWindow/C $"extTRIG_Display_"+S_holdCLASS
					Endif
			Endfor
			
		SetDataFolder CDF
	Endfor

End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Static Constant CBarHeight=24

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_IF_display(M_V,W_I_master,S_ID)
	WAVE M_V,W_I_master
	String S_ID
	
	If(waveexists(W_I_master)==0 || waveexists(M_V)==0)
		return 0
	Endif 
		
	DFREF CDF=GetDataFolderDFR( )
	
	Variable i
	
	String S_DFLst=ListMatch(DFList(),S_ID)
		
	If(ItemsInList(S_DFLst)==0)
		return -1
	Endif
	
	String S_win=ReplaceString("*",ReplaceString("!",S_ID,""),"")
	
	SetDataFolder $StringfromList(0,S_DFLst)
		WAVE W_I=FMI_matchStrToWaveRef("W_IF_I*",0)
		WAVE W_V=FMI_matchStrToWaveRef("W_IF_V*",0)
		
		If(waveexists(W_I)==0 || waveexists(W_V)==0)
			SetDataFolder CDF
			return -2
		Endif 
		
		InsertPoints/M=1 0,1,M_V 
		
		For(i=0;i<numpnts(W_I);i+=1)
			FindValue/T=1e-15/V=(W_I[i]) W_I_master 
			
			If(V_value!=-1)	// value found
				M_V[V_value][0]=W_V[i]
			Endif
		Endfor
		
		DoWindow $S_win
			If(V_flag)		// window exists
				AppendToGraph/W=$S_win W_V vs W_I
			Else
				Display/K=1 W_V vs W_I
					DoWindow/C $S_win
			Endif
	SetDataFolder CDF
End


// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_rstPlot_display([V_mode])
	Variable V_mode
	
	If(ParamIsDefault(V_mode)) 					// default: parameter is not specified
		V_mode=0		// 0: unsegmented traces; 1: segmented traces
	Endif
	
	Variable i,V_count
	
	Variable V_RGB_max=65280
	
	DFREF CDF=GetDataFolderDFR( )
	
	If(DataFolderExists("TRC_analysis_SPK"))
		SetDataFolder :TRC_analysis_SPK
	ElseIf(DataFolderExists("TRC_analysis_EVT"))
		SetDataFolder :TRC_analysis_EVT
	Else
		return 0
	Endif
		
		String S_Lst_Xtms=GrepList(WaveList("*_tr*",";",""),"(Xtms$)")
			S_Lst_Xtms=SortList(S_Lst_Xtms)	// ... this sorting step avoids unwanted behavior, in which segments from more than one trace are later displayed in the same graph  
				
		For(i=0;i<ItemsInList(S_Lst_Xtms);i+=1)
			WAVE W_Xtms=$StringFromList(i,S_Lst_Xtms)
			
			SetDataFolder ::
				Switch(V_mode)
					case 0:
						WAVE W_trc=$FMI_StringfromString(note(W_Xtms),"segment.parentWAVE: ")
					break
					
					case 1:
						WAVE W_trc=$ReplaceString("_Xtms",nameofwave(W_Xtms),"")
					break
				Endswitch
				
				If(waveexists(W_trc)&&waveexists(W_Xtms))
					String S_trcID_full=FMI_StringfromString(note(W_trc),"pFolder2: ")+"_"+FMI_StringfromString(note(W_trc),"pFolder1: ")+FMI_StringfromString(note(W_trc),"pFolder: ")+FMI_StringfromString(note(W_trc),"Field3: ")
					
					String S_txt="\\Z10 "+FMI_StringfromString(note(W_Xtms),"segment.ID: ")+": "+num2str(DimSize(W_Xtms,0))+" spike(s) detected"
					
					DoWindow $S_trcID_full
						// ..............................................................................
						If(V_flag==0)	// window does not exist
							Display/K=1 W_trc;AppendToGraph/R W_Xtms[][1] vs W_Xtms[][0]
								DoWindow/C $S_trcID_full
								
							TextBox/C/N=$S_trcID_full/F=0/B=1/A=LB/X=0.00/Y=0.00/E=2 S_txt
							ModifyGraph margin(bottom)=57
							
							// Add Control Bar
							GetWindow kwTopWin,wsize
							ControlInfo kwControlBar
							If(V_height==0)
								ControlBar CBarHeight
								MoveWindow/W=$S_trcID_full V_left,V_top,V_right,V_bottom+CBarHeight
							Endif
							Button Button_RSTplot_Exclusion,pos={1,2},size={80,20},proc=ButtonProc_FMI_Ephus_RSTplot,title="Exclude trace"
							Button Button_RSTplot_Rescale,pos={85,2},size={80,20},proc=ButtonProc_FMI_Ephus_RSTplot,title="Rescale View"
								
							V_count=0
							
							SetWindow kwTopWin,userdata(fullDF)+=GetWavesDataFolder(W_trc,1)	// full path of data folder containing waveName, without wave name.
							SetWindow kwTopWin,userdata(trcID)+=FMI_StringfromString(note(W_trc),"pFolder1: ")+FMI_StringfromString(note(W_trc),"pFolder: ")+FMI_StringfromString(note(W_trc),"Field3: ")
							
						// ..............................................................................	
						Elseif(V_flag==1) // window exists
							Switch(V_mode)
								case 0:
								break
								
								case 1:
									AppendToGraph W_trc
								break
							Endswitch
							AppendToGraph/R W_Xtms[][1] vs W_Xtms[][0]
								
							V_count+=1
						Endif
							ModifyGraph lsize=0.5,rgb($nameofwave(W_trc))=(0,0,0)
							ModifyGraph mode($nameofwave(W_Xtms))=1
							ModifyGraph nticks=3,axThick=0.5,font="Arial",fsize=14
							ModifyGraph nticks(right)=0,noLabel(right)=2,axThick(right)=0
							ModifyGraph axisEnab(left)={0,0.95},axisEnab(right)={0.96,1}
							SetAxis right 0,1
							ModifyGraph margin(right)=14
							
							Switch(V_count)
								default:
									ModifyGraph/Z rgb($nameofwave(W_trc))=(0,0,0)		// BLACK
									ModifyGraph/Z rgb($nameofwave(W_Xtms))=(0,0,0)		// BLACK
								break
								case 1:
									If(V_mode)
										ModifyGraph/Z rgb($nameofwave(W_trc))=(V_RGB_max,0,0)		// RED
									Endif
									ModifyGraph/Z rgb($nameofwave(W_Xtms))=(V_RGB_max,0,0)	// RED
									AppendText/W=$S_trcID_full /N=$S_trcID_full "\K("+num2str(V_RGB_max)+",0,0)"+S_txt
								break
								case 2:
									If(V_mode)
										ModifyGraph/Z rgb($nameofwave(W_trc))=(0,0,V_RGB_max)		// BLUE
									Endif
									ModifyGraph/Z rgb($nameofwave(W_Xtms))=(0,0,V_RGB_max)	// BLUE
									AppendText/W=$S_trcID_full /N=$S_trcID_full "\K(0,0,"+num2str(V_RGB_max)+")"+S_txt
								break
								case 3:
									If(V_mode)
										ModifyGraph/Z rgb($nameofwave(W_trc))=(0,V_RGB_max/2,0)		// GREEN
									Endif
									ModifyGraph/Z rgb($nameofwave(W_Xtms))=(0,V_RGB_max/2,0)		// GREEN
									AppendText/W=$S_trcID_full /N=$S_trcID_full "\K(0,"+num2str(V_RGB_max/2)+",0)"+S_txt
								break
							Endswitch
				Endif
			
			If(DataFolderExists("TRC_analysis_SPK"))
				SetDataFolder :TRC_analysis_SPK
			ElseIf(DataFolderExists("TRC_analysis_EVT"))
				SetDataFolder :TRC_analysis_EVT
			Endif
		Endfor
	
	SetDataFolder CDF 
End


// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function ButtonProc_FMI_Ephus_RSTplot(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	Variable i
	
	DFREF CDF=GetDataFolderDFR( )
	
	switch( ba.eventCode )
		case 2: // mouse up
			StrSwitch(ba.ctrlName)
			
				// ..............................................................................	
				case "Button_RSTplot_Exclusion":
					SetDataFolder $GetUserData(ba.win,"","fullDF")
						DFREF DF=GetDataFolderDFR( )
						
						String S_trcID=GetUserData(ba.win,"","trcID")
						
						String S_DFnm=GetDataFolder(0)
						
						String S_trcLst=WaveList(S_trcID+"*",";","")
						String S_trcLst_anl=""
						String S_trcLst_org=""
						
						// .................................................. WAVE LISTS ...............................................
						If(ItemsinList(S_trcLst)==0)
							SetDataFolder CDF
							return 0
						Endif
						
						If(DataFolderExists("TRC_analysis_SPK"))
							SetDataFolder :TRC_analysis_SPK
								DFREF DF_anl=GetDataFolderDFR( )
								S_trcLst_anl=WaveList(S_trcID+"*",";","")
							SetDataFolder DF
						Endif
						
						If(DataFolderExists("unsegmented_traces"))
							SetDatafolder :unsegmented_traces
								DFREF DF_org=GetDataFolderDFR( )
								S_trcLst_org=WaveList(S_trcID+"*",";","")
							SetDataFolder DF
						Endif
						
						// .................................................. DATA FOLDERS ...............................................
						NewDataFolder/O/S ::EXCLUDED
							DFREF exclDF=GetDataFolderDFR( )
							NewDataFolder/O/S :$S_DFnm
								DFREF dDF=GetDataFolderDFR( )
						
						If(ItemsinList(S_trcLst_anl)>0)
							SetDataFolder dDF
								NewDataFolder/O/S :TRC_analysis_SPK
									DFREF dDF_anl=GetDataFolderDFR( )
						Endif
						
						If(ItemsinList(S_trcLst_org)>0)	
							SetDataFolder dDF
								NewDataFolder/O/S :unsegmented_traces
									DFREF dDF_org=GetDataFolderDFR( )
						Endif

						
					SetDataFolder DF
						// .................................................. REMOVE TRACES  FROM GRAPH ...............................................
						String S_grfTRCLst=TraceNameList("",";",1)
						
						For(i=0;i<ItemsinList(S_grfTRCLst);i+=1)
							RemoveFromGraph/W=$ba.win/Z $StringfromList(i,S_grfTRCLst)
						Endfor

						// .................................................. MOVE WAVES ...............................................
						For(i=0;i<ItemsinList(S_trcLst);i+=1)
							WAVE W_trc=$StringfromList(i,S_trcLst)
								SetDataFolder dDF
									Duplicate/O W_trc,:$nameofwave(W_trc)
									Killwaves/Z W_trc
								SetDataFolder DF
						Endfor			

					SetDataFolder DF_anl
						For(i=0;i<ItemsinList(S_trcLst_anl);i+=1)
							WAVE W_trc=$StringfromList(i,S_trcLst_anl)
								SetDataFolder dDF_anl
									Duplicate/O W_trc,:$nameofwave(W_trc)
									Killwaves/Z W_trc
								SetDataFolder DF_anl 
						Endfor
					
					SetDataFolder DF_org
						For(i=0;i<ItemsinList(S_trcLst_org);i+=1)
							WAVE W_trc=$StringfromList(i,S_trcLst_org)
								SetDataFolder dDF_org
//								SetDataFolder exclDF
									Duplicate/O W_trc,:$nameofwave(W_trc)
									Killwaves/Z W_trc
								SetDataFolder DF_org 
						Endfor
						
					SetDataFolder CDF 
					
					KillWindow $ba.win
				break
				
				// ..............................................................................	
				case "Button_RSTplot_Rescale":
					SetAxis/A
					SetAxis right 0,1
				break
			Endswitch
		break
		
		case -1: // control being killed
		break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_2Ch_display([V_rng])
	Variable V_rng
	Variable i
	String S_matchStr1="*_tr1"
	String S_matchStr2="*_tr2"
	
	String DFsav=GetDataFolder(1)
	
	String S_WvLst1=WaveList(S_matchStr1,";","")
	String S_WvLst2=WaveList(S_matchStr2,";","")
	
	For(i=0;i<ItemsinList(S_WvLst1);i+=1)
		If(V_rng!=0 && i==V_rng)
			break
		Endif
		
		WAVE/Z W_trc1=$StringfromList(i,S_WvLst1)
		WAVE/Z W_trc2=$ReplaceString(ReplaceString("*",S_matchStr1,""),StringfromList(i,S_WvLst1),ReplaceString("*",S_matchStr2,""))
		
		If(waveexists(W_trc1)&&waveexists(W_trc2))
			Display/K=1 W_trc1;AppendToGraph/R W_trc2
				ModifyGraph lsize=0.5,rgb($nameofwave(W_trc1))=(0,0,0),rgb($nameofwave(W_trc2))=(65280,0,0)
				ModifyGraph nticks=3,axThick=0.5,font="Arial",fsize=14
		Endif
	Endfor
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Proc IFdisplay() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z mode=4
	ModifyGraph/Z marker=19
	ModifyGraph/Z lSize=0.5
	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(0,39168,0),rgb[2]=(0,0,65280)
	ModifyGraph/Z opaque=1
	ModifyGraph/Z nticks=3
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	ModifyGraph/Z axThick=0.5
	Label/Z left "\\u#2Firing rate (Hz)"
	Label/Z bottom "\\u#2I\\Bstim\\M (pA)"
	SetAxis/Z bottom 5e-12,1.0000001e-10
	SetAxis/A=2 left
EndMacro

Proc BPstyle() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z mode[0]=5,mode[1]=1,mode[2]=5,mode[3]=1,mode[4]=5,mode[5]=1
	ModifyGraph/Z marker[1]=8,marker[3]=8,marker[5]=8
	ModifyGraph/Z rgb[2]=(0,39168,0),rgb[3]=(0,39168,0),rgb[4]=(0,0,65280),rgb[5]=(0,0,65280)
	ModifyGraph/Z msize[3]=0.5
	ModifyGraph/Z opaque[1]=1,opaque[3]=1,opaque[5]=1
	ModifyGraph/Z hbFill[0]=2,hbFill[2]=2,hbFill[4]=2
	ModifyGraph/Z useMrkStrokeRGB[1]=1,useMrkStrokeRGB[3]=1,useMrkStrokeRGB[5]=1
	ModifyGraph/Z zero(left)=2
	ModifyGraph/Z nticks(left)=3
	ModifyGraph/Z noLabel(bottom)=2
	ModifyGraph/Z fSize(left)=16
	ModifyGraph/Z lblMargin(left)=5
	ModifyGraph/Z axThick(bottom)=0
	ModifyGraph/Z lblLatPos(left)=6
	Label/Z left "\\u#2<EPSC amplitude> (pA)"
	SetAxis/Z left 0,*
	SetAxis/Z bottom 0,7
EndMacro

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GraphPrefs(S_type,[S_win])
	String S_type
	String S_win
	
	If(ParamIsDefault(S_win))
		S_win=WinName(0,1)		// 0=index; 1=Graph windows (window type) 
	Endif
	
	ModifyGraph nticks=3,axThick=0.5,font="Arial"
	ModifyGraph lsize=0.5,rgb=(0,0,0)
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_KillAllPlots([S_matchStr])
	String S_matchStr
	
	If(ParamIsDefault(S_matchStr)) 		// default: parameter is not specified
		S_matchStr="*"
	Endif
	
	Variable i
	
	String S_kWnLst=WinList(S_matchStr,";","WIN:3")									// ... graphs/tables
	
	For(i=0;i<ItemsinList(S_kWnLst);i+=1)
		DoWindow/K $StringfromList(i,S_kWnLst)
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPHstyle()
	String S_WinLst=WinList("*",";","WIN:1")
		If(ItemsinList(S_WinLst)==0)
			return -1
		Endif

		ModifyGraph lsize=0.5
		ModifyGraph nticks=3,axThick=0.5,font="Arial",fsize=16
		ModifyGraph mode=4,marker=8,opaque=1
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GRPHstyle_Vm_vs_t()
	String S_WinLst=WinList("*",";","WIN:1")
		If(ItemsinList(S_WinLst)==0)
			return -1
		Endif
		
		ModifyGraph lsize=0.5
		ModifyGraph nticks=3,axThick=0.5,font="Arial",fsize=16
		ModifyGraph nticks(right)=0,axThick(right)=0
		Label left "\\u#2V\\Bm\\M (mV)"
		Label bottom "\\u#2 Time (s)"
		ModifyGraph margin(right)=14
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

//Proc Graph0Style() : GraphStyle
//	PauseUpdate; Silent 1		// modifying window...
//	ModifyGraph/Z margin(left)=14,margin(bottom)=14
//	ModifyGraph/Z mode[1]=1
//	ModifyGraph/Z rgb[1]=(0,0,65280)
//	ModifyGraph/Z nticks(left)=3,nticks(bottom)=3
//	ModifyGraph/Z font(left)="Arial",font(bottom)="Arial"
//	ModifyGraph/Z noLabel=2
//	ModifyGraph/Z fSize(left)=16,fSize(bottom)=16
//	ModifyGraph/Z axThick=0
//	ModifyGraph/Z lblPos=73
//	ModifyGraph/Z freePos(left2)=-50
//	ModifyGraph/Z axisEnab(left)={0,0.95}
//	ModifyGraph/Z axisEnab(left2)={0.98,1}
//	SetAxis/Z/A=2 left
//	SetAxis/Z bottom 0.3,1.3
//	SetAxis/Z left2 0,1
//EndMacro
//
//Proc Graph0_3Style() : GraphStyle
//	PauseUpdate; Silent 1		// modifying window...
//	ModifyGraph/Z margin(left)=14,margin(bottom)=14
//	ModifyGraph/Z mode[1]=1
//	ModifyGraph/Z lSize[0]=0.5,lSize[1]=0.5
//	ModifyGraph/Z rgb[0]=(65280,0,0),rgb[1]=(0,0,65280),rgb[2]=(26112,0,0)
//	ModifyGraph/Z nticks(left)=3,nticks(bottom)=3
//	ModifyGraph/Z font(left)="Arial",font(bottom)="Arial"
//	ModifyGraph/Z noLabel=2
//	ModifyGraph/Z fSize(left)=16,fSize(bottom)=16
//	ModifyGraph/Z axThick=0
//	ModifyGraph/Z lblPos(left)=73,lblPos(bottom)=73,lblPos(left2)=73
//	ModifyGraph/Z freePos(left2)=-50
//	ModifyGraph/Z freePos(left3)=0
//	ModifyGraph/Z axisEnab(left)={0.15,0.95}
//	ModifyGraph/Z axisEnab(left2)={0.98,1}
//	ModifyGraph/Z axisEnab(left3)={0,0.15}
//	SetAxis/Z/A=2 left
//	SetAxis/Z bottom 0.3,1.3
//	SetAxis/Z left2 0,1
//	SetAxis/Z left3 -4e-11,0
//	ToolsGrid snap=1,visible=1
//	SetWindow kwTopWin,hook(FVTB_hook)=FVTB_hook
//EndMacro

Proc APamp_vs_APthrStyle() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z margin(top)=43
	ModifyGraph/Z mode=3
	ModifyGraph/Z marker[0]=8,marker[1]=8,marker[2]=8,marker[3]=19,marker[4]=19,marker[5]=19
	ModifyGraph/Z lSize=0.5
	ModifyGraph/Z rgb[0]=(65280,0,0),rgb[1]=(0,52224,0),rgb[2]=(0,0,65280),rgb[3]=(65280,0,0)
	ModifyGraph/Z rgb[4]=(0,52224,0),rgb[5]=(0,0,65280)
	ModifyGraph/Z mrkThick[0]=0.75,mrkThick[1]=0.75,mrkThick[2]=0.75
	ModifyGraph/Z nticks=3
	ModifyGraph/Z font="Arial"
	ModifyGraph/Z fSize=16
	Label/Z left "\\u#2AP amplitude (mV)"
	Label/Z bottom "\\u#2 AP threshold (mV)"
EndMacro
