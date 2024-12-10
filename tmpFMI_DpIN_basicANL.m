saveStr= strcat('C:\Users\tfrank\Dropbox (Personal)\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\fishdata_basicANL\tmp_basicANL',sfxNOW,'_os',num2str(osnum),'.mat');
saveStr= strcat('D:\Dropbox\SHARED with FMILab\lab - FMI\fmi - science\RAW DATA - CLOUD\fishdata_basicANL\tmp_basicANL',sfxNOW,'_os',num2str(osnum),'.mat');


% tuning, signal correlations, spt 
sprsC= DATA.grp(1).anlCEL.psC(1).avg.sprs';
sigCORC= DATA.grp(1).anlPOP.psC(1).avg.sigCORavg.avg';
roiid= DATA.grp(1).info.roiid';
if isfield(DATA.grp(1),'mdelta') == 1
    sprsP= DATA.grp(1).anlCEL.psC(2).avg.sprs';
    sigCORP= DATA.grp(1).anlPOP.psC(2).avg.sigCORavg.avg';
    dsprs= sprsP-sprsC;
    save(saveStr,'dsprs','sprsC','sigCORC','sprsP','sigCORP','roiid');
    
    % IRC and 2nd order correlations
    IRCvPIN= DATA.grp(1).mdelta.IRCvPIN.trl_avg';
    
    if DATA.grp(1).info.osnum == 2
        % plane-wise
        sigCOR_r2nd_exp= DATA.grp.mdelta.sigCOR.r2nd_exp';
        % across entire dataset
        sigCORPvec= DATA.grp.mdelta.sigCOR.Pvec';
        sigCORdvec= DATA.grp.mdelta.sigCOR.dvec';
        sigCOR_r2nd= DATA.grp.mdelta.sigCOR.r2nd';
        sigCOR_r2ndSHF= DATA.grp.mdelta.sigCOR.r2ndSHF';
        save(saveStr,'IRCvPIN','sigCOR_r2nd_exp','sigCORPvec','sigCORdvec','sigCOR_r2ndSHF','sigCOR_r2ndSHF','-append');
    else
        save(saveStr,'IRCvPIN','-append');
    end
else
    save(saveStr,'sprsC','sigCORC','roiid');
end


% distance matrices
mCORC= DATA.grp(1).anlPOP.psC(1).avg.corrmat.avg;
mCOSC= DATA.grp(1).anlPOP.psC(1).avg.cosDmat.avg;
mCORCset= DATA.grp(1).anlPOP.psC(1).avg.corrmat.set;
mCOSCset= DATA.grp(1).anlPOP.psC(1).avg.cosDmat.set;
% wCORC= DATA.grp(1).mdelta.anlPOP.dCOR.vecC_avg;
% mCORvecC= DATA.grp(1).mdelta.anlPOP.dCOR.vecC;
if isfield(DATA.grp(1),'mdelta') == 1
    wCORC= DATA.grp(1).mdelta.anlPOP.dCOR.vecC_avg;
    mCORvecC= DATA.grp(1).mdelta.anlPOP.dCOR.vecC;

    mCORP= DATA.grp(1).anlPOP.psC(2).avg.corrmat.avg;
    mCOSP= DATA.grp(1).anlPOP.psC(2).avg.cosDmat.avg;
    mCORPset= DATA.grp(1).anlPOP.psC(2).avg.corrmat.set;
    mCOSPset= DATA.grp(1).anlPOP.psC(2).avg.cosDmat.set;
    mCORd= mCORP-mCORC; mCOSd= mCOSP-mCOSC;
    wCORd_exp= DATA.grp(1).mdelta.anlPOP.dCOR.vecd_EXPavg';
    wCORd= DATA.grp(1).mdelta.anlPOP.dCOR.vecd_avg;
    wCORP= DATA.grp(1).mdelta.anlPOP.dCOR.vecP_avg;
    wCORdvP= DATA.grp(1).mdelta.anlPOP.dCORvCORP.r;
    mCORvecP= DATA.grp(1).mdelta.anlPOP.dCOR.vecP;
    mCORvecd= DATA.grp(1).mdelta.anlPOP.dCOR.vecd;
    save(saveStr,'mCOSC','mCORC','mCOSCset','mCORCset','mCOSP','mCOSPset','mCORd','mCOSd','mCORP','mCORPset','wCORd','wCORP','wCORC','wCORd_exp','wCORdvP','mCORvecC','mCORvecP','mCORvecd','-append');
else
    save(saveStr,'mCOSC','mCORC','mCOSCset','mCORCset','-append');
end

% distance matrices - temporally resolved
if isfield(DATA.grp(1),'anlPOPtim') == 1
    timCORC_avg= DATA.grp(1).anlPOPtim.psC(1).timCOR_avg;
    timCORC_gavg= DATA.grp(1).anlPOPtim.psC(1).timCOR_gavg';
    timCORC_gstd= DATA.grp(1).anlPOPtim.psC(1).timCOR_gstd';
    timCORC_gsem= DATA.grp(1).anlPOPtim.psC(1).timCOR_gsem';
    if isfield(DATA.grp(1),'mdelta') == 1
        timCORP_avg= DATA.grp(1).anlPOPtim.psC(2).timCOR_avg;
        timCORP_gavg= DATA.grp(1).anlPOPtim.psC(2).timCOR_gavg';
        timCORP_gstd= DATA.grp(1).anlPOPtim.psC(2).timCOR_gstd';
        timCORP_gsem= DATA.grp(1).anlPOPtim.psC(2).timCOR_gsem';
        timCORd_avg= DATA.grp(1).mdelta.anlPOPtim.dCOR_avg;
        timCORd_gavg= DATA.grp(1).mdelta.anlPOPtim.dCOR_gavg';
        timCORd_gstd= DATA.grp(1).mdelta.anlPOPtim.dCOR_gstd';
        timCORd_gsem= DATA.grp(1).mdelta.anlPOPtim.dCOR_gsem';
        save(saveStr,'timCORC_gavg','timCORC_gstd','timCORC_gsem','timCORC_avg','timCORP_gstd','timCORP_gavg','timCORP_gsem','timCORP_avg','timCORd_gavg','timCORd_gstd','timCORd_gsem','timCORd_avg','-append');
    else
        save(saveStr,'timCORC_gavg','timCORC_gstd','timCORC_gsem','timCORC_avg','-append');
    end
end
% contribution to correlation
if isfield(DATA.grp(1),'mdelta') == 1
    icorrC= DATA.grp.anlPOP.psC(1).avg.icorr.all';
    imaxAC= DATA.grp.anlPOP.psC(1).avg.imaxA.all';
    isumAC= DATA.grp.anlPOP.psC(1).avg.isumA.all';
    idAC= DATA.grp.anlPOP.psC(1).avg.idA.all';

    icorrC_vs_maxAC= DATA.grp.anlPOP.psC(1).avg.icorr_vs_maxA.avg';
    icorrC_vs_sumAC= DATA.grp.anlPOP.psC(1).avg.icorr_vs_sumA.avg';
    icorrC_vs_dAC= DATA.grp.anlPOP.psC(1).avg.icorr_vs_dA.avg';

    icorrP= DATA.grp.anlPOP.psC(2).avg.icorr.all';
    imaxAP= DATA.grp.anlPOP.psC(2).avg.imaxA.all';
    isumAP= DATA.grp.anlPOP.psC(2).avg.isumA.all';
    idAP= DATA.grp.anlPOP.psC(2).avg.idA.all';
    icorrP_vs_maxAP= DATA.grp.anlPOP.psC(2).avg.icorr_vs_maxA.avg';
    icorrP_vs_sumAP= DATA.grp.anlPOP.psC(2).avg.icorr_vs_sumA.avg';
    icorrP_vs_dAP= DATA.grp.anlPOP.psC(2).avg.icorr_vs_dA.avg';
    
    % delta values
    dicorr= DATA.grp.anlPOP.psC(2).avg.dicorr.all';
    dimaxA= DATA.grp.anlPOP.psC(2).avg.dimaxA.all';
    disumA= DATA.grp.anlPOP.psC(2).avg.disumA.all';
    didA= DATA.grp.anlPOP.psC(2).avg.didA.all';
    dicorrSRTd= DATA.grp.anlPOP.psC(2).avg.dicorr.allSRTd';
    dimaxASRTd= DATA.grp.anlPOP.psC(2).avg.dimaxA.allSRTd';
    disumASRTd= DATA.grp.anlPOP.psC(2).avg.disumA.allSRTd';
    didASRTd= DATA.grp.anlPOP.psC(2).avg.didA.allSRTd';
    dicorr_vs_dmaxA= DATA.grp.anlPOP.psC(2).avg.dicorr_vs_dmaxA.avg';
    dicorr_vs_dsumA= DATA.grp.anlPOP.psC(2).avg.dicorr_vs_dsumA.avg';
    dicorr_vs_ddA= DATA.grp.anlPOP.psC(2).avg.dicorr_vs_ddA.avg';
    icorrP_vs_ddA= DATA.grp.anlPOP.psC(2).avg.icorrP_vs_ddA.avg';
    
    % top 5% contribution to r
    frc= round(size(didA,1)*0.05);
    [icorrPtop,I]= sort(icorrP,'descend');icorrPtop= icorrPtop(1:frc);
    didAtop= didA(I);didAtop= didAtop(1:frc);
    disumAtop= disumA(I);disumAtop= disumAtop(1:frc);
    dicorrtop= dicorr(I);dicorrtop= dicorrtop(1:frc);
    save(saveStr,'icorrC','imaxAC','isumAC','idAC','icorrC_vs_maxAC','icorrC_vs_sumAC','icorrC_vs_dAC','icorrP','imaxAP','isumAP','idAP','dicorr','dimaxA','disumA','didA','dicorrSRTd','dimaxASRTd','disumASRTd','didASRTd','icorrP_vs_dAP','icorrP_vs_maxAP','icorrP_vs_sumAP','icorrP_vs_ddA','dicorr_vs_dmaxA','dicorr_vs_dsumA','dicorr_vs_ddA','icorrPtop','didAtop','disumAtop','dicorrtop','-append');
% else
%     save(saveStr,'icorrC','imaxAC','isumAC','idAC','icorrC_vs_maxAC','icorrC_vs_sumAC','icorrC_vs_dAC','-append');
end


% traces, amp
ampC= DATA.grp(1).mAMP.psC(1).avg(idx,:);
amp_exp= DATA.grp(1).mAMP.all.avg_exp(idx,:);
trlampC= DATA.grp(1).mAMP.psC(1).trl(idx2,:);
trlamp_exp= DATA.grp(1).mAMP.all.trl_exp(idx2,:);
ampC_roiAVG= mean(DATA.grp(1).mAMP.psC(1).avg(1:cutdim,:),'omitnan')';

NRMampC= DATA.grp(1).mAMP.psC(1).NRMavg_avg2;
NRMampC_exp= DATA.grp(1).mAMP.psC(1).NRMavg_avg2_exp;
NsrtC= sort(ampC(1:cutdim,:),'descend');NsrtC= NsrtC./NsrtC(1,:);
trcC_avg= DATA.grp(1).mTRC.psC(1).avg_avg(:,idx);
trcC_gavg= DATA.grp(1).mTRC.psC(1).avg_avg_avg;

if isfield(DATA.grp(1),'mdelta') == 1
    ampP= DATA.grp(1).mAMP.psC(2).avg(idx,:);
    trlampP= DATA.grp(1).mAMP.psC(2).trl(idx2,:);
    ampP_roiAVG= mean(DATA.grp(1).mAMP.psC(2).avg(1:cutdim,:),'omitnan')';
    ampC_expAVG= DATA.grp(1).mdelta.ampC.expAVG(1:cutdim,:);
    ampP_expAVG= DATA.grp(1).mdelta.ampP.expAVG(1:cutdim,:);
    NRMampP= DATA.grp(1).mAMP.psC(2).NRMavg_avg2;
    NRMampP_exp= DATA.grp(1).mAMP.psC(2).NRMavg_avg2_exp;
    NsrtP= sort(ampP(1:cutdim,:),'descend');NsrtP= NsrtP./NsrtP(1,:);
    save(saveStr,'NsrtC','NsrtP','NRMampC','NRMampC_exp','NRMampP','NRMampP_exp','ampC','ampP','ampC_roiAVG','ampP_roiAVG','ampC_expAVG','ampP_expAVG','amp_exp','trlampC','trlampP','trlamp_exp','-append');
    
    trcP_avg= DATA.grp(1).mTRC.psC(2).avg_avg(:,idx);
    trcP_gavg= DATA.grp(1).mTRC.psC(2).avg_avg_avg;
    
    ChIvPtim_corr= DATA.grp(1).mdelta.trc.ChIvPtim_corr_exp';
    GMIvPtim_corr= DATA.grp(1).mdelta.trc.GMIvPtim_corr_exp';
    ChItim_sd= reshape(DATA.grp(1).mdelta.trc.ChItim_sd_exp,size(DATA.grp(1).mdelta.trc.ChItim_sd_exp,1)*size(DATA.grp(1).mdelta.trc.ChItim_sd_exp,2),1);
    GMItim_sd2= reshape(DATA.grp(1).mdelta.trc.GMItim_sd2_exp,size(DATA.grp(1).mdelta.trc.GMItim_sd2_exp,1)*size(DATA.grp(1).mdelta.trc.GMItim_sd2_exp,2),1);
    save(saveStr,'trcC_avg','trcC_gavg','trcP_avg','trcP_gavg','ChIvPtim_corr','ChItim_sd','GMIvPtim_corr','GMItim_sd2','-append');
else
    save(saveStr,'NsrtC','NRMampC','NRMampC_exp','ampC','ampC_roiAVG','amp_exp','trlampC','trlamp_exp','-append');
    save(saveStr,'trcC_avg','trcC_gavg','-append');
end

% delta AMP & ChI
% avg0: all neuron-odor pairs (... preferred for most analyses, in order to avoid bias towards few neurons taht are considered responsive)
% avg: only responding neuron-odor pairs
if isfield(DATA.grp(1),'mdelta') == 1
    dAMP= DATA.grp(1).mdelta.dAMP.avg;
    dAMP_odr= DATA.grp(1).mdelta.dAMP.gavg';
    dAMP_roiAVG= DATA.grp(1).mdelta.dAMP.avg_avg';
    dAMP_roiSD= DATA.grp(1).mdelta.dAMP.avg_sd';
    dAMP_expAVG= DATA.grp(1).mdelta.dAMP.expAVG(1:cutdim,:);
    ChI= DATA.grp(1).mdelta.ChI.avg;
        ChI0= DATA.grp(1).mdelta.ChI.avg0;
    ChI_odr= DATA.grp(1).mdelta.ChI.gavg';
        ChI0_odr= DATA.grp(1).mdelta.ChI.gavg0';
    ChI_roiAVG= DATA.grp(1).mdelta.ChI.avg_avg';
    ChI_roiSD= DATA.grp(1).mdelta.ChI.avg_sd';
        ChI0_roiAVG= DATA.grp(1).mdelta.ChI.avg0_avg';
        ChI0_roiSD= DATA.grp(1).mdelta.ChI.avg0_sd';
    ChI_expAVG= DATA.grp(1).mdelta.ChI.expAVG(1:cutdim,:);
    ChI_NRMexpAVG= DATA.grp(1).mdelta.ChI.NRMexpAVG(1:cutdim,:);

    ChIvP_roiAVG_exp= DATA.grp(1).mdelta.IRCvPIN.roi.avg.exp';
    
    % sorted by icorr(PIN)
    Iall= DATA.grp(1).anlPOP.psC(2).avg.icorrIDX.all;
    dAMP_roiAVGsrt= dAMP_roiAVG(Iall);
    ChI_roiAVGsrt= ChI_roiAVG(Iall);
    ChI0_roiAVGsrt= ChI0_roiAVG(Iall);
    ampP_roiAVGsrt= ampP_roiAVG(Iall);
    ampC_roiAVGsrt= ampC_roiAVG(Iall);
    
    sigCHGall= DATA.grp(1).mAMP.all.sigCHGall';
    sigCHGsel= DATA.grp(1).mAMP.all.sigCHGsel';
    NsrtdAMP= sort(dAMP(1:cutdim,:),'descend');NsrtdAMP= NsrtdAMP./NsrtdAMP(1,:);
    NsrtChI= sort(ChI(1:cutdim,:),'descend');NsrtChI= NsrtChI./NsrtChI(1,:);
    save(saveStr,'dAMP_roiAVGsrt','ChI_roiAVGsrt','ChI0_roiAVGsrt','ampP_roiAVGsrt','ampC_roiAVGsrt','NsrtChI','NsrtdAMP','sigCHGall','sigCHGsel','ChIvP_roiAVG_exp','ChI','ChI_odr','ChI_roiAVG','ChI_roiSD','ChI0','ChI0_odr','ChI0_roiAVG','ChI0_roiSD','ChI_expAVG','ChI_NRMexpAVG','dAMP','dAMP_odr','dAMP_roiAVG','dAMP_roiSD','dAMP_expAVG','-append');
end

% Odor "tuning bias"
if isfield(DATA.grp(1).anlCEL.psC(1).avg,'AmIsim')
    ChIAmIsim= DATA.grp(1).mdelta.AmI.ChIAmIsim_avg';
    ChIAmIdis= DATA.grp(1).mdelta.AmI.ChIAmIdis_avg';
    dChIAmI_simdis= DATA.grp(1).mdelta.AmI.dChIAmIsimdis_avg';

    ChiAmI_vs_CORP= DATA.grp(1).mdelta.AmI.ChiAmI_vs_CORP';
    save(saveStr,'ChIAmIsim','ChIAmIdis','dChIAmI_simdis','ChiAmI_vs_CORP','-append');
end

% mixture amp
% mix #1
if DATA.grp(1).info.osnum==2
    cmp1C= mean(DATA.grp(1).mAMP.psC(1).avg(1:2,:))';
    bmx1C= DATA.grp(1).mAMP.psC(1).avg(5,:)';
    cmp1P= mean(DATA.grp(1).mAMP.psC(2).avg(1:2,:))';
    bmx1P= DATA.grp(1).mAMP.psC(2).avg(5,:)';
    cmp1ChI0= (cmp1P-cmp1C) ./ (cmp1P+cmp1C);
    bmx1ChI0= (bmx1P-bmx1C) ./ (bmx1P+bmx1C);
    cmp1ChI= cmp1ChI0(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0));
    bmx1ChI= bmx1ChI0(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0));
    cmp1C= cmp1C(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0)); cmp1P= cmp1P(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0));
    bmx1C= bmx1C(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0)); bmx1P= bmx1P(~isnan(bmx1ChI0) & ~isnan(cmp1ChI0));
    save(saveStr,'cmp1C','cmp1P','cmp1ChI','bmx1C','bmx1P','bmx1ChI','-append');

    % mix #2
    cmp2C= mean(DATA.grp(1).mAMP.psC(1).avg(3:4,:))';
    bmx2C= DATA.grp(1).mAMP.psC(1).avg(6,:)';
    cmp2P= mean(DATA.grp(1).mAMP.psC(2).avg(1:2,:))';
    bmx2P= DATA.grp(1).mAMP.psC(2).avg(6,:)';
    cmp2ChI0= (cmp2P-cmp2C) ./ (cmp2P+cmp2C);
    bmx2ChI0= (bmx2P-bmx2C) ./ (bmx2P+bmx2C);
    cmp2ChI= cmp2ChI0(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0));
    bmx2ChI= bmx2ChI0(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0));
    cmp2C= cmp2C(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0)); cmp2P= cmp2P(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0));
    bmx2C= bmx2C(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0)); bmx2P= bmx2P(~isnan(bmx2ChI0) & ~isnan(cmp2ChI0));
    save(saveStr,'cmp2C','cmp2P','cmp2ChI','bmx2C','bmx2P','bmx2ChI','-append');

    % both mixes
    cmpC= mean(DATA.grp(1).mAMP.psC(1).avg(1:4,:))';
    bmxC= mean(DATA.grp(1).mAMP.psC(1).avg(5:6,:))';
    cmpP= mean(DATA.grp(1).mAMP.psC(2).avg(1:4,:))';
    bmxP= mean(DATA.grp(1).mAMP.psC(2).avg(5:6,:))';
    cmpChI0= (cmpP-cmpC) ./ (cmpP+cmpC);
    bmxChI0= (bmxP-bmxC) ./ (bmxP+bmxC);
    cmpChI= cmpChI0(~isnan(bmxChI0) & ~isnan(cmpChI0));
    bmxChI= bmxChI0(~isnan(bmxChI0) & ~isnan(cmpChI0));
    save(saveStr,'cmpC','cmpP','cmpChI','bmxC','bmxP','bmxChI','-append');
end


% PCA (trial-averaged)
if isfield(DATA.grp(1),'mdelta') == 1
    pc1C= squeeze(DATA.grp(1).mPCA.psC(3).PCA(1,:,idx)); 
    pc2C= squeeze(DATA.grp(1).mPCA.psC(3).PCA(2,:,idx));
    pc3C= squeeze(DATA.grp(1).mPCA.psC(3).PCA(3,:,idx)); 

    pc1P= squeeze(DATA.grp(1).mPCA.psC(3).PCA(1,:,idx+(idx(size(idx,2))))); 
    pc2P= squeeze(DATA.grp(1).mPCA.psC(3).PCA(2,:,idx+(idx(size(idx,2))))); 
    pc3P= squeeze(DATA.grp(1).mPCA.psC(3).PCA(3,:,idx+(idx(size(idx,2))))); 

    pc1M= squeeze(DATA.grp(1).mPCA.psC(3).PCA(1,:,cat(2,idx,idx+(idx(size(idx,2)))))); 
    pc2M= squeeze(DATA.grp(1).mPCA.psC(3).PCA(2,:,cat(2,idx,idx+(idx(size(idx,2)))))); 
    pc3M= squeeze(DATA.grp(1).mPCA.psC(3).PCA(3,:,cat(2,idx,idx+(idx(size(idx,2)))))); 
    pcaSCORESM= DATA.grp(1).mPCA.psC(3).scores; 
    pcaVARexplM= DATA.grp(1).mPCA.psC(3).explained; 
    save(saveStr,'pc1C','pc2C','pc3C','pc1P','pc2P','pc3P','pc1M','pc2M','pc3M','pcaSCORESM','pcaVARexplM','-append');
end

% % PCA (trials)
% pc1trl= squeeze(DATA.grp(1).mPCAtrl.PCA(1,:,idx2)); pc1trlSCR= DATA.grp.mPCAtrl.scores(:,1);
% pc2trl= squeeze(DATA.grp(1).mPCAtrl.PCA(2,:,idx2)); pc2trlSCR= DATA.grp.mPCAtrl.scores(:,2);
% pc3trl= squeeze(DATA.grp(1).mPCAtrl.PCA(3,:,idx2)); pc3trlSCR= DATA.grp.mPCAtrl.scores(:,3);
% pcatrlSCORES= DATA.grp(1).mPCAtrl.scores; 
% pcatrlVARexpl= DATA.grp(1).mPCAtrl.explained; 
% for i = 1 : DATA.grp(1).info.nexp
%     pc1trlexp(i,:,:)=  DATA.grp(1).mPCAtrl.exp(i).PCA(1,:,idx2);
%     pc2trlexp(i,:,:)=  DATA.grp(1).mPCAtrl.exp(i).PCA(2,:,idx2);
%     pc3trlexp(i,:,:)=  DATA.grp(1).mPCAtrl.exp(i).PCA(3,:,idx2);
% end
% pc1trlSCR0= pc1trlSCR(isnan(valI)==0);
% pc2trlSCR0= pc2trlSCR(isnan(valI)==0);
% pc3trlSCR0= pc3trlSCR(isnan(valI)==0);
% save(saveStr,'pc1trl','pc2trl','pc3trl','pc1trlexp','pc2trlexp','pc3trlexp','pc1trlSCR','pc2trlSCR','pc3trlSCR','pc1trlSCR0','pc2trlSCR0','pc3trlSCR0','pcatrlSCORES','pcatrlVARexpl','-append');
