function mPCA = MPI_pcatrace(input,info,fig,PCdims,startFRM,endFRM,evenVAlstim)
% Input to this function is matrix with 2 dimensions. Output will be in three dimensions
% Different cells are in the 1. dimension, the different stimuli in the 2. dimension and
% the frames (time) in the 3. dimension. The 2. and 3. dimension are
% expected to be merged in the input data 
% --> the PCA is done on the whole dataset at once (pca needs a 2D input matrix).

if nargin < 4
    PCdims= 15;
end
if nargin < 5
    startFRM= 1;
end
if nargin < 6
    endFRM= 204;
    endFRM= info.nfrm;
end
if nargin < 7
    evenVAlstim=0;
end

if evenVAlstim == 1
    TRLnum= info.ntrl./info.nstm;
    info.nstm= 6;
    info.ntrl= info.nstm.*TRLnum;
end

nroi= size(input,1);
nrep= round(size(input,2)./info.nfrm);

% added 14.05.21: all NaNs set to 0
input(isnan(input))=0;

if isfield (info,'NEGidx0')
    VALanl= 1;
else
    VALanl= 0;
end
if isfield (info,'PCAopt')
    PCAopt= info.PCAopt;
else
    PCAopt= 1;
end

if size(input,1) < PCdims
    PCdims= size(input,1)-1;
end

%% global PCA (all neurons)
% here, we use standardisation of the input data before PCA (i.e. z-scoring
% of input
switch PCAopt
    case 1 % prior "standard": standardisation along each time frame (???)
        [pcsz,scoresz,~,~,explained,~] = pca(zscore(input));
    case 0 % no standardisation
        [pcsz,scoresz,~,~,explained,~] = pca(input);
    case 2 % standardisation along each trial 
        [pcsz,scoresz,~,~,explained,~] = pca((zscore(input'))');
end
        
        
PCA=pcsz(:,1:PCdims);
PCA=PCA';
PCA=reshape(PCA,PCdims,info.nfrm,nrep);

% main PCA results
mPCA.PCA= PCA; % principal components over time (n = PCdims)
mPCA.scores= scoresz(:,1:PCdims); % "loading" for each PC
mPCA.explained= explained;


% analyse individual PCs (i.e. channel correlations, time-averaged amplitude)
if VALanl == 1
    % 09.03.22 - quick and dirty...  
    if info.nfrm == 300
        anlPCxON= 140;
    else
        anlPCxON= 100;
    end
    mPCA.anlPCx= MPI_pcadim(pcsz,info,PCdims,anlPCxON,info.nfrm,evenVAlstim,0);
end

% RAW INPUT
input0= reshape(input',nroi,info.nfrm,nrep);


%% experiment-specific PCA
pcaAROCexpl3= zeros(info.nexp,1);
pcaAROCexpl5= zeros(info.nexp,1);
pcaAROCexpl10= zeros(info.nexp,1);

for i=1:info.nexp
    selROI = (i == info.roiid);
    [pcsz0,scoresz0,~,~,explained0,~] = pca(zscore(input(selROI>0,:)));
    
    if size(pcsz0,2) < PCdims
       mPCA.exp(i).PCA= NaN;
       mPCA.exp(i).scores= NaN;
       mPCA.exp(i).explained= NaN;
       
       pcaAROCexpl3(i)= NaN;
       pcaAROCexpl5(i)= NaN;
       pcaAROCexpl10(i)= NaN;
       continue 
    end
    
    PCA0=pcsz0(:,1:PCdims);
    PCA0=PCA0';
    PCA0=reshape(PCA0,PCdims,info.nfrm,nrep);
   
    % ---------------------------------------------------------------------
    % main PCA results
    mPCA.exp(i).PCA= PCA0; % principal components over time (n = PCdims)
    mPCA.exp(i).scores= scoresz0(:,1:PCdims); % "loading" for each PC
    mPCA.exp(i).explained= explained0;
    
    % ---------------------------------------------------------------------
    % analyse individual PCs (i.e. channel correlations, time-averaged
    % amplitude, classification analyses)
    if VALanl == 1
        mPCA.exp(i).anlPCx= MPI_pcadim(pcsz0,info,PCdims,anlPCxON,info.nfrm,evenVAlstim,info.dupliTRL(i));
        
        if(nrep ~= info.nstm && (info.osnum ~=9 && info.osnum ~=91))
            % cumulate results across experiments
            mPCA.anlPCx.PCxODRclssEXP(i,:)= mPCA.exp(i).anlPCx.PCxODRclssAVG;
            mPCA.anlPCx.PCxVALclssEXP(i,:)= mPCA.exp(i).anlPCx.PCxVALclssAVG;

            if i == 1
                mPCA.anlPCx.PCxODRclssTRL(PCdims,info.nexp*info.ntrl)= zeros;
                mPCA.anlPCx.PCxVALclssTRL(PCdims,info.nexp*info.ntrl)= zeros;
            end

            for j = 1 : PCdims
                if i == 1
                    mPCA.anlPCx.PCxODRclssTRL(j, 1:info.ntrl)= mPCA.exp(i).anlPCx.PCx(j).ODRclss;
                    mPCA.anlPCx.PCxVALclssTRL(j, 1:info.ntrl)= mPCA.exp(i).anlPCx.PCx(j).VALclss;
                else
                    mPCA.anlPCx.PCxODRclssTRL(j, (i-1)*info.ntrl+1:i*info.ntrl)= mPCA.exp(i).anlPCx.PCx(j).ODRclss;
                    mPCA.anlPCx.PCxVALclssTRL(j, (i-1)*info.ntrl+1:i*info.ntrl)= mPCA.exp(i).anlPCx.PCx(j).VALclss;
                end
            end
        end
        
        % ---------------------------------------------------------------------
        % follow-up analysis
        % ... temporarily, only works with trial-averaged input data
        if(nrep == info.nstm)
            VALnrm= 0;
            VALin= mPCA.exp(i).anlPCx.ddp;

            % first 3 PCs
            pcaAROC= VALin(1:3);
            if VALnrm==1
                minAROC= min(pcaAROC); tmp= pcaAROC-minAROC;
                tmp2= ((tmp)./(1-minAROC)) .* explained0(1:size(pcaAROC,2))';
            else
                tmp2= pcaAROC .* explained0(1:size(pcaAROC,2))';
            end
            pcaAROCexpl3(i)= mean(tmp2);

            % first 5 PCs
            pcaAROC= VALin(1:5);
            if VALnrm==1
                minAROC= min(pcaAROC); tmp= pcaAROC-minAROC;
                tmp2= ((tmp)./(1-minAROC)) .* explained0(1:size(pcaAROC,2))';
            else
                tmp2= pcaAROC .* explained0(1:size(pcaAROC,2))';
            end
            pcaAROCexpl5(i)= mean(tmp2);

            % first 10 PCs
            pcaAROC= VALin(1:10);
            if VALnrm==1
                minAROC= min(pcaAROC); tmp= pcaAROC-minAROC;
                tmp2= ((tmp)./(1-minAROC)) .* explained0(1:size(pcaAROC,2))';
            else
                tmp2= pcaAROC .* explained0(1:size(pcaAROC,2))';
            end
            pcaAROCexpl10(i)= mean(tmp2);
        end
        mPCA.pcaAROCexpl3= pcaAROCexpl3;
        mPCA.pcaAROCexpl5= pcaAROCexpl5;
        mPCA.pcaAROCexpl10= pcaAROCexpl10;
    end
end


%% here the trajectories are smoothed a bit and visualized.
if fig ~= 0
    for z=1:size(PCA,1);
        parfor u=1:size(PCA,3);
            temp(z,:,u)=smooth(PCA(z,:,u),125,'rloess');
        end
    end
    
    temp= temp(:,startFRM:endFRM,:);
end

%% DISPLAY
if fig ~= 0
    figure(fig);clf;
    plt = subplot(2,3,4);
    cmap= linspecer(info.nstm);
%     cmap= valcmap(info.nstm);
    
    PCchoice= [1 2 3];
    
    for i=1:size(temp,3)
        hold on;
        plot3(squeeze(temp(PCchoice(1),:,info.idx(i)))',squeeze(temp(PCchoice(2),:,info.idx(i)))',squeeze(temp(PCchoice(3),:,info.idx(i)))','LineWidth',1.5,'Color',cmap(i,:));
        whitebg(0,'white');
        axis square;
        box on
    end

    % set GRAPH properties
    view(plt,[45 20]); 
    xlabel (cat(2,'PC ',num2str(PCchoice(1)),' (',num2str(round(explained(PCchoice(1)),1)),'%)'));
    ylabel (cat(2,'PC ',num2str(PCchoice(2)),' (',num2str(round(explained(PCchoice(2)),1)),'%)'));
    zlabel (cat(2,'PC ',num2str(PCchoice(3)),' (',num2str(round(explained(PCchoice(3)),1)),'%)'));
    lgd = legend(info.stmLST(info.idx),'Location', 'eastoutside');
%     set(lgd,...
%         'Position',[0.57 0.48 0.10 0.13]);
    % lgd.fontsize = 8;
end
