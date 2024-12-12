#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include ":FMI_Ephus"

Menu "Ephus"
	Submenu "IMPORT"
		"Import *.mat files",/Q,FMI_matIMPORT()
	End
	Submenu "EXPORT"
		"Ephus pulse designer",/Q,FMIpd_InitPanel()
	End
	Submenu "DATA HANDLING"
		"Group CDF --> iterations",/Q,FMI_GROUPit()
		"unGroup CDF",/Q,FMI_unGROUPit()
	End
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_InitPanel()
	DFREF CDF=GetDataFolderDFR( )
	
	DefaultGuiFont/Win all= {"MS Sans Serif", 12, 0} 
	DoWindow PulseDesigner // ... assign this name (not a string) to the panel  
		If(V_flag==1)
			DoAlert 1, "One panel of this type is already existing - Do you want to replace it by a new one (note: this will re-initialze the values, controlled by the panel)?"
				If(V_flag==2)
					return -1
				ElseIf(V_flag==1)
					DoWindow/K PulseDesigner
				Endif
		Endif
	
	FMIpd_InitVar()
	
	NVAR FMIpd_tabValue=root:Packages:FMIpd:FMIpd_tabValue
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1/W=(700,61,1157,559) as "Ephus Pulse Designer"
	DoWindow/C PulseDesigner
		SetDrawLayer UserBack
	
	// simple tab
	SetVariable FMIpd_t0_length,pos={8,25},size={134,16},bodyWidth=60,proc=FMIpd_SetVarProc,title="Base length (s)"
	SetVariable FMIpd_t0_length,format="%.3f"
	SetVariable FMIpd_t0_length,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_length
	SetVariable FMIpd_t0_tnum,pos={36,70},size={106,16},bodyWidth=40,proc=FMIpd_SetVarProc,title="Train number"
	SetVariable FMIpd_t0_tnum,format="%.0f"
	SetVariable FMIpd_t0_tnum,limits={1,inf,1},value= root:Packages:FMIpd:FMIpd_tnum
	SetVariable FMIpd_t0_tISI,pos={36,92},size={106,16},bodyWidth=58,proc=FMIpd_SetVarProc,title="Train ISI (s)"
	SetVariable FMIpd_t0_tISI,format="%.4f"
	SetVariable FMIpd_t0_tISI,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_tISI
	SetVariable FMIpd_t0_twidth,pos={24,115},size={118,16},bodyWidth=58,proc=FMIpd_SetVarProc,title="Train width (s)"
	SetVariable FMIpd_t0_twidth,format="%.4f"
	SetVariable FMIpd_t0_twidth,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_twidth
	SetVariable FMIpd_t0_tdelay,pos={24,137},size={118,16},bodyWidth=58,proc=FMIpd_SetVarProc,title="Train delay (s)"
	SetVariable FMIpd_t0_tdelay,format="%.4f"
	SetVariable FMIpd_t0_tdelay,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_tdelay
	SetVariable FMIpd_t0_srnum,pos={192,25},size={111,16},bodyWidth=40,proc=FMIpd_SetVarProc,title="Series number"
	SetVariable FMIpd_t0_srnum,format="%.3f"
	SetVariable FMIpd_t0_srnum,limits={1,inf,1},value= root:Packages:FMIpd:FMIpd_srnum
	SetVariable FMIpd_t0_srdeltaAMP,pos={152,46},size={151,16},bodyWidth=60,proc=FMIpd_SetVarProc,title="Series delta (AMP)"
	SetVariable FMIpd_t0_srdeltaAMP,format="%.3f"
	SetVariable FMIpd_t0_srdeltaAMP,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_srdeltaAMP
	SetVariable FMIpd_t0_srdeltaTIME,pos={149,67},size={154,16},bodyWidth=60,proc=FMIpd_SetVarProc,title="Series delta (TIME)"
	SetVariable FMIpd_t0_srdeltaTIME,format="%.3f"
	SetVariable FMIpd_t0_srdeltaTIME,limits={0.0001,inf,0.001},value= root:Packages:FMIpd:FMIpd_srdeltaTIME
	CheckBox FMIpd_t0_srAMPact,pos={232,89},size={71,14},proc=FMIpd_CheckProc,title="AMP series"
	CheckBox FMIpd_t0_srAMPact,variable= root:Packages:FMIpd:FMIpd_srAMPact
	CheckBox FMIpd_t0_srTIMEact,pos={229,110},size={74,14},proc=FMIpd_CheckProc,title="TIME series"
	CheckBox FMIpd_t0_srTIMEact,variable= root:Packages:FMIpd:FMIpd_srTIMEact
	SetVariable FMIpd_t0_amp,pos={4,48},size={138,16},bodyWidth=60,proc=FMIpd_SetVarProc,title="Base amp (a.u.)"
	SetVariable FMIpd_t0_amp,format="%.3f"
	SetVariable FMIpd_t0_amp,limits={-inf,inf,0.001},value= root:Packages:FMIpd:FMIpd_amp
	
	// complex tab
	ListBox FMIpd_t1_SegmentList,pos={4,24},size={250,125},proc=FMIpd_ListBoxProc
	ListBox FMIpd_t1_SegmentList,listWave=root:Packages:FMIpd:M_content
	ListBox FMIpd_t1_SegmentList,selWave=root:Packages:FMIpd:M_selection
	ListBox FMIpd_t1_SegmentList,titleWave=root:Packages:FMIpd:W_collbl,mode= 6
	ListBox FMIpd_t1_SegmentList,editStyle= 1,widths={50},userColumnResize= 0
	Button FMIpd_t1_ADDBEFseg,pos={263,24},size={120,20},proc=FMIpd_ButtonProc,title="Add segment before"
	Button FMIpd_t1_ADDAFTseg,pos={263,48},size={120,20},proc=FMIpd_ButtonProc,title="Add segment after"
	Button FMIpd_t1_DELseg,pos={263,72},size={120,20},proc=FMIpd_ButtonProc,title="Delete current segment"
	Button FMIpd_t1_LOAD,pos={393,24},size={60,20},proc=FMIpd_ButtonProc,title="LOAD"
	Button FMIpd_t1_UNLOAD,pos={393,48},size={60,20},proc=FMIpd_ButtonProc,title="UNLOAD"
	
	// general controls
	TabControl FMIpd_ta_TabType,pos={1,1},size={120,20},proc=FMIpd_TabProc
	TabControl FMIpd_ta_TabType,tabLabel(0)="simple",tabLabel(1)="complex",value= FMIpd_tabValue
	SetVariable FMIpd_ta_PthNm,pos={11,162},size={376,16},bodyWidth=350,title="Path"
	SetVariable FMIpd_ta_PthNm,value= root:Packages:FMIpd:FMIpd_PthNm,noedit=1
	SetVariable FMIpd_ta_WvNm,pos={5,187},size={192,16},bodyWidth=160,title="Name"
	SetVariable FMIpd_ta_WvNm,value= root:Packages:FMIpd:FMIpd_WvNm
	SetVariable FMIpd_ta_totlength,pos={263,132},size={124,16},bodyWidth=50,title="Total length (s)"
	SetVariable FMIpd_ta_totlength,format="%.3f"
	SetVariable FMIpd_ta_totlength,limits={-inf,inf,0},value= root:Packages:FMIpd:FMIpd_totlength,noedit= 1
	Button FMIpd_ta_SETPATH,pos={393,160},size={60,20},proc=FMIpd_ButtonProc,title="SET PATH"
	Button FMIpd_ta_EXPORT,pos={203,185},size={60,20},proc=FMIpd_ButtonProc,title="EXPORT"
	Button FMIpd_ta_POPOUT,pos={393,185},size={60,20},proc=FMIpd_ButtonProc,title="POPOUT"
	
	// subwindow
	Display/W=(8,211,448,490)/HOST=#  root:Packages:FMIpd:W_stim
	ModifyGraph lSize=0.5
	ModifyGraph rgb=(0,0,0)
	ModifyGraph nticks=3
	ModifyGraph font="Arial"
	ModifyGraph axThick=0.5
	RenameWindow #,G0
	SetActiveSubwindow ##
	
	FMIpd_TabSwitch()
	
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_InitVar()
	DFREF CDF=GetDataFolderDFR( )
	
	SetDataFolder root:
		NewDataFolder/O/S :Packages
		NewDataFolder/O/S :FMIpd
		
		Variable/G FMIpd_smplrate=10000,FMIpd_totlength=0
		Variable/G FMIpd_length=2,FMIpd_amp=5,FMIpd_tnum=1,FMIpd_tISI=1,FMIpd_twidth=0.5,FMIpd_tdelay=0.5
		Variable/G FMIpd_srnum=1,FMIpd_srdeltaAMP=5,FMIpd_srdeltaTIME=0.1
		Variable/G FMIpd_srAMPact=0,FMIpd_srTIMEact=0
		Variable/G FMIpd_tabValue=1
		
		String/G FMIpd_WvNm="stim",FMIpd_PthNm=""
		
		WAVE/D W_stim
		If(waveexists(W_stim))
			Note/K W_stim
		Endif
		
		KillPath/Z FMIpd_SavePath
		
		Make/O/T/N=2 W_collbl={"Segment length (s)","Amplitude (a.u.)"}
		Make/O/T/N=(5,2) M_content
			M_content[][0]="0.5"
			M_content[][1]="0";M_content[1][1]="-5";M_content[3][1]="5"
		Make/O/N=(5,2) M_selection;M_selection= q==0 ? 6 : 6
	
	SetDataFolder CDF
		
	FMIpd_CREATEwvs()
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			FMIpd_CREATEwvs()	
		break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	DFREF CDF=GetDataFolderDFR( )
	
	Setdatafolder root:Packages:FMIpd:
		String S_VARLst_act=VariableList("*act",";",4)
		
		String S_ctrlName=ReplaceString("_t0",cba.ctrlName,"")
		
		switch( cba.eventCode )
			case 2: // mouse up
				// ... reference the global variable that matches the control Name (they are initialized with the same name as its variable) 
					NVAR V=$StringfromList(WhichListItem(S_ctrlName,S_VARLst_act),S_VARLst_act) 
				// ... set it to the current value of the check box
					V=cba.checked
			
				Variable i
				// ... go through all global variables "checked*"
				For(i=0;i<ItemsinList(S_VARLst_act);i+=1)						
					
					String S_ctrlName_CHECK=ReplaceString("FMIpd_",StringfromList(i,S_VARLst_act),"FMIpd_t0_")
					String S_ctrlName_SETVAR=ReplaceString("FMIpd_sr",ReplaceString("act",StringfromList(i,S_VARLst_act),""),"FMIpd_t0_srdelta")
					
					// ... if control Name does not show match with the ith variable from 'VLst_checked'
					If(cmpstr(S_ctrlName,StringfromList(i,S_VARLst_act))!=0)	
						// ... reference this global variable
							NVAR V=$StringfromList(i,S_VARLst_act)				
						// ... set it to 0
							V=0													
						// ... accordingly, adjust the value of its control name (to 0)
						 	CheckBox $S_ctrlName_CHECK,value=0
						 	SetVariable $S_ctrlName_SETVAR,disable=2
					Else
						SetVariable $S_ctrlName_SETVAR,disable=0
					Endif
				Endfor
				
			break
		endswitch
	
	SetDataFolder CDF
	
	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_ListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave

	switch( lba.eventCode )
		case 1: // mouse down
			break
		case 3: // double click
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			FMIpd_CREATEwvs()
		break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_TabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			NVAR FMIpd_tabValue=root:Packages:FMIpd:FMIpd_tabValue
			FMIpd_tabValue=tca.tab
			FMIpd_TabSwitch()
		break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	DFREF CDF=GetDataFolderDFR( )
	
	switch( ba.eventCode )
		case 2: // mouse up
			WAVE/T M_content=root:Packages:FMIpd:M_content
			WAVE M_selection=root:Packages:FMIpd:M_selection
			WAVE/D W_stim=root:Packages:FMIpd:W_stim
			
			NVAR FMIpd_smplrate=root:Packages:FMIpd:FMIpd_smplrate
			NVAR FMIpd_totlength=root:Packages:FMIpd:FMIpd_totlength
			SVAR FMIpd_WvNm=root:Packages:FMIpd:FMIpd_WvNm
			
			Variable V_row
			
			If(DimSize(M_selection,0)>1)
				ImageStats/Q M_selection
			Else
				V_row=0
			Endif
			
			
			StrSwitch(ba.ctrlName)
				case "FMIpd_t1_ADDBEFseg":
					V_row=V_maxRowLoc
				break
				case "FMIpd_t1_ADDAFTseg":
					V_row=V_maxRowLoc+1
				break
			Endswitch
			
			StrSwitch(ba.ctrlName)
				// ...............................................................................................................................................................................................
				case "FMIpd_t1_ADDBEFseg":
				case "FMIpd_t1_ADDAFTseg":
					If(DimSize(M_selection,0)>1 && V_sdev==0) 	// no cell selected
						break
					Endif
					
					InsertPoints/M=0 V_row, 1, M_content,M_selection
						M_content[V_row][0]={"0.5"}
						M_content[V_row][1]={"0"}
						M_selection= p==V_row ? 7 : 6
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_t1_DELseg":
					If(V_sdev==0) 	// no cell selected
						break
					Endif
					
					If(DimSize(M_selection,0)>1)
						DeletePoints/M=0 V_maxRowLoc,1,M_content,M_selection
							M_selection[V_maxRowLoc-1<0 ? 0 : V_maxRowLoc-1][]=7
					Endif
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_t1_LOAD":
					WAVE w=FindByBrowser("select wave")
					
					If(waveexists(w))
						If(WaveType(w)==2)						// FP32
							SetDataFolder root:Packages:FMIpd:
								Duplicate/O w,W_tmp
								If(deltax(W_tmp)!=1/FMIpd_smplrate)
									Resample/RATE=(FMIpd_smplrate) W_tmp
								Endif
									
								MAKE/D/O/N=(numpnts(W_tmp)) W_stim
								CopyScales/P W_tmp,W_Stim
								W_stim=W_tmp
								Killwaves/Z W_tmp
							SetDataFolder CDF
						
						Elseif(WaveType(w)==4)					// FP64
							SetDataFolder root:Packages:FMIpd:
								Duplicate/O w,W_tmp
								If(deltax(W_tmp)!=1/FMIpd_smplrate)
									Resample/RATE=(FMIpd_smplrate) W_tmp
								Endif
								
								Duplicate/O W_tmp,W_Stim
								Killwaves/Z W_tmp
							SetDataFolder CDF
						
						Else
							Print "Selected wave not flotaing point type" 
							return -1
						Endif
						
						FMIpd_WvNm=CleanupName(nameOfWave(w),0)
						Note/K W_stim,"LOCKED by LOAD"
					Endif
					
					FMIpd_totlength=numpnts(W_stim)/FMIpd_smplrate
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_t1_UNLOAD":
					SetDataFolder root:Packages:FMIpd:
						WAVE/D W_stim
						Note/K W_stim
					SetDataFolder CDF
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_ta_EXPORT":
					PathInfo FMIpd_SavePath
						If(V_flag==0)								// path does not exist
							If(FMIpd_SetSavePath()==-1)			// path not set
								break
							Endif
						Endif
					
					// check if file exists already
					GetFileFolderInfo/P=FMIpd_SavePath/Q/Z=1 FMIpd_WvNm+".txt"
						If(V_flag==-1)								// user cancelled the Open File dialog.
							return -1
						Elseif(V_flag==0 && V_isFile==1)			// file exists
							DoAlert/T="File name conflict" 1, "A file with the same name exists already in this path. Do you want to overwrite the existing file?"
								If(V_flag==2)						// no clicked
									return -1
								Endif
						Endif
					
					// check if path is still valid 
					GetFileFolderInfo/P=FMIpd_SavePath/Q/Z=1
						If(V_flag!=0)
							FMIpd_SetSavePath()
						Endif
						
					Rename W_stim,$CleanupName(FMIpd_WvNm,0) 
					Save/G/O/W/P=FMIpd_SavePath W_stim as FMIpd_WvNm+".txt"
						Print "\rEPHUS PULSE DESIGNER on: "+Secs2Date(DateTime,2)+" @ "+Secs2Time(DateTime,3)+"\r\tExported "+ FMIpd_WvNm 
					Rename W_stim,W_stim
								
					If(DataFolderExists("root:Packages:FMIpd:EXPORT")==0)
						NewDataFolder/S root:Packages:FMIpd:EXPORT
					Else
						SetDataFolder root:Packages:FMIpd:EXPORT
					Endif
					
					Duplicate/O W_stim,$FMIpd_WvNm
						Note/K $FMIpd_WvNm,"\rEPHUS PULSE DESIGNER\rcreated on: "+Secs2Date(DateTime,2)+" @ "+Secs2Time(DateTime,3)	
					SetDataFolder CDF
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_ta_SETPATH":
					FMIpd_SetSavePath()
				break
				
				// ...............................................................................................................................................................................................
				case "FMIpd_ta_POPOUT":
					Display/K=1 W_stim
				break
			Endswitch
			
			FMIpd_CREATEwvs()
		break
	endswitch

	return 0
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_SetSavePath()
	SVAR FMIpd_PthNm=root:Packages:FMIpd:FMIpd_PthNm
	
	GetFileFolderInfo/D/Q/Z=2 "" 		// opens dialog for selecting a folder (/D flag; rather than open file dialog
		If (V_flag==-1)				// user cancelled theopen folder dialog
			return -1
		Endif
		
		If (V_isFolder==1)
			NewPath/O/Q FMIpd_SavePath S_path
			FMIpd_PthNm=S_path
			
			return 1
		Else
			return -1	 
		Endif
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_TabSwitch()
	NVAR FMIpd_tabValue=root:Packages:FMIpd:FMIpd_tabValue
	
	Variable i,V_set
	
	Switch(FMIpd_tabValue)
		default:
			String S_CtrlLst_KEY=ControlNameList("PulseDesigner")
			
			For(i=0;i<ItemsinList(ControlNameList("PulseDesigner"));i+=1)
				If(stringmatch(StringfromList(i,ControlNameList("PulseDesigner")),"*_t"+num2str(FMIpd_tabValue)+"_*")==1)
					V_set=0
				Elseif(stringmatch(StringfromList(i,ControlNameList("PulseDesigner")),"*_ta_*")==1)
					V_set=0
				Else
					V_set=1
				Endif
				S_CtrlLst_KEY=ReplaceString(StringfromList(i,ControlNameList("PulseDesigner")),S_CtrlLst_KEY, StringfromList(i,ControlNameList("PulseDesigner"))+":"+num2str(V_set))
			Endfor
			
			For(i=0;i<ItemsinList(ControlNameList("PulseDesigner"));i+=1)
				ControlInfo/W=PulseDesigner $StringfromList(i,ControlNameList("PulseDesigner"))
				
				Switch(abs(V_flag))
					case 1: 	// Button
						Button $StringfromList(i,ControlNameList("PulseDesigner")),disable=NumberByKey(StringfromList(i,ControlNameList("PulseDesigner")),S_CtrlLst_KEY)
					break
					
					case 2:	// CheckBox
						CheckBox $StringfromList(i,ControlNameList("PulseDesigner")),disable=NumberByKey(StringfromList(i,ControlNameList("PulseDesigner")),S_CtrlLst_KEY)
					break
					
					case 5:	// SetVariable
						SetVariable $StringfromList(i,ControlNameList("PulseDesigner")),disable=NumberByKey(StringfromList(i,ControlNameList("PulseDesigner")),S_CtrlLst_KEY)
					break
					
					case 11:	// ListBox
						ListBox $StringfromList(i,ControlNameList("PulseDesigner")),disable=NumberByKey(StringfromList(i,ControlNameList("PulseDesigner")),S_CtrlLst_KEY)
					break
				Endswitch
			Endfor
									
			FMIpd_CREATEwvs()
		break
	Endswitch
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMIpd_CREATEwvs()
	DFREF CDF=GetDataFolderDFR( )
	
	SetDataFolder root:Packages:FMIpd:
		NVAR FMIpd_smplrate,FMIpd_totlength
		NVAR FMIpd_length,FMIpd_amp,FMIpd_tnum,FMIpd_tISI,FMIpd_twidth,FMIpd_tdelay
		NVAR FMIpd_srnum,FMIpd_srdeltaAMP,FMIpd_srdeltaTIME
		NVAR FMIpd_srAMPact,FMIpd_srTIMEact
		NVAR FMIpd_tabValue
		SVAR FMIpd_WvNm
		
		Variable V_autoNM=0
		
		WAVE/T M_content
		
		Variable i
		
		WAVE/D/Z W_stim
		If(waveexists(W_stim))
			If(cmpstr(note(W_stim),"LOCKED by LOAD")==0)
				SetDataFolder CDF
				return -1
			Endif
		Endif
				
		Switch(FMIpd_tabValue)
			// ...............................................................................................................................................................................................
			case 0: // simple tab active
				Make/D/O/N=(FMIpd_length*FMIpd_smplrate) W_stim
					WAVE/D W_stim
					FastOP W_stim=0
					SetScale/P x,0,1/FMIpd_smplrate,"s",W_stim
					
				Variable V_number=FMIpd_tnum
				Variable V_ISI=FMIpd_tISI*FMIpd_smplrate
				Variable V_width=FMIpd_twidth*FMIpd_smplrate
				Variable V_delay=FMIpd_tdelay*FMIpd_smplrate
				
				If(V_autoNM)
					FMIpd_WvNm=""
				Endif
				
				For(i=0;i<V_number;i+=1)
					W_stim[V_delay+i*V_ISI,(V_delay+i*V_ISI+V_width)-1]=FMIpd_amp
				Endfor
				
				If(V_autoNM)
					If(FMIpd_amp<0)
						FMIpd_WvNm+="hp"
					ElseIf(FMIpd_amp>0)
						FMIpd_WvNm+="dp"
					Endif
					FMIpd_WvNm+=num2str(FMIpd_twidth*1000)+"ms_"+num2str(abs(FMIpd_amp))+"pA"
				Endif
			break
			
			// ...............................................................................................................................................................................................
			case 1:	// complex tab active
				MAKE/D/O/N=0 W_stim
					WAVE W_stim
					SetScale/P x,0,1/FMIpd_smplrate,"s",W_stim
				
				If(V_autoNM)
					FMIpd_WvNm=""
				Endif
				
				For(i=0;i<DimSize(M_content,0);i+=1)
					Variable V_Pnum=numpnts(W_stim)
					Variable V_Pstart=V_Pnum
//					Variable V_Pend=V_Pnum+str2num(M_content[i+1][0])*FMIpd_smplrate
					
					InsertPoints V_Pnum,str2num(M_content[i][0])/deltax(W_stim),W_stim
					
					W_stim[V_Pstart,]=str2num(M_content[i][1])
					
					If(str2num(M_content[i][1])==0)
						continue
					Else
						If(V_autoNM)
							If(strlen(FMIpd_WvNm)!=0)
								FMIpd_WvNm+="_"
							Endif
							
							If(str2num(M_content[i][1])<0)
								FMIpd_WvNm+="hp"
							ElseIf(str2num(M_content[i][1])>0)
								FMIpd_WvNm+="dp"
							Endif
						
							FMIpd_WvNm+=num2str(str2num(M_content[i][0])*1000)+"ms_"+num2str(abs(str2num(M_content[i][1])))+"pA"
						Endif
					Endif
				Endfor
			break
		Endswitch
		
		FMIpd_totlength=numpnts(W_stim)/FMIpd_smplrate
		
	SetDataFolder CDF
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_matIMPORT()
	Variable i,i2
	String S_matList
	String S_path,S_folder,S_pfolder1,S_pfolder2
	
	Variable V_bit=2	// 32bit FP
//	Variable V_bit=4	// 64bit FP
	
	String DFsav=GetDataFolder(1)
	
	SetDataFolder root:
	
	Open/D/R/M="Locate folder by selecting any *.mat file "/T=".mat" V_refnum
		If(strlen(S_filename)==0)
			return -1
		Endif
	
	S_pfolder2=ParseFilePath(0,S_filename,":",1, 3)		// 'grandparent folder'		(e.g. E_130101)
	S_pfolder1=ParseFilePath(0,S_filename,":",1, 2)		// 'parent' folder			(e.g. TF001)
	S_folder=ParseFilePath(0,S_filename,":",1, 1)		// folder 					(e.g. AAAA)
	S_path=ParseFilePath(1,S_filename,":",1, 0)			// complete filepath
	Newpath/Q/O P_path,S_path
	
	String S_pPathStr=S_pfolder2+"_"+S_pfolder1+"_"+S_folder
	
	S_matList=IndexedFile(P_path,-1,".mat")
		If(ItemsinList(S_MatList)==0)
			return -1
		Endif
	
	// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ DATA FOLDER section \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	If(strlen(S_pfolder2)!=0&&strlen(S_pfolder1)!=0)
		If(DataFolderExists(S_pfolder2+"_"+S_pfolder1)==0)
			NewDataFolder/O/S $S_pfolder2+"_"+S_pfolder1
		Else
			SetDataFolder $S_pfolder2+"_"+S_pfolder1
		Endif
	Endif
	
	If(DataFolderExists(S_folder)==0)
		NewDataFolder/O/S $S_folder
	Else
		SetDataFolder $S_folder
	Endif
	
	// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ IMPORT section \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	For(i=0;i<ItemsInList(S_matList);i+=1)
		MLLoadWave/Q/O/S=3/P=P_path/N=$ReplaceString(".mat",StringFromList(i,S_matList),"")/C/Y=(V_bit)/E/V/G StringFromList(i,S_matList)
	Endfor
	
	Variable V_refNum
	Open/P=P_path/R/Z=1 V_refNum as S_pfolder1+".txt"
		If(V_flag==0)						// file was opened
			DoWindow $"NB_"+S_pPathStr
				If(V_flag)
					DoWindow/K $"NB_"+S_pPathStr
				Endif
			NewNotebook/F=1/K=2/N=$"NB_"+S_pPathStr /W=(12.75,74.75,565.5,812)/V=1 as S_pPathStr+"_"+S_pfolder1+".txt"
			Notebook $"NB_"+S_pPathStr,backRGB=(60928,60928,60928)
			
			Variable V_linNum, V_len
			String S_buffer
			V_linNum = 0
			do
				FReadLine V_refNum, S_buffer
				V_len = strlen(S_buffer)
				if (V_len == 0)
					break							// No more lines to be read
				endif
				
				Notebook $"NB_"+S_pPathStr,selection={endofFile,endofFile},findText={"",0},text= S_buffer
				
				V_linNum += 1
			while (1)
		
			Close V_refNum
		Endif
	
	String S_WvLst=WaveList("*_tr*",";","")
		For(i=0;i<ItemsInList(S_WvLst);i+=1)
			WAVE/Z W_trc=$StringfromList(i,S_WvLst)
			
			String S_note=""
			Variable V_trc
			
			String S_INTL,S_FLD1,S_FLD2,S_FLD3
			sscanf NameOfWave(W_trc),"%2[A-Za-z]%4[0-9]%4[A-Za-z]%4[0-9]",S_INTL,S_FLD1,S_FLD2,S_FLD3
				String S_WVstr=S_INTL+S_FLD1+S_FLD2+S_FLD3
				S_note+="\rpFolder2: "+S_pfolder2
				S_note+="\rpFolder1: "+S_pfolder1
				S_note+="\rpFolder: "+S_folder
				S_note+="\rInitials: "+S_INTL
				S_note+="\rField1: "+S_FLD1
				S_note+="\rField2: "+S_FLD2
				S_note+="\rField3: "+S_FLD3
				
				V_trc=str2num(ReplaceString(S_WVstr+"_tr",NameOfWave(W_trc),""))
			
			If(V_trc==2)
			
			Endif
			
			WAVE/Z/T W_Hd00=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd00")
			WAVE/Z/T W_Hd01=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd01")
			WAVE/Z W_Hd10=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd10")
			WAVE/Z/T W_Hd11=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd11")
				
			// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ STRING section \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
			If(waveexists(W_Hd00)&&waveexists(W_Hd01))
				
				If(cmpstr(note(W_Hd00),"LOCKED")!=0) 	// avoid re-transformation of header waves (in case of 2 channel data)
					String S_Hd00=W_Hd00[0]
					String S_Hd01=W_Hd01[0]
					KillWaves/Z $NameOfWave(W_Hd00),$NameOfWave(W_Hd01)
					
					MAKE/O/T/N=0 $ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd00"),$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd01")
						WAVE/Z/T W_Hd00=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd00")
						WAVE/Z/T W_Hd01=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd01")
					
					do
						InsertPoints numpnts(W_Hd00),1, W_Hd00,W_Hd01
						W_Hd00	[numpnts(W_Hd00)-1]=StringfromList(numpnts(W_Hd00)-1,S_Hd00)
						W_Hd01[numpnts(W_Hd01)-1]=StringfromList(numpnts(W_Hd01)-1,S_Hd01)
					while(numpnts(W_Hd00)<ItemsInList(S_Hd00))
					
					Note/K W_Hd00,"LOCKED"
				Endif			
				
				For(i2=0;i2<numpnts(W_Hd00);i2+=1)
					If(stringmatch(W_Hd01[i2],"Ch*")==1)						// match --> channel-dependent information
						If(stringmatch(W_Hd01[i2],"Ch"+num2str(V_trc)+"*")==0)	// no match --> inappropriate channel
							continue
						Endif
					Endif
					S_note+="\r\t"+W_Hd01[i2]+": "+W_Hd00[i2]
				Endfor
			Endif
			
			// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ VARIABLE section \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
			If(waveexists(W_Hd10)&&waveexists(W_Hd11))
				
				If(cmpstr(note(W_Hd10),"LOCKED")!=0)		// avoid re-transformation of header waves (in case of 2 channel data)
					String S_Hd11=W_Hd11[0]
					KillWaves/Z $NameOfWave(W_Hd11)
					MAKE/O/T/N=0 $ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd11")
						WAVE/Z/T W_Hd11=$ReplaceString("tr"+num2str(V_trc),StringFromList(i,S_WvLst),"Hd11")
					
					do
						InsertPoints numpnts(W_Hd11),1, W_Hd11
						W_Hd11[numpnts(W_Hd11)-1]=StringfromList(numpnts(W_Hd11)-1,S_Hd11)
					while(numpnts(W_Hd11)<ItemsInList(S_Hd11))
					
					Note/K W_Hd10,"LOCKED"
				Endif	
				
				For(i2=0;i2<numpnts(W_Hd10);i2+=1)
					If(stringmatch(W_Hd11[i2],"Ch*")==1)						// match --> channel-dependent information
						If(stringmatch(W_Hd11[i2],"Ch"+num2str(V_trc)+"*")==0)	// no match --> inappropriate channel
							continue
						Endif
					Endif
					S_note+="\r\t"+W_Hd11[i2]+": "+num2str(W_Hd10[i2])
				Endfor
			Endif
			
			Note/K W_trc,S_note
					
			SetScale/P x,0,1/FVCV_ValuefromString(S_note,"ephys.sampleRate: "),"s",W_trc
			
			strswitch(FMI_StringfromString(S_note,"Ch"+num2str(V_trc)+".input_units: "))	
				case "pA":
					W_trc*=1e-12
					SetScale d 0,0,"A",W_trc
				break						
				
				case "mV":
					W_trc*=1e-3
					SetScale d 0,0,"V",W_trc
				break
			endswitch
		Endfor
		
		Killwvs("*_Hd*")		// ...kill all header waves
		
		FMI_GROUPit()
		
	SetDataFolder $DFsav
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_slimDF([V_grade])
	Variable V_grade
	
	If(ParamIsDefault(V_grade)) 	// default: parameter is not specified
		V_grade=0			
	Endif
	
	Variable i
	String S_Lst_Kill,S_Lst_tmp
	
	
	If(DataFolderExists(":TRC_analysis_SPK"))
		SetDataFolder :TRC_analysis_SPK
			
			Switch(V_grade)
				case 0:	// slimming lite
					S_Lst_Kill=WaveList("*_DIF",";","")
					S_Lst_Kill+=WaveList("*_APs",";","")
				break
				
				case 1:	// keeping display & further analysis capabilities
					S_Lst_tmp=WaveList("*_Xtms",";","")
					S_Lst_tmp+=WaveList("*_ISI",";","")
					S_Lst_tmp+=WaveList("*_AP_",";","")
					
					S_Lst_Kill=RemoveFromList(S_Lst_tmp,WaveList("*",";",""))
				break
				
				case 2:
					S_Lst_Kill=WaveList("*",";","")	// all waves
				break
			
			Endswitch
			
			For(i=0;i<itemsinList(S_Lst_Kill);i+=1)
				WAVE w=$StringfromList(i,S_Lst_Kill)
				Killwaves/Z w
			Endfor
			
		SetDataFolder ::
	Endif
	
	If(DataFolderExists(":TRC_analysis_EVT"))
		SetDataFolder :TRC_analysis_EVT
			
			Switch(V_grade)
				case 0:	// slimming lite
					S_Lst_Kill=WaveList("*_DIF*",";","")
					S_Lst_Kill+=WaveList("*_smth",";","")
				break
				
				case 1:	// keeping display capabilities
					S_Lst_tmp=WaveList("*_Xtms",";","")
					S_Lst_tmp+=WaveList("*_IEI",";","")
									
					S_Lst_Kill=RemoveFromList(S_Lst_tmp,WaveList("*",";",""))
				break
				
				case 2:
					S_Lst_Kill=WaveList("*",";","")	// all waves
				break
			
			Endswitch
			
			For(i=0;i<itemsinList(S_Lst_Kill);i+=1)
				WAVE w=$StringfromList(i,S_Lst_Kill)
				Killwaves/Z w
			Endfor
			
		SetDataFolder ::
	Endif
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_GROUPit([S_matchStr])
	String S_matchStr
	
	Variable i
	
	If(ParamIsDefault(S_matchStr)) 	// default: parameter is not specified
		S_matchStr="*"			
	Endif
	
	String S_WvLst=SortList(WaveList(S_matchStr,";",""))

	DFREF CDF=GetDataFolderDFR( )
	
	Variable V_RTerror
	String S_NDF
	// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: SORTING INTO DFs :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<ItemsinList(S_WvLst);i+=1)
		WAVE w=$StringfromList(i,S_WvLst)
		
		Variable V_NUMiter=FVCV_ValuefromString(note(w),"loop.iterations: ")
		Variable V_CNTiter=FVCV_ValuefromString(note(w),"loop.iterationCounter: ")
		
		If(V_NUMiter>0)
			If(V_CNTiter==1)
				NewDataFolder/O/S $UniqueName(CleanUpName(ReplaceString("x",ReplaceString("ms_",ReplaceString("CCstep",FMI_StringfromString(note(w),"ephys.pulseName: "),"CC"),"_"),"")+"_n",0),11,0)
					V_RTerror=GetRTError(1)
				
					DFREF NDF=GetDataFolderDFR( )
					S_NDF=GetDataFolder(0)
					
					If(V_RTerror==0)
						FMI_stimWV(w)
						
						Variable/G V_extTRIG=str2num(FMI_StringfromString(note(w),"stim.externalTrigger: "))
					Endif
				SetDataFolder CDF
				
				If(V_RTerror!=0)
					Print "No unique base name could be created for "+nameofwave(w)+". Grouping for iterations was skipped." 
					continue
				Endif
			
			Else
				If(StringMatch(S_NDF,"*"+CleanUpName(ReplaceString("x",ReplaceString("ms_",ReplaceString("CCstep",FMI_StringfromString(note(w),"ephys.pulseName: "),"CC"),"_"),""),0)+"*")==0)
					NewDataFolder/O/S $UniqueName(CleanUpName(ReplaceString("x",ReplaceString("ms_",ReplaceString("CCstep",FMI_StringfromString(note(w),"ephys.pulseName: "),"CC"),"_"),"")+"_n",0),11,0)
						V_RTerror=GetRTError(1)
					
						DFREF NDF=GetDataFolderDFR( )
						S_NDF=GetDataFolder(0)
						
						If(V_RTerror==0)
							FMI_stimWV(w)
						Endif
					SetDataFolder CDF
				
				Endif
			Endif
			
			If(V_RTerror==0)
				Duplicate/O w, NDF:$nameofwave(w)
				Killwaves/Z w
			Endif
		Else
			continue
		Endif
	Endfor
	
	NewDataFolder/O :EXCLUDED
	
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_unGROUPit([V_dialog])
	Variable V_dialog
	
	If(ParamIsDefault(V_dialog)) 	// default: parameter is not specified
		V_dialog=1			
	Endif
	
	Variable i,i2,i3
	
	DFREF CDF=GetDataFolderDFR( )
	String S_DFLst=DFList()
	
	If(V_dialog==1)
		If(ItemsinList(S_DFLst)>0)
			DoAlert/T="WARNING..." 1, "This will only recover the original traces from the folders in the current data folder (and 1 level of sub-folders) - any other waves (e.g. analysis results and segmented waves) will be lost. Proceed anyway?"
				Switch(V_flag)
					case 1:	//YES
					break
					default:	// NO
						return -1
					break
				Endswitch  
		Endif
	Endif
		
	// :::::::::::::::::::::::::::::::::::::::::::::::: EXCLUDED DF - special treatment ::::::::::::::::::::::::::::::::::::::::::
	If(DataFolderExists("EXCLUDED"))
		S_DFLst=RemoveFromList("EXCLUDED",S_DFLst)
		
		SetDataFolder :EXCLUDED
			String S_DFLst_EXCL=DFList()
			
			For(i=0;i<ItemsinList(S_DFLst_EXCL);i+=1)
				SetDataFolder $StringfromList(i,S_DFLst_EXCL)
					KillDataFolder/Z TRC_analysis_SPK
					KillDataFolder/Z TRC_analysis_EVT
				SetDataFolder ::
			Endfor
			
		SetDataFolder CDF
	Endif
	
	// :::::::::::::::::::::::::::::::::::::::::::::::: KILL all waves in CDF (e.g. PVector) ::::::::::::::::::::::::::::::::::::::::::
	Killwaves/Z/A
	
	// :::::::::::::::::::::::::::::::::::::::::::::::: REMAINING DFs ::::::::::::::::::::::::::::::::::::::::::
	For(i=0;i<ItemsinList(S_DFLst);i+=1)
		SetDataFolder $StringfromList(i,S_DFLst)
			DFREF ODF=GetDataFolderDFR( )
			String S_WvLst=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!*_s*")
			
			For(i2=0;i2<ItemsinList(S_WvLst);i2+=1)
				WAVE w=$StringfromList(i2,S_WvLst)
				Duplicate/O w, CDF:$nameofwave(w)
				Killwaves/Z w
			Endfor
			
			// :::::::::::::::::::::::::::::::::::::::::::::::::: recognizes 1 level of SUBFOLDERS (content in lower levels is DESTROYED) :::::::::::::::::::::::::::::::::::::
			If(ItemsInList(DFList())>0)
				String S_sDFLst=DFList()
				For(i2=0;i2<ItemsinList(S_sDFLst);i2+=1)
					SetDataFolder $StringfromList(i2,S_sDFLst)
						DFREF sDF=GetDataFolderDFR( )
						String S_sWvLst=ListMatch(GrepList(WaveList("*_tr*",";",""),"(tr1$|tr2$)"),"!*_s*")
						
					For(i3=0;i3<ItemsinList(S_sWvLst);i3+=1)
						WAVE w=$StringfromList(i3,S_sWvLst)
						Duplicate/O w, CDF:$nameofwave(w)
						Killwaves w
					Endfor
					KillDataFolder sDF
				Endfor
			Endif
			// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			
			KillDataFolder/Z ODF
		SetDataFolder CDF	
	Endfor
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Function FMI_stimWV(w[,V_rate])
	WAVE w
	Variable V_rate					// [Hz]
	
	Variable i
	
	If(ParamIsDefault(V_rate)) 	// default: parameter is not specified
		V_rate=1000			// [Hz]
	Endif
	
	If(cmpstr(FMI_StringfromString(note(w),"ephys.type: "),"squarePulseTrain")!=0)
		return -1
	Endif
	
	String S_wvNm=FMI_StringfromString(note(w),"Initials: ")+FMI_StringfromString(note(w),"Field1: ")+FMI_StringfromString(note(w),"Field2: ")+FMI_StringfromString(note(w),"Field3: ")+"_stim"
	Make/O/N=(FVCV_ValuefromString(note(w),"ephys.traceLength: ")*V_rate) $S_wvNm
		WAVE W_stim=$S_wvNm
	
	Variable V_number=FVCV_ValuefromString(note(w),"ephys.trainNumber: ")
	Variable V_ISI=FVCV_ValuefromString(note(w),"ephys.trainISI: ")*V_rate
	Variable V_width=FVCV_ValuefromString(note(w),"ephys.trainWidth: ")*V_rate
	Variable V_delay=FVCV_ValuefromString(note(w),"ephys.trainDelay: ")*V_rate
	
	If(V_delay>0)
		W_stim[,V_delay-1]=0
	Endif
	
	For(i=0;i<V_number;i+=1)
		W_stim[V_delay+i*V_ISI,(V_delay+i*V_ISI+V_width)-1]=FVCV_ValuefromString(note(w),"ephys.amp: ")
	Endfor
	W_stim[(V_delay+i*V_ISI+V_width),]=0
	
	String S_units
	Variable V_scale
	Strswitch(FMI_StringfromString(note(w),"Ch"+num2str(FMItrcnum(w))+".input_units: "))
		case "mV":
			S_units="A"
			V_scale=1e-12
		break
		case "pA":
			S_units="V"
			V_scale=1e-3
		break
	Endswitch
	
	SetScale/P x,0,1/V_rate,"s",W_stim
	SetScale d 0,0,S_units,W_stim
	W_stim*=V_scale
End

// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
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