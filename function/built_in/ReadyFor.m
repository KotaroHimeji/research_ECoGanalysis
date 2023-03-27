% READYFOR  Ready for Running Program "linear_sparse_space"

%  Model : Structure for estimated model
%  if Model is empty, initialization is done before training
%  if Model is previous training result, re-training us done

%parm  : Structure for learning parameter

Model = struct;

parm.Ntrain = 300;      % # of training
parm.Npre_train = 150;   % # of VB-update in initial training
parm.Nskip = 100;        % skip # for print
parm.Tau = 1;            % Lag time
parm.Dtau = 1;           % Number of embedding dimension
parm.Tpred = 0;
parm.a_min = 1e-4;
parm.Prune = 1;


% coded by Kotato Himeji
% last modification : 2021.01.13