function x_kl = sfft(X_nm)
% Implement the Finite Symplectic Fourier Transform   

[N,M] = size(X_nm);

%% OLD SFFT IMPLEMENTATION
 x_kl = sqrt(1/N/M)*N*fft(ifft(X_nm,[],2),[],1); 

%% NEW SFFT IMPLEMENTATION
% x_kl = sqrt(1/N/M)*N*fft((ifft(X_nm.',[],2)),[],1); %dsft 

% x_kl =  sqrt(1/N/M)*N*ifft(fft(X_nm.')); %ALTERNATE NEW


end

