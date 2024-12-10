function mTRC = MPI_trcm_JENKINS(input,info,zsc,filt)
if nargin < 4
    filt= 0;
end

% test lower threshold on 09.09.21 thr= 0.03;
% threshold used to be set to 0.05 before 16.03.21;
SDthr= 4;
filtSET= 0.5;
BHVon= info.exp(1).rsp1;    % first frame to be used for BHV bout count; before 15.04.22: 140
BHVoff= info.nfrm-5;        % last frame to be used for BHV bout count; before 21.11.21: info.nfrm-5

ntrl= (info.ntrl./info.nstm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% split into trials
for i = 1 : info.ntrl
    if isfield(info,'exp')
        bsl0 = info.exp(1).bsl0;
        bsl1 = info.exp(1).bsl1;
    else
        bsl0 = info.bsl0;
        bsl1 = info.bsl1;
    end
    
    if zsc == 1 || zsc == 3 || zsc == 99
        trl = input((i-1)*info.nfrm+1:i*info.nfrm,:);
        bsl_mn = mean(trl(bsl1:bsl0,:),'omitnan');
        bsl_sd = std(trl(bsl1:bsl0,:),'omitnan');
        
        if zsc == 3 || zsc == 99
            % df/f
            tmp2 = (trl(:,:)-bsl_mn(1,:))./bsl_mn(1,:);
            
            % new baseline estimates
            bsl_mn = mean(tmp2(bsl1:bsl0,:),'omitnan');
            bsl_sd = std(tmp2(bsl1:bsl0,:),'omitnan');
            
        else
            tmp2 = trl(:,:);
        end
        
        % z-score
        tmp = (tmp2-bsl_mn(1,:))./bsl_sd(1,:);
        
        if zsc==99
            tmp(tmp<0)=0;
        end
        
        TEMP(:,:,i) = tmp;
        
    elseif zsc == -1
        trl = input((i-1)*info.nfrm+1:i*info.nfrm,:);
        bsl_mn = mean(trl(bsl1:bsl0,:),'omitnan');
        bsl_sd = std(trl(bsl1:bsl0,:),'omitnan');
        
        % df/f
        tmp = (trl(:,:)-bsl_mn(1,:))./bsl_mn(1,:);
        
        TEMP(:,:,i) = tmp;
        
    elseif zsc == -2
        % P.S. Aus den MAT-Files erhaeltst du echte Feuerraten in Hz, wenn
        % du einfach alles mit der Bildrate (7.8125 Hz) multiplizierst.
        trl = input((i-1)*info.nfrm+1:i*info.nfrm,:).* 7.8125;
        bsl_mn = mean(trl(bsl1:bsl0,:),'omitnan');
        
        %         % "df" ... try to relate spike count to baseline firing rate
        %        tmp = (trl(:,:) - bsl_mn(1,:));
        tmp = (trl(:,:));
        
        TEMP(:,:,i) = tmp;
        
    else
        TEMP(:,:,i) = input((i-1)*info.nfrm+1:i*info.nfrm,:);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRIAL VALUES - split according to psC conditions
for i = 1 : info.npsC
    selT = strcmp(info.psCLST(i),info.psCLST_trl);
    mTRC.psC(i).trl(:,:,:) = TEMP(:,:,selT>0);
    
    % (grand) average for each trial (across all ROIs)
    mTRC.psC(i).trl_avg(:,:) = mean(TEMP(:,:,selT>0),2,'omitnan');
    
    if filt == 1
        for h = 1 : info.ntrl
            for j = 1 : info.nexp
                selROI = (j == info.roiid);
                mTRC.psC(i).exp(j).trl_avg(:,h)= mean(TEMP(:,selROI>0,h),2,'omitnan');
                
                % -----------------------------------------------------------------
                % high pass filtering --> "indirect BHV detection" error
                % avoidance
                a= mTRC.psC(i).exp(j).trl_avg(:,h);
                a= isnan(a);
                
                if sum (a) ~= size(a,1)
                    mTRC.psC(i).exp(j).trl_avg_Hifilt(:,h)= highpass(mTRC.psC(i).exp(j).trl_avg(:,h),filtSET);
                        sd= std(mTRC.psC(i).exp(j).trl_avg_Hifilt(bsl1:bsl0,h),0,1); mTRC.psC(i).exp(j).trl_avg_Hifilt_sdBSL(h)= sd;
                    mTRC.psC(i).exp(j).trl_avg_EVT(:,h)= mTRC.psC(i).exp(j).trl_avg_Hifilt(:,h) < sd .* -SDthr;
                    mTRC.psC(i).trl_avg_EVTcnt(h,j)= sum(mTRC.psC(i).exp(j).trl_avg_EVT(BHVon:BHVoff,h));
                else
                    mTRC.psC(i).exp(j).trl_avg_Hifilt(:,h)= NaN;
                    mTRC.psC(i).trl_avg_EVTcnt(h,j)= 0;
                end
            end
         end
        
        for j = 1 : info.nexp
            % ... (1) average across all trials for each stimulus in the
            % current experiment: ntrl --> nstm "reduction"
            for k = 1:info.nstm
                mTRC.psC(i).trl_avg_EVTcnt_avg(k,j)= mean(mTRC.psC(i).trl_avg_EVTcnt((k-1)*ntrl+1 : k*ntrl,j));
            end
        end
        
        % ... (2) and average (1) across all experiments
        mTRC.psC(i).trl_avg_EVTcnt_avg_avg= mean(mTRC.psC(i).trl_avg_EVTcnt_avg,2);
        mTRC.psC(i).trl_avg_EVTcnt_trl_avg= mean(mTRC.psC(i).trl_avg_EVTcnt,2);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVERAGED VALUES - all psC conditions; read and distribute to psC
% conditions
for i = 1 : info.ncnd
    selA = strcmp(info.cndLST(i),info.trlLST);
    
    stimpos = find(strcmp(info.cndLST{i}(1:3),info.stmLST));
    psCpos = find(strcmp(info.cndLST{i}(4),info.psCLST));
    
    mTRC.psC(psCpos).avg(:,:,stimpos) = mean(TEMP(:,:,selA>0),3,'omitnan');
    
    % grand average for each condition (across all ROIs)
    mTRC.psC(psCpos).avg_avg(:,stimpos) = mean(mean(TEMP(:,:,selA>0),3,'omitnan'),2,'omitnan');
    
    % for each experiment
    for j = 1 : info.nexp
        selROI = (j == info.roiid);
        mTRC.psC(psCpos).exp(j).avg_avg(:,stimpos)= mean(mean(TEMP(:,selROI>0,selA>0),3,'omitnan'),2,'omitnan');
        
        % -----------------------------------------------------------------
        % high pass filtering --> "indirect BHV detection" error avoidance
        if filt == 1
            a= mTRC.psC(psCpos).exp(j).avg_avg(:,stimpos);
            a= isnan(a);
            if sum (a) ~= size(a,1)
                mTRC.psC(psCpos).exp(j).avg_avg_Hifilt(:,stimpos)= highpass(mTRC.psC(psCpos).exp(j).avg_avg(:,stimpos),filtSET);
                sd= std(mTRC.psC(psCpos).exp(j).avg_avg_Hifilt(bsl1:bsl0,stimpos),0,1);
                mTRC.psC(psCpos).exp(j).avg_avg_EVT(:,stimpos)= mTRC.psC(psCpos).exp(j).avg_avg_Hifilt(BHVon:BHVoff,stimpos) < sd .* -SDthr;
                mTRC.psC(psCpos).avg_avg_EVTcnt(stimpos,j)= sum (mTRC.psC(psCpos).exp(j).avg_avg_EVT(:,stimpos));
            else
                mTRC.psC(psCpos).exp(j).avg_avg_Hifilt(:,stimpos)= NaN;
                mTRC.psC(psCpos).avg_avg_EVTcnt(stimpos,j)= 0;
            end
        end
    end
    
    if filt == 1
        mTRC.psC(psCpos).avg_avg_EVTcnt_avg(stimpos)= mean(mTRC.psC(psCpos).avg_avg_EVTcnt(stimpos,:),2);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1 : info.npsC
    selT = strcmp(info.psCLST(i),info.psCLST_trl);
    
    % grand average for each condition (across all ROIs and odors)
    mTRC.psC(i).avg_avg_avg(:) = mean(mean(mean(TEMP(:,:,selT>0),3,'omitnan'),2,'omitnan'),2,'omitnan');
    mTRC.psC(i).avg_avg_avg = mTRC.psC(i).avg_avg_avg.';
    
    % concatenated (trial) responses
    temp2 = permute(mTRC.psC(i).trl,[1 3 2]);
    
    % concatenated (trial-averaged) responses
    temp = permute(mTRC.psC(i).avg,[1 3 2]);
    
    % ... had to add this on 14.05.21
    temp2(isnan(temp2))=0;
    temp(isnan(temp))=0;
    
    mTRC.psC(i).input2trl= reshape(temp2,info.nfrm*info.ntrl./size(info.psCLST,1),info.nroi);
    mTRC.psC(i).input2= reshape(temp,info.nfrm*info.nstm,info.nroi);
end
