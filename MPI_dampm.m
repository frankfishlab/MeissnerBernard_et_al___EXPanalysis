function mdelta = MPI_dampm(input,info,psC1,psC2,cutdim)

if isfield(info,'RSPonly') == 0
    RSPonly = 1;
else
    RSPonly = info.RSPonly;
end

ntrl= info.ntrl./(info.nstm*info.npsC);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME TRACES
for j = 1 : info.nexp
    gavgd= zeros(info.nfrm,info.nstm);
    gavgd2= zeros(info.nfrm,info.nstm);
    
    rsptim1= 32;
    rsptim0= 72;
    
    for k = 1 : info.nstm
        gavgC= input.mTRC.psC(1).exp(j).avg_avg(:,k);
        gavgP= input.mTRC.psC(2).exp(j).avg_avg(:,k);
        
        % time-dependent change index
        gavgd(:,k)= (gavgP-gavgC)./(gavgP+gavgC);
        
        ampPsmth= smooth(gavgP,0.1,'loess'); 
        ampdsmth= smooth(gavgd(:,k),0.1,'loess'); 
        [maxP,I1]= max(ampPsmth(rsptim1:rsptim0));I1= I1+rsptim1-1; 
        I2= find(ampPsmth(I1:end) < (maxP./2),1);I2= I2+I1-1; 
        
        % error handling
        if size(I2,1) == 0
            I2= I1+8;
        end    
        
        ChImax= ampdsmth(I1);
        ChIref= ampdsmth(I2);
        mdelta.trc.ChItim_sd_exp(j,k)= (ChImax-ChIref);
        
        
        % time-dependent gain modulation index
        gavgd2(:,k)= gavgP./gavgC;
        
        ampd2smth= smooth(gavgd2(:,k),0.1,'loess');
        GMImax= ampd2smth(I1);
        GMIref= ampd2smth(I2);
        mdelta.trc.GMItim_sd_exp(j,k)= (GMImax-GMIref);
    end
    
    mdelta.trc.exp(j).gavgd= mean(gavgd,2);
    mdelta.trc.exp(j).gavgd2= mean(gavgd2,2);
    mdelta.trc.exp(j).gavgP= mean(gavgP,2);
    
    mdelta.trc.ChIvPtim_corr_exp(j)= corr(mdelta.trc.exp(j).gavgd(rsptim1:rsptim0), mdelta.trc.exp(j).gavgP(rsptim1:rsptim0));
    mdelta.trc.GMIvPtim_corr_exp(j)= corr(mdelta.trc.exp(j).gavgd2(rsptim1:rsptim0), mdelta.trc.exp(j).gavgP(rsptim1:rsptim0));

    
    % time-dependent gain modulation index - averaged across all stimuli
    gavgd20= mean(input.mTRC.psC(2).exp(j).avg_avg,2) ./ mean(input.mTRC.psC(1).exp(j).avg_avg,2);
    
    ampPsmth= smooth(mean(input.mTRC.psC(2).exp(j).avg_avg,2),0.2,'loess'); 
    ampd20smth= smooth(gavgd20,0.2,'loess'); 
    [maxP,I1]= max(ampPsmth(rsptim1:rsptim0));I1= I1+rsptim1-1; 
    I2= find(ampPsmth(I1:end) < (maxP./2),1);I2= I2+I1-1;
    
    GMImax= ampd20smth(I1);
    GMIref= ampd20smth(I2);
    mdelta.trc.GMItim_sd2_exp(j)= (GMImax-GMIref);
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRIAL VALUES
mdelta.dAMP.trl = input.mAMP.psC(psC2).trl(:,:) - input.mAMP.psC(psC1).trl(:,:);
mdelta.ChI.trl = mdelta.dAMP.trl ./ (input.mAMP.psC(psC2).trl(:,:) + input.mAMP.psC(psC1).trl(:,:));

mdelta.IRCvPIN.trl= zeros(2,info.nroi);
thres= 0.25;
% IRC= mdelta.ChI.trl;
% 02.03.23 --> mdelta as IRC (before: ChI)
IRC= mdelta.dAMP.trl;

% for each neuron
for i= 1:info.nroi
    vecd1= IRC(1:2:cutdim*ntrl,i);
    vecP1= input.mAMP.psC(psC2).trl(1:2:cutdim*ntrl,i);
    
    vecd2= IRC(2:2:cutdim*ntrl,i);
    vecP2= input.mAMP.psC(psC2).trl(2:2:cutdim*ntrl,i);
    
    if max(vecP2) > thres
        mdelta.IRCvPIN.trl(1,i)= corr(vecd1,vecP2);
    else
        mdelta.IRCvPIN.trl(1,i)= NaN;
    end
    if max(vecP2) > thres
        mdelta.IRCvPIN.trl(2,i)= corr(vecd2,vecP1);
    else
        mdelta.IRCvPIN.trl(2,i)= NaN;
    end
end
mdelta.IRCvPIN.trl_avg= mean(mdelta.IRCvPIN.trl,1,'omitnan');

% across all neuron-odor pairs (experiment-wise)
for j = 1 : info.nexp
    selROI = (j == info.roiid);
    
    vecd1= IRC(1:2:cutdim*2,selROI>0); vecd1= reshape(vecd1,size(vecd1,1)*size(vecd1,2),1);
    vecP1= input.mAMP.psC(psC2).trl(1:2:cutdim*2,selROI>0); vecP1= reshape(vecP1,size(vecP1,1)*size(vecP1,2),1);

    vecd2= IRC(2:2:cutdim*2,selROI>0); vecd2= reshape(vecd2,size(vecd2,1)*size(vecd2,2),1);
    vecP2= input.mAMP.psC(psC2).trl(2:2:cutdim*2,selROI>0); vecP2= reshape(vecP2,size(vecP2,1)*size(vecP2,2),1);
    
    tmpsum= vecd1+vecP1+vecd2+vecP2;
    
    rtmp(1)= corr(vecd1(~isnan(tmpsum)),vecP2(~isnan(tmpsum)));
    rtmp(2)= corr(vecd2(~isnan(tmpsum)),vecP1(~isnan(tmpsum)));
    mdelta.IRCvPIN.roiodr.trl.exp(j)= mean(rtmp,2);
    
    % accumulate across all planes (experiments)
    if j == 1
        vd1= vecd1; vd2= vecd2;
        vP1= vecP1; vP2= vecP2;
        tsum= tmpsum;
    else
        vd1= cat(1,vd1,vecd1); vd2= cat(1,vd2,vecd2);
        vP1= cat(1,vP1,vecP1); vP2= cat(1,vP2,vecP2);
        tsum= cat(1,tsum,tmpsum);
    end
    
    clear tmpsum;
end

% across all neuron-odor pairs (accumulated)
rtmp(1)= corr(vd1(~isnan(tsum)),vP1(~isnan(tsum)));
rtmp(2)= corr(vd2(~isnan(tsum)),vP2(~isnan(tsum)));
mdelta.IRCvPIN.roiodr.trl.all= mean(rtmp,2);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVERAGED VALUES
mdelta.dAMP.avg = input.mAMP.psC(psC2).avg(:,:) - input.mAMP.psC(psC1).avg(:,:);
mdelta.ChI.avg = mdelta.dAMP.avg ./ (input.mAMP.psC(psC2).avg(:,:) + input.mAMP.psC(psC1).avg(:,:));

% take all neuron-odor pairs
mdelta.dAMP.avg0= mdelta.dAMP.avg;
mdelta.ChI.avg0= mdelta.ChI.avg;

% ... exclude neuron-odor pairs w/o "any response"
avg_RSPsum= input.mAMP.psC(2).avg_RSP + input.mAMP.psC(1).avg_RSP;
[row,col] = find(avg_RSPsum == 0);
for i= 1:size(row,1)
    mdelta.ChI.avg(row(i),col(i))= NaN;
    mdelta.dAMP.avg(row(i),col(i))= NaN;
end


% ------------------------------------------------------------------------
% ROI-wise
% ... exclude neuron-odor pairs w/o "any response"
mdelta.dAMP.avg_avg = mean(mdelta.dAMP.avg,'omitnan');
mdelta.dAMP.avg_sd = std(mdelta.dAMP.avg,'omitnan');
mdelta.ChI.avg_avg = mean(mdelta.ChI.avg,'omitnan');
mdelta.ChI.avg_sd = std(mdelta.ChI.avg,'omitnan');

% take all neuron-odor pairs
mdelta.dAMP.avg0_avg = mean(mdelta.dAMP.avg0,'omitnan');
mdelta.dAMP.avg0_sd = std(mdelta.dAMP.avg0,'omitnan');
mdelta.ChI.avg0_avg = mean(mdelta.ChI.avg0,'omitnan');
mdelta.ChI.avg0_sd = std(mdelta.ChI.avg0,'omitnan');


% ------------------------------------------------------------------------
% ODOR-wise
% ... exclude neuron-odor pairs w/o "any response"
mdelta.dAMP.gavg = mean(mdelta.dAMP.avg','omitnan');
mdelta.ChI.gavg = mean(mdelta.ChI.avg','omitnan');

% take all neuron-odor pairs
mdelta.dAMP.gavg0 = mean(mdelta.dAMP.avg0','omitnan');
mdelta.ChI.gavg0 = mean(mdelta.ChI.avg0','omitnan');

% amplitudes and changes of amplitude - experiment-wise
% mdelta.ampC.expNRM= zeros(cutdim,info.nroi);
% mdelta.ampP.expNRM= zeros(cutdim,info.nroi);


% ------------------------------------------------------------------------
% experiment-specific average response amplitudes (trial-averaged)
for i = 1 : cutdim
    cnt= 1;
    for j = 1 : info.nexp
        selROI = (j == info.roiid);
        
        % experiment-specific average response amplitudes (trial-averaged)
        % - nstim x nexp
        tmpC = input.mAMP.psC(psC1).avg(i,selROI>0);
        tmpP = input.mAMP.psC(psC2).avg(i,selROI>0);
        
        mdelta.ampC.expAVG(i,j)= mean(tmpC,2,'omitnan');
        mdelta.ampP.expAVG(i,j)= mean(tmpP,2,'omitnan');
        mdelta.dAMP.expAVG(i,j)= mean(mdelta.ampP.expAVG(i,j) - mdelta.ampC.expAVG(i,j),2,'omitnan');
        mdelta.ChI.expAVG(i,j)= mean(mdelta.dAMP.expAVG(i,j) ./ (mdelta.ampP.expAVG(i,j) + mdelta.ampC.expAVG(i,j)),2,'omitnan');
        
%         % for later analysis - plane-normalized response amplitudes
%         mdelta.ampC.expNRM(i,cnt:cnt+size(tmpC,2)-1)= tmpC ./ median(tmpC,2,'omitnan');
%         mdelta.ampP.expNRM(i,cnt:cnt+size(tmpC,2)-1)= tmpP ./ median(tmpC,2,'omitnan');
%         
%         cnt= cnt+size(tmpC,2);
    end
end


%% ... sigCOR(IRC) and sigCOR(PIN) - for 2nd order correlations
if info.osnum==2
    for j = 1 : info.nexp
        selROI = j == info.roiid;    selROI0 = j == info.roiid;
        
        %     % option #1 - based on binary response classification - prior 7.7.22
        %     bool = input.mAMP.psC(psC2).avg_RSP_avg1(1,:) > 0.5;
        
        %     % option #2 - based on mean absolute amplitude
        %     bool = input.mAMP.psC(psC2).avg_avg1(1,:) > 0.1;
        
        % option #3.1 - based on top x % responding neurons per plane
        [~,I]= sort(input.mAMP.psC(psC2).avg_avg1(1,selROI0),'descend');
        frc0= 0.05;
        incr= find(selROI0>0,1)-1;
        I= I+incr;
        frc=round(frc0.*size(I,2));
        bool0= zeros(1,size(selROI,2));
        bool0(I(1:frc))= 1; bool= bool0; clear selROI0 bool0
        
        % option #3.2 - based on top x % iCOR neurons per plane
        I= input.anlPOP.psC(2).avg.icorrIDX_frc.exp{j};
        I= I+incr;
        bool0= zeros(1,size(selROI,2));
        bool0(I)= 1; bool= bool0; clear bool0
        
        % final selection
        selROI = selROI .* bool;
        
        % isolating trial-specific ERCs and IRCs
        vecd1= IRC(1:2:cutdim*2,selROI>0);
        vecP1= input.mAMP.psC(psC2).trl(1:2:cutdim*2,selROI>0);
        
        vecd2= IRC(2:2:cutdim*2,selROI>0);
        vecP2= input.mAMP.psC(psC2).trl(2:2:cutdim*2,selROI>0);
        
        % --> here we calculate the 1st order (signal) correlations (for IRCs
        % and ERCs, respectively) - based on individual trials
        mdelta.sigCOR.exp(j).d1vec= flatmat2(corrcoef(vecd1(1:cutdim,:)));
        mdelta.sigCOR.exp(j).d2vec= flatmat2(corrcoef(vecd2(1:cutdim,:)));
        mdelta.sigCOR.exp(j).P1vec= flatmat2(corrcoef(vecP1(1:cutdim,:)));
        mdelta.sigCOR.exp(j).P2vec= flatmat2(corrcoef(vecP2(1:cutdim,:)));
        
        % average the two independently calculated (1st) order signal
        % correlation values (ERC, IRC)
        tmpP= cat(1,mdelta.sigCOR.exp(j).P1vec,mdelta.sigCOR.exp(j).P2vec);
        tmpd= cat(1,mdelta.sigCOR.exp(j).d1vec,mdelta.sigCOR.exp(j).d2vec);
        mdelta.sigCOR.exp(j).Pvec= mean(tmpP,1);
        mdelta.sigCOR.exp(j).dvec= mean(tmpd,1);
        
        % accumulate across planes
        if j == 1
            mdelta.sigCOR.Pvec= mdelta.sigCOR.exp(j).Pvec;
            mdelta.sigCOR.dvec= mdelta.sigCOR.exp(j).dvec;
        else
            mdelta.sigCOR.Pvec= cat(2,mdelta.sigCOR.Pvec,mdelta.sigCOR.exp(j).Pvec);
            mdelta.sigCOR.dvec= cat(2,mdelta.sigCOR.dvec,mdelta.sigCOR.exp(j).dvec);
        end
        
        % plane-specific 2nd order correlations
        mdelta.sigCOR.r2nd_exp(j)= corr(mdelta.sigCOR.exp(j).dvec',mdelta.sigCOR.exp(j).Pvec','Rows','complete');
    end
    
    % 2nd order correlation across all neurons
    mdelta.sigCOR.r2nd= corr(mdelta.sigCOR.dvec',mdelta.sigCOR.Pvec','Rows','complete');
    
    % Shuffling
    shfN= 1000;
    for j = 1 : shfN
        Pvec= mdelta.sigCOR.Pvec(randperm(size(mdelta.sigCOR.Pvec,2)));
        dvec= mdelta.sigCOR.dvec(randperm(size(mdelta.sigCOR.dvec,2)));
        
        mdelta.sigCOR.r2ndSHF(j)= corr(dvec',Pvec','Rows','complete');
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in EACH experiment, look at the correlation between <ChI> and <PIN>
nrmN= 4;
for j = 1 : info.nexp
    tmpP= mdelta.ampP.expAVG(:,j);
    tmpd= mdelta.ChI.expAVG(:,j);
    
    if(size(tmpd,1) >= nrmN)
        mdelta.ChI.NRMexpAVG(:,j)= tmpd / mean(tmpd(1:nrmN),1,'omitnan');
    end
    
    mdelta.IRCvPIN.pln.avg.exp(j)= corr(tmpd,tmpP);
    
    % 28.08 - all neuron averages (does not suffer from IRC-PIN dilemma!!!)
    selROI = (j == info.roiid);
    tmpC = mean(input.mAMP.psC(psC1).avg(1:cutdim,selROI>0),1,'omitnan');
    tmpP = mean(input.mAMP.psC(psC2).avg(1:cutdim,selROI>0),1,'omitnan');
    
    tmpsum= tmpP+tmpC;
    tmpC= tmpC(tmpsum>0);
    tmpP= tmpP(tmpsum>0);
    
    tmpChI= (tmpP-tmpC) ./ (tmpP+tmpC);
    
    mdelta.IRCvPIN.roi.avg.exp(j)= corr(tmpChI',tmpP');
    
    
    % 28.08 - all neuron-odor pairs (... suffers from IRC-PIN dilemma!!!)
    tmpC = input.mAMP.psC(psC1).avg(1:cutdim,selROI>0); 
        tmpC= reshape(tmpC,size(tmpC,1)*size(tmpC,2),1);
    tmpP = input.mAMP.psC(psC2).avg(1:cutdim,selROI>0); 
        tmpP= reshape(tmpP,size(tmpP,1)*size(tmpP,2),1);
    
    tmpsum= tmpP+tmpC;
    tmpC= tmpC(tmpsum>0);
    tmpP= tmpP(tmpsum>0);
    
    tmpChI= (tmpP-tmpC) ./ (tmpP+tmpC);
    
    mdelta.IRCvPIN.roiodr.avg.exp(j)= corr(tmpChI,tmpP);
end

% 28.08 - all neuron averages (does not suffer from IRC-PIN dilemma!!!)
tmpC = mean(input.mAMP.psC(psC1).avg(1:cutdim,:),1,'omitnan');
tmpP = mean(input.mAMP.psC(psC2).avg(1:cutdim,:),1,'omitnan');

tmpsum= tmpP+tmpC;
tmpC= tmpC(tmpsum>0);
tmpP= tmpP(tmpsum>0);
    
tmpChI= (tmpP-tmpC) ./ (tmpP+tmpC);
    
mdelta.IRCvPIN.roi.avg.all= corr(tmpChI',tmpP');

 % 28.08 - all neuron-odor pairs (... suffers from IRC-PIN dilemma!!!)
tmpC = input.mAMP.psC(psC1).avg(1:cutdim,:); 
    tmpC= reshape(tmpC,size(tmpC,1)*size(tmpC,2),1);
tmpP = input.mAMP.psC(psC2).avg(1:cutdim,:); 
    tmpP= reshape(tmpP,size(tmpP,1)*size(tmpP,2),1);

tmpsum= tmpP+tmpC;
tmpC= tmpC(tmpsum>0);
tmpP= tmpP(tmpsum>0);

tmpChI= (tmpP-tmpC) ./ (tmpP+tmpC);

mdelta.IRCvPIN.roiodr.avg.all= corr(tmpChI,tmpP);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AmI analysis (amplitude index)
% (2) … ChIAmI metric is negative if PIN responses are less selective, i.e.
% if AmI metric is smaller for PIN [(P-C) / (P+C)] → more negative values
% indicate stronger "sharpening" of odor selectivity by INs
% (3) …∆ChIAmI(simdis) is negative if PIN has stronger effect on sharpening
% of odor responses between pairs of dissimilar odors, and positive for
% stronger effect on similar odors [ChIAmI(dissimilar) - ChIAmI(similiar)]

if isfield(input.anlCEL.psC(2).avg,'AmIsim')
    % option 1 for step (2) - ChI for each odor pair
    simC= input.anlCEL.psC(1).avg.AmIsim; simP= input.anlCEL.psC(2).avg.AmIsim;
    mdelta.AmI.ChIAmIsim= (simP - simC) ./ (simP + simC);
    
    disC= input.anlCEL.psC(1).avg.AmIdis; disP= input.anlCEL.psC(2).avg.AmIdis;
    mdelta.AmI.ChIAmIdis= (disP - disC) ./ (disP + disC);
    
    
    % option 2 for step (2) - ChI for average of odor pairs (... used in 2019)
    simC= input.anlCEL.psC(1).avg.AmIsim_avg; simP= input.anlCEL.psC(2).avg.AmIsim_avg;
    mdelta.AmI.ChIAmIsim_avg= (simP - simC) ./ (simP + simC);
    
    disC= input.anlCEL.psC(1).avg.AmIdis_avg; disP= input.anlCEL.psC(2).avg.AmIdis_avg;
    mdelta.AmI.ChIAmIdis_avg= (disP - disC) ./ (disP + disC);
    
    
    % step (3)
    mdelta.AmI.dChIAmIsimdis_avg= mdelta.AmI.ChIAmIdis_avg - mdelta.AmI.ChIAmIsim_avg;
    mdelta.AmI.dChIAmIsimdis_avg= mdelta.AmI.dChIAmIsimdis_avg(abs(mdelta.AmI.dChIAmIsimdis_avg) <= 1);
    
    
    % ---------------------------------------------------------------------
    % choice of odor pairs is somewhat subjective; can we perform this
    % analysis more systematically?
    MwCORC= zeros(info.nstm,info.nstm,info.nexp);
    MwCORP= zeros(info.nstm,info.nstm,info.nexp);
    MwdCOR= zeros(info.nstm,info.nstm,info.nexp);
    MwChIAmI= zeros(info.nstm,info.nstm,info.nexp);
    
    % thres currently deactivated
    thres= 0;
    avg_avg_RSPsum= sum(avg_RSPsum,1,'omitnan');
    
    for i= 1:info.nexp
        selROI= info.roiid==i;
        selRSP= avg_avg_RSPsum > thres;
        
        selROI= selROI.* selRSP;
        
        for j= 1:info.nstm
            w1C= input.mAMP.psC(psC1).avg(j,selROI==1);
            w1P= input.mAMP.psC(psC2).avg(j,selROI==1);
            
            for k= 1:info.nstm
                w2C= input.mAMP.psC(psC1).avg(k,selROI==1);
                w2P= input.mAMP.psC(psC2).avg(k,selROI==1);
                
                % (0) calculate pattern correlation - redundant, but easy here
                MwCORC(j,k,i)= corr(w1C',w2C');
                MwCORP(j,k,i)= corr(w1P',w2P');
                MwdCOR(j,k,i)= MwCORP(j,k,i) - MwCORC(j,k,i);
                
                % (1) calculate amplitude ratios
                wAmIC= abs((w1C-w2C) ./ (w1C+w2C));
                wAmIP= abs((w1P-w2P) ./ (w1P+w2P));
                
                % (2) calculate PIN-mediated change in amplitude ratio
                wChIAmI= (wAmIP-wAmIC) ./ (wAmIP+wAmIC);
                MwChIAmI(j,k,i)= mean(wChIAmI,'omitnan');
            end
        end
        
        wChIAmI= flatmat(MwChIAmI(1:cutdim,1:cutdim,i));
        wCORP= flatmat(MwCORP(1:cutdim,1:cutdim,i));
        
        mdelta.AmI.ChiAmI_vs_CORP(i)= corr(wChIAmI',wCORP');
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELTA POPULATION ANALYSES - CORRELATION
dCOS= 0;

if dCOS == 1
    % DELTA POPULATION ANALYSES - COSINE DISTANCE
    mdelta.anlPOP.dCOR.exp= input.anlPOP.psC(psC2).avg.cosDmat.exp(1:cutdim,1:cutdim,:) - input.anlPOP.psC(psC1).avg.cosDmat.exp(1:cutdim,1:cutdim,:);
else
    % DELTA POPULATION ANALYSES - CORRELATION
    mdelta.anlPOP.dCOR.exp= input.anlPOP.psC(psC2).avg.corrmat.exp(1:cutdim,1:cutdim,:) - input.anlPOP.psC(psC1).avg.corrmat.exp(1:cutdim,1:cutdim,:);
end
mdelta.anlPOP.dCOR.vec= NaN(pwCOMPnum(cutdim),info.nexp);
mdelta.anlPOP.dCOR.avg= NaN(info.nexp,1);
mdelta.anlPOP.dCORvCORP.r= NaN(info.nexp,1);
mdelta.anlPOP.dCORvCORP.rho= NaN(info.nexp,1);
mdelta.anlPOP.dCORvCORP.tau= NaN(info.nexp,1);

mdelta.anlPOP.dCORvCORC.r= NaN(info.nexp,1);
mdelta.anlPOP.dCORvCORC.rho= NaN(info.nexp,1);
mdelta.anlPOP.dCORvCORC.tau= NaN(info.nexp,1);

for i = 1:info.nexp
    vecd= flatmat(mdelta.anlPOP.dCOR.exp(1:cutdim,1:cutdim,i));
    if dCOS == 1
        vecP= flatmat(input.anlPOP.psC(psC2).avg.cosDmat.exp(1:cutdim,1:cutdim,i));
        vecC= flatmat(input.anlPOP.psC(psC1).avg.cosDmat.exp(1:cutdim,1:cutdim,i));
    else
        vecP= flatmat(input.anlPOP.psC(psC2).avg.corrmat.exp(1:cutdim,1:cutdim,i));
        vecC= flatmat(input.anlPOP.psC(psC1).avg.corrmat.exp(1:cutdim,1:cutdim,i));
    end
    mdelta.anlPOP.dCOR.avg(i)= mean(vecd);
    
    if size(vecd,2) == size(vecP,2)
        mdelta.anlPOP.dCORvCORP.r(i)= corr(vecd',vecP');
        mdelta.anlPOP.dCORvCORP.rho(i)= corr(vecd',vecP','Type','Spearman');
        mdelta.anlPOP.dCORvCORP.tau(i)= corr(vecd',vecP','Type','Kendall');
        
        mdelta.anlPOP.dCORvCORC.r(i)= corr(vecd',vecC');
        mdelta.anlPOP.dCORvCORC.rho(i)= corr(vecd',vecC','Type','Spearman');
        mdelta.anlPOP.dCORvCORC.tau(i)= corr(vecd',vecC','Type','Kendall');
        
        mdelta.anlPOP.dCOR.vecd(:,i)= vecd';
        mdelta.anlPOP.dCOR.vecP(:,i)= vecP';
        mdelta.anlPOP.dCOR.vecC(:,i)= vecC';
        
        mdelta.anlPOP.dCOR.vecd_EXPavg(i)= mean(vecd);
    end
    
    % iCOR
    mdelta.anlPOP.diCOR.avg.exp{i}= input.anlPOP.psC(psC2).avg.icorrmat.exp{1,i}(1:cutdim,1:cutdim,:) - input.anlPOP.psC(psC1).avg.icorrmat.exp{1,i}(1:cutdim,1:cutdim,:);
    mdelta.anlPOP.diCOR.trl.exp{i}= input.anlPOP.psC(psC2).trl.icorrmat.exp{1,i}(1:cutdim*ntrl,1:cutdim*ntrl,:) - input.anlPOP.psC(psC1).trl.icorrmat.exp{1,i}(1:cutdim*ntrl,1:cutdim*ntrl,:);
end

mdelta.anlPOP.dCOR.vecd_avg= mean(mdelta.anlPOP.dCOR.vecd,2,'omitnan');
mdelta.anlPOP.dCOR.vecP_avg= mean(mdelta.anlPOP.dCOR.vecP,2,'omitnan');
mdelta.anlPOP.dCOR.vecC_avg= mean(mdelta.anlPOP.dCOR.vecC,2,'omitnan');
mdelta.anlPOP.dCOR.avg= mean(mdelta.anlPOP.dCOR.exp,3,'omitnan');


%% individual contribution to correlation coefficient
if isfield(input.anlPOP.psC(2).avg,'icorrmat')
    for i = 1:info.nexp
        mdelta.anlPOP.dicorrmat_avg.exp{1,i}= input.anlPOP.psC(2).avg.icorrmat.exp{1,i}-input.anlPOP.psC(1).avg.icorrmat.exp{1,i};
    end
end


%% time-dependent pattern correlations
if isfield(input.anlPOPtim.psC(2),'timCOR_exp')
    % calculate delta
    mdelta.anlPOPtim.dCOR_exp= input.anlPOPtim.psC(2).timCOR_exp(1:cutdim,1:cutdim,:,:)-input.anlPOPtim.psC(1).timCOR_exp(1:cutdim,1:cutdim,:,:);
    
    % average across experiments
    tmp0= mean(mdelta.anlPOPtim.dCOR_exp,4,'omitnan');
    
    % convert matrices to vectors 
    mdelta.anlPOPtim.dCOR_avg= flatmat3D(tmp0);
    mdelta.anlPOPtim.dCOR_gavg= mean(mdelta.anlPOPtim.dCOR_avg,1,'omitnan');
    mdelta.anlPOPtim.dCOR_gstd= std(mdelta.anlPOPtim.dCOR_avg,0,1,'omitnan');
    mdelta.anlPOPtim.dCOR_gsem= std(mdelta.anlPOPtim.dCOR_avg,0,1,'omitnan')./(size(mdelta.anlPOPtim.dCOR_avg,1)-1);
end

end