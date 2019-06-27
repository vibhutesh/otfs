function test_failed = test_libltfat_middlepad(varargin)
test_failed = 0;

fprintf(' ===============  %s ================ \n',upper(mfilename));

definput.flags.complexity={'double','single'};
[flags]=ltfatarghelper({},definput,varargin);
dataPtr = [flags.complexity, 'Ptr'];

[~,~,enuminfo]=libltfatprotofile;
Cenumsymmetry = enuminfo.ltfat_symmetry_t;

Larr =    [9,11,110, 9, 8, 8,    11, 11, 10, 11,9,12,221,10, 10, 11, 15, 16, 1000];
Loutarr = [9,12,221,10, 10, 11, 15, 16, 1000, 1, 9,11,110, 9, 8, 8,   11, 11, 10];

for symflag = {'wp','hp'}
symflag = symflag{1};

switch symflag
    case 'wp'
       csymflag = Cenumsymmetry.LTFAT_WHOLEPOINT;  
    case 'hp'
       csymflag = Cenumsymmetry.LTFAT_HALFPOINT; 
end       
    

for do_complex = 0:1
    complexstring = '';
    if do_complex, complexstring = 'complex'; end
    funname = makelibraryname('middlepad',flags.complexity,do_complex);
    
    for Lidx = 1:numel(Larr)
        L = Larr(Lidx);
        Lout = Loutarr(Lidx);
            
            if do_complex
                z = cast((1:L)'+1i*(L:-1:1)',flags.complexity);
                zi = complex2interleaved(z);
                zout = randn(2*Lout,1,flags.complexity);
                
                ziPtr = libpointer(dataPtr,zi);
                zoutPtr = libpointer(dataPtr,zout);
            else
                z = cast((1:L)',flags.complexity);
                zi = z;
                zout = randn(Lout,1,flags.complexity);
                
                ziPtr = libpointer(dataPtr,zi);
                zoutPtr = libpointer(dataPtr,zout);
            end
            
            trueres = middlepad(z,Lout,symflag);
            
            
            status = calllib('libltfat',funname,ziPtr,L,csymflag,Lout,zoutPtr);
            
            if do_complex
                res = norm(trueres - interleaved2complex(zoutPtr.Value));
            else
                res = norm(trueres - zoutPtr.Value);
            end
            
            [test_failed,fail]=ltfatdiditfail(res+status,test_failed,0);
            fprintf(['MIDDLEPAD OP L:%3i, Lout:%3i, %s %s %s %s\n'],L,Lout,flags.complexity,complexstring,ltfatstatusstring(status),fail);
            
            zoutPtr.Value(:) = randn(size(zoutPtr.Value),flags.complexity);
            zoutPtr.Value(1:numel(ziPtr.Value)) = ziPtr.Value;
            status = calllib('libltfat',funname,zoutPtr,L,csymflag,Lout,zoutPtr);
            
            if do_complex
                res = norm(trueres - postpad(interleaved2complex(zoutPtr.Value),Lout));
            else
                res = norm(trueres - zoutPtr.Value(1:Lout));
            end
            
            [test_failed,fail]=ltfatdiditfail(res+status,test_failed,0);
            fprintf(['MIDDLEPAD IP L:%3i, Lout:%3i, %s %s %s %s\n'],L,Lout,flags.complexity,complexstring,ltfatstatusstring(status),fail);
    end
end
end

