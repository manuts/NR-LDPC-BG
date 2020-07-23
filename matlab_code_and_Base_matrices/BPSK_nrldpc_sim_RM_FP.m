EbNodB = 1;
MaxItrs = 20;
rmax = 3;
maxqr = 31;
maxqL = 127;
offset = 2;

load base_matrices/NR_2_6_52.txt
B = NR_2_6_52;
[mb,nb] = size(B);
z = 52;

Slen = sum(B(:)~=-1); %number of non -1 in B
Slenmax = max(sum(B ~= -1,2));

kb = nb - mb;
k = kb * z; %number of message bits
Rate = 1/2;
nbRM = ceil(kb/Rate) + 2;
n = nbRM * z;
mbRM = nbRM - kb;

EbNo = 10^(EbNodB/10);
sigma = sqrt(1/(2*(k/(n-2*z))*EbNo));

Nbiterrs = 0; Nblkerrs = 0; Nblocks = 100; 
parfor i = 1: Nblocks
	msg = randi([0 1],1,k); %generate random k-bit message
	%Encoding 
	cword = nrldpc_encode(B,z,msg);
    cword = cword(1:n);
             
    s = 1 - 2 * cword; %BPSK bit to symbol conversion 
    r = s + sigma * randn(1,n); %AWGN channel I
    %Puncturing of message
    r(1:2*z) = 0;
    %quantization
    rq = floor(r/rmax*maxqr);
    rq(rq>maxqr) = maxqr;
    rq(rq<-(maxqr+1)) = -(maxqr+1);
    
    %Soft-decision, iterative message-passing layered decoding 
    L = rq; %total belief
    itr = 0; %iteration number
    R = zeros(Slen,z); %storage for row processing
    treg = zeros(Slenmax,z); %register storage for minsum
    while itr < MaxItrs
        Ri = 0;
        for lyr = 1:mbRM
            ti = 0; %number of non -1 in row=lyr
            for col = find(B(lyr,1:nbRM) ~= -1)
                   ti = ti + 1;
                   Ri = Ri + 1;
                   %Subtraction
                   L((col-1)*z+1:col*z) = L((col-1)*z+1:col*z)-R(Ri,:);
                   %Row alignment and store in treg
                   temp = mul_sh(L((col-1)*z+1:col*z),B(lyr,col)); 
                   temp(temp>maxqr) = maxqr;
                   temp(temp<-(maxqr+1)) = -(maxqr+1);
                   treg(ti,:) = temp;
            end
            %minsum on treg: ti x z
            for i1 = 1:z %treg(1:ti,i1)
                [min1,pos] = min(abs(treg(1:ti,i1))); %first minimum
                min2 = min(abs(treg([1:pos-1 pos+1:ti],i1))); %second minimum
                S = 2*(treg(1:ti,i1)>=0)-1;
                parity = prod(S);
                %offset
                min1 = min1 - offset;
                if min1<0
                    min1 = 0;
                end
                min2 = min2 - offset;
                if min2<0
                    min2 = 0;
                end
                treg(1:ti,i1) = min1; %absolute value for all
                treg(pos,i1) = min2; %absolute value for min1 position
                treg(1:ti,i1) = parity*S.*treg(1:ti,i1); %assign signs
            end
            %column alignment, addition and store in R
            Ri = Ri - ti; %reset the storage counter
            ti = 0;
            for col = find(B(lyr,1:nbRM) ~= -1)
                    Ri = Ri + 1;
                    ti = ti + 1;
                    %Column alignment
                    R(Ri,:) = mul_sh(treg(ti,:),z-B(lyr,col));
                    %Addition
                    temp = L((col-1)*z+1:col*z)+R(Ri,:);
                    temp(temp>maxqL) = maxqL;
                    temp(temp<-(maxqL+1)) = -(maxqL+1);
                    L((col-1)*z+1:col*z) = temp;
            end
        end
        msg_cap = L(1:k) < 0; %decision
        itr = itr + 1;
    end
    
    %Counting errors
    Nerrs = sum(msg ~= msg_cap);
    if Nerrs > 0
		Nbiterrs = Nbiterrs + Nerrs;
		Nblkerrs = Nblkerrs + 1;
    end
end

BER_sim = Nbiterrs/k/Nblocks;
FER_sim = Nblkerrs/Nblocks;

disp([EbNodB FER_sim BER_sim Nblkerrs Nbiterrs Nblocks])	

