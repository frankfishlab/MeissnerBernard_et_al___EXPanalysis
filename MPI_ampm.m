function [mAMP,input,info] = MPI_ampm(input,info,vsum,zsc,ACSexcl,RSPexcl,PLNexcl,XYexcl,PLNid,Xbnd,Ybnd,VALtun,valI,valFRC,valSHF)

if nargin < 5
    ACSexcl= 0;
end
if nargin < 6
    RSPexcl= 0;
end
if nargin < 7
    PLNexcl= 0;
end
if nargin < 8
    XYexcl= 0;
end
if nargin < 9
    PLNid= [1];
end
if nargin < 10
    Xbnd= [1];
end
if nargin < 11
    Ybnd= [1];
end
if nargin < 12
    VALtun= [];
end
if nargin < 13
    valI= [];
end
if nargin < 14
    valFRC= 0.50;
    valFRC= 0.75;
    valFRC= 0.15;
    valFRC= 1.00;
end
if nargin < 15
    valSHF= 0;
%     valSHF= 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRIAL VALUES - all psC conditions
mtrl= zeros(info.ntrl,info.nroi);
mtrl_RSP= zeros(info.ntrl,info.nroi);

for i = 1 : info.ntrl
    % input is "raw"
    trl = input((i-1)*info.nfrm+1:i*info.nfrm,:);
    
    if vsum == 1 % typically, vsum = tdCa 
        offset= 8.030198514461517e-04;
        offset= -0.000930115580558777;
        offset= 0;
        
        % P.S. Aus den MAT-Files erhaeltst du echte Feuerraten in Hz, wenn
        % du einfach alles mit der Bildrate (7.8125 Hz) multiplizierst.
        
        trl= (trl+offset) .* 7.8125;
    end
    
    parfor j = 1 : info.nroi
        roiid = info.roiid(j);
        rsp0 = info.exp(roiid).rsp0;
        rsp1 = info.exp(roiid).rsp1;
        bsl0 = info.exp(roiid).bsl0;
        bsl1 = info.exp(roiid).bsl1;
        
        % baseline estimates (e.g. for "z-score normalized" traces, response classification)
        bsl_mn = mean(trl(bsl1:bsl0,j));
        bsl_sd = std(trl(bsl1:bsl0,j));
        
        
        if vsum == 0
            if zsc==1 || zsc==3 || zsc==99 % initial input is variable, then z-score normalization
                
                if zsc==3 || zsc==99
                     % df/f
                     trc = (squeeze(trl(:,j)) - bsl_mn) ./ bsl_mn; 
                     
                     % NEW baseline estimates (e.g. for "z-score normalized" traces)
                     bsl_mn = mean(trc(bsl1:bsl0),'omitnan');
                     bsl_sd = std(trc(bsl1:bsl0),'omitnan');
                     
                     % z-score
                     trc2 = (trc - bsl_mn) ./ bsl_sd;
                     
                     if zsc==99
                        trc2(trc2<0)=0;
                     end
                     
                     trc = trc2;
                
                elseif zsc==1
                    % z-score                 
                    trc = (squeeze(trl(:,j)) - bsl_mn) ./ bsl_sd;
                end
                
                mtrl(i,j) = mean(trc(rsp1:rsp0),'omitnan');
                
%                 thres = 3;     % standard for 21Q2-22Q1
%                 thres = 2;     % tried on 15.01.24
%                 thres = 1.65;  % before 23.03.21
                thres = 1;       % tried on 15.01.24
%                thres = 5;
                
                trc2 = smooth(trc,15);
                rsp = find(trc2(rsp1:rsp0)>thres);
                rsp2 = find(trc2(rsp1:rsp0)<-thres);
                if(size(rsp,1)>0 || size(rsp2,1)>0)
                    mtrl_RSP(i,j) = 1;
                else
                    mtrl_RSP(i,j) = 0;
                end
                
            else % initial input is variable, no further processing
                if zsc==-1 % initial input is raw (e.g. Suite2P), no further processing
                    % df/f
                    trc = (squeeze(trl(:,j)) - bsl_mn) ./ bsl_mn;
                    
                    % NEW baseline estimates (for RSP classification)
                    bsl_mn = mean(trc(bsl1:bsl0),'omitnan');
                    bsl_sd = std(trc(bsl1:bsl0),'omitnan');
                
                else % initial input is df/f (e.g. Pymagor or Cascade), no further processing
                    trc = (squeeze(trl(:,j).* 7.8125)); % multiplication for Cascade
                end
                    
                mtrl(i,j) = mean(trc(rsp1:rsp0),'omitnan');
                
                % RSP: yes or no 
                if zsc == -2 % Cascade in CMB et al., 2024 = info.thres = 1
                    if sum(trc(bsl0:end)) >= info.thres % * 7.8125
                        mtrl_RSP(i,j) = 1;
                    else
                        mtrl_RSP(i,j) = 0;
                    end
                    
                else
                    thres= 2
                    if(mtrl(i,j)>thres*bsl_sd || mtrl(i,j)<-thres*bsl_sd)
                        mtrl_RSP(i,j) = 1;
                    else
                        mtrl_RSP(i,j) = 0;
                    end
                end
            end
      
        else
            % last change: 21.07.21
            thres= info.thres;
%           Rationale: "Es koennte sein, dass Neuropil-Kontamination dafuer
%           sorgt, dass bei diesem oder jenem Neuron faelschlicherweise
%           etwa 0.5-1 APs zu viel detektiert werden." ... assuming extra
%           detection of 0.5 and minimum requirement of 1 AP --> 1.5
            
            % change in spiking
            mtrl(i,j) = sum(trl(rsp1:rsp0,j)) - bsl_mn.*(rsp0-rsp1);
            
%             % absolute spike #
%             mtrl(i,j) = sum(trl(rsp1:rsp0,j));
%             
            if(mtrl(i,j)>thres || mtrl(i,j)<-thres)
                mtrl_RSP(i,j) = 1;
            else
                mtrl_RSP(i,j) = 0;
            end
        end
    end
end
mAMP.all.trl= mtrl;
mAMP.all.trl_RSP= mtrl_RSP;

% TRL - split according to psC conditions
for i = 1 : info.npsC
    selTT = strcmp(info.psCLST(i),info.psCLST_trl);
    mAMP.psC(i).trl(:,:) =  mAMP.all.trl(selTT>0,:);
    mAMP.psC(i).trl_RSP(:,:) =  mAMP.all.trl_RSP(selTT>0,:);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVERAGED VALUES - all psC conditions
RSPcrit= 0;

% sigCHG #1 - for preselection
if info.npsC > 1
    sigCHG= zeros(1,info.nroi);
    for i = 1 : info.nroi
        wC= mAMP.psC(1).trl(:,i);
        wP= mAMP.psC(2).trl(:,i);

        [~,h]= signrank(wC,wP,'alpha', 0.1);
        sigCHG(i)= h; 
    end
    mAMP.all.sigCHGall= sigCHG;
end

if RSPcrit == 0
    % any one trial
    tmpR0= mean(mAMP.all.trl_RSP,1,'omitnan');
    selRSP= tmpR0> 0;

elseif RSPcrit == 1
    % at least 10 trials
    tmpR0= mean(mAMP.all.trl_RSP,1,'omitnan');
    selRSP= tmpR0> 9/info.ntrl;
    
elseif RSPcrit == 2
    % at least one trial
    tmpR0= mean(mAMP.all.trl_RSP,1,'omitnan');
    selRSP= tmpR0> 1/info.ntrl;
    
    % ... and significant change!
    if info.npsC > 1
        selRSP= selRSP .* sigCHG;
    end
end

info.selRSP= selRSP;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1 : info.ncnd
    selA = strcmp(info.cndLST(i),info.trlLST);
    tmpA = mtrl(selA>0,:);
    tmpR = mtrl_RSP(selA>0,:);
    
    mAMP.all.avg(i,:) = mean(tmpA,1,'omitnan');
    mAMP.all.avg_RSP(i,:) = mean(tmpR,1,'omitnan');
end

% -------------------------------------------------------
% ACSF response EXCLUSION
ACSpos= 1;
info.ACSexcl= ACSexcl; 

if ACSexcl == 1
    selACS0= mAMP.all.avg_RSP(ACSpos,:)==0; 
elseif ACSexcl == 2
    ACSpos= info.ACSpos;
    ACSrsp= mAMP.all.avg_RSP(ACSpos,:)==0;  % --> 'invert' RSP vector
    selACS0= sum(ACSrsp)~=0;                % --> do NOT include if responses to ALL "ACSpos stimuli" (in at least one trial...)
else
    selACS0= mAMP.all.avg_RSP(ACSpos,:)>=0;
end

% -------------------------------------------------------
% area-based EXCLUSION
if isfield(info,'selARA') == 1
    selACS0= selACS0 .* info.selARA;
end

if isfield(info,'plnZ') == 1
    roiid0= info.plnZ(info.roiid);
    selZmin= roiid0 >= info.minZ;
    selZmax= roiid0 <= info.maxZ;
    selACS0= selACS0 .* selZmin .* selZmax;
    clear roiid0
end

% -------------------------------------------------------
% response EXCLUSION
if RSPexcl == 1
    selACS0= selACS0 .* selRSP;
end

if mean(VALtun)> 0 % --> d' or AROC or absPC
    if max(VALtun)>1 % d'
        top= 1;
%         top= 2;
    else % AROC
        top= -1;
    end
    
else % --> dVALtun
    top= 1;
end

if size(VALtun,2) > 1
    % AROC-based exclusion --> higher value means more valence tuned
    if top == -1
%        selVAL= VALtun > 0.85; % assuming AROC; used for TRLanl=0
       selVAL= VALtun >= 0.80; % assuming AROC; used for TRLanl=1

    % dVALtun-based exclusion --> lower value means more valence tuned 
    elseif top == 0
       selVAL= VALtun == 0;

    % dVALtun- or ddp-based exclusion --> higher value means more valence tuned
    % most valence-tuned
    elseif top == 1
       dVALtun2= sort(VALtun,'descend');
       dVALcut= dVALtun2(round(size(VALtun,2)*valFRC));
       selVAL= VALtun > dVALcut;

    % least valence-tuned
    else
       dVALtun2= sort(VALtun,'ascend');
%         dVALcut= dVALtun2(round(size(VALtun,2)*0.25));
%         dVALcut= dVALtun2(round(size(VALtun,2)*0.5));
%         dVALcut= dVALtun2(round(size(VALtun,2)*0.75));
%         dVALcut= dVALtun2(round(size(VALtun,2)*0.90));
        dVALcut= dVALtun2(round(size(VALtun,2)*valFRC));
       
        if valSHF == 1
            selVAL= VALtun(randperm(size(VALtun,2))) < dVALcut;
        else
            selVAL= VALtun < dVALcut;
        end
    end

    valSEL= -.25;
    if size(valI,2) > 1
        % NEG only
        if valSEL < 0
            sel0= valI < valSEL;
        % POS only
        elseif valSEL > 0
            sel0= valI > valSEL;
        end

        selVAL= selVAL .* sel0;
    end

   selACS0= selACS0 .* selVAL;
end

tmp00 = zeros(info.ntrl,info.nexp);
for i = 1 : info.ncnd
    selACS= selACS0;

    % -------------------------------------------------------
    % re-calculation after - various - response exclusion criteria
    for j = 1 : info.nexp
        selROI = (j == info.roiid);
        
        % plane exclusion
        if PLNexcl == 1
            xy= info.xy(:,3);
            selPLN= ismember(xy,PLNid(:,j));selPLN= selPLN';
            
            selACS= selACS .* selPLN;
        end
        
        % XY exclusion
        if XYexcl == 1
            XYinv= 0;
            
            XYthr= [Xbnd(j) Ybnd(j)];
            xy= info.xy(:,4:5);
            if Xbnd(j) >= 0 
                if Ybnd(j) >= 0
                    selXY= (xy(:,1)>=XYthr(1)) & (xy(:,2)>=XYthr(2));
                elseif Ybnd(j) < 0
                    selXY= (xy(:,1)>=XYthr(1)) & (xy(:,2)<abs(XYthr(2)));
                end
                
            elseif Xbnd(j) < 0
                if Ybnd(j) >= 0
                    selXY= (xy(:,1)<abs(XYthr(1))) & (xy(:,2)>=XYthr(2));
                elseif Ybnd(j) < 0
                    selXY= (xy(:,1)<abs(XYthr(1))) & (xy(:,2)<abs(XYthr(2)));
                end
            end
            
            invselXY= selXY<1;
            selXY= selXY';invselXY= invselXY';
            
            if XYinv == 0
                selACS= selACS .* selXY;
            elseif XYinv == 1
                selACS= selACS .* invselXY;
            end
        end
        
        % experiment-specific average response amplitudes (trial-averaged) - nstim x nexp
        selROI = selROI .* selACS;
        tmp0 = mAMP.all.avg(i,selROI>0);
        mAMP.all.avg_exp(i,j) = mean(tmp0,2,'omitnan');
        
        % experiment-specific average response amplitudes (single trials) - ntrial x nexp
        selA = strcmp(info.cndLST(i),info.trlLST);
        tmp00 = mAMP.all.trl(selA>0,selROI>0);
        mAMP.all.trl_exp(selA>0,j) = mean(tmp00,2,'omitnan');
    end
end

% "CLEANUP" - due to ACSF responder exclusion
% ... selected raw data - w/o ACSF responders (if  ACSexcl == 1) 
input= input(:,selACS==1);
info.roiid= info.roiid(selACS==1);

% AVG - split according to psC conditions
nrmN= 4;

for i = 1 : info.npsC
    % response amplitude
    selAA = strcmp(info.psCLST(i),info.psCLST_cnd);
    mAMP.psC(i).avg(:,:) = mAMP.all.avg(selAA>0,selACS==1);
    mAMP.psC(i).avg_avg1 = mean(mAMP.psC(i).avg,1,'omitnan');
    mAMP.psC(i).avg_avg2 = mean(mAMP.psC(i).avg,2,'omitnan');
    
    if(size(mAMP.psC(i).avg_avg2,1) >= nrmN)
        mAMP.psC(i).NRMavg_avg2= mAMP.psC(i).avg_avg2(:) ./ mean(mAMP.psC(i).avg_avg2(1:nrmN),'omitnan');
    end
    
    for j = 1 : info.nexp
        selROI = (j == info.roiid);
        ampX= mAMP.psC(i).avg(:,selROI==1);
        mAMP.psC(i).avg_avg2_exp(:,j)= mean(ampX,2,'omitnan');
        
        if(size(mAMP.psC(i).avg_avg2,1) >= nrmN)
            mAMP.psC(i).NRMavg_avg2_exp(:,j)= mAMP.psC(i).avg_avg2_exp(:,j) / mean(mAMP.psC(i).avg_avg2_exp(1:nrmN,j),1,'omitnan');
        end
    end
    % binary response classification
    mAMP.psC(i).avg_RSP(:,:) = mAMP.all.avg_RSP(selAA>0,selACS==1);
    mAMP.psC(i).avg_RSP_avg1 = mean(mAMP.psC(i).avg_RSP,1,'omitnan');
    mAMP.psC(i).avg_RSP_avg2 = mean(mAMP.psC(i).avg_RSP,2,'omitnan');
end


% ------------------------------------------------------------------------
% "CLEANUP" - due to ACSF responder exclusion
% TRL - split according to psC conditions
for i = 1 : info.npsC
    clear mAMP.psC(i).trl;
    clear mAMP.psC(i).trl_RSP;
    
    selTT = strcmp(info.psCLST(i),info.psCLST_trl);
    mAMP.psC(i).trl =  mAMP.all.trl(selTT>0,selACS==1);
    mAMP.psC(i).trl_RSP =  mAMP.all.trl_RSP(selTT>0,selACS==1);
end

% -------------------------------------------------------------------------
% ---- clear "empty" experiments
% ---- added 24.05.2022
keepEXPid= unique(info.roiid);
for i = 1 : size(keepEXPid,2)
    info.roiid(info.roiid==keepEXPid(i))=i; 
end
info.nexp= size(keepEXPid,2);
% -------------------------------------------------------------------------

for i = 1 : info.nexp
    info.roinum2(i)= sum(info.roiid==i);
end

if isfield(info,'roiSFX') == 1
    info.roiSFX= info.roiSFX(selACS==1);
end
if isfield(info,'xy') == 1
    info.xy= info.xy(selACS==1,:);
end
if isfield(info,'selARA') == 1
    info.selARA= info.selARA(selACS==1);
end
if isfield(info,'roiARA') == 1
    info.roiARA= info.roiARA(selACS==1);
end
if isfield(info,'roiARAid') == 1
    info.roiARAid= info.roiARAid(selACS==1);
end
info.nroi= size(info.roiid,2);


% sigCHG #2 - for documentation
if info.npsC > 1
    sigCHG= zeros(1,info.nroi);
    for i = 1 : info.nroi
        wC= mAMP.psC(1).trl(:,i);
        wP= mAMP.psC(2).trl(:,i);

        [~,h]= signrank(wC,wP,'alpha', 0.1);
        sigCHG(i)= h; 
    end
    mAMP.all.sigCHGsel= sigCHG;
end
end