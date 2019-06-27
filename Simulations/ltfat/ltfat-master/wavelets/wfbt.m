function [c,info]=wfbt(f,wt,varargin)
%WFBT   Wavelet FilterBank Tree
%   Usage:  c=wfbt(f,wt);
%           c=wfbt(f,wt,ext);
%           [c,info]=wfbt(...);
%
%   Input parameters:
%         f     : Input data.
%         wt    : Wavelet filterbank tree definition.
%
%   Output parameters:
%         c    : Coefficients stored in a cell-array.
%         info : Transform parameters struct.
%
%   `wfbt(f,wt)` returns coefficients *c* obtained by applying a wavelet
%   filterbank tree defined by *wt* to the input data *f*. 
%
%   `[c,info]=wfbt(f,wt)` additionally returns struct. `info` containing
%   transform parameters. It can be conviniently used for the inverse 
%   transform |iwfbt| e.g. `fhat = iwfbt(c,info)`. It is also required by
%   the |plotwavelets| function.
%
%   *wt* defines a tree shaped filterbank structure build from the
%   elementary two (or more) channel wavelet filters. The tree can have any
%   shape and thus provide a flexible frequency covering. The outputs of the
%   tree leaves are stored in *c*.
%
%   The *wt* parameter can have two formats: 
%
%   1) Cell array containing 3 elements `{w,J,treetype}`, where `w` is
%      the basic wavelet filterbank definition as in |fwt| function, *J*
%      stands for the depth of the tree and the flag `treetype` defines
%      the type of the tree to be used. Supported options are:
%
%      `'dwt'`
%         Plain DWT tree (default). This gives one band per octave freq. 
%         resolution when using 2 channel basic wavelet filterbank and
%         produces coefficients identical to the ones in |fwt|.
%
%      `'full'`
%         Full filterbank tree. Both (all) basic filterbank outputs are
%         decomposed further up to depth *J* achieving linear frequency band
%         division.
%
%      `'doubleband'`,`'quadband'`,`'octaband'`
%         The filterbank is designed such that it mimics 4-band, 8-band or
%         16-band complex wavelet transform provided the basic filterbank
%         is 2 channel. In this case, *J* is treated such that it defines
%         number of levels of 4-band, 8-band or 16-band transform.
%
%   2) Structure returned by the |wfbtinit| function and possibly
%      modified by |wfbtput| and |wfbtremove|.
%
%   Please see |wfbtinit| for a detailed description and more options.
%
%   If *f* is row/column vector, the coefficient vectors `c{jj}` are columns.
%
%   If *f* is a matrix, the transformation is by default applied to each of
%   *W* columns `[Ls, W]=size(f)`.
%
%   In addition, the following flag groups are supported:
%
%   `'per'`(default),`'zero'`,`'odd'`,`'even'`
%     Type of the boundary handling. Please see the help on |fwt| for a 
%     description of the boundary condition flags.
%
%   `'freq'`(default),`'nat'`
%     Frequency or natural ordering of the coefficient subbands. The direct
%     usage of the wavelet tree (`'nat'` option) does not produce coefficient
%     subbans ordered according to the frequency. To achieve that, some
%     filter shuffling has to be done (`'freq'` option).
%
%   Examples:
%   ---------
%
%   A simple example of calling the |wfbt| function using the "full 
%   decomposition" wavelet tree:::
%
%     f = gspi;
%     J = 7;
%     [c,info] = wfbt(f,{'sym10',J,'full'});
%     plotwavelets(c,info,44100,'dynrange',90);
%
%   See also: iwfbt, wfbtinit

% AUTHOR: Zdenek Prusa

complainif_notenoughargs(nargin,2,'WFBT');

definput.import = {'fwt','wfbtcommon'};
[flags,kv]=ltfatarghelper({},definput,varargin);

% Initialize the wavelet tree structure
wt = wfbtinit(wt,flags.forder);

%% ----- step 1 : Verify f and determine its length -------
[f,Ls]=comp_sigreshape_pre(f,upper(mfilename),0);

% Determine next legal input data length.
L = wfbtlength(Ls,wt,flags.ext);

% Pad with zeros if the safe length L differ from the Ls.
if(Ls~=L)
   f=postpad(f,L);
end

%% ----- step 3 : Run computation
[nodesBF, rangeLoc, rangeOut] = treeBFranges(wt);
c = comp_wfbt(f,wt.nodes(nodesBF),rangeLoc,rangeOut,flags.ext);

%% ----- Optionally : Fill info struct ----
if nargout>1
   info.fname = 'wfbt';
   info.wt = wt;
   info.ext = flags.ext;
   info.Lc = cellfun(@(cEl) size(cEl,1),c);
   info.Ls = Ls;
   info.fOrder = flags.forder;
   info.isPacked = 0;
end


