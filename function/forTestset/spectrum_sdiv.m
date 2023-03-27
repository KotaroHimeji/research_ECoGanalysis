[hz,t,task,channel] = size(FFT_signal);
for c = 1:hz
    tmp = FFT_signal(c,:,:,9);
    tmp = squeeze(tmp);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    figure()
    hold on
    plot(M)
    plot(M+S)
    plot(M-S)

end