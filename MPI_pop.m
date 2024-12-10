function POP = MPI_pop(input,info,cutdim,target,trlLST)

% input (tmpX): data matrix, e.g. odors x ROIs
%---rows are neurons = variables = dimensions;
%---cols are trials = observations = datapoints
%classind: a vector defining the class (e.g. odor) for each trial.

cnt = 0;
if isfield(info,'RSPonly') == 0
    RSPonly = 1;
else
    RSPonly = info.RSPonly;
end

if isfield(info,'ContrE') == 0
    ContrE = 0;
else
    ContrE = info.ContrE;
    ampthrLO= 0.05;
    ampthrHI= 0.5;
end

trlCLSSFCTN= 0;

if nargin<4
    % Ade, Ala, Cad, Cys, Spe, TCA, (Trp)
    if trlCLSSFCTN==0
        target= [1 1 2 2 2 1]; % average-based
    else
        target= [1 1 1 1 2 2 2 2 2 2 1 1]; % trial-based
    end
end
if nargin<5
    % Ade, Ala, Cad, Cys, Spe, TCA, (Trp)
    if trlCLSSFCTN==0
        trlLST= {'AdeC','AlaC','CadC','CysC','SpeC','TCAC'};
        maxiter= 50;
    else
        trlLST= {'AdeC','AdeC','AlaC','AlaC','CadC','CadC','CysC','CysC','SpeC','SpeC','TCAC','TCAC'};
        maxiter= 100;
    end
end

psCcnt= 0;
delta= 0;
for i = 1 : info.npsC
    
    if info.npsC == 2
        if i == 1
            i= 2;
            psCcnt= psCcnt+1;
        else
            i= 1;
            psCcnt= psCcnt+1;
        end
    end
    
    if psCcnt == 3
        break
    end
    
    if RSPonly==1
        bool = input.psC(i).avg_RSP_avg1(1,:) > 0;
        selROI0 = info.roiid .* bool;
    end
    
    POP.psC(i).avg.cosDmat.exp = NaN (info.nstm,info.nstm,info.nexp);
    
    % for each experiment
    cnt2=0;
    for j = 1 : info.nexp
        
        selROI = j == info.roiid;
        
        if RSPonly==1
            bool = input.psC(i).avg_RSP_avg1(1,:) > 0;
            selROI = selROI .* bool;
        else
            selROI0 = j == info.roiid;
        end
        
        % ... check whether each experiment has the minimum number of rois, e.g. 5!
        roinum= sum(selROI,'all');
        if roinum <=4
            exp= 0;
        else
            exp= 1;
            cnt2= cnt2+1;
        end
        
        % vectors based on AVG responses
        tmp0 = input.psC(i).avg(:,:);
        tmp1 = tmp0(:,selROI>0);
        tmp2 = tmp0(:,selROI0>0);
        tmp3 = tmp0(:,j == info.roiid); % equivalent to tmp1 w/ RSPonly=0
        tmp2lda = tmp0(1:6,selROI0>0);
        
        % vectors based on TRL responses
        tmp00 = input.psC(i).trl(:,:);
        tmp11 = tmp00(:,selROI>0);
        tmp22 = tmp00(:,selROI0>0);
        tmp22lda = tmp00(1:12,selROI0>0);
        tmp33 = tmp00(:,j == info.roiid);
        
        
        %% ODOR CORRELATION matrix (within experiment)
        if exp == 1
            % re-calculate ctrl patterns - leave PIN patterns untouched
            if ContrE == 1 && i == 1
                % take PIN data 
                tmpP = input.psC(2).avg(:,selROI>0);
                tmp1 = tmpP;

                tmpLO= tmp1(:,:)<ampthrLO;
                tmpHI= tmp1(:,:)>ampthrHI;

                tmp1(tmpLO)= 0;
                
                % STRATEGY 1
                % tmp1(tmpHI)= ampthrHI; 
                % STRATEGY 2
                ampMAX= max(tmp1');
                ampMAXM= repmat(ampMAX,size(tmp1,2),1)';
                tmp1(tmpHI)= ampMAXM(tmpHI);

                % tmpd= tmpP-tmp1;
            end

            POP.psC(i).avg.corrmat.exp(:,:,j) = corrcoef(tmp1');
            POP.psC(i).trl.corrmat.exp(:,:,j) = corrcoef(tmp11');
            
            % -------------------------------------------------------------
            % -------------------------------------------------------------
            % INDIVIDUAL CONTRIBUTION TO CORRELATION COEFFICIENT
            % Input: matrix neurons x stimuli. Correlations are calculated between stimuli.
            % Output: matrix stimuli x stimuli x neurons. Each entry is the contribution
            % of each neuron to the correlation between each stimulus pair.
            
            
            % -------------------------------------------------------------
            % vectors based on AVG responses
            [ccc,~,maxA,sumA,dA,A]= CorrCoefContrib(tmp1');
            POP.psC(i).avg.icorrmat.exp{j} = ccc;
            POP.psC(i).avg.imaxAmat.exp{j} = maxA;
            POP.psC(i).avg.isumAmat.exp{j} = sumA;
            POP.psC(i).avg.idAmat.exp{j} = dA;
            POP.psC(i).avg.iAmat.exp{j} = A;
            
            % ... correlation between iCOR and max response
            vdA= flatmat3D(dA(1:cutdim,1:cutdim,:));
            vsumA= flatmat3D(sumA(1:cutdim,1:cutdim,:));
            vmaxA= flatmat3D(maxA(1:cutdim,1:cutdim,:));
            vccc= flatmat3D(ccc(1:cutdim,1:cutdim,:));
            
            cccIDX= zeros(size(vccc,1),size(ccc,3));
            cccRNK= zeros(size(vccc,1),size(ccc,3));dcccRNK= zeros(size(vccc,1),size(ccc,3));
            maxARNK= zeros(size(vccc,1),size(ccc,3));dmaxARNK= zeros(size(vccc,1),size(ccc,3));
            sumARNK= zeros(size(vccc,1),size(ccc,3));dsumARNK= zeros(size(vccc,1),size(ccc,3));
            dARNK= zeros(size(vccc,1),size(ccc,3));ddARNK= zeros(size(vccc,1),size(ccc,3));
            
            % LOOP through odor PAIRS!
            for k = 1:size(vccc,1)
                POP.psC(i).avg.icorr_vs_maxA.exp(k,j)= corr(vccc(k,:)',vmaxA(k,:)');
                POP.psC(i).avg.icorr_vs_sumA.exp(k,j)= corr(vccc(k,:)',vsumA(k,:)');
                POP.psC(i).avg.icorr_vs_dA.exp(k,j)= corr(vccc(k,:)',vdA(k,:)');
                
                % make ssure that the indexing is kept across psC 1 & 2
                % (i.e. defined during PIN)
                if info.npsC == 2
                    delta= 1;
                    if i == 2
                        [~,I]= sort(vccc(k,:),'descend');
                    else
                        I= POP.psC(2).avg.icorrIDX.exp{j}(k,:);
                    end
                    
                else
                    delta= 0;
                    [~,I]= sort(vccc(k,:),'descend');
                end
                
                cccIDX(k,:)= I;
                cccRNK(k,:)= vccc(k,I);
                maxARNK(k,:)= vmaxA(k,I);
                sumARNK(k,:)= vsumA(k,I);
                dARNK(k,:)= vdA(k,I);
                
                % top 5% neurons with high iCOR (PIN)
                minAPPRNC= 5;
                
                frc= round(size(vccc,2)*0.05);
                
                % standard: top 5%
                I0= I(1:frc);
                
                % try... 5-10%
                r= 4;
                I0= I(r*frc+1:(r+1)*frc);
                  
%                 % try last 5%
%                 I0= I(size(I,2)-frc+1:end);
                
                if k == 1
                    Ifrc= I0;
                else
                    Ifrc= cat(2,Ifrc,I0);
                    
                    if k == size(vccc,1)
                        for z = 1:size(Ifrc,2)
                            count= find(Ifrc==Ifrc(z));
                            if size(count,2) < minAPPRNC
                               Ifrc(count)= NaN; 
                            end
                        end
                        Ifrc= Ifrc(~isnan(Ifrc));
                        Ifrc= unique(Ifrc);
                        POP.psC(i).avg.icorrIDX_frc.exp{j}= Ifrc;
                    end
                end
                
                
                % calculate PIN-induced changes - for each odor pair and
                % plane to assure correspondence between ROIs
                if delta == 1 && i == 1
                    % get PIN data
                    cccP= POP.psC(2).avg.icorrmat.exp{j};
                    maxAP= POP.psC(2).avg.imaxAmat.exp{j};
                    sumAP= POP.psC(2).avg.isumAmat.exp{j};
                    dAP= POP.psC(2).avg.idAmat.exp{j};
                    
                    % flatten PIN data
                    vdAP= flatmat3D(dAP(1:cutdim,1:cutdim,:));
                    vmaxAP= flatmat3D(maxAP(1:cutdim,1:cutdim,:));
                    vsumAP= flatmat3D(sumAP(1:cutdim,1:cutdim,:));
                    vcccP= flatmat3D(cccP(1:cutdim,1:cutdim,:));
                    
                    % delta icorr and delta amplitudes for each odor
                    % pair
                    dcccRNK(k,:)= vcccP(k,I) - vccc(k,I);
                    dmaxARNK(k,:)= vmaxAP(k,I) - vmaxA(k,I);
                    dsumARNK(k,:)= vsumAP(k,I) - vsumA(k,I);
                    ddARNK(k,:)= vdAP(k,I) - vdA(k,I);
                    
                    POP.psC(2).avg.dicorr_vs_dmaxA.exp(k,j)= corr(dcccRNK(k,:)',dmaxARNK(k,:)');
                    POP.psC(2).avg.dicorr_vs_dsumA.exp(k,j)= corr(dcccRNK(k,:)',dsumARNK(k,:)');
                    POP.psC(2).avg.dicorr_vs_ddA.exp(k,j)= corr(dcccRNK(k,:)',ddARNK(k,:)');
                    POP.psC(2).avg.icorrP_vs_ddA.exp(k,j)= corr(vcccP(k,:)',ddARNK(k,:)');
                end
            end
            POP.psC(i).avg.icorrIDX.exp{j} = cccIDX;
            POP.psC(i).avg.icorr.exp{j} = mean(cccRNK,1);
            POP.psC(i).avg.imaxA.exp{j} = mean(maxARNK,1);
            POP.psC(i).avg.isumA.exp{j} = mean(sumARNK,1);
            POP.psC(i).avg.idA.exp{j} = mean(dARNK,1);
            
            % accumulate across planes
            if exist('first') == 0
                POP.psC(i).avg.icorr.all = mean(cccRNK,1);
                POP.psC(i).avg.imaxA.all = mean(maxARNK,1);
                POP.psC(i).avg.isumA.all = mean(sumARNK,1);
                POP.psC(i).avg.idA.all = mean(dARNK,1);
                first= 1;
            else
                POP.psC(i).avg.icorr.all = cat(2,POP.psC(i).avg.icorr.all,mean(cccRNK,1));
                POP.psC(i).avg.imaxA.all = cat(2,POP.psC(i).avg.imaxA.all,mean(maxARNK,1));
                POP.psC(i).avg.isumA.all = cat(2,POP.psC(i).avg.isumA.all,mean(sumARNK,1));
                POP.psC(i).avg.idA.all = cat(2,POP.psC(i).avg.idA.all,mean(dARNK,1));
            end
            
            % sort concatenated data in the very end
            % ... after last experiment was analysed
            if j == info.nexp
                POP.psC(i).avg.icorr.all_unsorted= POP.psC(i).avg.icorr.all;
                
                if delta == 1
                    if i == 2 %(psC: PIN)
                        [~,Iall]= sort(POP.psC(2).avg.icorr.all,'descend');
                    end
                else
                    [~,Iall]= sort(POP.psC(1).avg.icorr.all,'descend');
                end
                POP.psC(i).avg.icorr.all= POP.psC(i).avg.icorr.all(Iall);
                POP.psC(i).avg.imaxA.all= POP.psC(i).avg.imaxA.all(Iall);
                POP.psC(i).avg.isumA.all= POP.psC(i).avg.isumA.all(Iall);
                POP.psC(i).avg.idA.all= POP.psC(i).avg.idA.all(Iall);
                POP.psC(i).avg.icorrIDX.all= Iall;
                
                POP.psC(i).avg.icorr_vs_maxA.avg= mean(POP.psC(i).avg.icorr_vs_maxA.exp,1);
                POP.psC(i).avg.icorr_vs_sumA.avg= mean(POP.psC(i).avg.icorr_vs_sumA.exp,1);
                POP.psC(i).avg.icorr_vs_dA.avg= mean(POP.psC(i).avg.icorr_vs_dA.exp,1);
                
                clear first
            end
            
            
            if delta == 1 && i == 1
                POP.psC(2).avg.dicorr.exp{j} = mean(dcccRNK,1);
                POP.psC(2).avg.dimaxA.exp{j} = mean(dmaxARNK,1);
                POP.psC(2).avg.disumA.exp{j} = mean(dsumARNK,1);
                POP.psC(2).avg.didA.exp{j} = mean(ddARNK,1);
                
                % accumulate across planes
                if j == 1
                    POP.psC(2).avg.dicorr.all= mean(dcccRNK,1);
                    POP.psC(2).avg.dimaxA.all= mean(dmaxARNK,1);
                    POP.psC(2).avg.disumA.all= mean(dsumARNK,1);
                    POP.psC(2).avg.didA.all= mean(ddARNK,1);
                else
                    POP.psC(2).avg.dicorr.all= cat(2,POP.psC(2).avg.dicorr.all,mean(dcccRNK,1));
                    POP.psC(2).avg.dimaxA.all= cat(2,POP.psC(2).avg.dimaxA.all,mean(dmaxARNK,1));
                    POP.psC(2).avg.disumA.all= cat(2,POP.psC(2).avg.disumA.all,mean(dsumARNK,1));
                    POP.psC(2).avg.didA.all= cat(2,POP.psC(2).avg.didA.all,mean(ddARNK,1));
                end
                
                % sort concatenated data in the very end
                % ... after last experiment was analysed
                if j == info.nexp
                    dicorr= POP.psC(2).avg.dicorr.all;
                    dimaxA= POP.psC(2).avg.dimaxA.all;
                    disumA= POP.psC(2).avg.disumA.all;
                    didA= POP.psC(2).avg.didA.all;
                    
                    % sort according to diCOR
                    [POP.psC(2).avg.dicorr.allSRTd,Iall2]= sort(dicorr,'descend');
                    POP.psC(2).avg.dimaxA.allSRTd= dimaxA(Iall2);
                    POP.psC(2).avg.disumA.allSRTd= disumA(Iall2);
                    POP.psC(2).avg.didA.allSRTd= didA(Iall2);
                    
                    % sort according to iCOR (PIN)
                    POP.psC(2).avg.dicorr.all= dicorr(Iall);
                    POP.psC(2).avg.dimaxA.all= dimaxA(Iall);
                    POP.psC(2).avg.disumA.all= disumA(Iall);
                    POP.psC(2).avg.didA.all= didA(Iall);
                    
                    POP.psC(2).avg.dicorr_vs_dmaxA.avg= mean(POP.psC(2).avg.dicorr_vs_dmaxA.exp,1);
                    POP.psC(2).avg.dicorr_vs_dsumA.avg= mean(POP.psC(2).avg.dicorr_vs_dsumA.exp,1);
                    POP.psC(2).avg.dicorr_vs_ddA.avg= mean(POP.psC(2).avg.dicorr_vs_ddA.exp,1);
                    POP.psC(2).avg.icorrP_vs_ddA.avg= mean(POP.psC(2).avg.icorrP_vs_ddA.exp,1);
                end
            end
            
            
            % -------------------------------------------------------------
            % vectors based on TRL responses
            [ccc,~,maxA]= CorrCoefContrib(tmp11');
            POP.psC(i).trl.icorrmat.exp{j} = ccc;
            POP.psC(i).trl.imaxAmat.exp{j} = maxA;
            
            % ... correlation between iCOR and max response
            vmaxA= flatmat3D(maxA);
            vccc= flatmat3D(ccc);
            
            for k = 1:size(vccc,1)
                POP.psC(i).trl.icorr_vs_maxA.exp(k,j)= corr(vmaxA(k,:)',vccc(k,:)');
            end
            
            clear maxA ccc
            
        else
            POP.psC(i).avg.corrmat.exp(1:size(tmp0,1),1:size(tmp0,1),j) = NaN;
            POP.psC(i).trl.corrmat.exp(1:size(tmp00,1),1:size(tmp00,1),j) = NaN;
        end
        
        
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % -----------------------------------------------------------------
        % FULL data set, not specific experiments - only run once!
        if j == 1
%             POP.psC(i).avg.corrmat.set = corrcoef(tmp2');
%             POP.psC(i).trl.corrmat.set = corrcoef(tmp22');
            
            % before 15.06.23,  tmp2 was used here - but tmp2 only contains
            % the rois from the current experiment (i.e. j == 1)
            POP.psC(i).avg.corrmat.set = corrcoef(tmp0');
            POP.psC(i).trl.corrmat.set = corrcoef(tmp00');          
            %              % factor analysis
            %              factnum= 3;
            %              [lambda,psi,T,stats] = factoran(tmp2',factnum);
            
            % 'smart' shuffling: shuffle until at least 70% of entries
            % differ from original odor assignment (note that w/ 6 odors
            % and 2 classes, this criterion 'blocks' only purely identical
            % permutations
            % note also, that reversing all entries is equivalent to
            % reversing none!
            
            CLSS=1;
            LDA=0;
            
            % ------------------------ prep ------------------------------
            if LDA == 1 || CLSS == 1
                
                PCdims= 2; % low feature number to avoid overfitting in LDA!
                PCdims= 50;
                PCdims= -1; % use all dimensions (no PCA)
                
                Pshf_d(1:size(target,2),maxiter)= ones;
                Pshf_avg(1:maxiter)= ones;
                
                smrtshf= 0;
                for z=1:maxiter
                    if smrtshf == 1
                        hiFRC= 0.8;
                        loFRC= 0.2;
                        d=size(target,2);
                    else
                        hiFRC= 1;
                        loFRC= 0;
                        d=-1;
                    end
                    
                    while sum(d,'all') > size(target,2)*hiFRC || sum(d,'all') < size(target,2)*loFRC
                        target2= target(randperm(size(target,2)));
                        d= target2 == target;
                        Pshf_d(:,z)= d;
                    end
                    
                    % ------------------------ CLSSFCTN ------------------------------
                    if CLSS == 1
                        if trlCLSSFCTN == 1
                            C= TFclssfctn(tmp22lda',target2,PCdims);
                        else
                            C= TFclssfctn(tmp2lda',target2,PCdims);
                        end
                    end
                    Cshf_avg(z)= C.Cavg;
                    
                    % ------------------------ LDA ------------------------------
                    if LDA == 1
                        POP.psC(i).avg.DIST.set= TFdistances(tmp22lda',target2,PCdims);
                        P= POP.psC(i).avg.DIST.set.P;
                        Pshf_true= diag(P(1:size(target2,2),target2));
                        Pshf_avg(z)= mean(diag(P(1:size(target2,2),target2)),'omitnan');
                    end
                end
            end
            
            % ------------------------ CLSSFCTN ------------------------------
            if CLSS == 1
                % original valence labels
                if trlCLSSFCTN == 1
                    POP.psC(i).trl.CLSSFCTN.set= TFclssfctn(tmp22lda',target2,PCdims);
                else
                    POP.psC(i).trl.CLSSFCTN.set= TFclssfctn(tmp2lda',target2,PCdims);
                end
                Ctrue= POP.psC(i).trl.CLSSFCTN.set.C(:,1);
                POP.psC(i).trl.CLSSFCTN.set.CavgPOS= Ctrue(target==1);
                POP.psC(i).trl.CLSSFCTN.set.CavgNEG= Ctrue(target==2);
                
                % shuffled valence labels
                Cshf_avg= sort(Cshf_avg);
                POP.psC(i).trl.CLSSFCTN.set.Cshf_d= Pshf_d; % changes in shuffled target vector (vs. original target vector)
                POP.psC(i).trl.CLSSFCTN.set.Cshf_avg= Cshf_avg;
                POP.psC(i).trl.CLSSFCTN.set.Cshf_avg_090= Cshf_avg(ceil(90*(maxiter/100)+1));
                POP.psC(i).trl.CLSSFCTN.set.Cshf_avg_max= Cshf_avg(maxiter);
            end
            
            % ------------------------ LDA ------------------------------
            if LDA == 1
                % original valence labels
                POP.psC(i).avg.DIST.set= TFdistances(tmp22lda',target,PCdims);
                P= POP.psC(i).avg.DIST.set.P;
                fullP = POP.psC(i).avg.DIST.set.fullP;
                POP.psC(i).avg.DIST.set.fullPtrue= diag(fullP(1:size(target,2),target));
                POP.psC(i).avg.DIST.set.fullPtrue_avg= mean(diag(fullP(1:size(target,2),target)),'omitnan');
                POP.psC(i).avg.DIST.set.Ptrue= diag(P(1:size(target,2),target));
                POP.psC(i).avg.DIST.set.PtruePOS= POP.psC(i).avg.DIST.set.Ptrue(target==1);
                POP.psC(i).avg.DIST.set.PtrueNEG= POP.psC(i).avg.DIST.set.Ptrue(target==2);
                POP.psC(i).avg.DIST.set.Ptrue_avg= mean(diag(P(1:size(target,2),target)),'omitnan');
                
                POP.psC(i).avg.DIST.set.trlLST= trlLST;
                POP.psC(i).avg.DIST.set.target= target;
                
                % shuffled valence labels
                Pshf_avg= sort(Pshf_avg);
                POP.psC(i).avg.DIST.set.Pshf_d= Pshf_d; % changes in shuffled target vector (vs. original target vector)
                POP.psC(i).avg.DIST.set.Pshf_avg= Pshf_avg;
                POP.psC(i).avg.DIST.set.Pshf_avg_090= Pshf_avg(ceil(90*(maxiter/100)+1));
                POP.psC(i).avg.DIST.set.Pshf_avg_max= Pshf_avg(maxiter);
            end
        end
        
        
        
        %% SIGNAL CORRELATION (within experiment; based on AVG responses only) - RSPonly choice applies!
        if exp == 1
            % -------------------------------------------------------------
            % signal correlations (RSPonly, if set)
            POP.psC(i).avg.sigCORmat.exp(j).mat = corrcoef(tmp1(1:cutdim,:));
            
            
            % -------------------------------------------------------------
            % perform AFFINITY PROPAGATION CLUSTERING (all ROIS after
            % RSPexcl; not affected by RSPonly)
            [~,~,~,~,ClustindsCells,~,~]= RF_doaffprop(tmp3','cosine');
            
            % size of each cluster
            szClust= zeros(max(ClustindsCells),1);
            for a1= 1 : max(ClustindsCells)
                szClust(a1)= sum(ClustindsCells==a1);
            end
            
            % size of primary cluster
            [M1,I1] = max(szClust);
            
            % silhouette analysis
            % The silhouette value for each point is a measure of how
            % similar that point is to points in its own cluster, when
            % compared to points in other clusters.
            % The silhouette value ranges from –1 to 1. A high silhouette
            % value indicates that i is well matched to its own cluster,
            % and poorly matched to other clusters.
            silh= silhouette(tmp3',ClustindsCells,'cosine');
            
            silhClust= zeros(max(ClustindsCells),1);
            for a1= 1 : max(ClustindsCells)
                silhClust(a1) = mean(silh(ClustindsCells==a1),'omitnan');
            end
            
            % 27.04.22: "switch" primary cluster to the cluster with the
            % highest mean silhouette value
            [M1,I1] = max(silhClust);
            % contrast with lowest mean silhouette value???
            [M0,I0] = min(silhClust);
            
            % output
            POP.psC(i).avg.affprop.exp(j).ClustindsCells= ClustindsCells;
            
            % all clusters
            POP.psC(i).avg.affprop.exp(j).nClust= max(ClustindsCells);
            POP.psC(i).avg.affprop.exp(j).szClust= (szClust ./ size(tmp3,2)) .* 100; % in percent
            POP.psC(i).avg.affprop.exp(j).silh= silh;
            POP.psC(i).avg.affprop.exp(j).silhClust= silhClust;
            for a1= 1 : max(ClustindsCells)
                POP.psC(i).avg.affprop.exp(j).idxClust_local{a1}= find(ClustindsCells==a1);
                if j==1
                    POP.psC(i).avg.affprop.exp(j).idxClust_global{a1}= find(ClustindsCells==a1);
                else
                    POP.psC(i).avg.affprop.exp(j).idxClust_global{a1}= find(ClustindsCells==a1) + info.roinum2(j-1);
                end
            end
            
            if info.osnum == 2 % ... quick workaround - because this caused problems with larval data --> restrict to DpIN data
                % primary cluster (size, silhouette)
                POP.psC(i).avg.affprop.exp(j).szClust1= (M1 ./ size(tmp3,2)) .* 100; % in percent
                POP.psC(i).avg.affprop.exp(j).idClust1= I1;
                POP.psC(i).avg.affprop.exp(j).idxClust1_local= find(ClustindsCells==I1);
                if j==1
                    POP.psC(i).avg.affprop.exp(j).idxClust1_global= find(ClustindsCells==I1);
                    POP.psC(i).avg.affprop.all.idxClust1_global= find(ClustindsCells==I1);
                else
                    POP.psC(i).avg.affprop.exp(j).idxClust1_global= find(ClustindsCells==I1) + sum(info.roinum2(1:j-1));
                    POP.psC(i).avg.affprop.all.idxClust1_global= cat(2,POP.psC(i).avg.affprop.all.idxClust1_global,find(ClustindsCells==I1) + sum(info.roinum2(1:j-1)));
                end
                POP.psC(i).avg.affprop.exp(j).silhClust1= silhClust(I1);
                
                % "contrast" cluster (size, silhouette) --> lowest silhouette
                % value
                POP.psC(i).avg.affprop.exp(j).szClust0= (M0 ./ size(tmp3,2)) .* 100; % in percent
                POP.psC(i).avg.affprop.exp(j).idClust0= I0;
                POP.psC(i).avg.affprop.exp(j).idxClust0_local= find(ClustindsCells==I0);
                if j==1
                    POP.psC(i).avg.affprop.exp(j).idxClust0_global= find(ClustindsCells==I0);
                    POP.psC(i).avg.affprop.all.idxClust0_global= find(ClustindsCells==I0);
                else
                    POP.psC(i).avg.affprop.exp(j).idxClust0_global= find(ClustindsCells==I0) + sum(info.roinum2(1:j-1));
                    POP.psC(i).avg.affprop.all.idxClust0_global= cat(2,POP.psC(i).avg.affprop.all.idxClust0_global,find(ClustindsCells==I0) + sum(info.roinum2(1:j-1)));
                end
                POP.psC(i).avg.affprop.exp(j).silhClust0= silhClust(I0);
            end
        end
        
        
        % -------------------------------------------------------------
        % signal correlations (RSPonly, if set)
        % FULL data set, not specific experiments - only run once!
        if j ==1
            POP.psC(i).avg.sigCORmat.set.mat = corrcoef(tmp2(1:cutdim,:));
            % average value for each roi
            for k = 1 : size(tmp2,2)
                POP.psC(i).avg.sigCORmat.set.mat(k,k) = NaN;
                POP.psC(i).avg.sigCORavg.set(k) = mean(POP.psC(i).avg.sigCORmat.set.mat(:,k),'omitnan');
                POP.psC(i).avg.sigCORmat.set.mat(k,k) = 1;
            end
        end
        
        % average value for each roi
        if exp == 1
            for k = 1 : size(tmp1,2)
                POP.psC(i).avg.sigCORmat.exp(j).mat(k,k) = NaN;
                POP.psC(i).avg.sigCORavg.exp(j).avg(k) = mean(POP.psC(i).avg.sigCORmat.exp(j).mat(:,k),'omitnan');
                POP.psC(i).avg.sigCORavg.avg(cnt+k) = POP.psC(i).avg.sigCORavg.exp(j).avg(k);
                POP.psC(i).avg.sigCORmat.exp(j).mat(k,k) = 1;
            end
            cnt = cnt + size(tmp1,2);
        end
        
        
        %% loop through STIMULI (#1)
        for k = 1 : info.nstm
            if info.npsC == 1
                % original option
                selTRL = strcmp(strcat(info.stmLST{k},info.psCLST{i}),info.trlLST);
            else
                % added this from above on 27.09.24 - due to error that was previously not there 
                selTRL = strcmp(strcat(info.stmLST{k}),info.stmLST_cnd);
            end

            % FULL data set, not specific experiments - only run once!
            if j ==1
                POP.psC(i).avg.popsprs.set = Sparseness(tmp2(k,:));
                
                tmp222 = tmp00(selTRL>0,selROI0>0);
            end
            
            
            % POPULATION SPARSENESS
            if exp == 1
                POP.psC(i).avg.popsprs.exp(k,j) = Sparseness(tmp1(k,:));
            end
            
            
            % TRIAL ODOR CORRELATION matrix (within experiment)
            if exp == 1
                tmp000 = tmp00(selTRL>0,selROI>0);
                if k==1
                    % FULL data set, not specific experiments - only run once!
                    if j ==1
                        POP.psC(i).trl.TRLcor.set(:,:,k) = corrcoef(tmp222');
                    end
                    POP.psC(i).trl.TRLcor.exp(j).mat(:,:,k) = corrcoef(tmp000');
                    
                elseif(k>1) && (size(tmp000,1) == size(POP.psC(i).trl.TRLcor.exp(j).mat,1))
                    % FULL data set, not specific experiments - only run once!
                    if j ==1
                        POP.psC(i).trl.TRLcor.set(:,:,k) = corrcoef(tmp222');
                    end
                    POP.psC(i).trl.TRLcor.exp(j).mat(:,:,k) = corrcoef(tmp000');
                end
            end
            
            % loop through STIMULI (#2)
            for l = 1 : info.nstm
                if exp == 1
                    mat12(1,:) = tmp1(k,:);
                    mat12(2,:) = tmp1(l,:);
                    POP.psC(i).avg.cosDmat.exp(k,l,j) = pdist(mat12,'cosine');
                end
                
                % FULL data set, not specific experiments - only run once!
                %                 if j == 1
                mat122(1,:) = tmp2(k,:);
                mat122(2,:) = tmp2(l,:);
                POP.psC(i).avg.cosDmat.set(k,l) = pdist(mat122,'cosine');
                %                 end
            end
        end
        clear mat12; clear mat122;
        
        for k = 1 : info.nstm
            POP.psC(i).avg.cosDmat.set(k,k) = NaN;
            POP.psC(i).avg.corrmat.set(k,k) = NaN;
            
            POP.psC(i).avg.cosDmat.set_avg2(k)= mean(POP.psC(i).avg.cosDmat.set(:,k),1,'omitnan');
            POP.psC(i).avg.corrmat.set_avg2(k)= mean(POP.psC(i).avg.corrmat.set(:,k),1,'omitnan');
            
            POP.psC(i).avg.cosDmat.set(k,k) = 0;
            POP.psC(i).avg.corrmat.set(k,k) = 1;
        end
        
        % average TRIAL ODOR CORRELATION matrix - for each experiment; mean across stimuli
        if exp == 1
            POP.psC(i).trl.TRLcor.exp(j).avg = mean(POP.psC(i).trl.TRLcor.exp(j).mat,3);
            trlCOR_tmp(:,:,j) = mean(POP.psC(i).trl.TRLcor.exp(j).mat,3);
        else
            POP.psC(i).trl.TRLcor.exp(j).avg(1:sum(selTRL),1:sum(selTRL)) = NaN;
            trlCOR_tmp(1:sum(selTRL),1:sum(selTRL),j) = NaN;
        end
    end
    
    if cnt2 >= 2
        % "coding structures"
        if info.CODstrct == 1
            POP.psC(i).avg.corrmat.vec = flatmat3D(POP.psC(i).avg.corrmat.exp(1:cutdim,1:cutdim,:));
            POP.psC(i).avg.cosDmat.vec = flatmat3D(POP.psC(i).avg.cosDmat.exp(1:cutdim,1:cutdim,:));
        end
        
        % grand average matrices
        POP.psC(i).avg.corrmat.avg = mean(POP.psC(i).avg.corrmat.exp,3,'omitnan');
        POP.psC(i).trl.corrmat.avg = mean(POP.psC(i).trl.corrmat.exp,3,'omitnan');
        POP.psC(i).avg.cosDmat.avg = mean(POP.psC(i).avg.cosDmat.exp,3,'omitnan');
        POP.psC(i).avg.popsprs.avg = mean(POP.psC(i).avg.popsprs.exp,2,'omitnan');
    end
    
    % grand average TRIAL ODOR CORRELATION matrix; <(<stimuli>)>
    POP.psC(i).trl.TRLcor.avg = mean(trlCOR_tmp,3,'omitnan');
end

end