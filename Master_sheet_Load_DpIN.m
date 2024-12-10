%% LOAD DATA
Dropbox_path = 'C:\Users\tfrank\Dropbox (Personal)';
Dropbox_path = 'D:\Dropbox';

grpnum= 1;
tdCa= 1;
tdCaid= 1;
PCdims= 15;
zsc = -2; % no further processing
CODstrct = 1; 
vsum = 0; % no summation of spikes (AUC) 
minZ= 50;
minZ= 0; % changed to 0 on 20.03.23
maxZ= 260;
    
ACSexcl= 0;
RSPexcl= 1;
PLNexcl= 0;
Zexcl= 1;
XYexcl= 0;
xyinfo = 0;
VALexcl= 0; % 1: dVALtun, 2: dAROC, 3: dd', 4: AROCsr
selVAL= 0; % valence index cutoff - yes or no
xyinfo= 0;
mixLST = [];

% added on 23.10.24
ContrE= 1;

TRLdisp = 1;

% -------------------------------------------------------------------------
% ELECTRICAL STIMULATION DATA
if osnum == 1
    if tdCa == 1
%         load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\TF_timeXroi_es_predictions_smoothing_',num2str(tdCaid),'.mat'));
%         input= predicted_spikes; clear predicted_spikes;

        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_es_x.mat'));
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_es_x_causal.mat'));
        input= spike_rates'; clear spike_rates;

%         load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_es7.mat'));
%         input= spike_prob'; clear spike_prob;

    else
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_input\Original_dF_traces\TF_timeXroi_es.mat'));
        input= dF_traces'; clear dF_traces;
    end
    
    % "manual" compilation of trial list for this data set
    s1 = {'t05C','t05C','t05P','t05P'};
    s2 = {'t10C','t10C','t10P','t10P'};
    s3 = {'t20C','t20C','t20P','t20P'};
    s4 = {'t30C','t30C','t30P','t30P'};
    s5 = {'t50C','t50C','t50P','t50P'};
    s6 = {'t75C','t75C','t75P','t75P'};
    trlLST = vertcat(s1,s2,s3,s4,s5,s6);
    
    % Initialize GENERAL parameters
    bsl1 = 8;
    bsl0 = 16;
    nfrm = 120;
    cutdim = 6;
    thres = 1; 
    RSPonly = 0; % setting this to 1 will lead to non-paired neuron sets for population analyses between psC conditions
    CODstrct = 0;
    % dummy...
%     AmIidx= [1 2 5 6; 1 2 4 6; 1 3 5 6; 1 3 4 6; 2 3 5 6; 2 3 4 6];

    % Initialize parameters - DpIN - 212C - NT
    if strcmp(sfxNOW,'_c212_NT') == 1
        rsp1 = 32; rsp0 = 72;
        DATA.grp(1).input = input(:, 1:2940);
        roinum = [258 351 270 357 242 214 322 91 91 68 55 230 161 78 97 55];
        plnZ= [70 40 60 40 25 70 50 70 90 105 120 35 50 100 85 90];
        
    % Initialize parameters - DpIN - dlx - NT
    elseif strcmp(sfxNOW,'_dlx_NT') == 1
        rsp1 = 32; rsp0 = 72;
        DATA.grp(1).input = input(:, 4005:4005+1051);
        roinum = [39 149 67 55 136 305 166 59 26 50];
        plnZ= [80 30 60 100 70 25 40 65 115 95];

    % Initialize parameters - DpIN - 212C - pDp
    elseif strcmp(sfxNOW,'_c212') == 1
        rsp1 = 47; rsp0 = 77;
        rsp1 = 32; rsp0 = 77;
        rsp1 = 32; rsp0 = 120;
        DATA.grp(1).input = input(:, 2941:2941+1063);
        roinum = [161 63 37 63 86 82 81 91 83 99 108 110];
        plnZ= [120 70 60 70 70 90 105 120 150 100 85 90];
            
    elseif strcmp(sfxNOW,'_dlx') == 1
        rsp1 = 47; rsp0 = 77;
        rsp1 = 32; rsp0 = 77;
        rsp1 = 32; rsp0 = 120;
        DATA.grp(1).input = input(:, 5057:5057+2419);
        roinum = [147 130 143 152 50 73 109 89 90 150 196 130 166 152 183 180 150 130];
        plnZ= [91 80 120 140 30 60 130 100 70 40 80 65 95 115 80 95 115 95];
    end
    
    sx = {'s1','s2','s3','s4','s5','s6'};
    clear(sx{:});
    clear sx;

% -------------------------------------------------------------------------
% ODOR STIMULATION DATA (old os8)
elseif osnum == 2 
    if tdCa == 1
%         load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\TF_timeXroi_os8_predictions_smoothing_',num2str(tdCaid),'.mat'));
%         input= predicted_spikes; clear predicted_spikes;

        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_os8_x.mat'));
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_os8_x_causal.mat'));
        input= spike_rates'; clear spike_rates;
        
%         load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_os87.mat'));
%         input= spike_prob'; clear spike_prob;
    else
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_input\Original_dF_traces\TF_timeXroi_os8.mat'));
        input= dF_traces'; clear dF_traces;
    end
    
    % "manual" compilation of trial list for this data set
    s1 = {'PheC','PheC','PheP','PheP'};
    s2 = {'TrpC','TrpC','TrpP','TrpP'};
    s3 = {'MetC','MetC','MetP','MetP'};
    s4 = {'LysC','LysC','LysP','LysP'};
    s5 = {'F+MC','F+MC','F+MP','F+MP'};
    s6 = {'W+KC','W+KC','W+KP','W+KP'};
    s7 = {'BmxC','BmxC','BmxP','BmxP'};
    s8 = {'FexC','FexC','FexP','FexP'};
    s9 = {'sptC','sptC','sptP','sptP'};
    trlLST = vertcat(s1,s2,s3,s4,s5,s6,s7,s8,s9);
    
     % Initialize GENERAL parameters
    bsl1 = 8;
    bsl0 = 16;
    nfrm = 160;
    cutdim = 8;
%     cutdim = 6;
    thres = 1;

    % subdivision selection
%     minZ= 0; maxZ= 180; % --> pDp, but not dpDp
%     minZ= 185; maxZ= 300; % --> dpDp, but not pDp
    
    % XXX tried on 27.09.24
    % minZ= 210; maxZ= 300; % --> dpDp, but not pDp
    minZ= 0; maxZ= 300; % --> dpDp, but not pDp

    RSPonly = 0; % setting this to 1 will lead to non-paired neuron sets for population analyses between psC conditions
    % {"Phe:Trp","Phe:F+M","Met:F+M","Trp:W+K","Lys:W+K"}
    % {"Bmx:Fex","Phe:Fex","Met:Bmx","Trp:Fex","Lys:Bmx"}
    % 2019 - initial 
    AmIidx= [1 2 7 8; 1 5 1 8; 3 5 3 7; 2 6 2 8; 4 6 4 7];
    % 2021 - update ("all Fex")
    AmIidx= [1 2 7 8; 1 5 1 8; 3 5 3 8; 2 6 2 8; 4 6 4 8];
    
    % Initialize parameters - DpIN - 212C
    if strcmp(sfxNOW,'_c212') == 1
        rsp1 = 32; rsp0 = 48;
        rsp1 = 32; rsp0 = 56;
        DATA.grp(1).input = input(:, 1:1314);
        roinum = [113 122 82 128 139 122 115 90 70 106 114 113];
        plnZ= [175 160 215 190 210 230 260 260 180 220 180 210];
        
    % Initialize parameters - DpIN - dlx
    elseif strcmp(sfxNOW,'_dlx') == 1
        rsp1 = 32; rsp0 = 48;
        rsp1 = 32; rsp0 = 56;
        DATA.grp(1).input = input(:, 1315:1315+1992);
        roinum = [133 88 77 103 84 98 168 95 52 101 79 85 123 101 141 125 129 106 105];
        plnZ= [140 115 180 130 100 160 190 260 240 245 165 225 225 200 230 205 220 200 260];
    end
    
    sx = {'s1','s2','s3','s4','s5','s6','s7','s8','s9'};
    clear(sx{:});
    clear sx;

% -------------------------------------------------------------------------    
% ODOR STIMULATION DATA (old os4)
elseif osnum == 21
    if tdCa == 1
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_os4x_Global_EXC_7.5Hz_smoothing200ms_causalkernel_.mat'));
        load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_output\predictions_TF_timeXroi_os4x_OGB_zf_pDp_7.5Hz_smoothing200ms_causalkernel_.mat'));
        input= spike_rates'; clear spike_rates;
    else
       load(strcat(Dropbox_path,'\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\___DECONV_input\Original_dF_traces\TF_timeXroi_os4.mat'));
       input= dF_traces'; clear dF_traces;
    end
    
    % "manual" compilation of trial list for this data set
    trlLST= {'AmxC','AmxC';'Rm3C','Rm3C';'Rm4C','Rm4C';'ArgC','ArgC';'Rm6C','Rm6C';'Rm7C','Rm7C';'LysC','LysC';'PheC','PheC';'TrpC','TrpC';'MetC','MetC';'HisC','HisC';'BmxC','BmxC';'TDCC','TDCC';'GCAC','GCAC';'NmxC','NmxC';'ATPC','ATPC';'ACSC','ACSC';'sptC','sptC'};
    ntrl= size(trlLST,2);
    
    % remove Arg concentration series, ACSF and nos odor trials
    odrSEL= [1 0 0 1 0 0 1 1 1 1 1 1 1 1 1 1 0 0];
%     odrSEL= [0 0 0 0 0 0 1 1 1 1 0 1 0 0 0 0 0 0];
    
    % Initialize GENERAL parameters
    bsl1 = 8;   bsl0 = 16;
    bsl1 = 8;   bsl0 = 24;
%     rsp1 = 32;  rsp0 = 72;
    rsp1 = 32;  rsp0 = 56;
    nfrm = 120;
    thres = 1;
    minZ= 50;
    maxZ= 260;
    RSPonly = 0; % setting this to 1 will lead to non-paired neuron sets for population analyses between psC conditions
    
    for i0 = 1:size(trlLST,1)
       if odrSEL(i0) == 0
           for i1 = 1:ntrl
               start0= 1+((i0-1)*ntrl+i1-1)*nfrm;
               end0= ((i0-1)*ntrl+i1)*nfrm;
               input(start0:end0,:)= NaN;
           end
       end
    end
    input= rmmissing(input);
    trlLST= trlLST(odrSEL==1,:);
    cutdim = size(trlLST,1);
    
    % Initialize parameters - os4 (odor tuning) - 212C
    if strcmp(sfxNOW,'_c212GFPneg') == 1
        DATA.grp(1).input = input(:, 1:1930);
        roinum= [404 381 304 313 174 237 117];
        plnZ= [50 85 60 70 35 20 70]; 
        
    elseif strcmp(sfxNOW,'_c212GFPpos') == 1
        DATA.grp(1).input = input(:, 1931:1931+74);
        roinum= [14 14 8 7 10 10 12]; 
        plnZ= [50 85 60 70 35 20 70];
        
    elseif strcmp(sfxNOW,'_dlxGFPneg') == 1
        DATA.grp(1).input = input(:, 2006:2006+3023);
        roinum= [224 137 144 119 172 168 164 78 167 202 99 272 343 87 129 195 121 203];
        plnZ= [50 70 50 120 75 50 65 75 45 25 75 40 25 35 70 65 80 30];
        
    elseif strcmp(sfxNOW,'_dlxGFPpos') == 1
        DATA.grp(1).input = input(:, 5030:5030+107);
        roinum= [12 8 2 5 4 2 5 5 8 7 4 4 5 15 6 5 7 4];
        plnZ= [50 70 50 120 75 50 65 75 45 25 75 40 25 35 70 65 80 30];
    end
end

% -------------------------------------------------------------------------
% GENERAL init PART
prod = size(trlLST,1) * size(trlLST,2);
trlLST = reshape(trlLST',[prod,1]);
ms.suffixes(1:size(roinum,2))= {sfxNOW};

info = MPI_DATinfo(trlLST,roinum,ms);
info.grpid = sfxNOW;
info.rsp1 = rsp1;info.rsp0 = rsp0;
info.bsl1 = bsl1;info.bsl0 = bsl0;
info.nfrm = nfrm;
idx = 1:info.nstm; info.idx = idx;
idx2 = 1:size(info.trlLST,1) ./ size(info.psCLST,1);
info.nroi = size(DATA.grp(1).input,2);
info.thres = thres;
info.RSPonly = RSPonly;
info.CODstrct = CODstrct; 
info.osnum= osnum;
info.ContrE= ContrE;
if Zexcl==1
    info.plnZ= plnZ;
    info.minZ= minZ;
    info.maxZ= maxZ;
end
DATA.grp(1).info = info;

for h = 1 : size(roinum,2)
    info.nroi = roinum(h);
    DATA.grp(1).info.exp(h) = info;  
end


%% CLEANUP
clc
clear Dropbox_path;
clear TF_timeXroi_es;
clear info;
clear nfrm; 
clear rsp0;
clear rsp1;
clear trlLST;
clear roinum;
clear ans;
clear prod;
clear input;
