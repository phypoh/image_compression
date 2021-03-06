    %Overall run scheme
load bridge
warning off;
bit_limit = 40960;

qstep = 17;
numbits = 256^2*8;

numbits_map = containers.Map;
err = containers.Map;
ssimval = containers.Map;
Z_dict = containers.Map;
vlc_map = containers.Map;
qstep_map = containers.Map;


disp('Running DCT method...')
while numbits > bit_limit
    [vlc bits huffval] = jpegenc_dct_dc(X, qstep);
    Z = jpegdec_dct_dc(vlc, qstep);
    %numbits = sum(vlc(:,2));
    numbits = vlctest(vlc);
    qstep = qstep + 1;
end
disp('Done.')
numbits_map('dct') = sum(vlc(:,2));
err('dct') = std(abs(X(:)-Z(:)));
ssimval('dct') = ssim(Z,X);
Z_dict('dct') = Z;
vlc_map('dct') = vlc;
qstep_map('dct') = qstep-1;


disp('Running LBT method...')
qstep = 17;
numbits = 256^2*8;
while numbits > bit_limit
    [vlc bits huffval] = jpegenc_lbt_dc(X, qstep);
    Z = jpegdec_lbt_dc(vlc, qstep);
    %numbits = sum(vlc(:,2));
    numbits = vlctest(vlc);
    qstep = qstep + 1;
end
disp('Done.')
numbits_map('lbt') = sum(vlc(:,2));
err('lbt') = std(abs(X(:)-Z(:)));
ssimval('lbt') = ssim(Z,X);
Z_dict('lbt') = Z;
vlc_map('lbt') = vlc;
qstep_map('lbt') = qstep-1;


disp('Running DWT method...')
qstep = 17;
numbits = 256^2*8;
while numbits > bit_limit
    [vlc bits huffval] = jpegenc_dwt_dc(X, qstep);
    Z = jpegdec_dwt_dc(vlc, qstep);
    %numbits = sum(vlc(:,2));
    numbits = vlctest(vlc);
    qstep = qstep + 1;
end
disp('Done.')
numbits_map('dwt') = sum(vlc(:,2));
err('dwt') = std(abs(X(:)-Z(:)));
ssimval('dwt') = ssim(Z,X);
Z_dict('dwt') = Z;
vlc_map('dwt') = vlc;
qstep_map('dwt') = qstep-1;

method = 'lbt';
ssimval_array = values(ssimval);
if ssimval('dct') == max([ssimval_array{:}])
    method = 'dct';
elseif ssimval('lbt') ==  max([ssimval_array{:}])
    method = 'lbt';
elseif ssimval('dwt') == max([ssimval_array{:}])
    method = 'dwt';
else
    disp('Error occured during comaprison. Setting default to lbt.')  
end

vlc = vlc_map(method);
qstep = qstep_map(method);

fprintf('\nMethod: %s', method)
fprintf('\nNumber of bits: %i', numbits_map(method))
fprintf('\nRMS Value: %0.4f', err(method))
fprintf('\nSSIM Value: %0.4f\n', ssimval(method))
save('cmp.mat','vlc','qstep', 'method')

draw(beside(X,Z))