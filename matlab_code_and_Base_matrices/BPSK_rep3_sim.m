EbNodB = 6;
R = 1/3; %n=3 repetition (1/3 bits/symbol)
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*R*EbNo)); 

k = 1; %number of message bits 
n = 3; %number of codeword bits

Nerrs = 0; Nblocks = 100000;
for i = 1: Nblocks
   	msg = randi([0 1],1,k); %generate random k-bit message 
	%Encoding
    cword = [msg msg msg]; 
    
	s = 1 - 2 * cword; %BPSK bit to symbol conversion 
    r = s + sigma * randn(1,n); %AWGN channel

    %Hard-decision decoding
	b = (r < 0); %threshold at zero 
    if sum(b) > 1
        msg_cap1 = 1; 
    else
        msg_cap1 = 0; 
    end

	%Soft-decision decoding
    if sum(r) < 0
    	msg_cap2 = 1; 
    else
    	msg_cap2 = 0; 
    end

    Nerrs = Nerrs + sum(msg ~= msg_cap2);
end

BER_sim = Nerrs/k/Nblocks; 
disp( [EbNodB BER_sim Nerrs k*Nblocks] )

