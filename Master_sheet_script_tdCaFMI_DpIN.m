%% LOOP THROUGH GROUPS
clc

f0= figure(3);
    f0.Units= 'normalized';
    f0.Position= [0.3285,0.223,0.66,0.70];

if osnum == 2 || osnum == 1
    f1= figure(4);
        f1.Units= 'normalized';
        f1.Position= [0.3285,0.223,0.66,0.70];
end
    
for i = 1 : size(DATA.grp,2)
    % PREPARE (i.e. SPLIT) response traces
    DATA.grp(i).mTRC = MPI_trcm(DATA.grp(i).input,DATA.grp(i).info,zsc,0);
    
    % PREPARE response amplitude matrices
    [DATA.grp(i).mAMP,DATA.grp(i).input,DATA.grp(i).info] = MPI_ampm(DATA.grp(i).input,DATA.grp(i).info,vsum,zsc,ACSexcl,RSPexcl,PLNexcl,XYexcl);
        
    % ANALYZE SINGLE CELL RESPONSES
    if osnum == 2
        DATA.grp(i).anlCEL= MPI_cel(DATA.grp(i).mAMP,DATA.grp(i).info,AmIidx);
    else
        DATA.grp(i).anlCEL = MPI_cel(DATA.grp(i).mAMP,DATA.grp(i).info);
    end
    
    % ANALYZE POPULATION RESPONSES
    DATA.grp(i).anlPOP = MPI_pop(DATA.grp(i).mAMP,DATA.grp(i).info,cutdim);
    if osnum ~= 21 
        DATA.grp(i).anlPOPtim = MPI_poptim(DATA.grp(i).mTRC,DATA.grp(i).info,1,DATA.grp(i).info.nfrm,1,cutdim);
    end
    
    DATA.grp(i).mPCA.psC(1) = MPI_pcatrace(DATA.grp(i).mTRC.psC(1).input2',DATA.grp(i).info,3,PCdims);
    if osnum == 2 || osnum == 1
        DATA.grp(i).mPCA.psC(2) = MPI_pcatrace(DATA.grp(i).mTRC.psC(2).input2',DATA.grp(i).info,4,PCdims);
        DATA.grp(i).mPCA.psC(3) = MPI_pcatrace(cat(2,DATA.grp(1).mTRC.psC(1).input2',DATA.grp(1).mTRC.psC(2).input2'),DATA.grp(i).info,0,PCdims);
    
        % PREPARE dAMP matrices (psC2 - psC1; e.g. PIN(= psC2) vs ctrl(= psC1))
        DATA.grp(i).mdelta = MPI_dampm(DATA.grp(i),DATA.grp(i).info,1,2,cutdim);
    end
    
%     % ANALYZE TRACES (correlations)
%     DATA.grp(i).anlTRC = MPI_trcCOR(DATA.grp(i).mTRC,DATA.grp(i).info,1,33,8,2);
end

%% DISPLAY

for i = 1:size(DATA.grp(1).info.psCLST,1)
    psC= i;
    
    if psC == 1
        f0= figure(3);
    else
        f0= figure(4);
    end
    
    A = DATA.grp(1).anlPOP.psC(psC).avg.corrmat.avg;
    B = DATA.grp(1).anlPOP.psC(psC).avg.cosDmat.avg;
    C = DATA.grp(1).mAMP.psC(psC).avg_avg2;
    L = DATA.grp(1).info.stmLST;
    if DATA.grp(1).info.osnum == 1 || DATA.grp(1).info.osnum == 2
        L2 = DATA.grp(1).info.stmLST_cnd;
    else
        L2 = DATA.grp(1).info.stmLST_trl;
    end
    T = DATA.grp(1).anlPOP.psC(psC).trl.corrmat.avg;
    
    COR = A(idx,idx);
    COS = B(idx,idx);
    AMP = C(idx);
    LST = L(idx);
    LST2 = L2(idx2);
    trlCOR= T(idx2,idx2);
    
    clear A;clear B;clear C;clear L;clear L2;clear T;
    
    subplot(2,3,5);
    if TRLdisp == 1
        imagesc(trlCOR);
        xticklabels(LST2); xticks([1:DATA.grp(1).info.ntrl]); xtickangle(45);
        yticklabels(LST2); yticks([1:DATA.grp(1).info.ntrl]);
    else
        imagesc(COR);
        xticklabels(LST); xticks([1:DATA.grp(1).info.nstm]); xtickangle(45);
        yticklabels(LST); yticks([1:DATA.grp(1).info.nstm]);
    end
    axis square;
    title(['correlation']);
    colorbar; caxis ([-0.1 1])
    colormap(subplot(2,3,5),'jet');
    
    subplot(2,3,6);
    imagesc(COS);
    axis square;
    title(['cosine distance']);
    xticklabels(LST); xticks([1:DATA.grp(1).info.nstm]); xtickangle(45);
    yticklabels(LST); yticks([1:DATA.grp(1).info.nstm]);
    colorbar; caxis ([0 1]);
    colormap(subplot(2,3,6),flipud(jet));
    
    subplot(2,3,6);
    imagesc(COR);
    axis square;
    title(['correlation']);
    xticklabels(LST); xticks([1:DATA.grp(1).info.nstm]); xtickangle(45);
    yticklabels(LST); yticks([1:DATA.grp(1).info.nstm]);
    colorbar; caxis ([-0.1 1]);
    colormap(subplot(2,3,6),'jet');
    
    subplot(2,3,2);
    plot(AMP,'r+');
    title([cat(2,'amplitude: [',num2str(DATA.grp(1).info.exp(1).rsp0-DATA.grp(1).info.exp(1).rsp1),' frame window]')]);
    xticklabels(LST); xticks([1:DATA.grp(1).info.nstm]); xtickangle(45);
    legend('off')
    ylim([-0.1 0.3]);
    
    subplot(2,3,1);
    cmap= linspecer(DATA.grp(1).info.nstm);
    for i = 1 : size(DATA.grp(1).mTRC.psC(psC).avg_avg,2)
        plot(DATA.grp(1).mTRC.psC(psC).avg_avg(:,idx(i)),'Color',cmap(i,:)); hold on;
    end
    hold off;
    title(['time course']);
    lgd = legend(DATA.grp(1).info.stmLST(idx),'Location', 'southoutside','Orientation','horizontal');
    ylim([-0.02 0.6]);
    
end