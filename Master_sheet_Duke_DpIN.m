%% MASTERSHEET LOADER
clear;

% sfxLST= {'_c212_NT','_dlx_NT','_c212','_dlx'};
% osLST= [1];

% sfxLST= {'_c212','_dlx','_dlxOB','_gad'};
% osLST= [2];

sfxLST= {'_c212','_dlx'};
osLST= [1];

% sfxLST= {'_dlx'};
% osLST= [1];

% sfxLST= {'_c212','_dlx'};
% osLST= [1 2];
 
% sfxLST= {'_c212','_dlx'};
% osLST= [2];

% sfxLST= {'_c212GFPneg','_c212GFPpos','_dlxGFPneg','_dlxGFPpos'};
% osLST= [21];

clrvar= 1;

%%
for i = 1:size(osLST,2)
    osnum= osLST(i);
    
    for j = 1:size(sfxLST,2)
        sfxNOW= sfxLST{j};
        
        Master_sheet_Load_DpIN
        Master_sheet_script_tdCaFMI_DpIN
        
        tmpFMI_DpIN_basicANL
        
        saveStr= strcat('C:\Users\tfrank\Dropbox (Personal)\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\fishdata_fullANL\tmp_fullANL',sfxNOW,'_os',num2str(osnum),'.mat');
        saveStr= strcat('D:\Dropbox\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\fishdata_fullANL\tmp_fullANL',sfxNOW,'_os',num2str(osnum),'.mat');
    
        save(saveStr);
        
        if clrvar == 1
            clearvars -except osLST sfxLST osnum i j clrvar;
        end
    end
end


