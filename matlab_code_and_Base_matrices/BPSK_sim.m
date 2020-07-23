EbNodB = 5;
R = 1; %uncoded1BPSK (1 bit/symbol) 
EbNo = 10^(EbNodB/10) ;
sigma = sqrt(1/ (2*R*EbNo)) ; 
BER_th = 0.5*erfc(sqrt (EbNo)) ;

N = 1000; %number of bits of message per block 
Nerrs = 0; Nblocks = 10000;
for i = 1: Nblocks
	msg = randi([0 1],1,N); %generate random message 	
    
    s = 1 - 2 * msg; %BPSK bit to symbol conversion 	
    r = s + sigma * randn(1,N); %AWGN channel
	
    msg_cap = (r < 0); %threshold at zero 
    
	Nerrs = Nerrs + sum(msg ~= msg_cap);      
end

BER_sim = Nerrs/N/Nblocks; 

disp([EbNodB BER_th BER_sim Nerrs N*Nblocks])
