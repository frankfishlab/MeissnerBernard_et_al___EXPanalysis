function CEL = MPI_cel(input,info,AmIidx)

if nargin < 3
    AmI= 0;
else
    AmI= 1;
end

for i = 1 : info.npsC
    % LOOP through ROIs
    for j = 1 : info.nroi
        % SPARSENESS
        CEL.psC(i).avg.sprs(j)= Sparseness(input.psC(i).avg(:,j));
    end
    
    % LOOP through stimuli
    for j = 1 : info.nstm
        sel= strcmp(strcat(info.stmLST{j},info.psCLST{i}),info.trlLST);
        sel= strcmp(info.stmLST{j},info.stmLST_cnd);
        tmp0= input.psC(i).trl(sel>0,:);
        rsp0= input.psC(i).trl_RSP(sel>0,:);
        rspMN= mean(rsp0,1);
        
        % TRIAL CV
        CEL.psC(i).trl.trlCV(j,:)= std(tmp0) ./ mean(tmp0);
        CEL.psC(i).trl.trlCV(j,rspMN<1)= NaN;
    end
    
    CEL.psC(i).trl.trlCV_avg= mean(CEL.psC(i).trl.trlCV,1,'omitnan');
    
    % LOOP through selected stimuli
    if AmI == 1
       % (1) … AmI metric is high (absolute values), when differences
       % between two odor responses are large [abs((O1-O2) / (O1+O2))] →
       % high values indicate high selectivity → {… since we are interested
       % in any difference between responses to two odors, we don't care
       % about the sign → use absolute values}
        CEL.psC(i).avg.AmIsim= zeros(size(AmIidx,1),info.nroi);
        CEL.psC(i).avg.AmIdis= zeros(size(AmIidx,1),info.nroi);
        amp= input.psC(i).avg(:,:);
        
        for k = 1:size(AmIidx,1)
            % similar odor pairs; absolute changes, as the sign is not
            % properly defined
            CEL.psC(i).avg.AmIsim(k,:)= abs(amp(AmIidx(k,1),:) - amp(AmIidx(k,2),:)) ./ (amp(AmIidx(k,1),:) + amp(AmIidx(k,2),:));
            
            % dissimilar odor pairs; absolute changes, as the sign is not
            % properly defined
            CEL.psC(i).avg.AmIdis(k,:)= abs(amp(AmIidx(k,3),:) - amp(AmIidx(k,4),:)) ./ (amp(AmIidx(k,3),:) + amp(AmIidx(k,4),:));
        end
        
        CEL.psC(i).avg.AmIsim_avg= mean(CEL.psC(i).avg.AmIsim,1,'omitnan');
        CEL.psC(i).avg.AmIdis_avg= mean(CEL.psC(i).avg.AmIdis,1,'omitnan');
    end
end
end