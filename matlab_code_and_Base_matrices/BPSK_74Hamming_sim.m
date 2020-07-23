EbNodB = 4;
R = 4/7; %(7,4) Hamming (4/7 bits/symbol) 
EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*R*EbNo));

k = 4; %number of message bits
n = 7; %number of codeword bits

cwords	=  [0	0	0	0	0	0	0;
			0	0	0	1	0	1	1;
			0	0	1	0	1	1	0;
			0	0	1	1	1	0	1;
			0	1	0	0	1	1	1;
			0	1	0	1	1	0	0;
			0	1	1	0	0	0	1;
			0	1	1	1	0	1	0;
			1	0	0	0	1	0	1;
			1	0	0	1	1	1	0;
			1	0	1	0	0	1	1;
			1	0	1	1	0	0	0;
			1	1	0	0	0	1	0;
			1	1	0	1	0	0	1;
			1	1	1	0	1	0	0;
     		1	1	1	1	1	1	1];

Nbiterrs = 0; Nblkerrs = 0; Nblocks = 10000; 
for i = 1: Nblocks
	msg = randi([0 1],1,k); %generate random k-bit message
	%Encoding 
	cword = [msg mod(msg(1)+msg(2)+msg(3) ,2) ... 
                 mod(msg(2)+msg(3)+msg(4) ,2) ...
                 mod(msg(1)+msg(2)+msg(4) ,2)]; %(7,4) Hamming
             
    s = 1 - 2 * cword; %BPSK bit to symbol conversion 
    r = s + sigma * randn(1,n); %AWGN channel I
    
    %Hard-decision decoding
    b = (r < 0); %threshold at zero
    dist = mod(repmat(b,16,1)+cwords,2)*ones(7,1); 
    [mind1,pos] = min(dist);
    msg_cap1 = cwords(pos,1:4); 
    
    %Soft-decision decoding 
    corr = (1-2*cwords)*r'; 
    [mind2,pos] = max(corr);
    msg_cap2 = cwords(pos,1:4); 
    
    Nerrs = sum(msg ~= msg_cap2);
    if Nerrs > 0
		Nbiterrs = Nbiterrs + Nerrs;
		Nblkerrs = Nblkerrs + 1;
    end
end

BER_sim = Nbiterrs/k/Nblocks;
FER_sim = Nblkerrs/Nblocks;

disp([EbNodB FER_sim BER_sim Nblkerrs Nbiterrs Nblocks])	

