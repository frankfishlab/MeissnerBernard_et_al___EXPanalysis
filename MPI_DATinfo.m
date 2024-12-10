function info = MPI_DATinfo(trlLST,roinum,ms)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info.roinum = roinum;
info.nexp = size(roinum,2);

info.roiid = ones([1,sum(info.roinum)]);
cnt1 = 1;
cnt2 = 0;

info.uniqueSFX = unique(ms.suffixes);

for i = 1 : info.nexp
    cnt2 = cnt2 + info.roinum(i);
    info.roiid(cnt1:cnt2) = i;
    [~,pos] = ismember(ms.suffixes(i),info.uniqueSFX);
    info.roiSFX(cnt1:cnt2) = pos;
    cnt1 = cnt1 + info.roinum(i);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info.trlLST = trlLST;
    info.ntrl = size(info.trlLST,1);
info.cndLST = unique(info.trlLST,'stable');
    info.ncnd = size(info.cndLST,1);
info.stmLST = info.cndLST;
info.psCLST = info.cndLST;

for i = 1 : size(info.cndLST)
    info.stmLST{i} = info.cndLST{i}(1:3);
    info.psCLST{i} = info.cndLST{i}(4);
end

info.stmLST = unique(info.stmLST,'stable');
    info.nstm = size(info.stmLST,1);
info.psCLST = unique(info.psCLST,'stable');
    info.npsC = size(info.psCLST,1);

% specific psC lists - trials and conditions
cntC = 1;
cntP = 1;
cntX = 1;
for i = 1 : size(info.trlLST)
    info.stmLST_trl{i} = info.trlLST{i}(1:3);
    info.psCLST_trl{i} = info.trlLST{i}(4);
    
    if strcmp(info.trlLST{i}(4),'C') == 1 % identical --> C
        info.psC(1).trlLST{cntC} = info.trlLST{i};
        cntC = cntC +1;
    elseif strcmp(info.trlLST{i}(4),'P') == 1 % identical --> P
        info.psC(2).trlLST{cntP} = info.trlLST{i};
        cntP = cntP +1;
    else
        info.psC(3).trlLST{cntX} = info.trlLST{i};
        cntX = cntX +1;
    end
end

for i = 1 : size(info.cndLST)
    info.stmLST_cnd{i} = info.cndLST{i}(1:3);
    info.psCLST_cnd{i} = info.cndLST{i}(4);
end

info.stmLST_trl = info.stmLST_trl';
info.psCLST_trl = info.psCLST_trl';
info.stmLST_cnd = info.stmLST_cnd';
info.psCLST_cnd = info.psCLST_cnd';

if cntC > 1
    info.psC(1).trlLST = info.psC(1).trlLST';
end
if cntP > 1
    info.psC(2).trlLST = info.psC(2).trlLST';
end
if cntX > 1
    info.psC(3).trlLST = info.psC(3).trlLST';
end
end